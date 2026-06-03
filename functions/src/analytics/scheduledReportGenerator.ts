import * as admin from "firebase-admin";
import {onSchedule} from "firebase-functions/v2/scheduler";

/**
 * Scheduled Cloud Function to generate reports
 * Task 29.9: Create scheduledReportGenerator Cloud Function
 */
export const scheduledReportGenerator = onSchedule(
  "0 0 * * *", // Run daily at midnight
  async () => {
    try {
      const db = admin.firestore();
      const now = admin.firestore.Timestamp.now();

      // Query scheduled reports that are due
      const dueReportsSnapshot = await db
        .collection("scheduled_reports")
        .where("isActive", "==", true)
        .where("nextScheduled", "<=", now)
        .get();

      console.log(`Found ${dueReportsSnapshot.size} due reports`);

      for (const doc of dueReportsSnapshot.docs) {
        const reportData = doc.data();
        const reportId = doc.id;

        try {
          // Generate the report (in production, call generateReport function)
          console.log(`Generating report: ${reportId}`);

          // For now, just log and update timestamps
          // In production, this would:
          // 1. Call generateReport Cloud Function
          // 2. Send email to recipients with the report
          // 3. Update lastGenerated and nextScheduled

          const frequency = reportData.frequency;
          const nextScheduled = calculateNextScheduledDate(frequency, now.toDate());

          await doc.ref.update({
            lastGenerated: now,
            nextScheduled: admin.firestore.Timestamp.fromDate(nextScheduled),
          });

          // Send email to recipients (placeholder)
          const recipients = reportData.recipientEmails || [];
          console.log(`Would send report to: ${recipients.join(", ")}`);

          // In production, integrate with email service:
          // await sendEmail({
          //   to: recipients,
          //   subject: `Scheduled Report: ${reportData.templateName}`,
          //   body: 'Your scheduled report is attached.',
          //   attachments: [reportFile],
          // });
        } catch (error) {
          console.error(`Error generating report ${reportId}:`, error);
          // Continue with other reports even if one fails
        }
      }
    } catch (error) {
      console.error("Error in scheduled report generator:", error);
      throw error;
    }
  });

/**
 * Calculate next scheduled date based on frequency
 */
function calculateNextScheduledDate(frequency: string, currentDate: Date): Date {
  const next = new Date(currentDate);

  switch (frequency) {
  case "daily":
    next.setDate(next.getDate() + 1);
    break;
  case "weekly":
    next.setDate(next.getDate() + 7);
    break;
  case "monthly":
    next.setMonth(next.getMonth() + 1);
    break;
  case "quarterly":
    next.setMonth(next.getMonth() + 3);
    break;
  case "annual":
    next.setFullYear(next.getFullYear() + 1);
    break;
  default:
    next.setDate(next.getDate() + 1);
  }

  return next;
}
