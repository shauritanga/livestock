import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:livestock/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:livestock/features/inventory/presentation/screens/add_product_screen.dart';
import 'package:livestock/features/inventory/presentation/screens/add_stock_screen.dart';
import 'package:livestock/features/inventory/presentation/screens/stock_audit_screen.dart';

/// Product detail screen
class ProductDetailScreen extends ConsumerWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productByIdProvider(productId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              productAsync.whenData((product) {
                if (product != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AddProductScreen(product: product),
                    ),
                  );
                }
              });
            },
          ),
        ],
      ),
      body: productAsync.when(
        data: (product) {
          if (product == null) {
            return const Center(child: Text('Product not found'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(productByIdProvider(productId));
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Product Info Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            Chip(
                              label: Text(product.sku),
                              avatar: const Icon(Icons.qr_code, size: 16),
                            ),
                            Chip(
                              label: Text(product.category.displayName),
                            ),
                            Chip(
                              label: Text(product.isActive ? 'Active' : 'Inactive'),
                              backgroundColor: product.isActive
                                  ? Colors.green.shade100
                                  : Colors.grey.shade300,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Stock Summary Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stock Summary',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    '${product.currentStock.toStringAsFixed(1)} ${product.unitOfMeasure}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          color: product.isOutOfStock
                                              ? Colors.red
                                              : product.isLowStock
                                                  ? Colors.orange
                                                  : Colors.green,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product.stockStatus,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 50,
                              color: Colors.grey.shade300,
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    product.reorderPoint.toStringAsFixed(1),
                                    style:
                                        Theme.of(context).textTheme.headlineSmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Reorder Point',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Last updated: ${DateFormat('MMM d, yyyy h:mm a').format(product.updatedAt)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Quick Actions
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddStockScreen(product: product),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Stock'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showAdjustStockDialog(context, ref, product);
                        },
                        icon: const Icon(Icons.tune),
                        label: const Text('Adjust'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Pricing Info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pricing',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Unit Price:'),
                            Text(
                              'TZS ${NumberFormat('#,##0').format(product.unitPrice)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Inventory Value:'),
                            Text(
                              'TZS ${NumberFormat('#,##0').format(product.inventoryValue)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Recent Transactions
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Activity',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        StockAuditScreen(product: product),
                                  ),
                                );
                              },
                              child: const Text('View All'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text('Transaction history available in audit screen'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  void _showAdjustStockDialog(BuildContext context, WidgetRef ref, product) {
    // Implement adjust stock dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adjust Stock'),
        content: const Text('Adjust stock dialog - to be implemented'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
