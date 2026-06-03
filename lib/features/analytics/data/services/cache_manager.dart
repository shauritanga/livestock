import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../datasources/analytics_local_datasource.dart';
import '../models/analytics_filter_model.dart';

/// Cache manager for analytics data
/// 
/// Provides generic caching functionality with TTL support and cache key generation.
class CacheManager {
  final AnalyticsLocalDataSource localDataSource;

  /// Default cache duration: 1 hour
  static const Duration defaultCacheDuration = Duration(hours: 1);

  CacheManager({required this.localDataSource});

  /// Get cached data with generic type support (Task 13.3)
  Future<T?> getCached<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
    String metricType,
  ) async {
    try {
      final cachedData = await localDataSource.getCachedMetrics(key, metricType);
      
      if (cachedData == null) {
        return null;
      }

      return fromJson(cachedData);
    } catch (e) {
      // If deserialization fails, return null
      return null;
    }
  }

  /// Cache data with TTL support (Task 13.3)
  Future<void> cache<T>(
    String key,
    T data,
    Map<String, dynamic> Function(T) toJson,
    String metricType, {
    Duration? ttl,
  }) async {
    try {
      final jsonData = toJson(data);
      final cacheDuration = ttl ?? defaultCacheDuration;

      await localDataSource.cacheMetrics(
        key,
        metricType,
        jsonData,
        cacheDuration,
      );
    } catch (e) {
      // Silently fail - caching is not critical
      // In production, you might want to log this
    }
  }

  /// Generate cache key using filter hash (Task 13.3)
  String generateCacheKey(
    AnalyticsFilterModel filter,
    String metricType,
  ) {
    // Use the filter's generateCacheKey method and append metric type
    final filterHash = filter.generateCacheKey();
    final combined = '$metricType:$filterHash';
    
    return combined;
  }

  /// Generate cache key from any object
  String generateCacheKeyFromObject(Map<String, dynamic> object) {
    final jsonString = jsonEncode(object);
    final bytes = utf8.encode(jsonString);
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  /// Check if cache is valid (Task 13.3)
  bool isCacheValid(DateTime cachedAt, Duration maxAge) {
    final now = DateTime.now();
    final expiresAt = cachedAt.add(maxAge);
    return now.isBefore(expiresAt);
  }

  /// Clear expired cache entries
  Future<int> clearExpiredCache() async {
    return await localDataSource.clearExpiredCache();
  }

  /// Clear all cache
  Future<int> clearAllCache() async {
    return await localDataSource.clearAllCache();
  }

  /// Clear cache for specific metric type
  Future<int> clearCacheByMetricType(String metricType) async {
    return await localDataSource.clearCacheByMetricType(metricType);
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    return await localDataSource.getCacheStats();
  }
}

/// Metric type constants for cache keys
class MetricType {
  static const String analyticsSummary = 'analytics_summary';
  static const String milkProduction = 'milk_production';
  static const String farmerDemographics = 'farmer_demographics';
  static const String livestock = 'livestock';
  static const String financial = 'financial';
  static const String inventory = 'inventory';
  static const String comparative = 'comparative';
  static const String predictive = 'predictive';
}
