import { prisma } from "../config/prisma";
import { getIO } from "../config/websocket";
import { NotificationType, NotificationChannel } from "@prisma/client";
import { sendPushToUser } from "./push.service";

export class NotificationService {
  /**
   * Send an absence alert to the recipient (parent/student)
   */
  static async sendAbsenceAlert(
    schoolId: string,
    recipientUserId: string | null,
    studentName: string,
    date: Date,
    period?: number
  ) {
    const formattedDate = date.toLocaleDateString("ar-EG");
    const periodText = period ? ` (الحصة ${period})` : "";
    const title = "تنبيه غياب";
    const message = `تم تسجيل غياب الطالب ${studentName} بتاريخ ${formattedDate}${periodText}.`;

    // 1. Save to Database
    const notification = await prisma.notification.create({
      data: {
        schoolId,
        recipientId: recipientUserId,
        title,
        message,
        type: "ABSENCE",
        channel: "SYSTEM",
      },
    });

    // 2. Emit via WebSocket
    const io = getIO();
    if (recipientUserId) {
      io.to(`user:${recipientUserId}`).emit("notification:new", notification);
    }
    
    // Also notify the school admins/dashboard
    io.to(`school:${schoolId}`).emit("notification:system", notification);

    // 3. Push notification (FCM) — no-op if push disabled or recipient has no devices
    if (recipientUserId) {
      void sendPushToUser(recipientUserId, {
        title,
        body: message,
        data: { type: "ABSENCE", notificationId: notification.id },
      });
    }

    // 4. Placeholder for SMS/WhatsApp
    // TODO: Integrate with external SMS/WhatsApp gateway if settings.smsEnabled is true
    console.log(`[NotificationService] Absence alert queued for ${studentName} via System/WebSocket/Push`);

    return notification;
  }
}
