import * as fs from "fs";
import { prisma } from "../config/prisma";
import { env } from "../config/env";

/**
 * Firebase Cloud Messaging (FCM) push-notification service.
 *
 * Design: graceful no-op. When no Firebase service account is configured
 * (`FIREBASE_SERVICE_ACCOUNT` / `FIREBASE_SERVICE_ACCOUNT_PATH`), every call
 * here is a silent no-op so the rest of the notification pipeline (DB row +
 * WebSocket emit) keeps working unchanged. Once credentials are set, push
 * delivery turns on automatically — no code change required.
 *
 * `firebase-admin` is loaded lazily so the dependency is only resolved when
 * push is actually enabled.
 */

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let messaging: any = null;
let initAttempted = false;

function loadServiceAccount(): Record<string, unknown> | null {
  try {
    if (env.firebaseServiceAccount) {
      return JSON.parse(env.firebaseServiceAccount);
    }
    if (env.firebaseServiceAccountPath && fs.existsSync(env.firebaseServiceAccountPath)) {
      return JSON.parse(fs.readFileSync(env.firebaseServiceAccountPath, "utf8"));
    }
  } catch (err) {
    console.error("[PushService] Failed to parse Firebase service account:", err);
  }
  return null;
}

function getMessaging() {
  if (initAttempted) return messaging;
  initAttempted = true;

  const serviceAccount = loadServiceAccount();
  if (!serviceAccount) {
    console.log("[PushService] No Firebase credentials configured — push notifications disabled (DB + WebSocket still active).");
    return null;
  }

  try {
    // Lazy require so the package is only pulled in when push is enabled.
    // eslint-disable-next-line @typescript-eslint/no-var-requires
    const admin = require("firebase-admin");
    if (!admin.apps.length) {
      admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
    }
    messaging = admin.messaging();
    console.log("[PushService] Firebase Cloud Messaging initialised — push notifications enabled.");
  } catch (err) {
    console.error("[PushService] Failed to initialise firebase-admin:", err);
    messaging = null;
  }
  return messaging;
}

export function isPushEnabled(): boolean {
  return getMessaging() !== null;
}

export interface PushPayload {
  title: string;
  body: string;
  /** Optional structured data delivered to the app (all values must be strings). */
  data?: Record<string, string>;
}

/**
 * Send a push notification to every device registered for a given User.
 * No-op when push is disabled or the user has no registered devices.
 * Automatically prunes tokens FCM reports as unregistered/invalid.
 */
export async function sendPushToUser(
  userId: string | null | undefined,
  payload: PushPayload
): Promise<void> {
  if (!userId) return;
  const fcm = getMessaging();
  if (!fcm) return;

  const devices = await prisma.deviceToken.findMany({
    where: { userId },
    select: { token: true },
  });
  if (devices.length === 0) return;

  const tokens = devices.map((d) => d.token);

  try {
    const res = await fcm.sendEachForMulticast({
      tokens,
      notification: { title: payload.title, body: payload.body },
      data: payload.data ?? {},
      android: { priority: "high" },
    });

    // Collect tokens FCM rejected as permanently invalid and prune them.
    const stale: string[] = [];
    res.responses.forEach((r: { success: boolean; error?: { code?: string } }, i: number) => {
      if (!r.success) {
        const code = r.error?.code ?? "";
        if (
          code === "messaging/invalid-registration-token" ||
          code === "messaging/registration-token-not-registered"
        ) {
          stale.push(tokens[i]);
        }
      }
    });

    if (stale.length > 0) {
      await prisma.deviceToken.deleteMany({ where: { token: { in: stale } } });
      console.log(`[PushService] Pruned ${stale.length} stale device token(s).`);
    }
  } catch (err) {
    // Never let a push failure break the request that triggered the notification.
    console.error("[PushService] sendEachForMulticast failed:", err);
  }
}
