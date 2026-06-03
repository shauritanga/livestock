import 'package:livestock/features/expenses/domain/entities/expense.dart';
import 'package:livestock/features/expenses/domain/repositories/expense_repository.dart';

/// Use case for retrieving expenses filtered by date range
class GetExpensesByDateRange {
  final ExpenseRepository repository;

  GetExpensesByDateRange(this.repository);

  /// Execute the use case
  Future<List<Expense>> call(
    String cooperativeId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (cooperativeId.isEmpty) {
      throw ArgumentError('Cooperative ID is required');
    }

    if (startDate.isAfter(endDate)) {
      throw ArgumentError('Start date must be before end date');
    }

    final expenses = await repository.getExpensesByDateRange(
      cooperativeId,
      startDate,
      endDate,
    );
    
    // Sort by date descending (most recent first)
    expenses.sort((a, b) => b.date.compareTo(a.date));
    
    return expenses;
  }
}
