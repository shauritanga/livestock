import 'package:flutter/material.dart';
import 'package:livestock/features/expenses/domain/entities/expense_category.dart';
import 'package:intl/intl.dart';

/// Widget to display spending total for a category
class CategoryTotalCard extends StatelessWidget {
  final ExpenseCategory category;
  final double total;

  const CategoryTotalCard({
    super.key,
    required this.category,
    required this.total,
  });

  Color _getCategoryColor() {
    switch (category.name) {
      case 'feed':
        return Colors.green;
      case 'veterinary':
        return Colors.blue;
      case 'transport':
        return Colors.orange;
      case 'utilities':
        return Colors.purple;
      case 'salaries':
        return Colors.teal;
      case 'maintenance':
        return Colors.brown;
      case 'supplies':
        return Colors.indigo;
      case 'other':
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon() {
    switch (category.name) {
      case 'feed':
        return Icons.grass;
      case 'veterinary':
        return Icons.medical_services;
      case 'transport':
        return Icons.local_shipping;
      case 'utilities':
        return Icons.bolt;
      case 'salaries':
        return Icons.people;
      case 'maintenance':
        return Icons.build;
      case 'supplies':
        return Icons.inventory;
      case 'other':
      default:
        return Icons.more_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor();

    return Container(
      width: 140,
      height: 100,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: categoryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: categoryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCategoryIcon(),
            color: categoryColor,
            size: 20,
          ),
          const SizedBox(height: 6),
          Text(
            category.displayName,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Text(
            'TZS ${NumberFormat('#,##0').format(total)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: categoryColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
