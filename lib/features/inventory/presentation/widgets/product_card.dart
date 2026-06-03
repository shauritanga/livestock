import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:livestock/features/inventory/domain/entities/product.dart';

/// Product card widget for displaying product in list
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getStockStatusColor(),
          ),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SKU: ${product.sku}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              '${product.currentStock.toStringAsFixed(1)} ${product.unitOfMeasure} • ${product.stockStatus}',
              style: TextStyle(
                fontSize: 12,
                color: _getStockStatusColor(),
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'TZS ${NumberFormat('#,##0').format(product.unitPrice)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              product.category.displayName,
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStockStatusColor() {
    if (product.isOutOfStock) {
      return Colors.red;
    } else if (product.isLowStock) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}
