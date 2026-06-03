import 'package:livestock/features/analytics/core/result.dart';
import 'package:livestock/features/analytics/domain/entities/analytics_filter.dart';
import 'package:livestock/features/analytics/domain/entities/milk_production_metrics.dart';
import 'package:livestock/features/analytics/domain/entities/farmer_metrics.dart';
import 'package:livestock/features/analytics/domain/entities/livestock_metrics.dart';
import 'package:livestock/features/analytics/domain/entities/financial_metrics.dart';
import 'package:livestock/features/analytics/domain/entities/inventory_metrics.dart';
import 'package:livestock/features/analytics/domain/entities/analytics_summary.dart';
import 'package:livestock/features/analytics/domain/entities/comparative_metrics.dart';
import 'package:livestock/features/analytics/domain/entities/predictive_metrics.dart';
import 'package:livestock/features/analytics/domain/entities/alert.dart';

/// Repository interface for analytics data
abstract class AnalyticsRepository {
  /// Get milk production analytics
  Future<Result<MilkProductionMetrics>> getMilkProductionAnalytics(
    AnalyticsFilter filter,
  );

  /// Get farmer demographics analytics
  Future<Result<FarmerMetrics>> getFarmerDemographics(
    AnalyticsFilter filter,
  );

  /// Get livestock analytics
  Future<Result<LivestockMetrics>> getLivestockAnalytics(
    AnalyticsFilter filter,
  );

  /// Get financial analytics
  Future<Result<FinancialMetrics>> getFinancialAnalytics(
    AnalyticsFilter filter,
  );

  /// Get inventory analytics
  Future<Result<InventoryMetrics>> getInventoryAnalytics(
    AnalyticsFilter filter,
  );

  /// Get comprehensive analytics summary
  Future<Result<AnalyticsSummary>> getAnalyticsSummary(
    AnalyticsFilter filter,
  );

  /// Get comparative analytics between two periods
  Future<Result<ComparativeMetrics>> getComparativeAnalytics(
    AnalyticsFilter currentPeriod,
    AnalyticsFilter comparisonPeriod,
  );

  /// Get predictive analytics with forecasts
  Future<Result<PredictiveMetrics>> getPredictiveAnalytics(
    AnalyticsFilter historicalFilter,
    int forecastDays,
  );

  /// Get alerts
  Future<Result<List<Alert>>> getAlerts({
    AlertSeverity? minSeverity,
    bool? unreadOnly,
  });

  /// Mark alert as read
  Future<Result<void>> markAlertAsRead(String alertId);

  // Additional methods will be added in subsequent tasks
}
