import {onCall, HttpsError} from "firebase-functions/v2/https";

/**
 * Cloud Function to generate comparative analytics
 * Task 29.6: Create generateComparativeAnalytics Cloud Function
 */
export const generateComparativeAnalytics = onCall(
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Authentication required");
    }

    const {currentFilter, comparisonFilter} = request.data;

    try {
      // TODO: Refactor to use HTTP calls or shared logic
      // For now, return placeholder data
      console.log("Comparative analytics requested for:", {
        currentFilter,
        comparisonFilter,
      });

      // Placeholder data structure
      const currentMilk = {totalLiters: 0, averageLitersPerDay: 0, averageLitersPerFarmer: 0};
      const comparisonMilk = {totalLiters: 0, averageLitersPerDay: 0, averageLitersPerFarmer: 0};
      const currentFarmer = {totalFarmers: 0, newFarmersThisPeriod: 0, farmersWithAppAccess: 0};
      const comparisonFarmer = {totalFarmers: 0, newFarmersThisPeriod: 0, farmersWithAppAccess: 0};
      const currentLivestock = {totalCattle: 0, lactationRate: 0};
      const comparisonLivestock = {totalCattle: 0, lactationRate: 0};
      const currentFinancial = {totalRevenue: 0, loanMetrics: {repaymentRate: 0}};
      const comparisonFinancial = {totalRevenue: 0, loanMetrics: {repaymentRate: 0}};
      const currentInventory = {totalSalesRevenue: 0, lowStockProducts: 0};
      const comparisonInventory = {totalSalesRevenue: 0, lowStockProducts: 0};

      // Calculate percentage changes
      const calculateChange = (current: number, previous: number): number => {
        if (previous === 0) return current > 0 ? 100 : 0;
        return ((current - previous) / previous) * 100;
      };

      // Determine trend indicators
      const getTrend = (change: number): string => {
        if (change > 5) return "improving";
        if (change < -5) return "declining";
        return "stable";
      };

      const percentageChanges = {
        milkProduction: {
          totalLiters: calculateChange(currentMilk.totalLiters, comparisonMilk.totalLiters),
          averageLitersPerDay: calculateChange(currentMilk.averageLitersPerDay, comparisonMilk.averageLitersPerDay),
          averageLitersPerFarmer: calculateChange(currentMilk.averageLitersPerFarmer, comparisonMilk.averageLitersPerFarmer),
        },
        farmers: {
          totalFarmers: calculateChange(currentFarmer.totalFarmers, comparisonFarmer.totalFarmers),
          newFarmers: calculateChange(currentFarmer.newFarmersThisPeriod, comparisonFarmer.newFarmersThisPeriod),
          appAdoption: calculateChange(currentFarmer.farmersWithAppAccess, comparisonFarmer.farmersWithAppAccess),
        },
        livestock: {
          totalCattle: calculateChange(currentLivestock.totalCattle, comparisonLivestock.totalCattle),
          lactationRate: calculateChange(currentLivestock.lactationRate, comparisonLivestock.lactationRate),
        },
        financial: {
          totalRevenue: calculateChange(currentFinancial.totalRevenue, comparisonFinancial.totalRevenue),
          loanRepaymentRate: calculateChange(
            currentFinancial.loanMetrics.repaymentRate,
            comparisonFinancial.loanMetrics.repaymentRate
          ),
        },
        inventory: {
          totalSalesRevenue: calculateChange(currentInventory.totalSalesRevenue, comparisonInventory.totalSalesRevenue),
          lowStockProducts: calculateChange(currentInventory.lowStockProducts, comparisonInventory.lowStockProducts),
        },
      };

      const trendIndicators = {
        milkProduction: getTrend(percentageChanges.milkProduction.totalLiters),
        farmers: getTrend(percentageChanges.farmers.totalFarmers),
        livestock: getTrend(percentageChanges.livestock.totalCattle),
        financial: getTrend(percentageChanges.financial.totalRevenue),
        inventory: getTrend(percentageChanges.inventory.totalSalesRevenue),
      };

      return {
        currentPeriod: {
          milk: currentMilk,
          farmer: currentFarmer,
          livestock: currentLivestock,
          financial: currentFinancial,
          inventory: currentInventory,
        },
        comparisonPeriod: {
          milk: comparisonMilk,
          farmer: comparisonFarmer,
          livestock: comparisonLivestock,
          financial: comparisonFinancial,
          inventory: comparisonInventory,
        },
        percentageChanges,
        trendIndicators,
      };
    } catch (error) {
      console.error("Error generating comparative analytics:", error);
      throw new HttpsError("internal", "Failed to generate comparative analytics");
    }
  }
);
