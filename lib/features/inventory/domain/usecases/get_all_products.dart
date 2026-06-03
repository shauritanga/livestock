import 'package:livestock/features/inventory/domain/entities/product.dart';
import 'package:livestock/features/inventory/domain/entities/product_category.dart';
import 'package:livestock/features/inventory/domain/repositories/inventory_repository.dart';

/// Use case for fetching all products with optional filtering
class GetAllProducts {
  final InventoryRepository _repository;

  GetAllProducts(this._repository);

  Future<List<Product>> call({
    required String cooperativeId,
    ProductCategory? category,
    bool? isLowStock,
    bool? isOutOfStock,
    bool activeOnly = true,
  }) async {
    // Validate cooperativeId
    if (cooperativeId.trim().isEmpty) {
      throw Exception('Cooperative ID is required');
    }

    // Get all products and filter by cooperativeId
    final allProducts = await _repository.getAllProducts(
      category: category,
      isLowStock: isLowStock,
      isOutOfStock: isOutOfStock,
      activeOnly: activeOnly,
    );

    // Filter by cooperativeId
    return allProducts.where((p) => p.cooperativeId == cooperativeId).toList();
  }
}
