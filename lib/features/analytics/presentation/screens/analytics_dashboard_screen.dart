import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/analytics_providers.dart';
import '../providers/background_cache_provider.dart';
import '../widgets/analytics_filter_dialog.dart';
import '../widgets/report_generation_dialog.dart';
import '../widgets/kpi_card.dart';
import '../widgets/skeleton_loader.dart';
import '../../domain/entities/analytics_summary.dart';
import 'milk_production_tab.dart';
import 'farmer_demographics_tab.dart';
import 'livestock_analytics_tab.dart';
import 'financial_analytics_tab.dart';
import 'inventory_analytics_tab.dart';
import 'alerts_screen.dart';
import 'package:hugeicons/hugeicons.dart';

/// Main Analytics Dashboard Screen (Task 19)
/// 
/// Provides comprehensive analytics visualization with:
/// - KPI summary cards
/// - Tab navigation for different analytics categories
/// - Filter and export functionality
/// - Pull-to-refresh support
class AnalyticsDashboardScreen extends ConsumerStatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  ConsumerState<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends ConsumerState<AnalyticsDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    
    // Initialize background cache service (Task 31.4)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Trigger the async provider to initialize background cache
      ref.read(backgroundCacheInitializerProvider);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(analyticsSummaryProvider);
    final unreadAlertsCount = ref.watch(unreadAlertsCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        actions: [
          // Alert badge button (Task 27.2)
          IconButton(
            icon: Badge(
              label: Text(unreadAlertsCount.toString()),
              isLabelVisible: unreadAlertsCount > 0,
              child: const Icon(Icons.notifications),
            ),
            onPressed: () => _navigateToAlerts(context),
            tooltip: 'Alerts',
          ),
          // Filter button
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
            tooltip: 'Filter',
          ),
          // Export button
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () => _showReportDialog(context),
            tooltip: 'Export Report',
          ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshData(),
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs:  [
            Tab(text: 'Overview', icon: HugeIcon(icon:HugeIcons.strokeRoundedDashboardSquare01)),
            Tab(text: 'Milk Production', icon: HugeIcon(
      icon: HugeIcons.strokeRoundedAnalyticsUp,
      
    )),
            Tab(text: 'Farmers', icon: HugeIcon(
      icon: HugeIcons.strokeRoundedAnalytics03,
      size: 20.0)),
            Tab(text: 'Livestock', icon: HugeIcon(
      icon: HugeIcons.strokeRoundedChartBubble02,
      size: 20.0,
     
    )),
            Tab(text: 'Financial', icon: HugeIcon(
      icon: HugeIcons.strokeRoundedMarketAnalysis,
      size: 20.0,
     
    )),
            Tab(text: 'Inventory', icon: HugeIcon(
      icon: HugeIcons.strokeRoundedAnalysisTextLink,
      size: 20.0,

    )),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: summaryAsync.when(
          data: (summary) => _buildDashboardContent(summary),
          loading: () => _buildLoadingState(), // Task 31.1 - Progressive loading
          error: (error, stack) => _buildErrorState(error),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(AnalyticsSummary summary) {
    return Column(
      children: [
        // KPI Summary Section (Task 19.2)
        _buildKpiSummarySection(summary),
        const Divider(height: 1),
        // Tab Content (Task 19.3)
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(summary),
              _buildMilkProductionTab(),
              _buildFarmersTab(),
              _buildLivestockTab(),
              _buildFinancialTab(),
              _buildInventoryTab(),
            ],
          ),
        ),
      ],
    );
  }

  /// KPI Summary Section (Task 19.2)
  /// 
  /// Displays key metrics at the top of the dashboard
  Widget _buildKpiSummarySection(AnalyticsSummary summary) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(
              width: 180,
              child: KpiCard(
                title: 'Total Farmers',
                value: summary.farmerMetrics.totalFarmers.toString(),
                subtitle: '${summary.farmerMetrics.newFarmersThisPeriod} new',
                icon: Icons.people,
                color: Colors.blue,
                percentageChange: _calculateFarmerGrowthRate(summary),
                onTap: () => _navigateToTab(2), // Farmers tab
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 180,
              child: KpiCard(
                title: 'Milk Today',
                value: '${summary.milkMetrics.totalLiters.toStringAsFixed(0)}L',
                subtitle: 'Avg: ${summary.milkMetrics.averageLitersPerDay.toStringAsFixed(1)}L/day',
                icon: Icons.water_drop,
                color: Colors.green,
                percentageChange: summary.milkMetrics.percentageChange,
                onTap: () => _navigateToTab(1), // Milk Production tab
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 180,
              child: KpiCard(
                title: 'Active Loans',
                value: summary.financialMetrics.loanMetrics.activeLoanCount.toString(),
                subtitle: 'Repayment: ${(summary.financialMetrics.loanMetrics.repaymentRate * 100).toStringAsFixed(1)}%',
                icon: Icons.account_balance,
                color: Colors.orange,
                onTap: () => _navigateToTab(4), // Financial tab
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 180,
              child: KpiCard(
                title: 'Active Policies',
                value: summary.financialMetrics.insuranceMetrics.activePolicies.toString(),
                subtitle: 'Coverage: ${(summary.financialMetrics.insuranceMetrics.coveragePercentage * 100).toStringAsFixed(1)}%',
                icon: Icons.shield,
                color: Colors.purple,
                onTap: () => _navigateToTab(4), // Financial tab
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Overview Tab (Task 19.4)
  /// 
  /// Displays summary KPIs from all categories
  Widget _buildOverviewTab(AnalyticsSummary summary) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Period: ${_formatDate(summary.startDate)} - ${_formatDate(summary.endDate)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),
          
          // Milk Production Summary
          _buildSectionHeader('Milk Production'),
          const SizedBox(height: 12),
          _buildOverviewMetricRow(
            'Total Liters',
            '${summary.milkMetrics.totalLiters.toStringAsFixed(0)}L',
            Icons.water_drop,
            Colors.blue,
          ),
          _buildOverviewMetricRow(
            'Average per Farmer',
            '${summary.milkMetrics.averageLitersPerFarmer.toStringAsFixed(1)}L',
            Icons.person,
            Colors.blue,
          ),
          const SizedBox(height: 24),
          
          // Farmer Summary
          _buildSectionHeader('Farmers'),
          const SizedBox(height: 12),
          _buildOverviewMetricRow(
            'Total Farmers',
            summary.farmerMetrics.totalFarmers.toString(),
            Icons.people,
            Colors.green,
          ),
          _buildOverviewMetricRow(
            'App Access',
            '${summary.farmerMetrics.farmersWithAppAccess} (${((summary.farmerMetrics.farmersWithAppAccess / summary.farmerMetrics.totalFarmers) * 100).toStringAsFixed(1)}%)',
            Icons.phone_android,
            Colors.green,
          ),
          const SizedBox(height: 24),
          
          // Livestock Summary
          _buildSectionHeader('Livestock'),
          const SizedBox(height: 12),
          _buildOverviewMetricRow(
            'Total Cattle',
            summary.livestockMetrics.totalCattle.toString(),
            Icons.pets,
            Colors.orange,
          ),
          _buildOverviewMetricRow(
            'Lactation Rate',
            '${(summary.livestockMetrics.lactationRate * 100).toStringAsFixed(1)}%',
            Icons.water_drop,
            Colors.orange,
          ),
          const SizedBox(height: 24),
          
          // Financial Summary
          _buildSectionHeader('Financial'),
          const SizedBox(height: 12),
          _buildOverviewMetricRow(
            'Total Revenue',
            'TZS ${_formatCurrency(summary.financialMetrics.totalRevenue)}',
            Icons.attach_money,
            Colors.purple,
          ),
          _buildOverviewMetricRow(
            'Milk Payments',
            'TZS ${_formatCurrency(summary.financialMetrics.totalMilkPayments)}',
            Icons.payment,
            Colors.purple,
          ),
          const SizedBox(height: 24),
          
          // Inventory Summary
          _buildSectionHeader('Inventory'),
          const SizedBox(height: 12),
          _buildOverviewMetricRow(
            'Total Value',
            'TZS ${_formatCurrency(summary.inventoryMetrics.totalInventoryValue)}',
            Icons.inventory,
            Colors.teal,
          ),
          _buildOverviewMetricRow(
            'Low Stock Items',
            summary.inventoryMetrics.lowStockProducts.toString(),
            Icons.warning,
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildOverviewMetricRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  // Milk Production Tab (Task 20)
  Widget _buildMilkProductionTab() {
    return const MilkProductionTab();
  }

  Widget _buildFarmersTab() {
    return const FarmerDemographicsTab();
  }

  Widget _buildLivestockTab() {
    return const LivestockAnalyticsTab();
  }

  Widget _buildFinancialTab() {
    return const FinancialAnalyticsTab();
  }

  Widget _buildInventoryTab() {
    return const InventoryAnalyticsTab();
  }

  /// Loading state with skeleton loaders (Task 31.1)
  Widget _buildLoadingState() {
    return Column(
      children: [
        // KPI skeleton loaders
        Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                4,
                (index) => Padding(
                  padding: EdgeInsets.only(right: index < 3 ? 12 : 0),
                  child: const SizedBox(
                    width: 180,
                    child: KpiCardSkeleton(),
                  ),
                ),
              ),
            ),
          ),
        ),
        const Divider(height: 1),
        // Content skeleton loaders
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const ChartSkeleton(height: 200),
              const SizedBox(height: 16),
              const ChartSkeleton(height: 150),
              const SizedBox(height: 16),
              const ChartSkeleton(height: 200),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading analytics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final currentFilter = ref.read(analyticsFilterProvider);
    
    showDialog(
      context: context,
      builder: (context) => AnalyticsFilterDialog(
        currentFilter: currentFilter,
        onApply: (newFilter) {
          // Update filter provider
          // Note: Since analyticsFilterProvider is a Provider (not StateProvider),
          // we need to create a StateProvider version or use a StateNotifier
          // For now, this is a placeholder
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ReportGenerationDialog(
        onGenerate: (template, format, sections) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Report generation coming soon'),
            ),
          );
        },
      ),
    );
  }

  Future<void> _refreshData() async {
    // Invalidate providers to trigger refresh
    ref.invalidate(analyticsSummaryProvider);
    ref.invalidate(milkProductionAnalyticsProvider);
    ref.invalidate(farmerDemographicsProvider);
    ref.invalidate(livestockAnalyticsProvider);
    ref.invalidate(financialAnalyticsProvider);
    ref.invalidate(inventoryAnalyticsProvider);
  }

  void _navigateToTab(int index) {
    _tabController.animateTo(index);
  }

  double? _calculateFarmerGrowthRate(AnalyticsSummary summary) {
    if (summary.farmerMetrics.totalFarmers == 0) return null;
    return (summary.farmerMetrics.newFarmersThisPeriod / 
            summary.farmerMetrics.totalFarmers) * 100;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }

  /// Navigate to alerts screen (Task 27.2)
  void _navigateToAlerts(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AlertsScreen(),
      ),
    );
  }
}
