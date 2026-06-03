import 'package:livestock/features/expenses/domain/entities/expense_category.dart';
import 'package:livestock/features/expenses/domain/repositories/expense_repository.dart';

/// Use case for calculating total spending by category
class GetCategoryTotals {
  final ExpenseRepository repository;

  GetCategoryTotals(this.repository);

  /// Execute the use case for all expenses
  Future<Map<ExpenseCategory, double>> call(String cooperativeId) async {
    if (cooperativeId.isEmpty) {
      throw ArgumentError('Cooperative ID is required');
    }

    return await repository.getCategoryTotals(cooperativeId);
  }

  /// Execute the use case for a specific date range
  Future<Map<ExpenseCategory, double>> callWithDateRange(
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

    return await repository.getCategoryTotalsByDateRange(
      cooperativeId,
      startDate,
      endDate,
    );
  }
}
