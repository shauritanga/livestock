# Analytics & Reporting Feature

## Overview

The Analytics & Reporting feature provides comprehensive data visualization and insights for the Agripoa livestock management platform. It enables cooperatives to make data-driven decisions and provides government stakeholders with aggregated insights for policy-making and agricultural planning.

## Architecture

The feature follows Clean Architecture principles with a feature-first approach:

```
lib/features/analytics/
├── core/
│   ├── result.dart                    # Result type for error handling
│   └── utils/
│       └── analytics_formatter.dart   # Locale-aware formatting utilities
├── domain/
│   ├── entities/                      # Business entities
│   ├── repositories/                  # Repository interfaces
│   └── usecases/                      # Business logic use cases
├── data/
│   ├── datasources/                   # Remote (Firestore) and local (SQLite) data sources
│   ├── models/                        # Data models with JSON serialization
│   ├── repositories/                  # Repository implementations
│   └── services/                      # Services (cache, report generation, export)
└── presentation/
    ├── providers/                     # Riverpod providers for state management
    ├── screens/                       # UI screens
    └── widgets/                       # Reusable UI components
```

## Key Features

### 1. Analytics Dashboard
- **Milk Production Analytics**: Track daily/weekly/monthly milk collection, quality distribution, and trends
- **Farmer Demographics**: Analyze farmer distribution by gender, age, location, and app adoption
- **Livestock Analytics**: Monitor cattle counts, lactation rates, breed distribution, and health status
- **Financial Analytics**: View payment trends, loan metrics, insurance coverage, and revenue breakdown
- **Inventory Analytics**: Track stock levels, sales performance, and turnover rates

### 2. Comparative Analytics
- Compare performance across different time periods
- Benchmark collection centers and farmers
- Identify top and bottom performers
- Track percentage changes and trends

### 3. Predictive Analytics
- Forecast milk production for 30/60/90 days
- Project farmer growth and cattle population
- Identify seasonal patterns
- Predict stock depletion dates

### 4. Alerts & Notifications
- Production drop alerts
- Low stock warnings
- Loan default notifications
- Insurance lapse alerts
- Quality concern notifications

### 5. Report Generation & Export
- Generate comprehensive reports (monthly, quarterly, annual)
- Export to PDF, Excel, and CSV formats
- Schedule automated report generation
- Government submission reports with data anonymization

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Firebase project with Firestore and Cloud Functions enabled
- Required packages (see `pubspec.yaml`)

### Installation

1. Ensure all dependencies are installed:
```bash
flutter pub get
```

2. Deploy Cloud Functions:
```bash
cd functions
npm install
firebase deploy --only functions
```

3. Configure Firestore indexes (see `firestore.indexes.json`)

### Usage

#### Accessing Analytics Dashboard

```dart
import 'package:go_router/go_router.dart';

// Navigate to analytics dashboard
context.go('/analytics');
```

#### Using Analytics Providers

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livestock/features/analytics/presentation/providers/analytics_providers.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch analytics summary
    final summaryAsync = ref.watch(analyticsSummaryProvider);
    
    return summaryAsync.when(
      data: (summary) => Text('Total Farmers: ${summary.farmerMetrics.totalFarmers}'),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

#### Applying Filters

```dart
// Create a custom filter
final customFilter = AnalyticsFilter(
  dateRange: DateRange(
    startDate: DateTime(2024, 1, 1),
    endDate: DateTime(2024, 12, 31),
  ),
  cooperativeIds: ['coop123'],
);

// Use with providers
final milkMetrics = await ref.read(
  getMilkProductionAnalyticsUseCaseProvider.future
).then((useCase) => useCase(customFilter));
```

## Adding New Analytics Metrics

### Step 1: Define the Entity

Create a new entity in `domain/entities/`:

```dart
import 'package:equatable/equatable.dart';

class MyNewMetrics extends Equatable {
  final int totalCount;
  final double averageValue;
  final Map<String, int> distribution;
  
  const MyNewMetrics({
    required this.totalCount,
    required this.averageValue,
    required this.distribution,
  });
  
  // Add computed properties
  double get percentageChange => /* calculation */;
  
  @override
  List<Object?> get props => [totalCount, averageValue, distribution];
}
```

### Step 2: Add Repository Method

Update `domain/repositories/analytics_repository.dart`:

```dart
abstract class AnalyticsRepository {
  // ... existing methods
  
  Future<Result<MyNewMetrics>> getMyNewMetrics(AnalyticsFilter filter);
}
```

### Step 3: Create Use Case

Create `domain/usecases/get_my_new_metrics.dart`:

```dart
import '../entities/my_new_metrics.dart';
import '../entities/analytics_filter.dart';
import '../repositories/analytics_repository.dart';
import '../../core/result.dart';

class GetMyNewMetrics {
  final AnalyticsRepository repository;
  
  GetMyNewMetrics(this.repository);
  
  Future<Result<MyNewMetrics>> call(AnalyticsFilter filter) {
    return repository.getMyNewMetrics(filter);
  }
}
```

### Step 4: Create Data Model

Create `data/models/my_new_metrics_model.dart`:

```dart
import '../../domain/entities/my_new_metrics.dart';

class MyNewMetricsModel extends MyNewMetrics {
  const MyNewMetricsModel({
    required super.totalCount,
    required super.averageValue,
    required super.distribution,
  });
  
  factory MyNewMetricsModel.fromJson(Map<String, dynamic> json) {
    return MyNewMetricsModel(
      totalCount: json['totalCount'] as int,
      averageValue: (json['averageValue'] as num).toDouble(),
      distribution: Map<String, int>.from(json['distribution'] as Map),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'totalCount': totalCount,
      'averageValue': averageValue,
      'distribution': distribution,
    };
  }
}
```

### Step 5: Implement Repository Method

Update `data/repositories/analytics_repository_impl.dart`:

```dart
@override
Future<Result<MyNewMetrics>> getMyNewMetrics(AnalyticsFilter filter) async {
  try {
    // Check cache first
    final cacheKey = cacheManager.generateCacheKey(filter, 'my_new_metrics');
    final cached = await cacheManager.getCached<MyNewMetricsModel>(
      cacheKey,
      MyNewMetricsModel.fromJson,
    );
    
    if (cached != null) {
      return Result.success(cached);
    }
    
    // Fetch from remote
    final metrics = await remoteDataSource.getMyNewMetrics(
      AnalyticsFilterModel.fromEntity(filter),
    );
    
    // Cache the result
    await cacheManager.cache(cacheKey, metrics, (m) => m.toJson());
    
    return Result.success(metrics);
  } catch (e) {
    return Result.failure('Failed to fetch metrics: $e');
  }
}
```

### Step 6: Add Remote Data Source Method

Update `data/datasources/analytics_remote_datasource.dart`:

```dart
Future<MyNewMetricsModel> getMyNewMetrics(AnalyticsFilterModel filter) async {
  // Option 1: Firestore aggregation query
  final query = firestore
    .collection('my_collection')
    .where('date', isGreaterThanOrEqualTo: filter.dateRange.startDate)
    .where('date', isLessThanOrEqualTo: filter.dateRange.endDate);
    
  final snapshot = await query.get();
  
  // Aggregate data
  int totalCount = snapshot.docs.length;
  double sum = 0;
  Map<String, int> distribution = {};
  
  for (var doc in snapshot.docs) {
    sum += doc.data()['value'] as num;
    // ... aggregate logic
  }
  
  return MyNewMetricsModel(
    totalCount: totalCount,
    averageValue: sum / totalCount,
    distribution: distribution,
  );
  
  // Option 2: Call Cloud Function for complex aggregations
  final result = await functions.httpsCallable('calculateMyNewMetrics').call({
    'filter': filter.toJson(),
  });
  
  return MyNewMetricsModel.fromJson(result.data);
}
```

### Step 7: Add Provider

Update `presentation/providers/analytics_providers.dart`:

```dart
final getMyNewMetricsUseCaseProvider = FutureProvider<GetMyNewMetrics>((ref) async {
  final repository = await ref.watch(analyticsRepositoryProvider.future);
  return GetMyNewMetrics(repository);
});

final myNewMetricsProvider = FutureProvider<MyNewMetrics>((ref) async {
  final filter = ref.watch(analyticsFilterProvider);
  final useCase = await ref.watch(getMyNewMetricsUseCaseProvider.future);
  
  final result = await useCase(filter);
  
  if (result.isSuccess) {
    return result.dataOrNull!;
  } else {
    throw Exception(result.errorOrNull ?? 'Unknown error');
  }
});
```

### Step 8: Create UI Component

Create a widget to display the metrics:

```dart
class MyNewMetricsCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(myNewMetricsProvider);
    
    return metricsAsync.when(
      data: (metrics) => Card(
        child: Column(
          children: [
            Text('Total: ${metrics.totalCount}'),
            Text('Average: ${metrics.averageValue.toStringAsFixed(2)}'),
            // ... display distribution
          ],
        ),
      ),
      loading: () => SkeletonLoader(),
      error: (error, stack) => ErrorWidget(error),
    );
  }
}
```

## Creating Custom Reports

### Step 1: Define Report Template

```dart
final customTemplate = ReportTemplate(
  id: 'custom_report_001',
  name: 'Custom Monthly Report',
  type: ReportType.customReport,
  sections: [
    ReportSection.milkProduction,
    ReportSection.farmerDemographics,
    ReportSection.financial,
  ],
  frequency: ReportFrequency.monthly,
  defaultFormat: ExportFormat.pdf,
);
```

### Step 2: Generate Report

```dart
// Using the use case
final generateReportUseCase = ref.read(generateReportUseCaseProvider);

final result = await generateReportUseCase(
  template: customTemplate,
  filter: AnalyticsFilter.thisMonth(),
  format: ExportFormat.pdf,
);

if (result.isSuccess) {
  final reportDocument = result.dataOrNull!;
  // Export or display the report
}
```

### Step 3: Export Report

```dart
final exportReportUseCase = ref.read(exportReportUseCaseProvider);

final exportResult = await exportReportUseCase(
  report: reportDocument,
  format: ExportFormat.pdf,
);

if (exportResult.isSuccess) {
  final filePath = exportResult.dataOrNull!;
  // Share or save the file
  await Share.shareFiles([filePath]);
}
```

### Step 4: Schedule Automated Reports

```dart
final scheduleReportUseCase = ref.read(scheduleReportUseCaseProvider);

await scheduleReportUseCase(
  template: customTemplate,
  frequency: ReportFrequency.weekly,
  recipientEmails: ['manager@cooperative.com'],
);
```

## Cloud Functions Deployment

### Prerequisites

1. Install Firebase CLI:
```bash
npm install -g firebase-tools
```

2. Login to Firebase:
```bash
firebase login
```

### Deploying Functions

1. Navigate to functions directory:
```bash
cd functions
```

2. Install dependencies:
```bash
npm install
```

3. Deploy all functions:
```bash
firebase deploy --only functions
```

4. Deploy specific function:
```bash
firebase deploy --only functions:calculateMilkProductionMetrics
```

### Available Cloud Functions

- `calculateMilkProductionMetrics`: Aggregates milk production data
- `calculateFarmerDemographics`: Aggregates farmer demographic data
- `calculateLivestockMetrics`: Aggregates livestock data
- `calculateFinancialMetrics`: Aggregates financial data
- `calculateInventoryMetrics`: Aggregates inventory data
- `generateComparativeAnalytics`: Compares metrics across periods
- `generatePredictiveAnalytics`: Generates forecasts and predictions
- `generateReport`: Creates comprehensive reports
- `scheduledReportGenerator`: Runs daily to generate scheduled reports
- `alertGenerator`: Runs hourly to check for alert conditions

### Function Configuration

Edit `functions/src/config.ts` to configure:

```typescript
export const config = {
  cacheExpiration: 3600, // 1 hour in seconds
  maxForecastDays: 90,
  alertThresholds: {
    productionDrop: 0.8, // 80% of average
    lowStock: 10, // items
    loanDefaultRate: 0.1, // 10%
  },
};
```

## Performance Optimization

### Caching Strategy

The analytics feature uses a multi-level caching strategy:

1. **In-Memory Cache**: Fast access for frequently used data
2. **SQLite Cache**: Persistent local storage for offline access
3. **Firestore Cache**: Built-in Firestore offline persistence

Cache TTL (Time To Live):
- Analytics summaries: 1 hour
- Detailed metrics: 30 minutes
- Real-time alerts: No cache (always fresh)

### Query Optimization

1. **Use Composite Indexes**: Ensure Firestore indexes are created for complex queries
2. **Limit Query Results**: Use pagination for large datasets
3. **Aggregate in Cloud Functions**: Move heavy computations to Cloud Functions
4. **Pre-aggregate Data**: Run nightly jobs to pre-calculate common metrics

### UI Optimization

1. **Progressive Loading**: Load KPIs first, then charts
2. **Lazy Loading**: Load charts as user scrolls
3. **Data Sampling**: Display sampled data for large datasets
4. **Skeleton Loaders**: Show loading placeholders for better UX

## Troubleshooting

### Common Issues

#### 1. Analytics Not Loading

**Problem**: Dashboard shows loading indefinitely

**Solutions**:
- Check internet connection
- Verify Firestore rules allow read access
- Check Cloud Functions are deployed
- Clear app cache: `flutter clean && flutter pub get`

#### 2. Incorrect Metrics

**Problem**: Metrics don't match expected values

**Solutions**:
- Verify date range filter is correct
- Check cooperative/center filters are applied
- Clear cache and refresh data
- Verify Firestore data integrity

#### 3. Report Generation Fails

**Problem**: Report export returns error

**Solutions**:
- Check storage permissions
- Verify report template is valid
- Ensure sufficient device storage
- Check Cloud Function logs for errors

#### 4. Slow Performance

**Problem**: Dashboard takes too long to load

**Solutions**:
- Enable caching in settings
- Reduce date range for queries
- Use data sampling for large datasets
- Check network connection speed

### Debug Mode

Enable debug logging:

```dart
// In main.dart
void main() {
  // Enable debug logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  
  runApp(MyApp());
}
```

## Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/features/analytics/domain/usecases/get_analytics_summary_test.dart

# Run with coverage
flutter test --coverage
```

### Test Structure

```
test/features/analytics/
├── domain/
│   ├── entities/          # Entity tests
│   └── usecases/          # Use case tests with mocks
├── data/
│   ├── models/            # Model serialization tests
│   ├── repositories/      # Repository tests with mocks
│   └── services/          # Service tests
└── presentation/
    └── widgets/           # Widget tests
```

## Contributing

When contributing to the analytics feature:

1. Follow Clean Architecture principles
2. Add dartdoc comments to public APIs
3. Write tests for new functionality
4. Update this README with new features
5. Ensure code passes linting: `flutter analyze`
6. Format code: `flutter format .`

## License

Copyright © 2024 AgriPOA. All rights reserved.
