import 'package:livestock/features/expenses/domain/entities/expense.dart';
import 'package:livestock/features/expenses/domain/entities/expense_category.dart';
import 'package:livestock/features/expenses/domain/repositories/expense_repository.dart';
import 'package:livestock/features/expenses/data/datasources/expense_remote_datasource.dart';
import 'package:livestock/features/expenses/data/models/expense_model.dart';

/// Implementation of ExpenseRepository
class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDataSource remoteDataSource;

  ExpenseRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Expense> createExpense(Expense expense) async {
    try {
      final model = ExpenseModel.fromEntity(expense);
      final createdModel = await remoteDataSource.createExpense(model);
      return createdModel.toEntity();
    } catch (e) {
      throw Exception('Failed to create expense: $e');
    }
  }

  @override
  Future<List<Expense>> getExpenses(String cooperativeId) async {
    try {
      final models = await remoteDataSource.getExpenses(cooperativeId);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get expenses: $e');
    }
  }

  @override
  Future<List<Expense>> getExpensesByDateRange(
    String cooperativeId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final models = await remoteDataSource.getExpensesByDateRange(
        cooperativeId,
        startDate,
        endDate,
      );
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get expenses by date range: $e');
    }
  }

  @override
  Future<Map<ExpenseCategory, double>> getCategoryTotals(
    String cooperativeId,
  ) async {
    try {
      return await remoteDataSource.getCategoryTotals(cooperativeId);
    } catch (e) {
      throw Exception('Failed to get category totals: $e');
    }
  }

  @override
  Future<Map<ExpenseCategory, double>> getCategoryTotalsByDateRange(
    String cooperativeId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await remoteDataSource.getCategoryTotalsByDateRange(
        cooperativeId,
        startDate,
        endDate,
      );
    } catch (e) {
      throw Exception('Failed to get category totals by date range: $e');
    }
  }
}
