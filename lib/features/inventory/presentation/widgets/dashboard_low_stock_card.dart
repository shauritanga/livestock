import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livestock/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:livestock/features/inventory/presentation/screens/inventory_list_screen.dart';

/// Dashboard card showing low stock alert
class DashboardLowStockCard extends ConsumerWidget {
  const DashboardLowStockCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lowStockCountAsync = ref.watch(lowStockCountProvider);

    return lowStockCountAsync.when(
      data: (count) {
        if (count == 0) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.orange.shade300, width: 2),
          ),
          child: InkWell(
            onTap: () {
              // Navigate to inventory with low stock filter
              ref
                  .read(stockStatusFilterProvider.notifier)
                  .setFilter(StockStatusFilter.lowStock);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const InventoryListScreen(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.shade50,
                    Colors.orange.shade100,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade600,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Low Stock Alert',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$count ${count == 1 ? 'product needs' : 'products need'} restocking',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.orange.shade700,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
