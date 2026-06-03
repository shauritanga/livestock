import 'package:livestock/features/inventory/domain/entities/product.dart';
import 'package:livestock/features/inventory/domain/repositories/inventory_repository.dart';

/// Use case for updating an existing product
class UpdateProduct {
  final InventoryRepository _repository;

  UpdateProduct(this._repository);

  Future<Product> call({
    required Product product,
    required String cooperativeId,
  }) async {
    // Validate cooperativeId
    if (cooperativeId.trim().isEmpty) {
      throw Exception('Cooperative ID is required');
    }

    // Validate product data
    _validateProduct(product);

    // Check if product exists
    final existingProduct = await _repository.getProductById(product.id);
    if (existingProduct == null) {
      throw Exception('Product not found');
    }

    // Validate product belongs to cooperative
    if (existingProduct.cooperativeId != cooperativeId) {
      throw Exception('Product does not belong to your cooperative');
    }

    // Ensure cooperativeId cannot be changed
    if (product.cooperativeId != cooperativeId) {
      throw Exception('Cannot change product cooperative');
    }

    // Check SKU uniqueness within cooperative (if SKU changed)
    if (existingProduct.sku != product.sku) {
      final productsWithSku = await _repository.searchProducts(product.sku);
      final duplicateInCoop = productsWithSku.any(
        (p) => p.sku == product.sku && 
               p.cooperativeId == cooperativeId && 
               p.id != product.id
      );
      
      if (duplicateInCoop) {
        throw Exception('SKU already exists in your cooperative. Please use a unique SKU.');
      }
    }

    // Update product with new timestamp
    final updatedProduct = product.copyWith(updatedAt: DateTime.now());
    return await _repository.updateProduct(updatedProduct);
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

    // Validate current stock
    if (product.currentStock < 0) {
      throw Exception('Current stock cannot be negative');
    }
  }
}
