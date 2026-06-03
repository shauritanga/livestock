import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:livestock/features/milk_collection/domain/entities/milk_delivery.dart';
import 'package:livestock/features/milk_inventory/domain/entities/inventory_batch.dart';
import 'package:livestock/features/milk_inventory/presentation/providers/milk_inventory_providers.dart';

/// Screen displaying current milk inventory
class MilkInventoryScreen extends ConsumerWidget {
  const MilkInventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryAsync = ref.watch(currentMilkInventoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Milk Inventory'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(currentMilkInventoryProvider);
        },
        child: inventoryAsync.when(
          data: (inventory) {
            if (inventory.isEmpty) {
              return _buildEmptyState(context);
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Total quantity card
                _buildTotalQuantityCard(context, inventory.totalQuantity),
                const SizedBox(height: 16),

                // Quantity by grade
                _buildQuantityByGradeCard(context, inventory.quantityByGrade),
                const SizedBox(height: 16),

                // Batches header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Inventory Batches',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '${inventory.batches.length} batches',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Batches list
                ...inventory.batches.map((batch) => _buildBatchCard(context, batch)),
              ],
            );
          },
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
                  onPressed: () => ref.invalidate(currentMilkInventoryProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalQuantityCard(BuildContext context, double totalQuantity) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Total Available',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '${totalQuantity.toStringAsFixed(1)} L',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityByGradeCard(
    BuildContext context,
    Map<MilkQualityGrade, double> quantityByGrade,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'By Quality Grade',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...MilkQualityGrade.values.map((grade) {
              final quantity = quantityByGrade[grade] ?? 0.0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _getGradeColor(grade),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getGradeName(grade),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    Text(
                      '${quantity.toStringAsFixed(1)} L',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchCard(BuildContext context, InventoryBatch batch) {
    final dateFormat = DateFormat('MMM dd, yyyy h:mm a');
    final isAging = batch.isAging;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isAging ? Colors.orange.withValues(alpha: 0.1) : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getGradeColor(batch.grade),
          child: Text(
            batch.quantity.toStringAsFixed(0),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(
          batch.farmerName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${batch.quantity.toStringAsFixed(1)} L - ${_getGradeName(batch.grade)}'),
            Text(
              dateFormat.format(batch.collectionDate),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isAging)
              const Icon(Icons.warning, color: Colors.orange, size: 20),
            Text(
              '${batch.ageInHours}h old',
              style: TextStyle(
                fontSize: 12,
                color: isAging ? Colors.orange : Colors.grey[600],
                fontWeight: isAging ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No milk in inventory',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Record milk deliveries to see inventory',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }

  Color _getGradeColor(MilkQualityGrade grade) {
    switch (grade) {
      case MilkQualityGrade.premium:
        return Colors.green;
      case MilkQualityGrade.standard:
        return Colors.blue;
      case MilkQualityGrade.substandard:
        return Colors.orange;
    }
  }

  String _getGradeName(MilkQualityGrade grade) {
    switch (grade) {
      case MilkQualityGrade.premium:
        return 'Premium';
      case MilkQualityGrade.standard:
        return 'Standard';
      case MilkQualityGrade.substandard:
        return 'Substandard';
    }
  }
}
