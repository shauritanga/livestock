import 'package:livestock/features/inventory/domain/entities/product.dart';
import 'package:livestock/features/inventory/domain/entities/product_category.dart';
import 'package:livestock/features/inventory/domain/entities/sale_transaction.dart';
import 'package:livestock/features/inventory/domain/entities/stock_transaction.dart';
import 'package:livestock/features/inventory/domain/entities/stock_transaction_type.dart';

/// Repository interface for inventory management
abstract class InventoryRepository {
  // Product CRUD operations
  Future<Product> createProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<Product?> getProductById(String id);
  Future<List<Product>> getAllProducts({
    ProductCategory? category,
    bool? isLowStock,
    bool? isOutOfStock,
    bool activeOnly = true,
  });
  Future<void> deactivateProduct(String id);

  // Stock management
  Future<StockTransaction> addStock({
    required String productId,
    required double quantity,
    String? reason,
    required String performedBy,
  });

  Future<StockTransaction> adjustStock({
    required String productId,
    required double newStock,
    required String reason,
    required String performedBy,
  });

  // Sales operations
  Future<SaleTransaction> recordSale({
    required String productId,
    required double quantity,
    required double unitPrice,
    String? customerName,
    String? notes,
    required String processedBy,
  });

  Future<List<SaleTransaction>> getSales({
    DateTime? startDate,
    DateTime? endDate,
    String? productId,
  });

  Future<SaleTransaction?> getSaleById(String id);

  // Transaction history
  Future<List<StockTransaction>> getStockTransactions({
    required String productId,
    StockTransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
  });

  // Search and filtering
  Future<List<Product>> searchProducts(String query);
  Future<List<Product>> getLowStockProducts();

  // Sync operations
  Future<void> syncPendingTransactions();
  Future<bool> hasPendingTransactions();
}
