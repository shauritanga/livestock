import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livestock/features/inventory/data/models/product_model.dart';
import 'package:livestock/features/inventory/data/models/sale_transaction_model.dart';
import 'package:livestock/features/inventory/data/models/stock_transaction_model.dart';
import 'package:livestock/features/inventory/domain/entities/product_category.dart';
import 'package:livestock/features/inventory/domain/entities/stock_transaction_type.dart';

/// Remote data source for inventory operations using Firestore
class InventoryRemoteDataSource {
  final FirebaseFirestore _firestore;

  // Collection references
  static const String productsCollection = 'products';
  static const String stockTransactionsCollection = 'stock_transactions';
  static const String saleTransactionsCollection = 'sale_transactions';

  InventoryRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Product CRUD operations
  Future<ProductModel> createProduct(ProductModel product) async {
    await _firestore
        .collection(productsCollection)
        .doc(product.id)
        .set(product.toJson());
    return product;
  }

  Future<ProductModel> updateProduct(ProductModel product) async {
    await _firestore
        .collection(productsCollection)
        .doc(product.id)
        .update(product.toJson());
    return product;
  }

  Future<ProductModel?> getProductById(String id) async {
    final doc =
        await _firestore.collection(productsCollection).doc(id).get();

    if (!doc.exists) return null;

    return ProductModel.fromJson(doc.data()!);
  }

  Future<List<ProductModel>> getAllProducts({
    required String cooperativeId,
    ProductCategory? category,
    bool? isLowStock,
    bool? isOutOfStock,
    bool activeOnly = true,
  }) async {
    Query query = _firestore
        .collection(productsCollection)
        .where('cooperativeId', isEqualTo: cooperativeId);

    // Filter by active status
    if (activeOnly) {
      query = query.where('isActive', isEqualTo: true);
    }

    // Filter by category
    if (category != null) {
      query = query.where('category', isEqualTo: category.name);
    }

    final snapshot = await query.get();
    final products = snapshot.docs
        .map((doc) => ProductModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();

    // Apply client-side filtering for stock status
    if (isLowStock == true) {
      return products.where((p) => p.isLowStock && !p.isOutOfStock).toList();
    }

    if (isOutOfStock == true) {
      return products.where((p) => p.isOutOfStock).toList();
    }

    return products;
  }

  Future<void> deactivateProduct(String id) async {
    await _firestore.collection(productsCollection).doc(id).update({
      'isActive': false,
      'updatedAt': Timestamp.now(),
    });
  }

  // Stock transaction operations
  Future<StockTransactionModel> createStockTransaction(
      StockTransactionModel transaction) async {
    await _firestore
        .collection(stockTransactionsCollection)
        .doc(transaction.id)
        .set(transaction.toJson());
    return transaction;
  }

  Future<List<StockTransactionModel>> getStockTransactions({
    required String cooperativeId,
    required String productId,
    StockTransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Query query = _firestore
        .collection(stockTransactionsCollection)
        .where('cooperativeId', isEqualTo: cooperativeId)
        .where('productId', isEqualTo: productId)
        .orderBy('timestamp', descending: true);

    if (type != null) {
      query = query.where('type', isEqualTo: type.name);
    }

    if (startDate != null) {
      query = query.where('timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }

    if (endDate != null) {
      query = query.where('timestamp',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) =>
            StockTransactionModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Sale transaction operations
  Future<SaleTransactionModel> createSaleTransaction(
      SaleTransactionModel transaction) async {
    await _firestore
        .collection(saleTransactionsCollection)
        .doc(transaction.id)
        .set(transaction.toJson());
    return transaction;
  }

  Future<SaleTransactionModel?> getSaleById(String id) async {
    final doc = await _firestore
        .collection(saleTransactionsCollection)
        .doc(id)
        .get();

    if (!doc.exists) return null;

    return SaleTransactionModel.fromJson(doc.data()!);
  }

  Future<List<SaleTransactionModel>> getSales({
    required String cooperativeId,
    DateTime? startDate,
    DateTime? endDate,
    String? productId,
  }) async {
    Query query = _firestore
        .collection(saleTransactionsCollection)
        .where('cooperativeId', isEqualTo: cooperativeId)
        .orderBy('timestamp', descending: true);

    if (productId != null) {
      query = query.where('productId', isEqualTo: productId);
    }

    if (startDate != null) {
      query = query.where('timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }

    if (endDate != null) {
      query = query.where('timestamp',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) =>
            SaleTransactionModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Search operations
  Future<List<ProductModel>> searchProducts({
    required String cooperativeId,
    required String query,
  }) async {
    final snapshot = await _firestore
        .collection(productsCollection)
        .where('cooperativeId', isEqualTo: cooperativeId)
        .where('isActive', isEqualTo: true)
        .get();

    final products = snapshot.docs
        .map((doc) => ProductModel.fromJson(doc.data()))
        .toList();

    // Client-side filtering for name and SKU
    final lowerQuery = query.toLowerCase();
    return products
        .where((product) =>
            product.name.toLowerCase().contains(lowerQuery) ||
            product.sku.toLowerCase().contains(lowerQuery))
        .toList();
  }

  Future<List<ProductModel>> getLowStockProducts({
    required String cooperativeId,
  }) async {
    final snapshot = await _firestore
        .collection(productsCollection)
        .where('cooperativeId', isEqualTo: cooperativeId)
        .where('isActive', isEqualTo: true)
        .get();

    final products = snapshot.docs
        .map((doc) => ProductModel.fromJson(doc.data()))
        .toList();

    // Client-side filtering for low stock
    return products.where((product) => product.isLowStock).toList();
  }
}
