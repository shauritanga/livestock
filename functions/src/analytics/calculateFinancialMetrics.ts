import * as admin from "firebase-admin";
import {onCall, HttpsError} from "firebase-functions/v2/https";

/**
 * Cloud Function to calculate financial metrics
 * Task 29.4: Create calculateFinancialMetrics Cloud Function
 */
export const calculateFinancialMetrics = onCall(
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Authentication required");
    }

    const {filter} = request.data;
    const {dateRange, cooperativeIds} = filter;

    const startDate = dateRange?.startDate;
    const endDate = dateRange?.endDate;

    try {
      const db = admin.firestore();

      // Query flat milkDeliveries collection
      let deliveriesQuery = db.collection("milkDeliveries") as admin.firestore.Query;

      // Filter by cooperativeIds if provided
      if (cooperativeIds && cooperativeIds.length > 0) {
        deliveriesQuery = deliveriesQuery.where("cooperativeId", "in", cooperativeIds.slice(0, 10));
      }

      // Apply date filters
      if (startDate) {
        deliveriesQuery = deliveriesQuery.where(
          "deliveryDate",
          ">=",
          admin.firestore.Timestamp.fromDate(new Date(startDate))
        );
      }
      if (endDate) {
        deliveriesQuery = deliveriesQuery.where(
          "deliveryDate",
          "<=",
          admin.firestore.Timestamp.fromDate(new Date(endDate))
        );
      }

      const deliveriesSnapshot = await deliveriesQuery.get();
      const deliveries = deliveriesSnapshot.docs.map((doc) => doc.data());

      // Query loans collection
      let loansQuery = db.collection("loans") as admin.firestore.Query;
      if (cooperativeIds && cooperativeIds.length > 0) {
        loansQuery = loansQuery.where("cooperativeId", "in", cooperativeIds.slice(0, 10));
      }

      const loansSnapshot = await loansQuery.get();
      const loans = loansSnapshot.docs.map((doc) => doc.data());

      const totalMilkPayments = deliveries.reduce(
        (sum, d) => sum + ((d.quantityLiters || 0) * (d.pricePerLiter || 0)),
        0
      );

      const totalLiters = deliveries.reduce((sum, d) => sum + (d.quantityLiters || 0), 0);
      const averagePricePerLiter = totalLiters > 0 ? totalMilkPayments / totalLiters : 0;

      // Payment trend
      const paymentTrend: Array<{ date: string; value: number }> = [];
      const dailyPayments = new Map<string, number>();

      deliveries.forEach((d) => {
        const date = d.deliveryDate?.toDate ?
          d.deliveryDate.toDate().toISOString().split("T")[0] :
          new Date(d.deliveryDate).toISOString().split("T")[0];
        const payment = (d.quantityLiters || 0) * (d.pricePerLiter || 0);
        dailyPayments.set(date, (dailyPayments.get(date) || 0) + payment);
      });

      Array.from(dailyPayments.entries())
        .sort((a, b) => a[0].localeCompare(b[0]))
        .forEach(([date, value]) => {
          paymentTrend.push({date, value});
        });

      // Loan metrics (already fetched above)

      const loanMetrics = {
        totalDisbursed: loans.reduce((sum, l) => sum + (l.amount || 0), 0),
        totalOutstanding: loans
          .filter((l) => l.status === "active")
          .reduce((sum, l) => sum + (l.outstandingBalance || 0), 0),
        repaymentRate: 0,
        defaultRate: 0,
        activeLoanCount: loans.filter((l) => l.status === "active").length,
        completedLoanCount: loans.filter((l) => l.status === "completed").length,
      };

      const totalRepaid = loans.reduce((sum, l) => sum + (l.amountRepaid || 0), 0);
      if (loanMetrics.totalDisbursed > 0) {
        loanMetrics.repaymentRate = (totalRepaid / loanMetrics.totalDisbursed) * 100;
      }

      const defaultedLoans = loans.filter((l) => l.status === "defaulted").length;
      if (loans.length > 0) {
        loanMetrics.defaultRate = (defaultedLoans / loans.length) * 100;
      }

      // Insurance metrics
      let insuranceQuery = db.collection("insurance_policies") as admin.firestore.Query;
      if (cooperativeIds && cooperativeIds.length > 0) {
        insuranceQuery = insuranceQuery.where("cooperativeId", "in", cooperativeIds);
      }

      const insuranceSnapshot = await insuranceQuery.get();
      const policies = insuranceSnapshot.docs.map((doc) => doc.data());

      const insuranceMetrics = {
        activePolicies: policies.filter((p) => p.status === "active").length,
        totalPremiumCollected: policies.reduce((sum, p) => sum + (p.premiumPaid || 0), 0),
        coveragePercentage: 0,
        overdueCount: policies.filter((p) => p.status === "overdue").length,
        outstandingPremium: policies
          .filter((p) => p.status === "overdue")
          .reduce((sum, p) => sum + (p.premiumAmount - (p.premiumPaid || 0)), 0),
      };

      // Calculate coverage percentage (active policies / total cattle)
      const cattleSnapshot = await db.collection("cattle").get();
      const totalCattle = cattleSnapshot.size;
      if (totalCattle > 0) {
        insuranceMetrics.coveragePercentage =
          (insuranceMetrics.activePolicies / totalCattle) * 100;
      }

      // Revenue breakdown
      const revenueBreakdown = {
        milkSales: totalMilkPayments,
        loanInterest: loans.reduce((sum, l) => sum + (l.interestPaid || 0), 0),
        insurancePremiums: insuranceMetrics.totalPremiumCollected,
      };

      const totalRevenue = Object.values(revenueBreakdown).reduce((sum, v) => sum + v, 0);

      return {
        totalMilkPayments,
        averagePricePerLiter,
        paymentTrend,
        loanMetrics,
        insuranceMetrics,
        totalRevenue,
        revenueBreakdown,
      };
    } catch (error) {
      console.error("Error calculating financial metrics:", error);
      throw new HttpsError("internal", "Failed to calculate financial metrics");
    }
  }
);
