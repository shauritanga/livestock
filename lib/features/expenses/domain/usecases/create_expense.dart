import 'package:livestock/features/expenses/domain/entities/expense.dart';
import 'package:livestock/features/expenses/domain/repositories/expense_repository.dart';

/// Use case for creating a new expense with validation
class CreateExpense {
  final ExpenseRepository repository;

  CreateExpense(this.repository);

  /// Execute the use case
  Future<Expense> call(Expense expense) async {
    // Validate expense data
    if (expense.description.trim().isEmpty) {
      throw ArgumentError('Description is required');
    }

    if (expense.amount <= 0) {
      throw ArgumentError('Amount must be greater than zero');
    }

    if (expense.date.isAfter(DateTime.now())) {
      throw ArgumentError('Date cannot be in the future');
    }

    // Create the expense
    return await repository.createExpense(expense);
  }
}
