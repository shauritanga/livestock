import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/analytics_filter.dart';
import '../../domain/repositories/analytics_repository.dart';

/// Background service for refreshing analytics cache
class BackgroundCacheService {
  final AnalyticsRepository _analyticsRepository;
  Timer? _refreshTimer;
  bool _isRefreshing = false;

  BackgroundCacheService(this._analyticsRepository);

  /// Start periodic cache refresh
  void startPeriodicRefresh({Duration interval = const Duration(minutes: 30)}) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(interval, (_) => refreshCache());
  }

  /// Stop periodic cache refresh
  void stopPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// Manually refresh cache for common analytics
  Future<void> refreshCache() async {
    if (_isRefreshing) return;

    _isRefreshing = true;
    try {
      // Pre-fetch common analytics filters
      final filters = [
        AnalyticsFilter.today(),
        AnalyticsFilter.thisWeek(),
        AnalyticsFilter.thisMonth(),
      ];

      for (final filter in filters) {
        await _refreshAnalyticsForFilter(filter);
      }
    } catch (e) {
      debugPrint('Error refreshing cache: $e');
    } finally {
      _isRefreshing = false;
    }
  }

  /// Refresh analytics for a specific filter
  Future<void> _refreshAnalyticsForFilter(AnalyticsFilter filter) async {
    // Fetch each analytics type individually to avoid one failure stopping all
    await _fetchWithErrorHandling(
      'Analytics Summary',
      () => _analyticsRepository.getAnalyticsSummary(filter),
    );
    await _fetchWithErrorHandling(
      'Milk Production',
      () => _analyticsRepository.getMilkProductionAnalytics(filter),
    );
    await _fetchWithErrorHandling(
      'Farmer Demographics',
      () => _analyticsRepository.getFarmerDemographics(filter),
    );
    await _fetchWithErrorHandling(
      'Livestock Analytics',
      () => _analyticsRepository.getLivestockAnalytics(filter),
    );
    await _fetchWithErrorHandling(
      'Financial Analytics',
      () => _analyticsRepository.getFinancialAnalytics(filter),
    );
    await _fetchWithErrorHandling(
      'Inventory Analytics',
      () => _analyticsRepository.getInventoryAnalytics(filter),
    );
  }

  /// Helper to fetch with error handling
  Future<void> _fetchWithErrorHandling(
    String name,
    Future<dynamic> Function() fetchFn,
  ) async {
    try {
      await fetchFn();
      debugPrint('✓ Pre-fetched $name');
    } catch (e) {
      debugPrint('✗ Failed to pre-fetch $name: $e');
    }
  }

  /// Pre-fetch analytics on app startup
  Future<void> preFetchCommonAnalytics() async {
    await refreshCache();
  }

  /// Invalidate cache for specific data types
  Future<void> invalidateCacheForDataType(String dataType) async {
    // This would be implemented based on your cache manager
    // For now, we'll just refresh the cache
    await refreshCache();
  }

  void dispose() {
    stopPeriodicRefresh();
  }
}
