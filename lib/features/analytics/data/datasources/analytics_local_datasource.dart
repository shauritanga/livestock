import 'dart:convert';
import 'package:sqflite/sqflite.dart';

/// Local data source for analytics caching using SQLite
/// 
/// Provides offline access to analytics data and improves performance
/// by caching frequently accessed metrics.
class AnalyticsLocalDataSource {
  final Database database;

  AnalyticsLocalDataSource({required this.database});

  /// Table name for analytics cache
  static const String _tableName = 'analytics_cache';

  /// Create analytics cache table (Task 13.1)
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        cache_key TEXT PRIMARY KEY,
        metric_type TEXT NOT NULL,
        filter_hash TEXT NOT NULL,
        data TEXT NOT NULL,
        cached_at INTEGER NOT NULL,
        expires_at INTEGER NOT NULL
      )
    ''');

    // Create index for faster queries
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_analytics_cache_metric_type 
      ON $_tableName (metric_type)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_analytics_cache_expires_at 
      ON $_tableName (expires_at)
    ''');
  }

  /// Cache analytics summary (Task 13.1)
  Future<void> cacheAnalyticsSummary(
    String cacheKey,
    Map<String, dynamic> summary,
    Duration ttl,
  ) async {
    final now = DateTime.now();
    final expiresAt = now.add(ttl);

    await database.insert(
      _tableName,
      {
        'cache_key': cacheKey,
        'metric_type': 'analytics_summary',
        'filter_hash': cacheKey,
        'data': jsonEncode(summary),
        'cached_at': now.millisecondsSinceEpoch,
        'expires_at': expiresAt.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get cached analytics summary (Task 13.1)
  Future<Map<String, dynamic>?> getCachedAnalyticsSummary(
    String cacheKey,
  ) async {
    final results = await database.query(
      _tableName,
      where: 'cache_key = ? AND metric_type = ?',
      whereArgs: [cacheKey, 'analytics_summary'],
    );

    if (results.isEmpty) {
      return null;
    }

    final row = results.first;
    final expiresAt = row['expires_at'] as int;

    // Check if cache is expired
    if (DateTime.now().millisecondsSinceEpoch > expiresAt) {
      // Delete expired cache
      await database.delete(
        _tableName,
        where: 'cache_key = ?',
        whereArgs: [cacheKey],
      );
      return null;
    }

    final dataString = row['data'] as String;
    return jsonDecode(dataString) as Map<String, dynamic>;
  }

  /// Cache any metrics (Task 13.2)
  Future<void> cacheMetrics(
    String cacheKey,
    String metricType,
    Map<String, dynamic> metrics,
    Duration ttl,
  ) async {
    final now = DateTime.now();
    final expiresAt = now.add(ttl);

    await database.insert(
      _tableName,
      {
        'cache_key': cacheKey,
        'metric_type': metricType,
        'filter_hash': cacheKey,
        'data': jsonEncode(metrics),
        'cached_at': now.millisecondsSinceEpoch,
        'expires_at': expiresAt.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get cached metrics (Task 13.2)
  Future<Map<String, dynamic>?> getCachedMetrics(
    String cacheKey,
    String metricType,
  ) async {
    final results = await database.query(
      _tableName,
      where: 'cache_key = ? AND metric_type = ?',
      whereArgs: [cacheKey, metricType],
    );

    if (results.isEmpty) {
      return null;
    }

    final row = results.first;
    final expiresAt = row['expires_at'] as int;

    // Check if cache is expired
    if (DateTime.now().millisecondsSinceEpoch > expiresAt) {
      // Delete expired cache
      await database.delete(
        _tableName,
        where: 'cache_key = ?',
        whereArgs: [cacheKey],
      );
      return null;
    }

    final dataString = row['data'] as String;
    return jsonDecode(dataString) as Map<String, dynamic>;
  }

  /// Clear expired cache (Task 13.2)
  Future<int> clearExpiredCache() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    return await database.delete(
      _tableName,
      where: 'expires_at < ?',
      whereArgs: [now],
    );
  }

  /// Clear all cache
  Future<int> clearAllCache() async {
    return await database.delete(_tableName);
  }

  /// Clear cache for specific metric type
  Future<int> clearCacheByMetricType(String metricType) async {
    return await database.delete(
      _tableName,
      where: 'metric_type = ?',
      whereArgs: [metricType],
    );
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    final totalCount = Sqflite.firstIntValue(
      await database.rawQuery('SELECT COUNT(*) FROM $_tableName'),
    ) ?? 0;

    final now = DateTime.now().millisecondsSinceEpoch;
    final expiredCount = Sqflite.firstIntValue(
      await database.rawQuery(
        'SELECT COUNT(*) FROM $_tableName WHERE expires_at < ?',
        [now],
      ),
    ) ?? 0;

    final validCount = totalCount - expiredCount;

    return {
      'totalCount': totalCount,
      'validCount': validCount,
      'expiredCount': expiredCount,
    };
  }
}
