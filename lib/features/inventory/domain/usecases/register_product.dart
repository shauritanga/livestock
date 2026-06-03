import 'package:livestock/features/inventory/domain/entities/product.dart';
import 'package:livestock/features/inventory/domain/repositories/inventory_repository.dart';

/// Use case for registering a new product
class RegisterProduct {
  final InventoryRepository _repository;

  RegisterProduct(this._repository);

  Future<Product> call({
    required Product product,
    required String cooperativeId,
  }) async {
    // Validate cooperativeId
    if (cooperativeId.trim().isEmpty) {
      throw Exception('Cooperative ID is required');
    }

    // Ensure product has cooperativeId set
    final productWithCoopId = product.copyWith(cooperativeId: cooperativeId);

    // Validate product data
    _validateProduct(productWithCoopId);

    // Check SKU uniqueness within cooperative
    final existingProducts = await _repository.searchProducts(productWithCoopId.sku);
    final duplicateInCoop = existingProducts.any(
      (p) => p.sku == productWithCoopId.sku && 
             p.cooperativeId == cooperativeId && 
             p.id != productWithCoopId.id
    );
    
    if (duplicateInCoop) {
      throw Exception('SKU already exists in your cooperative. Please use a unique SKU.');
    }

    // Create product
    return await _repository.createProduct(productWithCoopId);
  }

  void _validateProduct(Product product) {
    // Validate name
    if (product.name.trim().isEmpty) {
      throw Exception('Product name is required');
    }
    if (product.name.length < 2 || product.name.length > 100) {
      throw Exception('Product name must be between 2 and 100 characters');
    }

    // Validate SKU
    if (product.sku.trim().isEmpty) {
      throw Exception('SKU is required');
    }
    if (!RegExp(r'^[a-zA-Z0-9-_]+$').hasMatch(product.sku)) {
      throw Exception('SKU must contain only alphanumeric characters, hyphens, and underscores');
    }

    // Validate unit price
    if (product.unitPrice <= 0) {
      throw Exception('Unit price must be a positive number');
    }

    // Validate reorder point
    if (product.reorderPoint < 0) {
      throw Exception('Reorder point cannot be negative');
    }

    // Validate initial stock
    if (product.currentStock < 0) {
      throw Exception('Initial stock cannot be negative');
    }
  }
}
