import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:livestock/features/inventory/domain/entities/sale_transaction.dart';

/// Sale card widget for displaying sale in list
class SaleCard extends StatelessWidget {
  final SaleTransaction sale;
  final VoidCallback onTap;

  const SaleCard({
    super.key,
    required this.sale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Icon(
            Icons.shopping_cart,
            color: Colors.green.shade700,
          ),
        ),
        title: Text(
          sale.productName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${sale.quantity.toStringAsFixed(1)} units × TZS ${NumberFormat('#,##0').format(sale.unitPrice)}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              DateFormat('MMM d, yyyy h:mm a').format(sale.timestamp),
              style: const TextStyle(fontSize: 12),
            ),
            if (sale.customerName != null)
              Text(
                'Customer: ${sale.customerName}',
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'TZS ${NumberFormat('#,##0').format(sale.totalAmount)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.green,
              ),
            ),
            if (!sale.isSynced)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Pending',
                  style: TextStyle(fontSize: 10, color: Colors.orange),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
