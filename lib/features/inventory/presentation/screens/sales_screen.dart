import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:livestock/features/inventory/presentation/providers/sales_providers.dart';
import 'package:livestock/features/inventory/presentation/screens/record_sale_screen.dart';
import 'package:livestock/features/inventory/presentation/widgets/sale_card.dart';
import 'package:livestock/routes/app_router.dart';

/// Sales screen showing list of recorded sales
class SalesScreen extends ConsumerWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(salesProvider);
    final todaySalesAsync = ref.watch(todaySalesProvider);
    final weekSalesAsync = ref.watch(thisWeekSalesProvider);
    final monthSalesAsync = ref.watch(thisMonthSalesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context, ref);
            },
          ),
        ],
      ),
      floatingActionButton: _ExpandableFab(
        onMilkSalePressed: () {
          context.push(AppRoutes.recordMilkSale);
        },
        onProductSalePressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const RecordSaleScreen(),
            ),
          );
        },
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(salesProvider);
          ref.invalidate(todaySalesProvider);
          ref.invalidate(thisWeekSalesProvider);
          ref.invalidate(thisMonthSalesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Summary Cards
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSummaryCard(
                    context,
                    'Today',
                    todaySalesAsync,
                    Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  _buildSummaryCard(
                    context,
                    'This Week',
                    weekSalesAsync,
                    Colors.green,
                  ),
                  const SizedBox(width: 12),
                  _buildSummaryCard(
                    context,
                    'This Month',
                    monthSalesAsync,
                    Colors.orange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sales List Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Sales',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Sales List
            salesAsync.when(
              data: (summary) {
                if (summary.sales.isEmpty) {
                  return _buildEmptyState(context);
                }

                return Column(
                  children: summary.sales.map((sale) {
                    return SaleCard(
                      sale: sale,
                      onTap: () {
                        _showSaleDetails(context, sale);
                      },
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => Center(
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(salesProvider);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    AsyncValue summary,
    Color color,
  ) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: summary.when(
        data: (data) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'TZS ${NumberFormat('#,##0').format(data.totalRevenue)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${data.totalCount} sales',
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.7),
              ),
            ),
          ],
        ),
        loading: () => const Center(
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        error: (_, __) => const Text('Error'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No sales recorded yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Record your first sale to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Sales'),
        content: const Text('Date range filter - to be implemented'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSaleDetails(BuildContext context, sale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sale Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product: ${sale.productName}'),
            Text('Quantity: ${sale.quantity} units'),
            Text('Unit Price: TZS ${NumberFormat('#,##0').format(sale.unitPrice)}'),
            Text('Total: TZS ${NumberFormat('#,##0').format(sale.totalAmount)}'),
            if (sale.customerName != null)
              Text('Customer: ${sale.customerName}'),
            if (sale.notes != null) Text('Notes: ${sale.notes}'),
            Text('Date: ${DateFormat('MMM d, yyyy h:mm a').format(sale.timestamp)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}


/// Expandable FAB widget for recording sales
class _ExpandableFab extends StatefulWidget {
  final VoidCallback onMilkSalePressed;
  final VoidCallback onProductSalePressed;

  const _ExpandableFab({
    required this.onMilkSalePressed,
    required this.onProductSalePressed,
  });

  @override
  State<_ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<_ExpandableFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Milk Sale Button
        ScaleTransition(
          scale: _expandAnimation,
          child: FadeTransition(
            opacity: _expandAnimation,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Label
                  Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Text(
                        'Milk Sale',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Button
                  FloatingActionButton(
                    heroTag: 'milk_sale',
                    onPressed: () {
                      _toggle();
                      widget.onMilkSalePressed();
                    },
                    backgroundColor: Colors.blue,
                    child: const Icon(Icons.water_drop),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Product Sale Button
        ScaleTransition(
          scale: _expandAnimation,
          child: FadeTransition(
            opacity: _expandAnimation,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Label
                  Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Text(
                        'Product Sale',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Button
                  FloatingActionButton(
                    heroTag: 'product_sale',
                    onPressed: () {
                      _toggle();
                      widget.onProductSalePressed();
                    },
                    backgroundColor: Colors.green,
                    child: const Icon(Icons.inventory_2),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Main FAB
        FloatingActionButton(
          heroTag: 'main_fab',
          onPressed: _toggle,
          backgroundColor: _isExpanded ? Colors.red : Colors.deepPurple,
          child: AnimatedRotation(
            turns: _isExpanded ? 0.125 : 0, // 45 degrees when expanded
            duration: const Duration(milliseconds: 250),
            child: Icon(_isExpanded ? Icons.close : Icons.add),
          ),
        ),
      ],
    );
  }
}
