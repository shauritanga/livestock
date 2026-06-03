import 'package:livestock/features/expenses/domain/entities/expense.dart';
import 'package:livestock/features/expenses/domain/repositories/expense_repository.dart';

/// Use case for retrieving all expenses for a cooperative
class GetExpenses {
  final ExpenseRepository repository;

  GetExpenses(this.repository);

  /// Execute the use case
  Future<List<Expense>> call(String cooperativeId) async {
    if (cooperativeId.isEmpty) {
      throw ArgumentError('Cooperative ID is required');
    }

    final expenses = await repository.getExpenses(cooperativeId);
    
    // Sort by date descending (most recent first)
    expenses.sort((a, b) => b.date.compareTo(a.date));
    
    return expenses;
  }
}
