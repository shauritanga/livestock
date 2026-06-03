import 'package:livestock/features/inventory/domain/entities/stock_transaction.dart';
import 'package:livestock/features/inventory/domain/entities/stock_transaction_type.dart';
import 'package:livestock/features/inventory/domain/repositories/inventory_repository.dart';

/// Use case for fetching stock transaction history
class GetStockTransactions {
  final InventoryRepository _repository;

  GetStockTransactions(this._repository);

  Future<List<StockTransaction>> call({
    required String cooperativeId,
    required String productId,
    StockTransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Validate cooperativeId
    if (cooperativeId.trim().isEmpty) {
      throw Exception('Cooperative ID is required');
    }

    // Validate product ID
    if (productId.trim().isEmpty) {
      throw Exception('Product ID is required');
    }

    // Validate date range
    if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
      throw Exception('Start date must be before end date');
    }

    // Get transactions and filter by cooperativeId
    final allTransactions = await _repository.getStockTransactions(
      productId: productId,
      type: type,
      startDate: startDate,
      endDate: endDate,
    );

    return allTransactions.where((t) => t.cooperativeId == cooperativeId).toList();
  }
}
