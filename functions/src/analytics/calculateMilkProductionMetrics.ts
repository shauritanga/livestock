import * as admin from "firebase-admin";
import {onCall, HttpsError} from "firebase-functions/v2/https";

/**
 * Cloud Function to calculate milk production metrics
 * Task 29.1: Create calculateMilkProductionMetrics Cloud Function
 */
export const calculateMilkProductionMetrics = onCall(
  async (request) => {
    // Verify authentication
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "User must be authenticated to access analytics"
      );
    }

    const {filter} = request.data;
    const {
      dateRange,
      cooperativeIds,
    } = filter;

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

      // Calculate metrics
      const totalLiters = deliveries.reduce(
        (sum, delivery) => sum + (delivery.quantityLiters || 0),
        0
      );

      const uniqueFarmers = new Set(
        deliveries.map((d) => d.farmerId)
      ).size;

      const daysDiff = endDate && startDate ?
        Math.ceil(
          (new Date(endDate).getTime() - new Date(startDate).getTime()) /
              (1000 * 60 * 60 * 24)
        ) :
        1;

      const averageLitersPerDay = totalLiters / daysDiff;
      const averageLitersPerFarmer = uniqueFarmers > 0 ?
        totalLiters / uniqueFarmers :
        0;

      // Quality distribution
      const qualityDistribution = {
        premium: 0,
        standard: 0,
        substandard: 0,
      };

      deliveries.forEach((delivery) => {
        const grade = delivery.qualityGrade?.toLowerCase() || "standard";
        if (grade === "premium" || grade === "a") {
          qualityDistribution.premium += delivery.quantityLiters || 0;
        } else if (grade === "substandard" || grade === "c") {
          qualityDistribution.substandard += delivery.quantityLiters || 0;
        } else {
          qualityDistribution.standard += delivery.quantityLiters || 0;
        }
      });

      // Daily trend
      const dailyMap = new Map<string, number>();
      deliveries.forEach((delivery) => {
        const date = delivery.deliveryDate?.toDate ?
          delivery.deliveryDate.toDate().toISOString().split("T")[0] :
          new Date(delivery.deliveryDate).toISOString().split("T")[0];
        dailyMap.set(date, (dailyMap.get(date) || 0) + (delivery.quantityLiters || 0));
      });

      const dailyTrend = Array.from(dailyMap.entries())
        .map(([date, value]) => ({date, value}))
        .sort((a, b) => a.date.localeCompare(b.date));

      // Cooperative breakdown (replaces collection center breakdown)
      const cooperativeMap = new Map<string, {
        cooperativeId: string;
        cooperativeName: string;
        totalLiters: number;
        farmerCount: number;
      }>();

      deliveries.forEach((delivery) => {
        const coopId = delivery.cooperativeId || "unknown";
        const coopName = delivery.cooperativeName || "Unknown Cooperative";

        if (!cooperativeMap.has(coopId)) {
          cooperativeMap.set(coopId, {
            cooperativeId: coopId,
            cooperativeName: coopName,
            totalLiters: 0,
            farmerCount: 0,
          });
        }

        const coop = cooperativeMap.get(coopId)!;
        coop.totalLiters += delivery.quantityLiters || 0;
      });

      // Count unique farmers per cooperative
      const cooperativeFarmers = new Map<string, Set<string>>();
      deliveries.forEach((delivery) => {
        const coopId = delivery.cooperativeId || "unknown";
        if (!cooperativeFarmers.has(coopId)) {
          cooperativeFarmers.set(coopId, new Set());
        }
        cooperativeFarmers.get(coopId)!.add(delivery.farmerId);
      });

      cooperativeFarmers.forEach((farmers, coopId) => {
        const coop = cooperativeMap.get(coopId);
        if (coop) {
          coop.farmerCount = farmers.size;
        }
      });

      const cooperativeBreakdown = Array.from(cooperativeMap.values())
        .map((coop) => ({
          ...coop,
          percentageOfTotal: totalLiters > 0 ?
            (coop.totalLiters / totalLiters) * 100 :
            0,
          averageLitersPerFarmer: coop.farmerCount > 0 ?
            coop.totalLiters / coop.farmerCount :
            0,
        }))
        .sort((a, b) => b.totalLiters - a.totalLiters);

      // Hourly distribution
      const hourlyDistribution: { [hour: number]: number } = {};
      deliveries.forEach((delivery) => {
        const hour = delivery.deliveryDate?.toDate ?
          delivery.deliveryDate.toDate().getHours() :
          new Date(delivery.deliveryDate).getHours();
        hourlyDistribution[hour] = (hourlyDistribution[hour] || 0) + (delivery.quantityLiters || 0);
      });

      // Calculate percentage change (compare with previous period)
      // TODO: Implement growth rate calculation with nested structure
      const percentageChange = 0;

      return {
        totalLiters,
        averageLitersPerDay,
        averageLitersPerFarmer,
        qualityDistribution,
        dailyTrend,
        cooperativeBreakdown,
        hourlyDistribution,
        percentageChange,
      };
    } catch (error) {
      console.error("Error calculating milk production metrics:", error);
      throw new HttpsError(
        "internal",
        "Failed to calculate milk production metrics"
      );
    }
  }
);
