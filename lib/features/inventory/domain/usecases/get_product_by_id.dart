import 'package:livestock/features/inventory/domain/entities/product.dart';
import 'package:livestock/features/inventory/domain/repositories/inventory_repository.dart';

/// Use case for fetching a single product by ID
class GetProductById {
  final InventoryRepository _repository;

  GetProductById(this._repository);

  Future<Product?> call({
    required String cooperativeId,
    required String id,
  }) async {
    // Validate cooperativeId
    if (cooperativeId.trim().isEmpty) {
      throw Exception('Cooperative ID is required');
    }

    // Validate product ID
    if (id.trim().isEmpty) {
      throw Exception('Product ID is required');
    }

    final product = await _repository.getProductById(id);
    
    // Validate product belongs to cooperative
    if (product != null && product.cooperativeId != cooperativeId) {
      return null; // Product doesn't belong to this cooperative
    }

    return product;
  }
}
