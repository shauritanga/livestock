import 'package:equatable/equatable.dart';
import 'package:livestock/features/inventory/domain/entities/product_category.dart';

/// Metrics for a product category
class CategoryMetrics extends Equatable {
  final ProductCategory category;
  final int totalProducts;
  final double totalValue;
  final double totalSales;
  final double stockTurnoverRate;
  final double percentageOfTotalSales;

  const CategoryMetrics({
    required this.category,
    required this.totalProducts,
    required this.totalValue,
    required this.totalSales,
    required this.stockTurnoverRate,
    required this.percentageOfTotalSales,
  });

  /// Average value per product
  double get averageValuePerProduct =>
      totalProducts > 0 ? totalValue / totalProducts : 0;

  /// Sales per product
  double get salesPerProduct =>
      totalProducts > 0 ? totalSales / totalProducts : 0;

  /// Turnover status
  String get turnoverStatus {
    if (stockTurnoverRate >= 12) return 'Excellent'; // Monthly turnover
    if (stockTurnoverRate >= 6) return 'Good'; // Bi-monthly
    if (stockTurnoverRate >= 3) return 'Fair'; // Quarterly
    return 'Slow';
  }

  @override
  List<Object?> get props => [
        category,
        totalProducts,
        totalValue,
        totalSales,
        stockTurnoverRate,
        percentageOfTotalSales,
      ];

  CategoryMetrics copyWith({
    ProductCategory? category,
    int? totalProducts,
    double? totalValue,
    double? totalSales,
    double? stockTurnoverRate,
    double? percentageOfTotalSales,
  }) {
    return CategoryMetrics(
      category: category ?? this.category,
      totalProducts: totalProducts ?? this.totalProducts,
      totalValue: totalValue ?? this.totalValue,
      totalSales: totalSales ?? this.totalSales,
      stockTurnoverRate: stockTurnoverRate ?? this.stockTurnoverRate,
      percentageOfTotalSales:
          percentageOfTotalSales ?? this.percentageOfTotalSales,
    );
  }
}
