import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:sqflite/sqflite.dart';
import '../../domain/entities/analytics_filter.dart';
import '../../domain/entities/date_range.dart';
import '../../domain/entities/analytics_summary.dart';
import '../../domain/entities/milk_production_metrics.dart';
import '../../domain/entities/farmer_metrics.dart';
import '../../domain/entities/livestock_metrics.dart';
import '../../domain/entities/financial_metrics.dart';
import '../../domain/entities/inventory_metrics.dart';
import '../../domain/entities/comparative_metrics.dart';
import '../../domain/entities/predictive_metrics.dart';
import '../../domain/entities/alert.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../../domain/repositories/report_repository.dart';
import '../../domain/usecases/get_analytics_summary.dart';
import '../../domain/usecases/get_milk_production_analytics.dart';
import '../../domain/usecases/get_farmer_demographics.dart';
import '../../domain/usecases/get_livestock_analytics.dart';
import '../../domain/usecases/get_financial_analytics.dart';
import '../../domain/usecases/get_inventory_analytics.dart';
import '../../domain/usecases/get_comparative_analytics.dart';
import '../../domain/usecases/get_predictive_analytics.dart';
import '../../data/repositories/analytics_repository_impl.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../../data/datasources/analytics_remote_datasource.dart';
import '../../data/datasources/analytics_local_datasource.dart';
import '../../data/services/cache_manager.dart';
import '../../data/services/report_template_service.dart';
import '../../data/services/report_generator_service.dart';
import '../../data/services/pdf_generator.dart';
import '../../data/services/excel_generator.dart';
import '../../data/services/csv_generator.dart';
import '../../core/result.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/database/database_helper.dart';

// ============================================================================
// Infrastructure Providers
// ============================================================================

/// Firestore provider
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Cloud Functions provider
final functionsProvider = Provider<FirebaseFunctions>((ref) {
  return FirebaseFunctions.instanceFor(region: 'us-central1');
});

/// Database provider
final databaseProvider = FutureProvider<Database>((ref) async {
  return await DatabaseHelper.database;
});

// ============================================================================
// Data Source Providers
// ============================================================================

/// Remote data source provider
final analyticsRemoteDataSourceProvider = Provider<AnalyticsRemoteDataSource>((ref) {
  return AnalyticsRemoteDataSource(
    firestore: ref.watch(firestoreProvider),
    functions: ref.watch(functionsProvider),
  );
});

/// Local data source provider
final analyticsLocalDataSourceProvider = FutureProvider<AnalyticsLocalDataSource>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return AnalyticsLocalDataSource(database: db);
});

/// Cache manager provider
final cacheManagerProvider = FutureProvider<CacheManager>((ref) async {
  final localDataSource = await ref.watch(analyticsLocalDataSourceProvider.future);
  return CacheManager(localDataSource: localDataSource);
});

// ============================================================================
// Repository Providers
// ============================================================================

/// Analytics repository provider
final analyticsRepositoryProvider = FutureProvider<AnalyticsRepository>((ref) async {
  final remoteDataSource = ref.watch(analyticsRemoteDataSourceProvider);
  final localDataSource = await ref.watch(analyticsLocalDataSourceProvider.future);
  final cacheManager = await ref.watch(cacheManagerProvider.future);
  final connectivityService = ref.watch(connectivityServiceProvider);

  return AnalyticsRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
    cacheManager: cacheManager,
    connectivityService: connectivityService,
  );
});

/// Report repository provider
final reportRepositoryProvider = FutureProvider<ReportRepository>((ref) async {
  final analyticsRepository = await ref.watch(analyticsRepositoryProvider.future);
  
  return ReportRepositoryImpl(
    reportGenerator: ReportGeneratorService(analyticsRepository: analyticsRepository),
    pdfGenerator: PdfGenerator(),
    excelGenerator: ExcelGenerator(),
    csvGenerator: CsvGenerator(),
    templateService: ReportTemplateService(),
    firestore: ref.watch(firestoreProvider),
  );
});

// ============================================================================
// Use Case Providers
// ============================================================================

final getAnalyticsSummaryUseCaseProvider = FutureProvider<GetAnalyticsSummary>((ref) async {
  final repository = await ref.watch(analyticsRepositoryProvider.future);
  return GetAnalyticsSummary(repository);
});

final getMilkProductionAnalyticsUseCaseProvider = FutureProvider<GetMilkProductionAnalytics>((ref) async {
  final repository = await ref.watch(analyticsRepositoryProvider.future);
  return GetMilkProductionAnalytics(repository);
});

final getFarmerDemographicsUseCaseProvider = FutureProvider<GetFarmerDemographics>((ref) async {
  final repository = await ref.watch(analyticsRepositoryProvider.future);
  return GetFarmerDemographics(repository);
});

final getLivestockAnalyticsUseCaseProvider = FutureProvider<GetLivestockAnalytics>((ref) async {
  final repository = await ref.watch(analyticsRepositoryProvider.future);
  return GetLivestockAnalytics(repository);
});

final getFinancialAnalyticsUseCaseProvider = FutureProvider<GetFinancialAnalytics>((ref) async {
  final repository = await ref.watch(analyticsRepositoryProvider.future);
  return GetFinancialAnalytics(repository);
});

final getInventoryAnalyticsUseCaseProvider = FutureProvider<GetInventoryAnalytics>((ref) async {
  final repository = await ref.watch(analyticsRepositoryProvider.future);
  return GetInventoryAnalytics(repository);
});

final getComparativeAnalyticsUseCaseProvider = FutureProvider<GetComparativeAnalytics>((ref) async {
  final repository = await ref.watch(analyticsRepositoryProvider.future);
  return GetComparativeAnalytics(repository);
});

final getPredictiveAnalyticsUseCaseProvider = FutureProvider<GetPredictiveAnalytics>((ref) async {
  final repository = await ref.watch(analyticsRepositoryProvider.future);
  return GetPredictiveAnalytics(repository);
});

// ============================================================================
// State Providers (Task 16.1, 16.2, 16.3, 16.4, 16.5, 16.6)
// ============================================================================

/// Analytics filter provider (Task 16.1)
/// 
/// Manages the current filter state for analytics queries.
/// Initialized with thisMonth filter.
final analyticsFilterProvider = Provider<AnalyticsFilter>((ref) {
  // TODO: Get cooperative ID from current user
  // For now, use the test cooperative
  return AnalyticsFilter.thisMonth().copyWith(
    cooperativeIds: ['coop_test_001'],
  );
});

/// Analytics summary provider (Task 16.2)
/// 
/// Watches analyticsFilterProvider and calls GetAnalyticsSummary use case.
final analyticsSummaryProvider = FutureProvider<AnalyticsSummary>((ref) async {
  final filter = ref.watch(analyticsFilterProvider);
  final useCase = await ref.watch(getAnalyticsSummaryUseCaseProvider.future);
  
  final result = await useCase(filter);
  
  if (result.isSuccess) {
    return result.dataOrNull!;
  } else {
    throw Exception(result.errorOrNull ?? 'Unknown error');
  }
});

/// Milk production analytics provider (Task 16.3)
final milkProductionAnalyticsProvider = FutureProvider<MilkProductionMetrics>((ref) async {
  final filter = ref.watch(analyticsFilterProvider);
  final useCase = await ref.watch(getMilkProductionAnalyticsUseCaseProvider.future);
  
  final result = await useCase(filter);
  
  if (result.isSuccess) {
    return result.dataOrNull!;
  } else {
    throw Exception(result.errorOrNull ?? 'Unknown error');
  }
});

/// Farmer demographics provider (Task 16.3)
final farmerDemographicsProvider = FutureProvider<FarmerMetrics>((ref) async {
  final filter = ref.watch(analyticsFilterProvider);
  final useCase = await ref.watch(getFarmerDemographicsUseCaseProvider.future);
  
  final result = await useCase(filter);
  
  if (result.isSuccess) {
    return result.dataOrNull!;
  } else {
    throw Exception(result.errorOrNull ?? 'Unknown error');
  }
});

/// Livestock analytics provider (Task 16.3)
final livestockAnalyticsProvider = FutureProvider<LivestockMetrics>((ref) async {
  final filter = ref.watch(analyticsFilterProvider);
  final useCase = await ref.watch(getLivestockAnalyticsUseCaseProvider.future);
  
  final result = await useCase(filter);
  
  if (result.isSuccess) {
    return result.dataOrNull!;
  } else {
    throw Exception(result.errorOrNull ?? 'Unknown error');
  }
});

/// Financial analytics provider (Task 16.3)
final financialAnalyticsProvider = FutureProvider<FinancialMetrics>((ref) async {
  final filter = ref.watch(analyticsFilterProvider);
  final useCase = await ref.watch(getFinancialAnalyticsUseCaseProvider.future);
  
  final result = await useCase(filter);
  
  if (result.isSuccess) {
    return result.dataOrNull!;
  } else {
    throw Exception(result.errorOrNull ?? 'Unknown error');
  }
});

/// Inventory analytics provider (Task 16.3)
final inventoryAnalyticsProvider = FutureProvider<InventoryMetrics>((ref) async {
  final filter = ref.watch(analyticsFilterProvider);
  final useCase = await ref.watch(getInventoryAnalyticsUseCaseProvider.future);
  
  final result = await useCase(filter);
  
  if (result.isSuccess) {
    return result.dataOrNull!;
  } else {
    throw Exception(result.errorOrNull ?? 'Unknown error');
  }
});

/// Comparison period provider for comparative analytics (Task 16.4)
final comparisonPeriodProvider = Provider<AnalyticsFilter>((ref) {
  // Default to previous month
  final now = DateTime.now();
  final lastMonth = DateTime(now.year, now.month - 1, 1);
  final lastMonthEnd = DateTime(now.year, now.month, 0, 23, 59, 59);
  
  return AnalyticsFilter(
    dateRange: DateRange(startDate: lastMonth, endDate: lastMonthEnd),
  );
});

/// Comparative analytics provider (Task 16.4)
final comparativeAnalyticsProvider = FutureProvider<ComparativeMetrics>((ref) async {
  final currentFilter = ref.watch(analyticsFilterProvider);
  final comparisonFilter = ref.watch(comparisonPeriodProvider);
  final useCase = await ref.watch(getComparativeAnalyticsUseCaseProvider.future);
  
  final result = await useCase(
    currentPeriod: currentFilter,
    comparisonPeriod: comparisonFilter,
  );
  
  if (result.isSuccess) {
    return result.dataOrNull!;
  } else {
    throw Exception(result.errorOrNull ?? 'Unknown error');
  }
});

/// Forecast days provider for predictive analytics (Task 16.4)
final forecastDaysProvider = Provider<int>((ref) => 30);

/// Predictive analytics provider (Task 16.4)
final predictiveAnalyticsProvider = FutureProvider<PredictiveMetrics>((ref) async {
  final filter = ref.watch(analyticsFilterProvider);
  final forecastDays = ref.watch(forecastDaysProvider);
  final useCase = await ref.watch(getPredictiveAnalyticsUseCaseProvider.future);
  
  final result = await useCase(
    historicalFilter: filter,
    forecastDays: forecastDays,
  );
  
  if (result.isSuccess) {
    return result.dataOrNull!;
  } else {
    throw Exception(result.errorOrNull ?? 'Unknown error');
  }
});

/// Alerts stream provider (Task 16.5)
/// 
/// Provides real-time updates for alerts.
final alertsStreamProvider = StreamProvider<List<Alert>>((ref) async* {
  final repository = await ref.watch(analyticsRepositoryProvider.future);
  
  // For now, return a simple stream that fetches alerts periodically
  // In a real implementation, this would use Firestore snapshots
  while (true) {
    final result = await repository.getAlerts(minSeverity: null, unreadOnly: false);
    if (result.isSuccess) {
      yield result.dataOrNull!;
    }
    await Future.delayed(const Duration(seconds: 30));
  }
});

/// Unread alerts count provider
final unreadAlertsCountProvider = Provider<int>((ref) {
  final alertsAsync = ref.watch(alertsStreamProvider);
  
  return alertsAsync.when(
    data: (alerts) => alerts.where((alert) => !alert.isRead).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});
