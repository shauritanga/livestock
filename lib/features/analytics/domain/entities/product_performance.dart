import 'package:equatable/equatable.dart';

/// Performance metrics for a single product
class ProductPerformance extends Equatable {
  final String productId;
  final String productName;
  final double totalSales;
  final double revenue;
  final int salesCount;
  final double averagePrice;
  final int rank;

  const ProductPerformance({
    required this.productId,
    required this.productName,
    required this.totalSales,
    required this.revenue,
    required this.salesCount,
    required this.averagePrice,
    required this.rank,
  });

  /// Average quantity per sale
  double get averageQuantityPerSale =>
      salesCount > 0 ? totalSales / salesCount : 0;

  /// Revenue per unit sold
  double get revenuePerUnit => totalSales > 0 ? revenue / totalSales : 0;

  @override
  List<Object?> get props => [
        productId,
        productName,
        totalSales,
        revenue,
        salesCount,
        averagePrice,
        rank,
      ];

  ProductPerformance copyWith({
    String? productId,
    String? productName,
    double? totalSales,
    double? revenue,
    int? salesCount,
    double? averagePrice,
    int? rank,
  }) {
    return ProductPerformance(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      totalSales: totalSales ?? this.totalSales,
      revenue: revenue ?? this.revenue,
      salesCount: salesCount ?? this.salesCount,
      averagePrice: averagePrice ?? this.averagePrice,
      rank: rank ?? this.rank,
    );
  }
}
