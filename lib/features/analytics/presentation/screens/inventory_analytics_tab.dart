import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/analytics_providers.dart';
import '../widgets/kpi_card.dart';
import '../widgets/time_series_chart.dart';
import '../widgets/distribution_pie_chart.dart';
import '../widgets/bar_comparison_chart.dart';
import '../../domain/entities/inventory_metrics.dart';
import '../../domain/entities/time_series_data_point.dart';
import '../../../inventory/domain/entities/product_category.dart';

/// Inventory Analytics Tab (Task 24)
/// 
/// Displays comprehensive inventory and sales analytics including:
/// - Total value, low stock count, sales revenue KPIs
/// - Top selling products list
/// - Category breakdown pie chart
/// - Sales trend line chart
/// - Stock turnover rates by category
class InventoryAnalyticsTab extends ConsumerWidget {
  const InventoryAnalyticsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(inventoryAnalyticsProvider);

    return metricsAsync.when(
      data: (metrics) => _buildContent(context, metrics),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(context, error),
    );
  }

  Widget _buildContent(BuildContext context, InventoryMetrics metrics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Cards (Task 24.1)
          _buildKpiSection(context, metrics),
          const SizedBox(height: 24),
          
          // Stock Health Indicator (Task 24.1)
          _buildStockHealthIndicator(context, metrics),
          const SizedBox(height: 24),
          
          // Top Selling Products (Task 24.1)
          _buildTopSellingProducts(context, metrics),
          const SizedBox(height: 24),
          
          // Category Breakdown (Task 24.1)
          _buildCategoryBreakdown(context, metrics),
          const SizedBox(height: 24),
          
          // Sales Trend (Task 24.1)
          _buildSalesTrend(context, metrics),
          const SizedBox(height: 24),
          
          // Stock Turnover Rates (Task 24.1)
          _buildStockTurnoverRates(context, metrics),
        ],
      ),
    );
  }

  /// KPI Cards Section (Task 24.1)
  Widget _buildKpiSection(BuildContext context, InventoryMetrics metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Inventory Analytics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: KpiCard(
                title: 'Total Value',
                value: 'TZS ${_formatCurrency(metrics.totalInventoryValue)}',
                icon: Icons.inventory,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KpiCard(
                title: 'Low Stock',
                value: metrics.lowStockProducts.toString(),
                subtitle: '${metrics.lowStockPercentage.toStringAsFixed(1)}% of total',
                icon: Icons.warning,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        KpiCard(
          title: 'Sales Revenue',
          value: 'TZS ${_formatCurrency(metrics.totalSalesRevenue)}',
          subtitle: 'Total sales',
          icon: Icons.shopping_cart,
          color: Colors.green,
        ),
      ],
    );
  }

  /// Stock Health Indicator (Task 24.1)
  Widget _buildStockHealthIndicator(BuildContext context, InventoryMetrics metrics) {
    final healthStatus = metrics.inventoryHealthStatus;
    final color = _getHealthStatusColor(healthStatus);
    
    return Card(
      elevation: 2,
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.health_and_safety, color: color, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inventory Health: $healthStatus',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                      ),
                      Text(
                        '${metrics.productsInGoodStock} of ${metrics.totalProducts} products in good stock',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStockStatusCard(
                    context,
                    'Good Stock',
                    metrics.productsInGoodStock,
                    metrics.stockHealthPercentage,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStockStatusCard(
                    context,
                    'Low Stock',
                    metrics.lowStockProducts,
                    metrics.lowStockPercentage,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStockStatusCard(
                    context,
                    'Out of Stock',
                    metrics.outOfStockProducts,
                    metrics.outOfStockPercentage,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockStatusCard(
    BuildContext context,
    String label,
    int count,
    double percentage,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  /// Top Selling Products List (Task 24.1)
  Widget _buildTopSellingProducts(BuildContext context, InventoryMetrics metrics) {
    final topProducts = metrics.getTopProducts(10);
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Top Selling Products',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                InkWell(
                  onTap: () => _showAllProductsDialog(context, metrics),
                  child: const Text(
                    'View All',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (topProducts.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No sales data available'),
                ),
              )
            else
              ...topProducts.asMap().entries.map((entry) {
                final index = entry.key;
                final product = entry.value;
                return Column(
                  children: [
                    InkWell(
                      onTap: () => _showProductDetails(context, product),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: _getRankColor(index + 1).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _getRankColor(index + 1),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.productName,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  Text(
                                    '${product.salesCount} sales',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'TZS ${_formatCurrency(product.revenue)}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Text(
                                    '${product.totalSales.toStringAsFixed(0)} units',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    if (index < topProducts.length - 1) const Divider(),
                  ],
                );
              }),
          ],
        ),
      ),
    );
  }

  /// Category Breakdown Pie Chart (Task 24.1)
  Widget _buildCategoryBreakdown(BuildContext context, InventoryMetrics metrics) {
    final distribution = <String, double>{};
    
    metrics.categoryBreakdown.forEach((category, categoryMetrics) {
      distribution[_getCategoryDisplayName(category)] = categoryMetrics.totalSales;
    });

    return InkWell(
      onTap: () => _showCategoryBreakdownDialog(context, metrics),
      child: DistributionPieChart(
        distribution: distribution,
        title: 'Sales by Category',
        colors: const [
          Color(0xFF4CAF50), // Green
          Color(0xFF2196F3), // Blue
          Color(0xFFFF9800), // Orange
          Color(0xFF9C27B0), // Purple
          Color(0xFFF44336), // Red
          Color(0xFF00BCD4), // Cyan
        ],
      ),
    );
  }

  /// Sales Trend Line Chart (Task 24.1)
  Widget _buildSalesTrend(BuildContext context, InventoryMetrics metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sales Trend',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        TimeSeriesChart(
          data: metrics.salesTrend.cast<TimeSeriesDataPoint>(),
          title: 'Sales Revenue Over Time',
          yAxisLabel: 'TZS',
          lineColor: Colors.green,
        ),
      ],
    );
  }

  /// Stock Turnover Rates by Category (Task 24.1)
  Widget _buildStockTurnoverRates(BuildContext context, InventoryMetrics metrics) {
    final chartData = metrics.stockTurnoverRates.entries.map((entry) {
      return BarChartDataItem(
        label: _getCategoryDisplayName(entry.key),
        value: entry.value,
      );
    }).toList();

    // Sort by turnover rate descending
    chartData.sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stock Turnover Rates',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        BarComparisonChart(
          data: chartData,
          title: 'Turnover Rate by Category',
          yAxisLabel: 'Turnover Rate',
          primaryColor: Colors.teal,
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 1,
          color: Colors.teal.shade50,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.info, color: Colors.teal),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Overall Turnover Rate: ${metrics.overallStockTurnoverRate.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading inventory analytics',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show All Products Dialog (Task 24.2)
  void _showAllProductsDialog(BuildContext context, InventoryMetrics metrics) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('All Top Selling Products'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: metrics.topSellingProducts.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final product = metrics.topSellingProducts[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getRankColor(index + 1).withValues(alpha: 0.2),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getRankColor(index + 1),
                    ),
                  ),
                ),
                title: Text(product.productName),
                subtitle: Text('${product.salesCount} sales • ${product.totalSales.toStringAsFixed(0)} units'),
                trailing: Text(
                  'TZS ${_formatCurrency(product.revenue)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _showProductDetails(context, product);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Show Product Details Dialog (Task 24.2)
  void _showProductDetails(BuildContext context, dynamic product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.productName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Product ID', product.productId),
            _buildDetailRow('Total Sales', '${product.totalSales.toStringAsFixed(0)} units'),
            _buildDetailRow('Sales Count', product.salesCount.toString()),
            _buildDetailRow('Revenue', 'TZS ${_formatCurrency(product.revenue)}'),
            _buildDetailRow('Average Price', 'TZS ${_formatCurrency(product.averagePrice)}'),
            _buildDetailRow('Rank', '#${product.rank}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToProductDetail(context, product.productId);
            },
            child: const Text('View Product'),
          ),
        ],
      ),
    );
  }

  /// Show Category Breakdown Dialog (Task 24.2)
  void _showCategoryBreakdownDialog(BuildContext context, InventoryMetrics metrics) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Category Breakdown Details'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: metrics.categoryBreakdown.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final entry = metrics.categoryBreakdown.entries.elementAt(index);
              final category = entry.key;
              final categoryMetrics = entry.value;
              
              return ListTile(
                leading: Icon(
                  _getCategoryIcon(category),
                  color: Colors.blue,
                ),
                title: Text(_getCategoryDisplayName(category)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${categoryMetrics.totalProducts} products'),
                    Text('Value: TZS ${_formatCurrency(categoryMetrics.totalValue)}'),
                    Text('Turnover: ${categoryMetrics.stockTurnoverRate.toStringAsFixed(2)}'),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'TZS ${_formatCurrency(categoryMetrics.totalSales)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${categoryMetrics.percentageOfTotalSales.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _navigateToCategoryProducts(context, category);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  /// Navigate to Product Detail (Task 24.2)
  void _navigateToProductDetail(BuildContext context, String productId) {
    // TODO: Navigate to product detail screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing product: $productId'),
      ),
    );
  }

  /// Navigate to Category Products (Task 24.2)
  void _navigateToCategoryProducts(BuildContext context, ProductCategory category) {
    // TODO: Navigate to products list filtered by category
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing products in category: ${_getCategoryDisplayName(category)}'),
      ),
    );
  }

  // Helper methods
  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }

  Color _getHealthStatusColor(String status) {
    switch (status) {
      case 'Excellent':
        return Colors.green;
      case 'Good':
        return Colors.blue;
      case 'Fair':
        return Colors.orange;
      case 'Poor':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return Colors.grey;
    if (rank == 3) return Colors.brown;
    return Colors.blue;
  }

  String _getCategoryDisplayName(ProductCategory category) {
    return category.displayName;
  }

  IconData _getCategoryIcon(ProductCategory category) {
    switch (category) {
      case ProductCategory.animalFeed:
        return Icons.grass;
      case ProductCategory.veterinarySupplies:
        return Icons.medical_services;
      case ProductCategory.farmEquipment:
        return Icons.build;
      case ProductCategory.seeds:
        return Icons.eco;
      case ProductCategory.fertilizers:
        return Icons.water_drop;
      case ProductCategory.other:
        return Icons.category;
    }
  }
}
