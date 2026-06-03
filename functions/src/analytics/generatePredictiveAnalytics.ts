import * as admin from "firebase-admin";
import {onCall, HttpsError} from "firebase-functions/v2/https";

/**
 * Cloud Function to generate predictive analytics
 * Task 29.7: Create generatePredictiveAnalytics Cloud Function
 */
export const generatePredictiveAnalytics = onCall(
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Authentication required");
    }

    const {filter, forecastDays} = request.data;
    const {startDate, endDate, cooperativeIds} = filter;

    try {
      const db = admin.firestore();

      // Fetch historical time series data
      let query = db.collection("milk_deliveries") as admin.firestore.Query;

      if (startDate) {
        query = query.where(
          "deliveryDate",
          ">=",
          admin.firestore.Timestamp.fromDate(new Date(startDate))
        );
      }
      if (endDate) {
        query = query.where(
          "deliveryDate",
          "<=",
          admin.firestore.Timestamp.fromDate(new Date(endDate))
        );
      }
      if (cooperativeIds && cooperativeIds.length > 0) {
        query = query.where("cooperativeId", "in", cooperativeIds);
      }

      const snapshot = await query.get();
      const deliveries = snapshot.docs.map((doc) => doc.data());

      // Aggregate daily data
      const dailyData = new Map<string, number>();
      deliveries.forEach((delivery) => {
        const date = delivery.deliveryDate?.toDate ?
          delivery.deliveryDate.toDate().toISOString().split("T")[0] :
          new Date(delivery.deliveryDate).toISOString().split("T")[0];
        dailyData.set(date, (dailyData.get(date) || 0) + (delivery.quantityLiters || 0));
      });

      // Convert to sorted array
      const historicalData = Array.from(dailyData.entries())
        .map(([date, value]) => ({date, value}))
        .sort((a, b) => a.date.localeCompare(b.date));

      if (historicalData.length < 7) {
        throw new HttpsError(
          "failed-precondition",
          "Insufficient historical data for forecasting (minimum 7 days required)"
        );
      }

      // Simple linear regression for trend line
      const n = historicalData.length;
      const xValues = historicalData.map((_, i) => i);
      const yValues = historicalData.map((d) => d.value);

      const sumX = xValues.reduce((a, b) => a + b, 0);
      const sumY = yValues.reduce((a, b) => a + b, 0);
      const sumXY = xValues.reduce((sum, x, i) => sum + x * yValues[i], 0);
      const sumX2 = xValues.reduce((sum, x) => sum + x * x, 0);

      const slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
      const intercept = (sumY - slope * sumX) / n;

      // Generate forecast
      const forecastData: Array<{ date: string; value: number }> = [];
      const lastDate = new Date(historicalData[historicalData.length - 1].date);

      for (let i = 1; i <= forecastDays; i++) {
        const forecastDate = new Date(lastDate);
        forecastDate.setDate(forecastDate.getDate() + i);
        const forecastValue = slope * (n + i - 1) + intercept;

        forecastData.push({
          date: forecastDate.toISOString().split("T")[0],
          value: Math.max(0, forecastValue), // Ensure non-negative
        });
      }

      // Calculate confidence intervals (simplified - using standard deviation)
      const mean = sumY / n;
      const variance = yValues.reduce((sum, y) => sum + Math.pow(y - mean, 2), 0) / n;
      const stdDev = Math.sqrt(variance);

      const confidenceInterval = {
        lower: forecastData.map((d) => ({
          date: d.date,
          value: Math.max(0, d.value - 1.96 * stdDev),
        })),
        upper: forecastData.map((d) => ({
          date: d.date,
          value: d.value + 1.96 * stdDev,
        })),
      };

      // Identify seasonal patterns (simplified - weekly pattern)
      const dayOfWeekPattern: { [key: number]: number[] } = {};
      historicalData.forEach((d) => {
        const dayOfWeek = new Date(d.date).getDay();
        if (!dayOfWeekPattern[dayOfWeek]) {
          dayOfWeekPattern[dayOfWeek] = [];
        }
        dayOfWeekPattern[dayOfWeek].push(d.value);
      });

      const seasonalPatterns = Object.entries(dayOfWeekPattern).map(([day, values]) => ({
        dayOfWeek: parseInt(day),
        averageValue: values.reduce((a, b) => a + b, 0) / values.length,
        pattern: values.length > 1 ? "recurring" : "insufficient_data",
      }));

      // Calculate forecast accuracy (using MAPE on historical data)
      let mapeSum = 0;
      let mapeCount = 0;
      for (let i = 7; i < historicalData.length; i++) {
        const predicted = slope * i + intercept;
        const actual = historicalData[i].value;
        if (actual !== 0) {
          mapeSum += Math.abs((actual - predicted) / actual);
          mapeCount++;
        }
      }
      const forecastAccuracy = mapeCount > 0 ? (1 - mapeSum / mapeCount) * 100 : 0;

      // Trend line for visualization
      const trendLine = historicalData.map((d, i) => ({
        date: d.date,
        value: slope * i + intercept,
      }));

      return {
        forecastData,
        trendLine,
        confidenceInterval,
        forecastAccuracy: Math.max(0, Math.min(100, forecastAccuracy)),
        seasonalPatterns,
        historicalData,
      };
    } catch (error) {
      console.error("Error generating predictive analytics:", error);
      throw new HttpsError("internal", "Failed to generate predictive analytics");
    }
  }
);
