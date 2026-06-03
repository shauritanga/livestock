import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livestock/features/auth/presentation/providers/auth_providers.dart';
import 'package:livestock/features/expenses/data/datasources/expense_remote_datasource.dart';
import 'package:livestock/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:livestock/features/expenses/domain/entities/expense.dart';
import 'package:livestock/features/expenses/domain/entities/expense_category.dart';
import 'package:livestock/features/expenses/domain/repositories/expense_repository.dart';
import 'package:livestock/features/expenses/domain/usecases/create_expense.dart';
import 'package:livestock/features/expenses/domain/usecases/get_expenses.dart';
import 'package:livestock/features/expenses/domain/usecases/get_expenses_by_date_range.dart';
import 'package:livestock/features/expenses/domain/usecases/get_category_totals.dart';

// Data source provider
final expenseRemoteDataSourceProvider = Provider<ExpenseRemoteDataSource>((ref) {
  return ExpenseRemoteDataSourceImpl(firestore: FirebaseFirestore.instance);
});

// Repository provider
final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final remoteDataSource = ref.watch(expenseRemoteDataSourceProvider);
  return ExpenseRepositoryImpl(remoteDataSource: remoteDataSource);
});

// Use case providers
final createExpenseUseCaseProvider = Provider<CreateExpense>((ref) {
  final repository = ref.watch(expenseRepositoryProvider);
  return CreateExpense(repository);
});

final getExpensesUseCaseProvider = Provider<GetExpenses>((ref) {
  final repository = ref.watch(expenseRepositoryProvider);
  return GetExpenses(repository);
});

final getExpensesByDateRangeUseCaseProvider = Provider<GetExpensesByDateRange>((ref) {
  final repository = ref.watch(expenseRepositoryProvider);
  return GetExpensesByDateRange(repository);
});

final getCategoryTotalsUseCaseProvider = Provider<GetCategoryTotals>((ref) {
  final repository = ref.watch(expenseRepositoryProvider);
  return GetCategoryTotals(repository);
});

// Date range filter state
class DateRangeFilter {
  final DateTime? startDate;
  final DateTime? endDate;

  const DateRangeFilter({this.startDate, this.endDate});

  bool get isActive => startDate != null && endDate != null;

  DateRangeFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return DateRangeFilter(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

// Date range filter notifier
class DateRangeFilterNotifier extends Notifier<DateRangeFilter> {
  @override
  DateRangeFilter build() => const DateRangeFilter();

  void setDateRange(DateTime startDate, DateTime endDate) {
    state = DateRangeFilter(startDate: startDate, endDate: endDate);
  }

  void setThisMonth() {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1);
    final endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    state = DateRangeFilter(startDate: startDate, endDate: endDate);
  }

  void setLastMonth() {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - 1, 1);
    final endDate = DateTime(now.year, now.month, 0, 23, 59, 59);
    state = DateRangeFilter(startDate: startDate, endDate: endDate);
  }

  void setThisYear() {
    final now = DateTime.now();
    final startDate = DateTime(now.year, 1, 1);
    final endDate = DateTime(now.year, 12, 31, 23, 59, 59);
    state = DateRangeFilter(startDate: startDate, endDate: endDate);
  }

  void clear() {
    state = const DateRangeFilter();
  }
}

final dateRangeFilterProvider = NotifierProvider<DateRangeFilterNotifier, DateRangeFilter>(() {
  return DateRangeFilterNotifier();
});

// Expenses provider (all expenses)
final expensesProvider = FutureProvider<List<Expense>>((ref) async {
  final useCase = ref.watch(getExpensesUseCaseProvider);
  final currentUser = ref.watch(currentAuthUserProvider);

  final cooperativeId = currentUser?.cooperativeId;
  if (cooperativeId == null || cooperativeId.isEmpty) {
    return [];
  }

  try {
    return await useCase(cooperativeId);
  } catch (e) {
    throw Exception('Failed to load expenses: $e');
  }
});

// Filtered expenses provider (with date range)
final filteredExpensesProvider = FutureProvider<List<Expense>>((ref) async {
  final dateFilter = ref.watch(dateRangeFilterProvider);
  final currentUser = ref.watch(currentAuthUserProvider);

  final cooperativeId = currentUser?.cooperativeId;
  if (cooperativeId == null || cooperativeId.isEmpty) {
    return [];
  }

  // If no filter is active, return all expenses
  if (!dateFilter.isActive) {
    return await ref.watch(expensesProvider.future);
  }

  // Otherwise, get filtered expenses
  final useCase = ref.watch(getExpensesByDateRangeUseCaseProvider);
  
  try {
    return await useCase(
      cooperativeId,
      dateFilter.startDate!,
      dateFilter.endDate!,
    );
  } catch (e) {
    throw Exception('Failed to load filtered expenses: $e');
  }
});

// Category totals provider
final categoryTotalsProvider = FutureProvider<Map<ExpenseCategory, double>>((ref) async {
  final dateFilter = ref.watch(dateRangeFilterProvider);
  final currentUser = ref.watch(currentAuthUserProvider);
  final useCase = ref.watch(getCategoryTotalsUseCaseProvider);

  final cooperativeId = currentUser?.cooperativeId;
  if (cooperativeId == null || cooperativeId.isEmpty) {
    return {};
  }

  try {
    if (dateFilter.isActive) {
      return await useCase.callWithDateRange(
        cooperativeId,
        dateFilter.startDate!,
        dateFilter.endDate!,
      );
    } else {
      return await useCase(cooperativeId);
    }
  } catch (e) {
    throw Exception('Failed to load category totals: $e');
  }
});

// Total expenses amount provider
final totalExpensesProvider = Provider<double>((ref) {
  final categoryTotals = ref.watch(categoryTotalsProvider);
  
  return categoryTotals.when(
    data: (totals) => totals.values.fold(0.0, (sum, amount) => sum + amount),
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});
