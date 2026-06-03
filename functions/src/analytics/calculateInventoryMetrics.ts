import * as admin from "firebase-admin";
import {onCall, HttpsError} from "firebase-functions/v2/https";

/**
 * Cloud Function to calculate inventory metrics
 * Task 29.5: Create calculateInventoryMetrics Cloud Function
 */
export const calculateInventoryMetrics = onCall(
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
      const products: any[] = [];
      const sales: any[] = [];

      // Query products and sales from cooperatives
      const cooperativesSnapshot = await db.collection("cooperatives").get();

      for (const coopDoc of cooperativesSnapshot.docs) {
        // Filter by cooperativeIds if provided
        if (cooperativeIds && cooperativeIds.length > 0) {
          if (!cooperativeIds.includes(coopDoc.id)) continue;
        }

        // Get products (assuming they're at cooperative level)
        const productsSnapshot = await coopDoc.ref.collection("products").get();
        products.push(...productsSnapshot.docs.map((doc) => ({
          id: doc.id,
          ...doc.data(),
        } as any)));

        // Get sales transactions
        let salesQuery = coopDoc.ref.collection("sales_transactions") as admin.firestore.Query;

        if (startDate) {
          salesQuery = salesQuery.where(
            "timestamp",
            ">=",
            admin.firestore.Timestamp.fromDate(new Date(startDate))
          );
        }
        if (endDate) {
          salesQuery = salesQuery.where(
            "timestamp",
            "<=",
            admin.firestore.Timestamp.fromDate(new Date(endDate))
          );
        }

        const salesSnapshot = await salesQuery.get();
        sales.push(...salesSnapshot.docs.map((doc) => doc.data()));
      }

      const totalInventoryValue = products.reduce(
        (sum, p) => sum + ((p.quantity || 0) * (p.price || 0)),
        0
      );

      const totalProducts = products.length;
      const lowStockProducts = products.filter(
        (p) => (p.quantity || 0) <= (p.reorderPoint || 0)
      ).length;
      const outOfStockProducts = products.filter((p) => (p.quantity || 0) === 0).length;

      // Sales transactions (already fetched above)

      const totalSalesRevenue = sales.reduce((sum, s) => sum + (s.totalAmount || 0), 0);

      // Top selling products
      const productSales = new Map<string, {
        productId: string;
        productName: string;
        totalSales: number;
        revenue: number;
        salesCount: number;
      }>();

      sales.forEach((sale) => {
        if (sale.items && Array.isArray(sale.items)) {
          sale.items.forEach((item: any) => {
            const productId = item.productId || "unknown";
            if (!productSales.has(productId)) {
              productSales.set(productId, {
                productId,
                productName: item.productName || "Unknown Product",
                totalSales: 0,
                revenue: 0,
                salesCount: 0,
              });
            }
            const productData = productSales.get(productId)!;
            productData.totalSales += item.quantity || 0;
            productData.revenue += (item.quantity || 0) * (item.price || 0);
            productData.salesCount++;
          });
        }
      });

      const topSellingProducts = Array.from(productSales.values())
        .sort((a, b) => b.revenue - a.revenue)
        .slice(0, 10)
        .map((p, index) => ({
          ...p,
          rank: index + 1,
          averagePrice: p.totalSales > 0 ? p.revenue / p.totalSales : 0,
        }));

      // Category breakdown
      const categoryBreakdown: { [category: string]: {
        totalProducts: number;
        totalValue: number;
        totalSales: number;
      }} = {};

      products.forEach((p) => {
        const category = p.category || "Uncategorized";
        if (!categoryBreakdown[category]) {
          categoryBreakdown[category] = {
            totalProducts: 0,
            totalValue: 0,
            totalSales: 0,
          };
        }
        categoryBreakdown[category].totalProducts++;
        categoryBreakdown[category].totalValue += (p.quantity || 0) * (p.price || 0);
      });

      // Add sales to categories
      sales.forEach((sale) => {
        if (sale.items && Array.isArray(sale.items)) {
          sale.items.forEach((item: any) => {
            const category = item.category || "Uncategorized";
            if (!categoryBreakdown[category]) {
              categoryBreakdown[category] = {
                totalProducts: 0,
                totalValue: 0,
                totalSales: 0,
              };
            }
            categoryBreakdown[category].totalSales += (item.quantity || 0) * (item.price || 0);
          });
        }
      });

      // Sales trend
      const salesTrend: Array<{ date: string; value: number }> = [];
      const dailySales = new Map<string, number>();

      sales.forEach((sale) => {
        const date = sale.timestamp?.toDate ?
          sale.timestamp.toDate().toISOString().split("T")[0] :
          new Date(sale.timestamp).toISOString().split("T")[0];
        dailySales.set(date, (dailySales.get(date) || 0) + (sale.totalAmount || 0));
      });

      Array.from(dailySales.entries())
        .sort((a, b) => a[0].localeCompare(b[0]))
        .forEach(([date, value]) => {
          salesTrend.push({date, value});
        });

      // Stock turnover rates (simplified calculation)
      const stockTurnoverRates: { [category: string]: number } = {};
      Object.entries(categoryBreakdown).forEach(([category, data]) => {
        if (data.totalValue > 0) {
          stockTurnoverRates[category] = data.totalSales / data.totalValue;
        } else {
          stockTurnoverRates[category] = 0;
        }
      });

      return {
        totalInventoryValue,
        totalProducts,
        lowStockProducts,
        outOfStockProducts,
        totalSalesRevenue,
        topSellingProducts,
        categoryBreakdown,
        salesTrend,
        stockTurnoverRates,
      };
    } catch (error) {
      console.error("Error calculating inventory metrics:", error);
      throw new HttpsError("internal", "Failed to calculate inventory metrics");
    }
  }
);
