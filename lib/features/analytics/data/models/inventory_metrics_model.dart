import '../../domain/entities/inventory_metrics.dart';
import '../../domain/entities/product_performance.dart';
import '../../domain/entities/category_metrics.dart';
import '../../domain/entities/time_series_data_point.dart';
import '../../../inventory/domain/entities/product_category.dart';

class InventoryMetricsModel extends InventoryMetrics {
  const InventoryMetricsModel({
    required super.totalInventoryValue,
    required super.totalProducts,
    required super.lowStockProducts,
    required super.outOfStockProducts,
    required super.totalSalesRevenue,
    required super.topSellingProducts,
    required super.categoryBreakdown,
    required super.salesTrend,
    required super.stockTurnoverRates,
  });

  factory InventoryMetricsModel.fromJson(Map<String, dynamic> json) {
    return InventoryMetricsModel(
      totalInventoryValue: (json['totalInventoryValue'] as num).toDouble(),
      totalProducts: json['totalProducts'] as int,
      lowStockProducts: json['lowStockProducts'] as int,
      outOfStockProducts: json['outOfStockProducts'] as int,
      totalSalesRevenue: (json['totalSalesRevenue'] as num).toDouble(),
      topSellingProducts: (json['topSellingProducts'] as List)
          .map((e) => ProductPerformance(
                productId: e['productId'] as String,
                productName: e['productName'] as String,
                totalSales: (e['totalSales'] as num).toDouble(),
                revenue: (e['revenue'] as num).toDouble(),
                salesCount: e['salesCount'] as int,
                averagePrice: (e['averagePrice'] as num).toDouble(),
                rank: e['rank'] as int,
              ))
          .toList(),
      categoryBreakdown: Map<ProductCategory, CategoryMetrics>.fromEntries(
        (json['categoryBreakdown'] as Map).entries.map(
          (entry) => MapEntry(
            ProductCategory.values.firstWhere((e) => e.name == entry.key),
            CategoryMetrics(
              category: ProductCategory.values.firstWhere((e) => e.name == entry.value['category']),
              totalProducts: entry.value['totalProducts'] as int,
              totalValue: (entry.value['totalValue'] as num).toDouble(),
              totalSales: (entry.value['totalSales'] as num).toDouble(),
              stockTurnoverRate: (entry.value['stockTurnoverRate'] as num).toDouble(),
              percentageOfTotalSales: (entry.value['percentageOfTotalSales'] as num).toDouble(),
            ),
          ),
        ),
      ),
      salesTrend: (json['salesTrend'] as List)
          .map((e) => TimeSeriesDataPoint(
                date: DateTime.parse(e['date'] as String),
                value: (e['value'] as num).toDouble(),
              ))
          .toList(),
      stockTurnoverRates: Map<ProductCategory, double>.fromEntries(
        (json['stockTurnoverRates'] as Map).entries.map(
          (entry) => MapEntry(
            ProductCategory.values.firstWhere((e) => e.name == entry.key),
            (entry.value as num).toDouble(),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalInventoryValue': totalInventoryValue,
      'totalProducts': totalProducts,
      'lowStockProducts': lowStockProducts,
      'outOfStockProducts': outOfStockProducts,
      'totalSalesRevenue': totalSalesRevenue,
      'topSellingProducts': topSellingProducts
          .map((e) => {
                'productId': e.productId,
                'productName': e.productName,
                'totalSales': e.totalSales,
                'revenue': e.revenue,
                'salesCount': e.salesCount,
                'averagePrice': e.averagePrice,
                'rank': e.rank,
              })
          .toList(),
      'categoryBreakdown': categoryBreakdown.map(
        (key, value) => MapEntry(
          key.name,
          {
            'category': value.category.name,
            'totalProducts': value.totalProducts,
            'totalValue': value.totalValue,
            'totalSales': value.totalSales,
            'stockTurnoverRate': value.stockTurnoverRate,
            'percentageOfTotalSales': value.percentageOfTotalSales,
          },
        ),
      ),
      'salesTrend': salesTrend
          .map((e) => {
                'date': e.date.toIso8601String(),
                'value': e.value,
              })
          .toList(),
      'stockTurnoverRates': stockTurnoverRates.map((key, value) => MapEntry(key.name, value)),
    };
  }
}
