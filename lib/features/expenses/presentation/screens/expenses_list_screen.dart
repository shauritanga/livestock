import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:livestock/features/expenses/presentation/providers/expense_providers.dart';
import 'package:livestock/features/expenses/presentation/widgets/expense_card.dart';
import 'package:livestock/features/expenses/presentation/widgets/expense_summary_card.dart';
import 'package:livestock/features/expenses/presentation/widgets/category_total_card.dart';
import 'package:livestock/features/expenses/presentation/widgets/date_range_filter_widget.dart';

/// Expenses list screen with filtering and analytics
class ExpensesListScreen extends ConsumerWidget {
  const ExpensesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(filteredExpensesProvider);
    final categoryTotalsAsync = ref.watch(categoryTotalsProvider);
    final totalAmount = ref.watch(totalExpensesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(expensesProvider);
          ref.invalidate(filteredExpensesProvider);
          ref.invalidate(categoryTotalsProvider);
        },
        child: expensesAsync.when(
          data: (expenses) {
            return CustomScrollView(
              slivers: [
                // Summary Card
                SliverToBoxAdapter(
                  child: ExpenseSummaryCard(
                    totalAmount: totalAmount,
                    expenseCount: expenses.length,
                  ),
                ),

                // Date Range Filter
                const SliverToBoxAdapter(
                  child: DateRangeFilterWidget(),
                ),

                // Category Totals
                SliverToBoxAdapter(
                  child: categoryTotalsAsync.when(
                    data: (totals) {
                      // Filter out categories with zero spending
                      final nonZeroTotals = totals.entries
                          .where((entry) => entry.value > 0)
                          .toList();

                      if (nonZeroTotals.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              'Spending by Category',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: nonZeroTotals.length,
                              itemBuilder: (context, index) {
                                final entry = nonZeroTotals[index];
                                return CategoryTotalCard(
                                  category: entry.key,
                                  total: entry.value,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                    loading: () => const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),

                // Expenses List Header
                if (expenses.isNotEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'Recent Expenses',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                // Expenses List
                if (expenses.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No expenses yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the + button to add your first expense',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final expense = expenses[index];
                        return ExpenseCard(
                          expense: expense,
                          onTap: () {
                            // Future: Navigate to expense detail screen
                          },
                        );
                      },
                      childCount: expenses.length,
                    ),
                  ),

                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load expenses',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    error.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.invalidate(expensesProvider);
                    ref.invalidate(filteredExpensesProvider);
                    ref.invalidate(categoryTotalsProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/expenses/add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
