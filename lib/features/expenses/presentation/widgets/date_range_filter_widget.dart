import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livestock/features/expenses/presentation/providers/expense_providers.dart';
import 'package:intl/intl.dart';

/// Widget for filtering expenses by date range
class DateRangeFilterWidget extends ConsumerWidget {
  const DateRangeFilterWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFilter = ref.watch(dateRangeFilterProvider);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick filter buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _QuickFilterChip(
                  label: 'This Month',
                  isSelected: dateFilter.isActive && _isThisMonth(dateFilter),
                  onTap: () {
                    ref.read(dateRangeFilterProvider.notifier).setThisMonth();
                  },
                ),
                const SizedBox(width: 8),
                _QuickFilterChip(
                  label: 'Last Month',
                  isSelected: dateFilter.isActive && _isLastMonth(dateFilter),
                  onTap: () {
                    ref.read(dateRangeFilterProvider.notifier).setLastMonth();
                  },
                ),
                const SizedBox(width: 8),
                _QuickFilterChip(
                  label: 'This Year',
                  isSelected: dateFilter.isActive && _isThisYear(dateFilter),
                  onTap: () {
                    ref.read(dateRangeFilterProvider.notifier).setThisYear();
                  },
                ),
                const SizedBox(width: 8),
                _QuickFilterChip(
                  label: 'Custom',
                  isSelected: dateFilter.isActive && 
                      !_isThisMonth(dateFilter) && 
                      !_isLastMonth(dateFilter) && 
                      !_isThisYear(dateFilter),
                  onTap: () async {
                    final DateTimeRange? picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      initialDateRange: dateFilter.isActive
                          ? DateTimeRange(
                              start: dateFilter.startDate!,
                              end: dateFilter.endDate!,
                            )
                          : null,
                    );

                    if (picked != null) {
                      ref.read(dateRangeFilterProvider.notifier).setDateRange(
                            picked.start,
                            picked.end,
                          );
                    }
                  },
                ),
                if (dateFilter.isActive) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      ref.read(dateRangeFilterProvider.notifier).clear();
                    },
                    tooltip: 'Clear filter',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.1),
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Display selected date range
          if (dateFilter.isActive) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.date_range,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${dateFormat.format(dateFilter.startDate!)} - ${dateFormat.format(dateFilter.endDate!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _isThisMonth(DateRangeFilter filter) {
    if (!filter.isActive) return false;
    final now = DateTime.now();
    final thisMonthStart = DateTime(now.year, now.month, 1);
    final thisMonthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    
    return filter.startDate!.year == thisMonthStart.year &&
        filter.startDate!.month == thisMonthStart.month &&
        filter.startDate!.day == thisMonthStart.day &&
        filter.endDate!.year == thisMonthEnd.year &&
        filter.endDate!.month == thisMonthEnd.month &&
        filter.endDate!.day == thisMonthEnd.day;
  }

  bool _isLastMonth(DateRangeFilter filter) {
    if (!filter.isActive) return false;
    final now = DateTime.now();
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = DateTime(now.year, now.month, 0, 23, 59, 59);
    
    return filter.startDate!.year == lastMonthStart.year &&
        filter.startDate!.month == lastMonthStart.month &&
        filter.startDate!.day == lastMonthStart.day &&
        filter.endDate!.year == lastMonthEnd.year &&
        filter.endDate!.month == lastMonthEnd.month &&
        filter.endDate!.day == lastMonthEnd.day;
  }

  bool _isThisYear(DateRangeFilter filter) {
    if (!filter.isActive) return false;
    final now = DateTime.now();
    final thisYearStart = DateTime(now.year, 1, 1);
    final thisYearEnd = DateTime(now.year, 12, 31, 23, 59, 59);
    
    return filter.startDate!.year == thisYearStart.year &&
        filter.startDate!.month == thisYearStart.month &&
        filter.startDate!.day == thisYearStart.day &&
        filter.endDate!.year == thisYearEnd.year &&
        filter.endDate!.month == thisYearEnd.month &&
        filter.endDate!.day == thisYearEnd.day;
  }
}

class _QuickFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).primaryColor : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}
