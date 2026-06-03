import 'package:livestock/features/inventory/domain/entities/stock_transaction.dart';
import 'package:livestock/features/inventory/domain/repositories/inventory_repository.dart';

/// Use case for adjusting stock to a specific level
class AdjustStock {
  final InventoryRepository _repository;

  AdjustStock(this._repository);

  Future<StockTransaction> call({
    required String cooperativeId,
    required String productId,
    required double newStock,
    required String reason,
    required String performedBy,
  }) async {
    // Validate cooperativeId
    if (cooperativeId.trim().isEmpty) {
      throw Exception('Cooperative ID is required');
    }

    // Validate product ID
    if (productId.trim().isEmpty) {
      throw Exception('Product ID is required');
    }

    // Validate product belongs to cooperative
    final product = await _repository.getProductById(productId);
    if (product == null) {
      throw Exception('Product not found');
    }
    if (product.cooperativeId != cooperativeId) {
      throw Exception('Product does not belong to your cooperative');
    }

    // Validate new stock level
    if (newStock < 0) {
      throw Exception('Stock level cannot be negative');
    }

    // Validate reason (required for adjustments)
    if (reason.trim().isEmpty) {
      throw Exception('Reason is required for stock adjustments');
    }

    if (reason.length > 500) {
      throw Exception('Reason must not exceed 500 characters');
    }

    // Validate performed by
    if (performedBy.trim().isEmpty) {
      throw Exception('User ID is required');
    }

    // Adjust stock
    return await _repository.adjustStock(
      productId: productId,
      newStock: newStock,
      reason: reason,
      performedBy: performedBy,
    );
  }
}
