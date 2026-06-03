import 'package:livestock/features/inventory/domain/entities/product.dart';
import 'package:livestock/features/inventory/domain/repositories/inventory_repository.dart';

/// Use case for fetching products with low stock
class GetLowStockProducts {
  final InventoryRepository _repository;

  GetLowStockProducts(this._repository);

  Future<List<Product>> call({required String cooperativeId}) async {
    // Validate cooperativeId
    if (cooperativeId.trim().isEmpty) {
      throw Exception('Cooperative ID is required');
    }

    // Get low stock products and filter by cooperativeId
    final lowStockProducts = await _repository.getLowStockProducts();
    return lowStockProducts.where((p) => p.cooperativeId == cooperativeId).toList();
  }
}
