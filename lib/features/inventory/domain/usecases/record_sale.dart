import 'package:livestock/features/inventory/domain/entities/sale_transaction.dart';
import 'package:livestock/features/inventory/domain/repositories/inventory_repository.dart';

/// Use case for recording a product sale
class RecordSale {
  final InventoryRepository _repository;

  RecordSale(this._repository);

  Future<SaleTransaction> call({
    required String cooperativeId,
    required String productId,
    required double quantity,
    required double unitPrice,
    String? customerName,
    String? notes,
    required String processedBy,
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
    if (!product.isActive) {
      throw Exception('Product is not active');
    }

    // Validate quantity
    if (quantity <= 0) {
      throw Exception('Quantity must be a positive number');
    }

    // Validate stock availability
    if (quantity > product.currentStock) {
      throw Exception(
        'Insufficient stock. Only ${product.currentStock} ${product.unitOfMeasure} available.'
      );
    }

    // Validate unit price
    if (unitPrice <= 0) {
      throw Exception('Unit price must be a positive number');
    }

    // Validate customer name length if provided
    if (customerName != null && customerName.length > 100) {
      throw Exception('Customer name must not exceed 100 characters');
    }

    // Validate notes length if provided
    if (notes != null && notes.length > 500) {
      throw Exception('Notes must not exceed 500 characters');
    }

    // Validate processed by
    if (processedBy.trim().isEmpty) {
      throw Exception('User ID is required');
    }

    // Record sale (repository will update stock)
    return await _repository.recordSale(
      productId: productId,
      quantity: quantity,
      unitPrice: unitPrice,
      customerName: customerName,
      notes: notes,
      processedBy: processedBy,
    );
  }
}
