import 'package:livestock/features/inventory/domain/entities/stock_transaction.dart';
import 'package:livestock/features/inventory/domain/repositories/inventory_repository.dart';

/// Use case for adding stock to a product
class AddStock {
  final InventoryRepository _repository;

  AddStock(this._repository);

  Future<StockTransaction> call({
    required String cooperativeId,
    required String productId,
    required double quantity,
    String? reason,
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

    // Validate quantity
    if (quantity <= 0) {
      throw Exception('Quantity must be a positive number');
    }

    // Validate performed by
    if (performedBy.trim().isEmpty) {
      throw Exception('User ID is required');
    }

    // Add stock
    return await _repository.addStock(
      productId: productId,
      quantity: quantity,
      reason: reason,
      performedBy: performedBy,
    );
  }
}
