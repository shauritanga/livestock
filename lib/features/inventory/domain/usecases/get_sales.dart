import 'package:livestock/features/inventory/domain/entities/sale_transaction.dart';
import 'package:livestock/features/inventory/domain/repositories/inventory_repository.dart';

/// Use case for fetching sales transactions with optional filtering
class GetSales {
  final InventoryRepository _repository;

  GetSales(this._repository);

  Future<SalesSummary> call({
    required String cooperativeId,
    DateTime? startDate,
    DateTime? endDate,
    String? productId,
  }) async {
    // Validate cooperativeId
    if (cooperativeId.trim().isEmpty) {
      throw Exception('Cooperative ID is required');
    }

    // Validate date range
    if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
      throw Exception('Start date must be before end date');
    }

    // Fetch sales
    final allSales = await _repository.getSales(
      startDate: startDate,
      endDate: endDate,
      productId: productId,
    );

    // Filter by cooperativeId
    final sales = allSales.where((s) => s.cooperativeId == cooperativeId).toList();

    // Calculate summary statistics for cooperative only
    final totalRevenue = sales.fold<double>(
      0,
      (sum, sale) => sum + sale.totalAmount,
    );

    final totalCount = sales.length;

    return SalesSummary(
      sales: sales,
      totalRevenue: totalRevenue,
      totalCount: totalCount,
    );
  }
}

/// Sales summary with statistics
class SalesSummary {
  final List<SaleTransaction> sales;
  final double totalRevenue;
  final int totalCount;

  SalesSummary({
    required this.sales,
    required this.totalRevenue,
    required this.totalCount,
  });
}
