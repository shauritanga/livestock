import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:livestock/features/inventory/domain/entities/product.dart';
import 'package:livestock/features/inventory/domain/entities/stock_transaction_type.dart';
import 'package:livestock/features/inventory/presentation/providers/stock_transaction_providers.dart';

/// Stock audit screen showing transaction history
class StockAuditScreen extends ConsumerWidget {
  final Product product;

  const StockAuditScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(stockTransactionsProvider(product.id));
    final typeFilter = ref.watch(transactionTypeFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Transaction History'),
            Text(
              product.name,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: typeFilter == null,
                  onSelected: (selected) {
                    ref.read(transactionTypeFilterProvider.notifier).clear();
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Additions'),
                  selected: typeFilter == StockTransactionType.addition,
                  onSelected: (selected) {
                    ref
                        .read(transactionTypeFilterProvider.notifier)
                        .setType(StockTransactionType.addition);
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Sales'),
                  selected: typeFilter == StockTransactionType.sale,
                  onSelected: (selected) {
                    ref
                        .read(transactionTypeFilterProvider.notifier)
                        .setType(StockTransactionType.sale);
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Adjustments'),
                  selected: typeFilter == StockTransactionType.adjustment,
                  onSelected: (selected) {
                    ref
                        .read(transactionTypeFilterProvider.notifier)
                        .setType(StockTransactionType.adjustment);
                  },
                ),
              ],
            ),
          ),

          // Transactions List
          Expanded(
            child: transactionsAsync.when(
              data: (transactions) {
                if (transactions.isEmpty) {
                  return const Center(
                    child: Text('No transactions found'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(stockTransactionsProvider(product.id));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getTypeColor(transaction.type)
                                .withOpacity(0.2),
                            child: Icon(
                              _getTypeIcon(transaction.type),
                              color: _getTypeColor(transaction.type),
                            ),
                          ),
                          title: Text(transaction.type.displayName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${transaction.previousStock.toStringAsFixed(1)} → ${transaction.newStock.toStringAsFixed(1)} ${product.unitOfMeasure}',
                              ),
                              Text(
                                DateFormat('MMM d, yyyy h:mm a')
                                    .format(transaction.timestamp),
                                style: const TextStyle(fontSize: 12),
                              ),
                              if (transaction.reason != null)
                                Text(
                                  transaction.reason!,
                                  style: const TextStyle(
                                      fontSize: 12, fontStyle: FontStyle.italic),
                                ),
                            ],
                          ),
                          trailing: Text(
                            '${transaction.quantityChange >= 0 ? '+' : ''}${transaction.quantityChange.toStringAsFixed(1)}',
                            style: TextStyle(
                              color: transaction.quantityChange >= 0
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(StockTransactionType type) {
    switch (type) {
      case StockTransactionType.addition:
        return Colors.green;
      case StockTransactionType.adjustment:
        return Colors.blue;
      case StockTransactionType.sale:
        return Colors.orange;
    }
  }

  IconData _getTypeIcon(StockTransactionType type) {
    switch (type) {
      case StockTransactionType.addition:
        return Icons.add_circle;
      case StockTransactionType.adjustment:
        return Icons.tune;
      case StockTransactionType.sale:
        return Icons.shopping_cart;
    }
  }
}
