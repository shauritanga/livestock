import 'package:livestock/features/inventory/domain/entities/product.dart';
import 'package:livestock/features/inventory/domain/repositories/inventory_repository.dart';

/// Use case for searching products by name or SKU
class SearchProducts {
  final InventoryRepository _repository;

  SearchProducts(this._repository);

  Future<List<Product>> call({
    required String cooperativeId,
    required String query,
  }) async {
    // Validate cooperativeId
    if (cooperativeId.trim().isEmpty) {
      throw Exception('Cooperative ID is required');
    }

    // Validate query
    if (query.trim().isEmpty) {
      return [];
    }

    // Search products and filter by cooperativeId
    final allProducts = await _repository.searchProducts(query.trim());
    return allProducts.where((p) => p.cooperativeId == cooperativeId).toList();
  }
}
