import '../../domain/repositories/analytics_repository.dart';
import '../../domain/entities/analytics_summary.dart';
import '../../domain/entities/analytics_filter.dart';
import '../../domain/entities/milk_production_metrics.dart';
import '../../domain/entities/farmer_metrics.dart';
import '../../domain/entities/livestock_metrics.dart';
import '../../domain/entities/financial_metrics.dart';
import '../../domain/entities/inventory_metrics.dart';
import '../../domain/entities/comparative_metrics.dart';
import '../../domain/entities/predictive_metrics.dart';
import '../../domain/entities/alert.dart';
import '../../core/result.dart';
import '../datasources/analytics_remote_datasource.dart';
import '../datasources/analytics_local_datasource.dart';
import '../services/cache_manager.dart';
import '../models/analytics_filter_model.dart';
import '../models/milk_production_metrics_model.dart';
import '../models/farmer_metrics_model.dart';
import '../models/livestock_metrics_model.dart';
import '../models/financial_metrics_model.dart';
import '../models/inventory_metrics_model.dart';
import '../../../../core/services/connectivity_service.dart';

/// Implementation of AnalyticsRepository with caching and offline support
/// 
/// Uses cache-first strategy for better performance and offline access.
/// Falls back to remote data when cache is stale or unavailable.
class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource remoteDataSource;
  final AnalyticsLocalDataSource localDataSource;
  final CacheManager cacheManager;
  final ConnectivityService connectivityService;

  AnalyticsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.cacheManager,
    required this.connectivityService,
  });

  /// Convert AnalyticsFilter to AnalyticsFilterModel
  AnalyticsFilterModel _toFilterModel(AnalyticsFilter filter) {
    if (filter is AnalyticsFilterModel) {
      return filter;
    }
    return AnalyticsFilterModel(
      dateRange: filter.dateRange,
      cooperativeIds: filter.cooperativeIds,
      collectionCenterIds: filter.collectionCenterIds,
      region: filter.region,
      district: filter.district,
      ward: filter.ward,
      village: filter.village,
    );
  }

  /// Get analytics summary with cache-first strategy (Task 14.1)
  @override
  Future<Result<AnalyticsSummary>> getAnalyticsSummary(
    AnalyticsFilter filter,
  ) async {
    try {
      // Fetch all individual metrics
      final milkResult = await getMilkProductionAnalytics(filter);
      final farmerResult = await getFarmerDemographics(filter);
      final livestockResult = await getLivestockAnalytics(filter);
      final financialResult = await getFinancialAnalytics(filter);
      final inventoryResult = await getInventoryAnalytics(filter);

      // Check if any fetch failed
      if (milkResult.isFailure) {
        final failure = milkResult as Failure<MilkProductionMetrics>;
        return Failure('Failed to fetch milk production metrics', failure.exception);
      }
      if (farmerResult.isFailure) {
        final failure = farmerResult as Failure<FarmerMetrics>;
        return Failure('Failed to fetch farmer demographics', failure.exception);
      }
      if (livestockResult.isFailure) {
        final failure = livestockResult as Failure<LivestockMetrics>;
        return Failure('Failed to fetch livestock metrics', failure.exception);
      }
      if (financialResult.isFailure) {
        final failure = financialResult as Failure<FinancialMetrics>;
        return Failure('Failed to fetch financial metrics', failure.exception);
      }
      if (inventoryResult.isFailure) {
        final failure = inventoryResult as Failure<InventoryMetrics>;
        return Failure('Failed to fetch inventory metrics', failure.exception);
      }

      // Aggregate all metrics into summary
      final summary = AnalyticsSummary(
        startDate: filter.dateRange.startDate,
        endDate: filter.dateRange.endDate,
        milkMetrics: (milkResult as Success<MilkProductionMetrics>).data,
        farmerMetrics: (farmerResult as Success<FarmerMetrics>).data,
        livestockMetrics: (livestockResult as Success<LivestockMetrics>).data,
        financialMetrics: (financialResult as Success<FinancialMetrics>).data,
        inventoryMetrics: (inventoryResult as Success<InventoryMetrics>).data,
      );

      return Success(summary);
    } catch (e, stackTrace) {
      return Failure(
        'Failed to get analytics summary: $e',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// Get milk production analytics with cache-first strategy (Task 14.1)
  @override
  Future<Result<MilkProductionMetrics>> getMilkProductionAnalytics(
    AnalyticsFilter filter,
  ) async {
    try {
      final filterModel = _toFilterModel(filter);
      final cacheKey = cacheManager.generateCacheKey(
        filterModel,
        MetricType.milkProduction,
      );

      // Try cache first
      final cachedData = await cacheManager.getCached<MilkProductionMetricsModel>(
        cacheKey,
        (json) => MilkProductionMetricsModel.fromJson(json),
        MetricType.milkProduction,
      );

      if (cachedData != null) {
        return Success(cachedData);
      }

      // Check network connectivity
      final isOnline = await connectivityService.isOnline();
      if (!isOnline) {
        return Failure('No internet connection and no cached data available');
      }

      // Fetch from remote
      final metrics = await remoteDataSource.getMilkProductionMetrics(filterModel);

      // Cache the result
      await cacheManager.cache<MilkProductionMetricsModel>(
        cacheKey,
        metrics,
        (data) => data.toJson(),
        MetricType.milkProduction,
      );

      return Success(metrics);
    } catch (e, stackTrace) {
      return Failure(
        'Failed to get milk production analytics: $e',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// Get farmer demographics with cache-first strategy (Task 14.1)
  @override
  Future<Result<FarmerMetrics>> getFarmerDemographics(
    AnalyticsFilter filter,
  ) async {
    try {
      final filterModel = _toFilterModel(filter);
      final cacheKey = cacheManager.generateCacheKey(
        filterModel,
        MetricType.farmerDemographics,
      );

      // Try cache first
      final cachedData = await cacheManager.getCached<FarmerMetricsModel>(
        cacheKey,
        (json) => FarmerMetricsModel.fromJson(json),
        MetricType.farmerDemographics,
      );

      if (cachedData != null) {
        return Success(cachedData);
      }

      // Check network connectivity
      final isOnline = await connectivityService.isOnline();
      if (!isOnline) {
        return Failure('No internet connection and no cached data available');
      }

      // Fetch from remote
      final metrics = await remoteDataSource.getFarmerMetrics(filterModel);

      // Cache the result
      await cacheManager.cache<FarmerMetricsModel>(
        cacheKey,
        metrics,
        (data) => data.toJson(),
        MetricType.farmerDemographics,
      );

      return Success(metrics);
    } catch (e, stackTrace) {
      return Failure(
        'Failed to get farmer demographics: $e',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// Get livestock analytics with cache-first strategy (Task 14.2)
  @override
  Future<Result<LivestockMetrics>> getLivestockAnalytics(
    AnalyticsFilter filter,
  ) async {
    try {
      final filterModel = _toFilterModel(filter);
      final cacheKey = cacheManager.generateCacheKey(
        filterModel,
        MetricType.livestock,
      );

      // Try cache first
      final cachedData = await cacheManager.getCached<LivestockMetricsModel>(
        cacheKey,
        (json) => LivestockMetricsModel.fromJson(json),
        MetricType.livestock,
      );

      if (cachedData != null) {
        return Success(cachedData);
      }

      // Check network connectivity
      final isOnline = await connectivityService.isOnline();
      if (!isOnline) {
        return Failure('No internet connection and no cached data available');
      }

      // Fetch from remote
      final metrics = await remoteDataSource.getLivestockMetrics(filterModel);

      // Cache the result
      await cacheManager.cache<LivestockMetricsModel>(
        cacheKey,
        metrics,
        (data) => data.toJson(),
        MetricType.livestock,
      );

      return Success(metrics);
    } catch (e, stackTrace) {
      return Failure(
        'Failed to get livestock analytics: $e',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// Get financial analytics with cache-first strategy (Task 14.2)
  @override
  Future<Result<FinancialMetrics>> getFinancialAnalytics(
    AnalyticsFilter filter,
  ) async {
    try {
      final filterModel = _toFilterModel(filter);
      final cacheKey = cacheManager.generateCacheKey(
        filterModel,
        MetricType.financial,
      );

      // Try cache first
      final cachedData = await cacheManager.getCached<FinancialMetricsModel>(
        cacheKey,
        (json) => FinancialMetricsModel.fromJson(json),
        MetricType.financial,
      );

      if (cachedData != null) {
        return Success(cachedData);
      }

      // Check network connectivity
      final isOnline = await connectivityService.isOnline();
      if (!isOnline) {
        return Failure('No internet connection and no cached data available');
      }

      // Fetch from remote
      final metrics = await remoteDataSource.getFinancialMetrics(filterModel);

      // Cache the result
      await cacheManager.cache<FinancialMetricsModel>(
        cacheKey,
        metrics,
        (data) => data.toJson(),
        MetricType.financial,
      );

      return Success(metrics);
    } catch (e, stackTrace) {
      return Failure(
        'Failed to get financial analytics: $e',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// Get inventory analytics with cache-first strategy (Task 14.2)
  @override
  Future<Result<InventoryMetrics>> getInventoryAnalytics(
    AnalyticsFilter filter,
  ) async {
    try {
      final filterModel = _toFilterModel(filter);
      final cacheKey = cacheManager.generateCacheKey(
        filterModel,
        MetricType.inventory,
      );

      // Try cache first
      final cachedData = await cacheManager.getCached<InventoryMetricsModel>(
        cacheKey,
        (json) => InventoryMetricsModel.fromJson(json),
        MetricType.inventory,
      );

      if (cachedData != null) {
        return Success(cachedData);
      }

      // Check network connectivity
      final isOnline = await connectivityService.isOnline();
      if (!isOnline) {
        return Failure('No internet connection and no cached data available');
      }

      // Fetch from remote
      final metrics = await remoteDataSource.getInventoryMetrics(filterModel);

      // Cache the result
      await cacheManager.cache<InventoryMetricsModel>(
        cacheKey,
        metrics,
        (data) => data.toJson(),
        MetricType.inventory,
      );

      return Success(metrics);
    } catch (e, stackTrace) {
      return Failure(
        'Failed to get inventory analytics: $e',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// Get comparative analytics with network-first strategy (Task 14.3)
  @override
  Future<Result<ComparativeMetrics>> getComparativeAnalytics(
    AnalyticsFilter current,
    AnalyticsFilter comparison,
  ) async {
    try {
      final currentModel = _toFilterModel(current);
      final comparisonModel = _toFilterModel(comparison);

      // Check network connectivity
      final isOnline = await connectivityService.isOnline();
      if (!isOnline) {
        return Failure('No internet connection available');
      }

      // Fetch from remote (network-first for comparative analytics)
      await remoteDataSource.getComparativeMetrics(
        currentModel,
        comparisonModel,
      );

      // Note: You would deserialize this to ComparativeMetrics
      // For now, return an error indicating this needs implementation
      return Failure(
        'Comparative metrics deserialization not yet implemented',
        Exception('Comparative metrics deserialization not yet implemented'),
      );
    } catch (e, stackTrace) {
      return Failure(
        'Failed to get comparative analytics: $e',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// Get predictive analytics with network-first strategy (Task 14.3)
  @override
  Future<Result<PredictiveMetrics>> getPredictiveAnalytics(
    AnalyticsFilter historical,
    int forecastDays,
  ) async {
    try {
      final historicalModel = _toFilterModel(historical);

      // Check network connectivity
      final isOnline = await connectivityService.isOnline();
      if (!isOnline) {
        return Failure('No internet connection available');
      }

      // Fetch from remote (network-first for predictive analytics)
      await remoteDataSource.getPredictiveMetrics(
        historicalModel,
        forecastDays,
      );

      // Note: You would deserialize this to PredictiveMetrics
      // For now, return an error indicating this needs implementation
      return Failure(
        'Predictive metrics deserialization not yet implemented',
        Exception('Predictive metrics deserialization not yet implemented'),
      );
    } catch (e, stackTrace) {
      return Failure(
        'Failed to get predictive analytics: $e',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// Get alerts with Firestore real-time listener (Task 14.4)
  @override
  Future<Result<List<Alert>>> getAlerts({
    AlertSeverity? minSeverity,
    bool? unreadOnly,
  }) async {
    try {
      // Check network connectivity
      final isOnline = await connectivityService.isOnline();
      if (!isOnline) {
        return Failure('No internet connection available');
      }

      final alerts = await remoteDataSource.getAlerts(
        minSeverity: minSeverity?.name,
        unreadOnly: unreadOnly,
      );

      return Success(alerts);
    } catch (e, stackTrace) {
      return Failure(
        'Failed to get alerts: $e',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// Mark alert as read with optimistic update (Task 14.4)
  @override
  Future<Result<void>> markAlertAsRead(String alertId) async {
    try {
      // Check network connectivity
      final isOnline = await connectivityService.isOnline();
      if (!isOnline) {
        return Failure('No internet connection available');
      }

      await remoteDataSource.markAlertAsRead(alertId);

      return Success(null);
    } catch (e, stackTrace) {
      return Failure(
        'Failed to mark alert as read: $e',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// Get alerts stream for real-time updates
  Stream<List<Alert>> getAlertsStream({
    AlertSeverity? minSeverity,
    bool? unreadOnly,
  }) {
    return remoteDataSource.getAlertsStream(
      minSeverity: minSeverity?.name,
      unreadOnly: unreadOnly,
    );
  }
}
