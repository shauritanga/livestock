import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:livestock/features/inventory/data/datasources/inventory_local_datasource.dart';
import 'package:livestock/features/inventory/data/datasources/inventory_remote_datasource.dart';
import 'package:livestock/features/inventory/data/models/product_model.dart';
import 'package:livestock/features/inventory/data/models/sale_transaction_model.dart';
import 'package:livestock/features/inventory/data/models/stock_transaction_model.dart';
import 'package:livestock/features/inventory/domain/entities/product.dart';
import 'package:livestock/features/inventory/domain/entities/product_category.dart';
import 'package:livestock/features/inventory/domain/entities/sale_transaction.dart';
import 'package:livestock/features/inventory/domain/entities/stock_transaction.dart';
import 'package:livestock/features/inventory/domain/entities/stock_transaction_type.dart';
import 'package:livestock/features/inventory/domain/repositories/inventory_repository.dart';

/// Implementation of InventoryRepository
class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryRemoteDataSource _remoteDataSource;
  final InventoryLocalDataSource _localDataSource;
  final Connectivity _connectivity;

  InventoryRepositoryImpl({
    required InventoryRemoteDataSource remoteDataSource,
    required InventoryLocalDataSource localDataSource,
    Connectivity? connectivity,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _connectivity = connectivity ?? Connectivity();

  /// Check if device is online
  Future<bool> _isOnline() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  @override
  Future<Product> createProduct(Product product) async {
    // Ensure product has cooperativeId
    if (product.cooperativeId.isEmpty) {
      throw Exception('Product must have a cooperativeId');
    }
    
    final productModel = ProductModel.fromEntity(product);

    if (await _isOnline()) {
      final created = await _remoteDataSource.createProduct(productModel);
      await _localDataSource.saveProduct(created);
      return created.toEntity();
    } else {
      await _localDataSource.saveProduct(productModel);
      await _localDataSource.queueTransaction(
        id: product.id,
        type: 'create_product',
        data: productModel.toJson(),
      );
      return product;
    }
  }

  @override
  Future<Product> updateProduct(Product product) async {
    final productModel = ProductModel.fromEntity(product);

    if (await _isOnline()) {
      final updated = await _remoteDataSource.updateProduct(productModel);
      await _localDataSource.saveProduct(updated);
      return updated.toEntity();
    } else {
      await _localDataSource.saveProduct(productModel);
      await _localDataSource.queueTransaction(
        id: product.id,
        type: 'update_product',
        data: productModel.toJson(),
      );
      return product;
    }
  }

  @override
  Future<Product?> getProductById(String id) async {
    if (await _isOnline()) {
      final product = await _remoteDataSource.getProductById(id);
      if (product != null) {
        await _localDataSource.saveProduct(product);
      }
      return product?.toEntity();
    } else {
      final product = await _localDataSource.getProductById(id);
      return product?.toEntity();
    }
  }

  /// Helper method to get cooperativeId from context
  /// In a real implementation, this should come from the authenticated user
  Future<String> _getCooperativeId() async {
    // TODO: Get cooperative ID from authenticated user's custom claims
    // For now, use the test cooperative
    return 'coop_test_001';
    
    // Original implementation (commented out for now):
    // final cachedProducts = await _localDataSource.getAllProducts(
    //   cooperativeId: '', // Empty to get any product
    //   activeOnly: false,
    // );
    // if (cachedProducts.isEmpty) {
    //   throw Exception('No cooperative context available. Please ensure user is authenticated.');
    // }
    // return cachedProducts.first.cooperativeId;
  }

  @override
  Future<List<Product>> getAllProducts({
    ProductCategory? category,
    bool? isLowStock,
    bool? isOutOfStock,
    bool activeOnly = true,
  }) async {
    final cooperativeId = await _getCooperativeId();
    
    if (await _isOnline()) {
      final products = await _remoteDataSource.getAllProducts(
        cooperativeId: cooperativeId,
        category: category,
        isLowStock: isLowStock,
        isOutOfStock: isOutOfStock,
        activeOnly: activeOnly,
      );
      await _localDataSource.saveProducts(products);
      return products.map((p) => p.toEntity()).toList();
    } else {
      final products = await _localDataSource.getAllProducts(
        cooperativeId: cooperativeId,
        category: category,
        activeOnly: activeOnly,
      );

      // Apply client-side filtering for stock status
      var filtered = products;
      if (isLowStock == true) {
        filtered = filtered.where((p) => p.isLowStock && !p.isOutOfStock).toList();
      }
      if (isOutOfStock == true) {
        filtered = filtered.where((p) => p.isOutOfStock).toList();
      }

      return filtered.map((p) => p.toEntity()).toList();
    }
  }

  @override
  Future<void> deactivateProduct(String id) async {
    if (await _isOnline()) {
      await _remoteDataSource.deactivateProduct(id);
      final product = await _localDataSource.getProductById(id);
      if (product != null) {
        await _localDataSource.saveProduct(
          product.copyWith(isActive: false, updatedAt: DateTime.now()),
        );
      }
    } else {
      await _localDataSource.queueTransaction(
        id: id,
        type: 'deactivate_product',
        data: {'id': id},
      );
    }
  }

  @override
  Future<StockTransaction> addStock({
    required String productId,
    required double quantity,
    String? reason,
    required String performedBy,
  }) async {
    // Get current product
    final product = await getProductById(productId);
    if (product == null) {
      throw Exception('Product not found');
    }

    final previousStock = product.currentStock;
    final newStock = previousStock + quantity;

    // Create stock transaction
    final transaction = StockTransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      cooperativeId: product.cooperativeId,
      productId: productId,
      type: StockTransactionType.addition,
      quantity: quantity,
      previousStock: previousStock,
      newStock: newStock,
      reason: reason,
      timestamp: DateTime.now(),
      performedBy: performedBy,
    );

    // Update product stock
    final updatedProduct = product.copyWith(
      currentStock: newStock,
      updatedAt: DateTime.now(),
    );

    if (await _isOnline()) {
      await _remoteDataSource.createStockTransaction(transaction);
      await _remoteDataSource.updateProduct(ProductModel.fromEntity(updatedProduct));
      await _localDataSource.saveProduct(ProductModel.fromEntity(updatedProduct));
    } else {
      await _localDataSource.updateProductStock(productId, newStock);
      await _localDataSource.queueTransaction(
        id: transaction.id,
        type: 'add_stock',
        data: transaction.toJson(),
      );
    }

    return transaction.toEntity();
  }

  @override
  Future<StockTransaction> adjustStock({
    required String productId,
    required double newStock,
    required String reason,
    required String performedBy,
  }) async {
    // Get current product
    final product = await getProductById(productId);
    if (product == null) {
      throw Exception('Product not found');
    }

    if (newStock < 0) {
      throw Exception('Stock cannot be negative');
    }

    final previousStock = product.currentStock;
    final quantity = (newStock - previousStock).abs();

    // Create stock transaction
    final transaction = StockTransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      cooperativeId: product.cooperativeId,
      productId: productId,
      type: StockTransactionType.adjustment,
      quantity: quantity,
      previousStock: previousStock,
      newStock: newStock,
      reason: reason,
      timestamp: DateTime.now(),
      performedBy: performedBy,
    );

    // Update product stock
    final updatedProduct = product.copyWith(
      currentStock: newStock,
      updatedAt: DateTime.now(),
    );

    if (await _isOnline()) {
      await _remoteDataSource.createStockTransaction(transaction);
      await _remoteDataSource.updateProduct(ProductModel.fromEntity(updatedProduct));
      await _localDataSource.saveProduct(ProductModel.fromEntity(updatedProduct));
    } else {
      await _localDataSource.updateProductStock(productId, newStock);
      await _localDataSource.queueTransaction(
        id: transaction.id,
        type: 'adjust_stock',
        data: transaction.toJson(),
      );
    }

    return transaction.toEntity();
  }

  @override
  Future<SaleTransaction> recordSale({
    required String productId,
    required double quantity,
    required double unitPrice,
    String? customerName,
    String? notes,
    required String processedBy,
  }) async {
    // Get current product
    final product = await getProductById(productId);
    if (product == null) {
      throw Exception('Product not found');
    }

    if (!product.isActive) {
      throw Exception('Product is not active');
    }

    if (quantity > product.currentStock) {
      throw Exception(
          'Insufficient stock. Only ${product.currentStock} ${product.unitOfMeasure} available.');
    }

    final previousStock = product.currentStock;
    final newStock = previousStock - quantity;
    final totalAmount = quantity * unitPrice;

    // Create sale transaction
    final saleTransaction = SaleTransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      cooperativeId: product.cooperativeId,
      productId: productId,
      productName: product.name,
      quantity: quantity,
      unitPrice: unitPrice,
      totalAmount: totalAmount,
      customerName: customerName,
      notes: notes,
      timestamp: DateTime.now(),
      processedBy: processedBy,
      isSynced: await _isOnline(),
    );

    // Create stock transaction
    final stockTransaction = StockTransactionModel(
      id: '${DateTime.now().millisecondsSinceEpoch}_stock',
      cooperativeId: product.cooperativeId,
      productId: productId,
      type: StockTransactionType.sale,
      quantity: quantity,
      previousStock: previousStock,
      newStock: newStock,
      reason: 'Sale transaction ${saleTransaction.id}',
      timestamp: DateTime.now(),
      performedBy: processedBy,
    );

    // Update product stock
    final updatedProduct = product.copyWith(
      currentStock: newStock,
      updatedAt: DateTime.now(),
    );

    if (await _isOnline()) {
      // Atomic transaction: create sale, create stock transaction, update product
      await _remoteDataSource.createSaleTransaction(saleTransaction);
      await _remoteDataSource.createStockTransaction(stockTransaction);
      await _remoteDataSource.updateProduct(ProductModel.fromEntity(updatedProduct));
      await _localDataSource.saveProduct(ProductModel.fromEntity(updatedProduct));
    } else {
      // Queue for offline sync
      await _localDataSource.updateProductStock(productId, newStock);
      await _localDataSource.queueTransaction(
        id: saleTransaction.id,
        type: 'record_sale',
        data: {
          'sale': saleTransaction.toJson(),
          'stock_transaction': stockTransaction.toJson(),
          'product_update': ProductModel.fromEntity(updatedProduct).toJson(),
        },
      );
    }

    return saleTransaction.toEntity();
  }

  @override
  Future<List<SaleTransaction>> getSales({
    DateTime? startDate,
    DateTime? endDate,
    String? productId,
  }) async {
    final cooperativeId = await _getCooperativeId();
    
    if (await _isOnline()) {
      final sales = await _remoteDataSource.getSales(
        cooperativeId: cooperativeId,
        startDate: startDate,
        endDate: endDate,
        productId: productId,
      );
      return sales.map((s) => s.toEntity()).toList();
    } else {
      // Return empty list for offline mode
      // In a full implementation, you might cache sales locally
      return [];
    }
  }

  @override
  Future<SaleTransaction?> getSaleById(String id) async {
    if (await _isOnline()) {
      final sale = await _remoteDataSource.getSaleById(id);
      return sale?.toEntity();
    } else {
      return null;
    }
  }

  @override
  Future<List<StockTransaction>> getStockTransactions({
    required String productId,
    StockTransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final cooperativeId = await _getCooperativeId();
    
    if (await _isOnline()) {
      final transactions = await _remoteDataSource.getStockTransactions(
        cooperativeId: cooperativeId,
        productId: productId,
        type: type,
        startDate: startDate,
        endDate: endDate,
      );
      return transactions.map((t) => t.toEntity()).toList();
    } else {
      return [];
    }
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    final cooperativeId = await _getCooperativeId();
    
    if (await _isOnline()) {
      final products = await _remoteDataSource.searchProducts(
        cooperativeId: cooperativeId,
        query: query,
      );
      return products.map((p) => p.toEntity()).toList();
    } else {
      final products = await _localDataSource.searchProducts(
        cooperativeId: cooperativeId,
        query: query,
      );
      return products.map((p) => p.toEntity()).toList();
    }
  }

  @override
  Future<List<Product>> getLowStockProducts() async {
    final cooperativeId = await _getCooperativeId();
    
    if (await _isOnline()) {
      final products = await _remoteDataSource.getLowStockProducts(
        cooperativeId: cooperativeId,
      );
      return products.map((p) => p.toEntity()).toList();
    } else {
      final products = await _localDataSource.getAllProducts(
        cooperativeId: cooperativeId,
        activeOnly: true,
      );
      final lowStock = products.where((p) => p.isLowStock).toList();
      return lowStock.map((p) => p.toEntity()).toList();
    }
  }

  @override
  Future<void> syncPendingTransactions() async {
    if (!await _isOnline()) {
      return;
    }

    final pendingTransactions = await _localDataSource.getPendingTransactions();

    for (final transaction in pendingTransactions) {
      try {
        final type = transaction['type'] as String;
        final data = transaction['data'] as Map<String, dynamic>;

        switch (type) {
          case 'create_product':
            await _remoteDataSource.createProduct(ProductModel.fromJson(data));
            break;
          case 'update_product':
            await _remoteDataSource.updateProduct(ProductModel.fromJson(data));
            break;
          case 'deactivate_product':
            await _remoteDataSource.deactivateProduct(data['id'] as String);
            break;
          case 'add_stock':
          case 'adjust_stock':
            await _remoteDataSource
                .createStockTransaction(StockTransactionModel.fromJson(data));
            break;
          case 'record_sale':
            await _remoteDataSource.createSaleTransaction(
                SaleTransactionModel.fromJson(data['sale'] as Map<String, dynamic>));
            await _remoteDataSource.createStockTransaction(
                StockTransactionModel.fromJson(
                    data['stock_transaction'] as Map<String, dynamic>));
            await _remoteDataSource.updateProduct(
                ProductModel.fromJson(data['product_update'] as Map<String, dynamic>));
            break;
        }

        await _localDataSource.removePendingTransaction(transaction['id'] as String);
      } catch (e) {
        // Increment retry count on failure
        await _localDataSource.incrementRetryCount(transaction['id'] as String);
      }
    }
  }

  @override
  Future<bool> hasPendingTransactions() async {
    return await _localDataSource.hasPendingTransactions();
  }
}
