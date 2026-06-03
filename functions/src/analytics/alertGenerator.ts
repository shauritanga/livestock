import * as admin from "firebase-admin";
import {onSchedule} from "firebase-functions/v2/scheduler";

/**
 * Scheduled Cloud Function to generate alerts
 * Task 29.10: Create alertGenerator Cloud Function
 */
export const alertGenerator = onSchedule(
  "0 * * * *", // Run every hour
  async () => {
    try {
      const db = admin.firestore();
      const now = new Date();
      const thirtyDaysAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);

      console.log("Starting alert generation...");

      // Check for production drops
      await checkProductionDrops(db, now, thirtyDaysAgo);

      // Check for low stock items
      await checkLowStock(db);

      // Check for loan defaults
      await checkLoanDefaults(db);

      // Check for overdue insurance premiums
      await checkOverdueInsurance(db, now);

      // Check for farmer engagement drops
      await checkFarmerEngagement(db, now, thirtyDaysAgo);

      // Check for quality concerns
      await checkQualityConcerns(db, now, thirtyDaysAgo);

      console.log("Alert generation completed");
    } catch (error) {
      console.error("Error in alert generator:", error);
      throw error;
    }
  });

/**
 * Check for production drops (below 80% of 30-day average)
 */
async function checkProductionDrops(
  db: admin.firestore.Firestore,
  now: Date,
  thirtyDaysAgo: Date
) {
  try {
    // Get last 30 days of deliveries from flat collection
    const deliveriesSnapshot = await db
      .collection("milkDeliveries")
      .where("deliveryDate", ">=", admin.firestore.Timestamp.fromDate(thirtyDaysAgo))
      .where("deliveryDate", "<=", admin.firestore.Timestamp.fromDate(now))
      .get();

    const deliveries = deliveriesSnapshot.docs.map((doc) => doc.data());

    // Calculate 30-day average
    const totalLiters = deliveries.reduce((sum, d) => sum + (d.quantity || 0), 0);
    const averagePerDay = totalLiters / 30;

    // Get today's production
    const today = new Date(now);
    today.setHours(0, 0, 0, 0);
    const todayDeliveries = deliveries.filter((d) => {
      const deliveryDate = d.deliveryDate?.toDate ? d.deliveryDate.toDate() : new Date(d.deliveryDate);
      return deliveryDate >= today;
    });
    const todayTotal = todayDeliveries.reduce((sum, d) => sum + (d.quantity || 0), 0);

    // Check if below 80% threshold
    if (todayTotal < averagePerDay * 0.8) {
      await createAlert(db, {
        type: "productionDrop",
        severity: "critical",
        title: "Production Drop Alert",
        message: `Today's milk production (${todayTotal.toFixed(1)}L) is ${((1 - todayTotal / averagePerDay) * 100).toFixed(1)}% below the 30-day average (${averagePerDay.toFixed(1)}L)`,
        metadata: {
          todayProduction: todayTotal,
          averageProduction: averagePerDay,
          percentageBelow: ((1 - todayTotal / averagePerDay) * 100).toFixed(1),
        },
      });
    }
  } catch (error) {
    console.error("Error checking production drops:", error);
  }
}

/**
 * Check for low stock items
 */
async function checkLowStock(db: admin.firestore.Firestore) {
  try {
    // Get all products and filter in memory
    const productsSnapshot = await db
      .collection("products")
      .get();

    const lowStockProducts = productsSnapshot.docs.filter((doc) => {
      const data = doc.data();
      return (data.quantity || 0) <= (data.reorderPoint || 0);
    });

    if (lowStockProducts.length > 0) {
      await createAlert(db, {
        type: "lowStock",
        severity: "warning",
        title: "Low Stock Alert",
        message: `${lowStockProducts.length} product(s) are below reorder point`,
        metadata: {
          productCount: lowStockProducts.length,
          products: lowStockProducts.slice(0, 5).map((doc) => ({
            id: doc.id,
            name: doc.data().name,
            quantity: doc.data().quantity,
            reorderPoint: doc.data().reorderPoint,
          })),
        },
      });
    }
  } catch (error) {
    console.error("Error checking low stock:", error);
  }
}

/**
 * Check for loan defaults (default rate > 10%)
 */
async function checkLoanDefaults(db: admin.firestore.Firestore) {
  try {
    const loansSnapshot = await db.collection("loans").get();
    const loans = loansSnapshot.docs.map((doc) => doc.data());

    const totalLoans = loans.length;
    const defaultedLoans = loans.filter((l) => l.status === "defaulted").length;
    const defaultRate = totalLoans > 0 ? (defaultedLoans / totalLoans) * 100 : 0;

    if (defaultRate > 10) {
      await createAlert(db, {
        type: "loanDefault",
        severity: "critical",
        title: "High Loan Default Rate",
        message: `Loan default rate is ${defaultRate.toFixed(1)}%, exceeding the 10% threshold`,
        metadata: {
          totalLoans,
          defaultedLoans,
          defaultRate: defaultRate.toFixed(1),
        },
      });
    }
  } catch (error) {
    console.error("Error checking loan defaults:", error);
  }
}

/**
 * Check for overdue insurance premiums (> 30 days)
 */
async function checkOverdueInsurance(
  db: admin.firestore.Firestore,
  now: Date
) {
  try {
    const thirtyDaysAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);

    const policiesSnapshot = await db
      .collection("insurance_policies")
      .where("status", "==", "overdue")
      .get();

    const overduePolicies = policiesSnapshot.docs.filter((doc) => {
      const data = doc.data();
      const dueDate = data.premiumDueDate?.toDate ? data.premiumDueDate.toDate() : new Date(data.premiumDueDate);
      return dueDate < thirtyDaysAgo;
    });

    if (overduePolicies.length > 0) {
      const totalOverdue = overduePolicies.reduce((sum, doc) => {
        const data = doc.data();
        return sum + (data.premiumAmount - (data.premiumPaid || 0));
      }, 0);

      await createAlert(db, {
        type: "insuranceLapse",
        severity: "warning",
        title: "Overdue Insurance Premiums",
        message: `${overduePolicies.length} insurance policies have premiums overdue by more than 30 days`,
        metadata: {
          policyCount: overduePolicies.length,
          totalOverdueAmount: totalOverdue,
        },
      });
    }
  } catch (error) {
    console.error("Error checking overdue insurance:", error);
  }
}

/**
 * Check for farmer engagement drops
 */
async function checkFarmerEngagement(
  db: admin.firestore.Firestore,
  now: Date,
  thirtyDaysAgo: Date
) {
  try {
    // Query flat milkDeliveries collection
    const deliveriesSnapshot = await db
      .collection("milkDeliveries")
      .where("deliveryDate", ">=", admin.firestore.Timestamp.fromDate(thirtyDaysAgo))
      .get();

    const uniqueFarmers = new Set(deliveriesSnapshot.docs.map((doc) => doc.data().farmerId));
    const activeFarmers = uniqueFarmers.size;

    // Query flat farmers collection
    const allFarmersSnapshot = await db.collection("farmers").get();
    const totalFarmers = allFarmersSnapshot.size;

    const engagementRate = totalFarmers > 0 ? (activeFarmers / totalFarmers) * 100 : 0;

    if (engagementRate < 50) {
      await createAlert(db, {
        type: "farmerEngagement",
        severity: "warning",
        title: "Low Farmer Engagement",
        message: `Only ${engagementRate.toFixed(1)}% of farmers have made deliveries in the last 30 days`,
        metadata: {
          activeFarmers,
          totalFarmers,
          engagementRate: engagementRate.toFixed(1),
        },
      });
    }
  } catch (error) {
    console.error("Error checking farmer engagement:", error);
  }
}

/**
 * Check for quality concerns (> 20% substandard milk)
 */
async function checkQualityConcerns(
  db: admin.firestore.Firestore,
  now: Date,
  thirtyDaysAgo: Date
) {
  try {
    // Query flat milkDeliveries collection
    const deliveriesSnapshot = await db
      .collection("milkDeliveries")
      .where("deliveryDate", ">=", admin.firestore.Timestamp.fromDate(thirtyDaysAgo))
      .get();

    const deliveries = deliveriesSnapshot.docs.map((doc) => doc.data());

    let substandardLiters = 0;
    let totalLiters = 0;

    deliveries.forEach((delivery) => {
      const quantity = delivery.quantityLiters || 0;
      totalLiters += quantity;

      const grade = delivery.qualityGrade?.toLowerCase() || "standard";
      if (grade === "substandard" || grade === "c") {
        substandardLiters += quantity;
      }
    });

    const substandardPercentage = totalLiters > 0 ? (substandardLiters / totalLiters) * 100 : 0;

    if (substandardPercentage > 20) {
      await createAlert(db, {
        type: "qualityConcern",
        severity: "warning",
        title: "Quality Concern Alert",
        message: `${substandardPercentage.toFixed(1)}% of milk collected in the last 30 days is substandard quality`,
        metadata: {
          substandardLiters,
          totalLiters,
          substandardPercentage: substandardPercentage.toFixed(1),
        },
      });
    }
  } catch (error) {
    console.error("Error checking quality concerns:", error);
  }
}

/**
 * Create an alert in Firestore
 */
async function createAlert(
  db: admin.firestore.Firestore,
  alertData: {
    type: string;
    severity: string;
    title: string;
    message: string;
    metadata: any;
  }
) {
  try {
    // Check if similar alert already exists in the last 24 hours
    const oneDayAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);
    const existingAlerts = await db
      .collection("alerts")
      .where("type", "==", alertData.type)
      .where("createdAt", ">=", admin.firestore.Timestamp.fromDate(oneDayAgo))
      .limit(1)
      .get();

    if (!existingAlerts.empty) {
      console.log(`Alert of type ${alertData.type} already exists, skipping`);
      return;
    }

    // Create new alert
    await db.collection("alerts").add({
      ...alertData,
      createdAt: admin.firestore.Timestamp.now(),
      isRead: false,
      readAt: null,
    });

    console.log(`Created alert: ${alertData.type} - ${alertData.title}`);

    // In production, send push notification for critical alerts
    if (alertData.severity === "critical") {
      // await sendPushNotification({
      //   title: alertData.title,
      //   body: alertData.message,
      //   data: alertData.metadata,
      // });
      console.log(`Would send push notification for critical alert: ${alertData.title}`);
    }
  } catch (error) {
    console.error("Error creating alert:", error);
  }
}
