import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:livestock/features/inventory/data/datasources/inventory_local_datasource.dart';

/// Database helper for managing SQLite database
class DatabaseHelper {
  static Database? _database;
  static const String _databaseName = 'livestock.db';
  static const int _databaseVersion = 2;

  /// Get database instance
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database
  static Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create database tables
  static Future<void> _onCreate(Database db, int version) async {
    // Create inventory tables
    await InventoryLocalDataSource.createTables(db);

    // Create analytics cache table
    await db.execute('''
      CREATE TABLE analytics_cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cache_key TEXT NOT NULL,
        metric_type TEXT NOT NULL,
        data TEXT NOT NULL,
        cached_at INTEGER NOT NULL,
        UNIQUE(cache_key, metric_type)
      )
    ''');

    // Add other feature tables here as needed
  }

  /// Upgrade database schema
  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Handle database migrations here
    if (oldVersion < 2) {
      // Add analytics_cache table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS analytics_cache (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          cache_key TEXT NOT NULL,
          metric_type TEXT NOT NULL,
          data TEXT NOT NULL,
          cached_at INTEGER NOT NULL,
          UNIQUE(cache_key, metric_type)
        )
      ''');
      
      // Add cooperative_id column to products table if it exists
      try {
        await db.execute('ALTER TABLE products ADD COLUMN cooperative_id TEXT');
      } catch (e) {
        // Column might already exist or table doesn't exist
        print('Could not add cooperative_id column: $e');
      }
    }
  }

  /// Close database
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Delete database (for testing)
  static Future<void> deleteDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);
    await deleteDatabase(path);
    _database = null;
  }
}
