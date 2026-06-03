import 'package:flutter/material.dart';
import 'package:livestock/features/expenses/domain/entities/expense.dart';
import 'package:intl/intl.dart';

/// Widget to display individual expense in a card
class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onTap;

  const ExpenseCard({
    super.key,
    required this.expense,
    this.onTap,
  });

  Color _getCategoryColor(BuildContext context) {
    switch (expense.category.name) {
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

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(context);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Category Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(),
                  color: categoryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              // Expense Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.description,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            expense.category.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              color: categoryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          dateFormat.format(expense.date),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'TZS ${NumberFormat('#,##0.00').format(expense.amount)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon() {
    switch (expense.category.name) {
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
}
