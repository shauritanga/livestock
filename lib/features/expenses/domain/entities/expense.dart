import 'package:equatable/equatable.dart';
import 'package:livestock/features/expenses/domain/entities/expense_category.dart';

/// Expense entity representing a cooperative expense record
class Expense extends Equatable {
  final String id;
  final String cooperativeId;
  final String description;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final DateTime createdAt;

  const Expense({
    required this.id,
    required this.cooperativeId,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
    required this.createdAt,
  });

  /// Validate expense data
  bool get isValid {
    return description.trim().isNotEmpty &&
        amount > 0 &&
        !date.isAfter(DateTime.now());
  }

  /// Get formatted amount with currency
  String getFormattedAmount({String currency = 'TZS'}) {
    return '$currency ${amount.toStringAsFixed(2)}';
  }

  /// Check if expense is from today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if expense is from this month
  bool get isThisMonth {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// Check if expense is from this year
  bool get isThisYear {
    final now = DateTime.now();
    return date.year == now.year;
  }

  /// Copy with method for creating modified copies
  Expense copyWith({
    String? id,
    String? cooperativeId,
    String? description,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      cooperativeId: cooperativeId ?? this.cooperativeId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        cooperativeId,
        description,
        amount,
        category,
        date,
        createdAt,
      ];
}
