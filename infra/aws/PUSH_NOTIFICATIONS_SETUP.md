# Push Notifications — Setup (FCM)

WeCircle delivers push via **Firebase Cloud Messaging (FCM)**. The code is fully wired on both
sides and **degrades gracefully**: until you complete the steps below, the app runs normally and
notifications still appear in-app (DB row) and live (WebSocket) — only the OS-level push is off.

- **Backend** `src/services/push.service.ts` → no-op unless `FIREBASE_SERVICE_ACCOUNT` is set.
- **Mobile** `lib/services/push_service.dart` → no-op unless `android/app/google-services.json` exists
  (the Gradle plugin auto-activates only when that file is present).

Scope today: **Android**. iOS support is coded but needs an Apple Developer account (see §5).

---

## 1. Create a Firebase project (free)

1. Go to <https://console.firebase.google.com> → **Add project** → name it e.g. `wecircle`.
2. Disable Google Analytics (optional) → **Create project**.

> Note: FCM is free and independent of the AWS account. This does **not** re-introduce Firestore —
> Firebase is used **only** for push delivery (Android push must go through FCM regardless of host).

---

## 2. Mobile (Android) — `google-services.json`

1. In the Firebase console → **Project settings** (⚙️) → **Your apps** → **Add app → Android**.
2. **Android package name:** `com.example.wesal`  (must match `applicationId` in
   [android/app/build.gradle.kts](../../mobile/android/app/build.gradle.kts)).
3. Register the app → **Download `google-services.json`**.
4. Place it at: `mobile/android/app/google-services.json`
   - It is git-ignored on purpose (per-project config). Keep a copy in your password manager.
5. Build & run:
   ```bash
   cd mobile
   flutter pub get
   flutter run --dart-define=API_URL=https://api.wecircle.helpers-tech.com/api
   ```
   The Gradle plugin now auto-applies (it detected the json) and `Firebase.initializeApp()` succeeds.
   On first launch the app asks for notification permission and registers its FCM token with the
   backend (`POST /notifications/mobile/device-token`).

---

## 3. Backend — Firebase service account

The backend sends pushes using the Firebase Admin SDK, authenticated with a **service account key**.

1. Firebase console → **Project settings → Service accounts** → **Generate new private key** →
   downloads a JSON file (keep it secret — it grants send rights).
2. On the EC2 box, expose it to the backend in **one** of two ways:

   **Option A — inline JSON env var (recommended, matches our SSM pattern):**
   ```bash
   # Minify the key to a single line and store it in the backend .env (or SSM Parameter Store)
   FIREBASE_SERVICE_ACCOUNT='{"type":"service_account","project_id":"wecircle",...}'
   ```

   **Option B — file path:**
   ```bash
   # Copy the key to the box, then point the env var at it
   FIREBASE_SERVICE_ACCOUNT_PATH=/opt/wecircle/secrets/firebase-service-account.json
   ```
3. Restart the backend:
   ```bash
   pm2 restart backend
   pm2 logs backend --lines 20   # expect: "[PushService] Firebase Cloud Messaging initialised — push notifications enabled."
   ```

> Never commit the service-account key. Treat it like `JWT_SECRET`.

---

## 4. Test end-to-end

1. Log in on a physical Android device (emulators get tokens too, but real devices are clearer).
2. From the dashboard, send a manual notification to that user, **or** mark their child absent
   (triggers `NotificationService.sendAbsenceAlert`).
3. The push should arrive in the device tray within a couple of seconds.
4. Verify the token landed:
   ```sql
   SELECT "userId", platform, "lastUsedAt" FROM "DeviceToken" ORDER BY "lastUsedAt" DESC LIMIT 5;
   ```

Stale/uninstalled tokens are pruned automatically (FCM reports them and the backend deletes them).

---

## 5. iOS (later — needs a paid Apple Developer account)

The Dart code already detects `Platform.isIOS` and registers tokens as `ios`. To activate:

1. Apple Developer account ($99/yr) → create an **APNs Auth Key** (`.p8`) + note **Key ID** + **Team ID**.
2. Firebase console → **Project settings → Cloud Messaging → Apple app configuration** → upload the
   `.p8` with Key ID + Team ID.
3. Add an iOS app in Firebase → download **`GoogleService-Info.plist`** → add it to the Runner target
   in Xcode (`mobile/ios/Runner/`).
4. Enable the **Push Notifications** + **Background Modes → Remote notifications** capabilities in Xcode.

No backend change is needed — the same `sendPushToUser` path serves both platforms.

---

## What's wired (reference)

| Piece | Location |
|---|---|
| FCM send service (graceful no-op) | `dashboard/backend/src/services/push.service.ts` |
| Push on every targeted notification | `modules/notification/notification.controller.ts` (`createNotification`, `sendManualNotification`) |
| Push on absence alerts | `services/notification.service.ts` |
| Token register / unregister API | `POST` / `DELETE /api/notifications/mobile/device-token` |
| `DeviceToken` model + migration | `prisma/schema.prisma`, `migrations/20260530000009_device_tokens` |
| Mobile FCM client | `mobile/lib/services/push_service.dart` (init in `main.dart`, register on login) |
| Gradle auto-activation | `mobile/android/settings.gradle.kts` + `app/build.gradle.kts` (guarded by `google-services.json`) |
