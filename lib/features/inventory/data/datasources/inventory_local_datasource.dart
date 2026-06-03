import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:livestock/features/inventory/data/models/product_model.dart';
import 'package:livestock/features/inventory/domain/entities/product_category.dart';

/// Local data source for offline inventory operations using SQLite
class InventoryLocalDataSource {
  final Database _database;

  // Table names
  static const String productsTable = 'products';
  static const String pendingTransactionsTable = 'pending_transactions';

  InventoryLocalDataSource(this._database);

  /// Initialize database tables
  static Future<void> createTables(Database db) async {
    // Products table
    await db.execute('''
      CREATE TABLE $productsTable (
        id TEXT PRIMARY KEY,
        cooperative_id TEXT NOT NULL,
        sku TEXT NOT NULL,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        unit_of_measure TEXT NOT NULL,
        unit_price REAL NOT NULL,
        current_stock REAL NOT NULL,
        reorder_point REAL NOT NULL,
        is_active INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        created_by TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Pending transactions table
    await db.execute('''
      CREATE TABLE $pendingTransactionsTable (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        retry_count INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Create indexes - cooperativeId first for optimal performance
    await db.execute(
        'CREATE INDEX idx_products_cooperative ON $productsTable(cooperative_id)');
    await db.execute(
        'CREATE INDEX idx_products_coop_sku ON $productsTable(cooperative_id, sku)');
    await db.execute(
        'CREATE INDEX idx_products_coop_category ON $productsTable(cooperative_id, category)');
    await db.execute(
        'CREATE INDEX idx_products_coop_active ON $productsTable(cooperative_id, is_active)');
  }

  // Product operations
  Future<void> saveProduct(ProductModel product) async {
    await _database.insert(
      productsTable,
      _productToMap(product),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveProducts(List<ProductModel> products) async {
    final batch = _database.batch();
    for (final product in products) {
      batch.insert(
        productsTable,
        _productToMap(product),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<ProductModel?> getProductById(String id) async {
    final results = await _database.query(
      productsTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) return null;

    return _productFromMap(results.first);
  }

  Future<List<ProductModel>> getAllProducts({
    required String cooperativeId,
    ProductCategory? category,
    bool activeOnly = true,
  }) async {
    String where = 'cooperative_id = ?';
    List<dynamic> whereArgs = [cooperativeId];

    if (activeOnly && category != null) {
      where += ' AND is_active = ? AND category = ?';
      whereArgs.addAll([1, category.name]);
    } else if (activeOnly) {
      where += ' AND is_active = ?';
      whereArgs.add(1);
    } else if (category != null) {
      where += ' AND category = ?';
      whereArgs.add(category.name);
    }

    final results = await _database.query(
      productsTable,
      where: where,
      whereArgs: whereArgs,
    );

    return results.map((map) => _productFromMap(map)).toList();
  }

  Future<void> updateProductStock(String id, double newStock) async {
    await _database.update(
      productsTable,
      {
        'current_stock': newStock,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'is_synced': 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<ProductModel>> searchProducts({
    required String cooperativeId,
    required String query,
  }) async {
    final lowerQuery = query.toLowerCase();
    final results = await _database.query(
      productsTable,
      where: 'cooperative_id = ? AND is_active = ? AND (LOWER(name) LIKE ? OR LOWER(sku) LIKE ?)',
      whereArgs: [cooperativeId, 1, '%$lowerQuery%', '%$lowerQuery%'],
    );

    return results.map((map) => _productFromMap(map)).toList();
  }

  // Pending transactions operations
  Future<void> queueTransaction({
    required String id,
    required String type,
    required Map<String, dynamic> data,
  }) async {
    await _database.insert(
      pendingTransactionsTable,
      {
        'id': id,
        'type': type,
        'data': jsonEncode(data),
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'retry_count': 0,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getPendingTransactions() async {
    final results = await _database.query(
      pendingTransactionsTable,
      orderBy: 'created_at ASC',
    );

    return results.map((map) {
      return {
        'id': map['id'] as String,
        'type': map['type'] as String,
        'data': jsonDecode(map['data'] as String) as Map<String, dynamic>,
        'created_at': DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
        'retry_count': map['retry_count'] as int,
      };
    }).toList();
  }

  Future<void> removePendingTransaction(String id) async {
    await _database.delete(
      pendingTransactionsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> incrementRetryCount(String id) async {
    await _database.rawUpdate(
      'UPDATE $pendingTransactionsTable SET retry_count = retry_count + 1 WHERE id = ?',
      [id],
    );
  }

  Future<bool> hasPendingTransactions() async {
    final result = await _database.rawQuery(
      'SELECT COUNT(*) as count FROM $pendingTransactionsTable',
    );
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }

  Future<void> clearAllData() async {
    await _database.delete(productsTable);
    await _database.delete(pendingTransactionsTable);
  }

  // Helper methods
  Map<String, dynamic> _productToMap(ProductModel product) {
    return {
      'id': product.id,
      'cooperative_id': product.cooperativeId,
      'sku': product.sku,
      'name': product.name,
      'category': product.category.name,
      'unit_of_measure': product.unitOfMeasure,
      'unit_price': product.unitPrice,
      'current_stock': product.currentStock,
      'reorder_point': product.reorderPoint,
      'is_active': product.isActive ? 1 : 0,
      'created_at': product.createdAt.millisecondsSinceEpoch,
      'updated_at': product.updatedAt.millisecondsSinceEpoch,
      'created_by': product.createdBy,
      'is_synced': 1,
    };
  }

  ProductModel _productFromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as String,
      cooperativeId: map['cooperative_id'] as String,
      sku: map['sku'] as String,
      name: map['name'] as String,
      category: ProductCategory.fromString(map['category'] as String),
      unitOfMeasure: map['unit_of_measure'] as String,
      unitPrice: (map['unit_price'] as num).toDouble(),
      currentStock: (map['current_stock'] as num).toDouble(),
      reorderPoint: (map['reorder_point'] as num).toDouble(),
      isActive: (map['is_active'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      createdBy: map['created_by'] as String,
    );
  }
}
