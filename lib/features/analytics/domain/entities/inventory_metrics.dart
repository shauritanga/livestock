import 'package:equatable/equatable.dart';
import 'package:livestock/features/analytics/domain/entities/product_performance.dart';
import 'package:livestock/features/analytics/domain/entities/category_metrics.dart';
import 'package:livestock/features/analytics/domain/entities/time_series_data_point.dart';
import 'package:livestock/features/inventory/domain/entities/product_category.dart';

/// Comprehensive inventory and sales analytics
class InventoryMetrics extends Equatable {
  final double totalInventoryValue;
  final int totalProducts;
  final int lowStockProducts;
  final int outOfStockProducts;
  final double totalSalesRevenue;
  final List<ProductPerformance> topSellingProducts;
  final Map<ProductCategory, CategoryMetrics> categoryBreakdown;
  final List<TimeSeriesDataPoint> salesTrend;
  final Map<ProductCategory, double> stockTurnoverRates;

  const InventoryMetrics({
    required this.totalInventoryValue,
    required this.totalProducts,
    required this.lowStockProducts,
    required this.outOfStockProducts,
    required this.totalSalesRevenue,
    required this.topSellingProducts,
    required this.categoryBreakdown,
    required this.salesTrend,
    required this.stockTurnoverRates,
  });

  /// Products in good stock (not low or out of stock)
  int get productsInGoodStock =>
      totalProducts - lowStockProducts - outOfStockProducts;

  /// Low stock percentage
  double get lowStockPercentage =>
      totalProducts > 0 ? (lowStockProducts / totalProducts) * 100 : 0;

  /// Out of stock percentage
  double get outOfStockPercentage =>
      totalProducts > 0 ? (outOfStockProducts / totalProducts) * 100 : 0;

  /// Stock health percentage (products in good stock)
  double get stockHealthPercentage =>
      totalProducts > 0 ? (productsInGoodStock / totalProducts) * 100 : 0;

  /// Average inventory value per product
  double get averageInventoryValuePerProduct =>
      totalProducts > 0 ? totalInventoryValue / totalProducts : 0;

  /// Average sales revenue per product
  double get averageSalesRevenuePerProduct =>
      totalProducts > 0 ? totalSalesRevenue / totalProducts : 0;

  /// Overall stock turnover rate (weighted average)
  double get overallStockTurnoverRate {
    if (stockTurnoverRates.isEmpty) return 0;

    double totalTurnover = 0;
    int count = 0;

    stockTurnoverRates.forEach((category, rate) {
      totalTurnover += rate;
      count++;
    });

    return count > 0 ? totalTurnover / count : 0;
  }

  /// Best performing category by sales
  ProductCategory? get bestPerformingCategory {
    if (categoryBreakdown.isEmpty) return null;

    ProductCategory? best;
    double maxSales = 0;

    categoryBreakdown.forEach((category, metrics) {
      if (metrics.totalSales > maxSales) {
        maxSales = metrics.totalSales;
        best = category;
      }
    });

    return best;
  }

  /// Inventory health status
  String get inventoryHealthStatus {
    if (stockHealthPercentage >= 80 && outOfStockPercentage < 5) {
      return 'Excellent';
    } else if (stockHealthPercentage >= 60 && outOfStockPercentage < 10) {
      return 'Good';
    } else if (stockHealthPercentage >= 40) {
      return 'Fair';
    }
    return 'Poor';
  }

  /// Get top N selling products
  List<ProductPerformance> getTopProducts(int n) {
    return topSellingProducts.take(n).toList();
  }

  @override
  List<Object?> get props => [
        totalInventoryValue,
        totalProducts,
        lowStockProducts,
        outOfStockProducts,
        totalSalesRevenue,
        topSellingProducts,
        categoryBreakdown,
        salesTrend,
        stockTurnoverRates,
      ];

  InventoryMetrics copyWith({
    double? totalInventoryValue,
    int? totalProducts,
    int? lowStockProducts,
    int? outOfStockProducts,
    double? totalSalesRevenue,
    List<ProductPerformance>? topSellingProducts,
    Map<ProductCategory, CategoryMetrics>? categoryBreakdown,
    List<TimeSeriesDataPoint>? salesTrend,
    Map<ProductCategory, double>? stockTurnoverRates,
  }) {
    return InventoryMetrics(
      totalInventoryValue: totalInventoryValue ?? this.totalInventoryValue,
      totalProducts: totalProducts ?? this.totalProducts,
      lowStockProducts: lowStockProducts ?? this.lowStockProducts,
      outOfStockProducts: outOfStockProducts ?? this.outOfStockProducts,
      totalSalesRevenue: totalSalesRevenue ?? this.totalSalesRevenue,
      topSellingProducts: topSellingProducts ?? this.topSellingProducts,
      categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
      salesTrend: salesTrend ?? this.salesTrend,
      stockTurnoverRates: stockTurnoverRates ?? this.stockTurnoverRates,
    );
  }
}
