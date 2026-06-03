import 'package:livestock/features/expenses/domain/entities/expense.dart';
import 'package:livestock/features/expenses/domain/entities/expense_category.dart';

/// Abstract repository interface for expense operations
abstract class ExpenseRepository {
  /// Get all expenses for a cooperative
  Future<List<Expense>> getExpenses(String cooperativeId);

  /// Get expenses filtered by date range
  Future<List<Expense>> getExpensesByDateRange(
    String cooperativeId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Create a new expense
  Future<Expense> createExpense(Expense expense);

  /// Get total spending by category
  Future<Map<ExpenseCategory, double>> getCategoryTotals(String cooperativeId);

  /// Get total spending by category for a date range
  Future<Map<ExpenseCategory, double>> getCategoryTotalsByDateRange(
    String cooperativeId,
    DateTime startDate,
    DateTime endDate,
  );
}
