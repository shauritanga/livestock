import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:livestock/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:livestock/l10n/app_localizations.dart';

/// Enhanced summary card showing collection, inventory, and sales data
class EnhancedSummaryCard extends ConsumerWidget {
  const EnhancedSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final salesAsync = ref.watch(todaysSalesSummaryProvider);
    final inventoryAsync = ref.watch(inventoryStatusProvider);

    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context).todayCollection,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    DateFormat('MMM d').format(DateTime.now()),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Milk Flow Summary (Collected → Sold → Revenue)
            Row(
              children: [
                Expanded(
                  child: summaryAsync.when(
                    data: (summary) => _SummaryItem(
                      icon: Icons.water_drop,
                      label: 'Collected',
                      value: '${NumberFormat('#,##0.#', 'en_US').format(summary.totalLiters)}L',
                      subtitle: '${summary.farmerCount} farmers',
                      color: Colors.blue,
                    ),
                    loading: () => const Center(child: SizedBox(height: 60, child: CircularProgressIndicator())),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: salesAsync.when(
                    data: (sales) => _SummaryItem(
                      icon: Icons.local_shipping,
                      label: 'Sold',
                      value: '${NumberFormat('#,##0.#', 'en_US').format(sales['totalLiters'] as double)}L',
                      subtitle: '${sales['salesCount']} sales',
                      color: Colors.green,
                    ),
                    loading: () => const Center(child: SizedBox(height: 60, child: CircularProgressIndicator())),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: salesAsync.when(
                    data: (sales) => _SummaryItem(
                      icon: Icons.payments,
                      label: 'Revenue',
                      value: 'TZS ${NumberFormat('#,##0', 'en_US').format(sales['totalRevenue'] as double)}',
                      subtitle: 'received',
                      color: Colors.orange,
                      fontSize: 14,
                    ),
                    loading: () => const Center(child: SizedBox(height: 60, child: CircularProgressIndicator())),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),
              ],
            ),

            const Divider(height: 32),

            // Inventory Status
            inventoryAsync.when(
              data: (inventory) => _InventorySection(
                totalQuantity: inventory['totalQuantity'] as double,
                hasLowStock: inventory['hasLowStock'] as bool,
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 16),

            // Sales Summary
            salesAsync.when(
              data: (sales) => _SalesSection(
                totalLiters: sales['totalLiters'] as double,
                totalRevenue: sales['totalRevenue'] as double,
                salesCount: sales['salesCount'] as int,
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Collection section widget
class _CollectionSection extends StatelessWidget {
  final double totalLiters;
  final int farmerCount;
  final double totalPayment;

  const _CollectionSection({
    required this.totalLiters,
    required this.farmerCount,
    required this.totalPayment,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryItem(
            icon: Icons.water_drop,
            label: 'Collected',
            value: '${NumberFormat('#,##0.#', 'en_US').format(totalLiters)}L',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryItem(
            icon: Icons.people,
            label: 'Farmers',
            value: farmerCount.toString(),
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryItem(
            icon: Icons.payments,
            label: 'Payment',
            value: 'TZS ${NumberFormat('#,##0', 'en_US').format(totalPayment)}',
            color: Colors.orange,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

/// Inventory section widget (simplified - no batches/aging)
class _InventorySection extends StatelessWidget {
  final double totalQuantity;
  final bool hasLowStock;

  const _InventorySection({
    required this.totalQuantity,
    required this.hasLowStock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasLowStock ? Colors.orange.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.inventory_2,
            color: hasLowStock ? Colors.orange.shade700 : Colors.blue.shade700,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Milk Stock',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${NumberFormat('#,##0.#', 'en_US').format(totalQuantity)}L',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: hasLowStock ? Colors.orange.shade700 : Colors.blue.shade700,
                      ),
                    ),
                    if (hasLowStock) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade700,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '⚠️ Low Stock',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Sales section widget
class _SalesSection extends StatelessWidget {
  final double totalLiters;
  final double totalRevenue;
  final int salesCount;

  const _SalesSection({
    required this.totalLiters,
    required this.totalRevenue,
    required this.salesCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.point_of_sale,
            color: Colors.green.shade700,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today\'s Sales',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${NumberFormat('#,##0.#', 'en_US').format(totalLiters)}L',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• TZS ${NumberFormat('#,##0', 'en_US').format(totalRevenue)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade600,
                      ),
                    ),
                    if (salesCount > 0) ...[
                      const SizedBox(width: 8),
                      Text(
                        '($salesCount ${salesCount == 1 ? 'sale' : 'sales'})',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Summary item widget
class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final Color color;
  final double? fontSize;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    required this.color,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize ?? 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
            ),
          ),
        ],
      ],
    );
  }
}

/// Error section widget
class _ErrorSection extends StatelessWidget {
  final String message;

  const _ErrorSection({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: TextStyle(color: Colors.red[700]),
      ),
    );
  }
}

