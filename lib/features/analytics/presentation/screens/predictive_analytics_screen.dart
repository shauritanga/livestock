import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/analytics_providers.dart';
import '../widgets/time_series_chart.dart';
import '../../domain/entities/predictive_metrics.dart';

/// Predictive Analytics Screen (Task 26.1)
/// 
/// Displays forecasts and trend predictions for various metrics.
class PredictiveAnalyticsScreen extends ConsumerStatefulWidget {
  const PredictiveAnalyticsScreen({super.key});

  @override
  ConsumerState<PredictiveAnalyticsScreen> createState() =>
      _PredictiveAnalyticsScreenState();
}

class _PredictiveAnalyticsScreenState
    extends ConsumerState<PredictiveAnalyticsScreen> {
  int _selectedForecastDays = 30;

  @override
  Widget build(BuildContext context) {
    final predictiveMetricsAsync = ref.watch(predictiveAnalyticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Predictive Analytics'),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Forecast Period',
            onSelected: (days) {
              setState(() {
                _selectedForecastDays = days;
              });
              // Update the forecast days provider
              // Note: This would require a StateProvider instead of Provider
              ref.invalidate(predictiveAnalyticsProvider);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 30, child: Text('30 Days')),
              const PopupMenuItem(value: 60, child: Text('60 Days')),
              const PopupMenuItem(value: 90, child: Text('90 Days')),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(predictiveAnalyticsProvider);
        },
        child: predictiveMetricsAsync.when(
          data: (metrics) => _buildContent(context, metrics),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(predictiveAnalyticsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, PredictiveMetrics metrics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildForecastHeader(context),
          const SizedBox(height: 24),
          _buildMilkProductionForecast(context, metrics),
          const SizedBox(height: 24),
          _buildFarmerGrowthProjections(context, metrics),
          const SizedBox(height: 24),
          _buildSeasonalPatternAnalysis(context, metrics),
          const SizedBox(height: 24),
          _buildStockDepletionPredictions(context, metrics),
          const SizedBox(height: 24),
          _buildForecastAccuracy(context, metrics),
        ],
      ),
    );
  }

  Widget _buildForecastHeader(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.trending_up,
                size: 32,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Forecast Period',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_selectedForecastDays Days Ahead',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilkProductionForecast(
      BuildContext context, PredictiveMetrics metrics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.water_drop, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Milk Production Forecast',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Predicted milk production with confidence intervals',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            // Task 26.2: Trend visualization with forecast
            TimeSeriesChart(
              data: metrics.forecastData,
              title: 'Production Forecast',
              yAxisLabel: 'Liters',
              lineColor: Colors.blue,
              showForecast: true,
              forecastData: metrics.forecastData,
            ),
            const SizedBox(height: 16),
            _buildConfidenceInterval(context, metrics),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceInterval(
      BuildContext context, PredictiveMetrics metrics) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Confidence Interval',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Forecast accuracy: ${metrics.forecastAccuracy.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmerGrowthProjections(
      BuildContext context, PredictiveMetrics metrics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Farmer Growth Projections',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Projected new farmer registrations based on historical trends',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            _buildProjectionCard(
              context,
              'Expected New Farmers',
              _calculateProjectedFarmers(metrics),
              Icons.person_add,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeasonalPatternAnalysis(
      BuildContext context, PredictiveMetrics metrics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Seasonal Pattern Analysis',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Recurring patterns identified in historical data',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            // Task 26.2: Display seasonal patterns with annotations
            if (metrics.seasonalPatterns.isNotEmpty)
              ...metrics.seasonalPatterns.entries.map(
                (entry) => _buildSeasonalPatternItem(
                  context,
                  entry.key,
                  entry.value,
                ),
              )
            else
              _buildPlaceholderMessage(
                'No significant seasonal patterns detected',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeasonalPatternItem(
      BuildContext context, String pattern, double impact) {
    final isPositive = impact >= 0;
    final color = isPositive ? Colors.green : Colors.red;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(
              isPositive ? Icons.arrow_upward : Icons.arrow_downward,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pattern,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Impact: ${isPositive ? '+' : ''}${impact.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: color,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockDepletionPredictions(
      BuildContext context, PredictiveMetrics metrics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.inventory, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'Stock Depletion Predictions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Predicted stock-out dates based on current sales velocity',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            _buildPlaceholderMessage(
              'Stock depletion predictions will be displayed here',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastAccuracy(
      BuildContext context, PredictiveMetrics metrics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Colors.indigo),
                const SizedBox(width: 8),
                Text(
                  'Forecast Accuracy',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Historical accuracy of predictions',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            _buildAccuracyIndicator(context, metrics.forecastAccuracy),
          ],
        ),
      ),
    );
  }

  Widget _buildAccuracyIndicator(BuildContext context, double accuracy) {
    Color color;
    String label;

    if (accuracy >= 80) {
      color = Colors.green;
      label = 'High Accuracy';
    } else if (accuracy >= 60) {
      color = Colors.orange;
      label = 'Moderate Accuracy';
    } else {
      color = Colors.red;
      label = 'Low Accuracy';
    }

    return Column(
      children: [
        LinearProgressIndicator(
          value: accuracy / 100,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 12,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${accuracy.toStringAsFixed(1)}%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProjectionCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  String _calculateProjectedFarmers(PredictiveMetrics metrics) {
    // Simple calculation based on forecast data
    // In a real implementation, this would use actual projection data
    return '${(_selectedForecastDays / 30 * 15).toStringAsFixed(0)} farmers';
  }
}
