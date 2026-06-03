import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livestock/features/expenses/data/models/expense_model.dart';
import 'package:livestock/features/expenses/domain/entities/expense_category.dart';

/// Remote data source interface for expenses
abstract class ExpenseRemoteDataSource {
  Future<ExpenseModel> createExpense(ExpenseModel expense);
  Future<List<ExpenseModel>> getExpenses(String cooperativeId);
  Future<List<ExpenseModel>> getExpensesByDateRange(
    String cooperativeId,
    DateTime startDate,
    DateTime endDate,
  );
  Future<Map<ExpenseCategory, double>> getCategoryTotals(String cooperativeId);
  Future<Map<ExpenseCategory, double>> getCategoryTotalsByDateRange(
    String cooperativeId,
    DateTime startDate,
    DateTime endDate,
  );
}

/// Implementation of expense remote data source using Firestore
class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final FirebaseFirestore firestore;

  ExpenseRemoteDataSourceImpl({required this.firestore});

  /// Get expenses collection reference for a cooperative
  CollectionReference _getExpensesCollection(String cooperativeId) {
    return firestore
        .collection('cooperatives')
        .doc(cooperativeId)
        .collection('expenses');
  }

  @override
  Future<ExpenseModel> createExpense(ExpenseModel expense) async {
    try {
      final docRef = _getExpensesCollection(expense.cooperativeId)
          .doc(expense.id);

      await docRef.set(expense.toJson());

      return expense;
    } on FirebaseException catch (e) {
      throw Exception('Failed to create expense: ${e.message}');
    } catch (e) {
      throw Exception('Failed to create expense: $e');
    }
  }

  @override
  Future<List<ExpenseModel>> getExpenses(String cooperativeId) async {
    try {
      final snapshot = await _getExpensesCollection(cooperativeId)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ExpenseModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Failed to get expenses: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get expenses: $e');
    }
  }

  @override
  Future<List<ExpenseModel>> getExpensesByDateRange(
    String cooperativeId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // Normalize dates to start and end of day
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

      final snapshot = await _getExpensesCollection(cooperativeId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ExpenseModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Failed to get expenses by date range: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get expenses by date range: $e');
    }
  }

  @override
  Future<Map<ExpenseCategory, double>> getCategoryTotals(
    String cooperativeId,
  ) async {
    try {
      final expenses = await getExpenses(cooperativeId);
      return _calculateCategoryTotals(expenses);
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
      final expenses = await getExpensesByDateRange(
        cooperativeId,
        startDate,
        endDate,
      );
      return _calculateCategoryTotals(expenses);
    } catch (e) {
      throw Exception('Failed to get category totals by date range: $e');
    }
  }

  /// Helper method to calculate category totals from expenses
  Map<ExpenseCategory, double> _calculateCategoryTotals(
    List<ExpenseModel> expenses,
  ) {
    final totals = <ExpenseCategory, double>{};

    // Initialize all categories with 0
    for (final category in ExpenseCategory.values) {
      totals[category] = 0.0;
    }

    // Sum up expenses by category
    for (final expense in expenses) {
      totals[expense.category] = (totals[expense.category] ?? 0.0) + expense.amount;
    }

    return totals;
  }
}
