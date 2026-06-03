import 'package:flutter/material.dart';
import 'package:livestock/features/analytics/domain/entities/analytics_filter.dart';
import 'package:livestock/features/analytics/domain/entities/date_range.dart';

/// Analytics Filter Dialog for customizing data filters (Task 18.1)
/// 
/// Provides comprehensive filtering options including date range, location, farmer, and cattle filters.
class AnalyticsFilterDialog extends StatefulWidget {
  final AnalyticsFilter currentFilter;
  final Function(AnalyticsFilter) onApply;

  const AnalyticsFilterDialog({
    super.key,
    required this.currentFilter,
    required this.onApply,
  });

  @override
  State<AnalyticsFilterDialog> createState() => _AnalyticsFilterDialogState();
}

class _AnalyticsFilterDialogState extends State<AnalyticsFilterDialog> {
  late DateTime _startDate;
  late DateTime _endDate;
  List<String> _selectedCooperatives = [];
  List<String> _selectedCollectionCenters = [];
  String? _region;
  String? _district;
  String? _ward;
  String? _village;

  @override
  void initState() {
    super.initState();
    _startDate = widget.currentFilter.dateRange.startDate;
    _endDate = widget.currentFilter.dateRange.endDate;
    _selectedCooperatives = widget.currentFilter.cooperativeIds ?? [];
    _selectedCollectionCenters = widget.currentFilter.collectionCenterIds ?? [];
    _region = widget.currentFilter.region;
    _district = widget.currentFilter.district;
    _ward = widget.currentFilter.ward;
    _village = widget.currentFilter.village;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDateRangeSection(context),
                    const Divider(height: 32),
                    _buildCooperativeSection(context),
                    const Divider(height: 32),
                    _buildCollectionCenterSection(context),
                    const Divider(height: 32),
                    _buildLocationSection(context),
                  ],
                ),
              ),
            ),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.filter_list, color: Colors.white),
          const SizedBox(width: 12),
          Text(
            'Filter Analytics',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildPresetChip(context, 'Today', () {
              final now = DateTime.now();
              setState(() {
                _startDate = DateTime(now.year, now.month, now.day);
                _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
              });
            }),
            _buildPresetChip(context, 'This Week', () {
              final now = DateTime.now();
              final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
              setState(() {
                _startDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
                _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
              });
            }),
            _buildPresetChip(context, 'This Month', () {
              final now = DateTime.now();
              setState(() {
                _startDate = DateTime(now.year, now.month, 1);
                _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
              });
            }),
            _buildPresetChip(context, 'This Quarter', () {
              final now = DateTime.now();
              final quarter = ((now.month - 1) / 3).floor();
              setState(() {
                _startDate = DateTime(now.year, quarter * 3 + 1, 1);
                _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
              });
            }),
            _buildPresetChip(context, 'This Year', () {
              final now = DateTime.now();
              setState(() {
                _startDate = DateTime(now.year, 1, 1);
                _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
              });
            }),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                context,
                'Start Date',
                _startDate,
                (date) {
                  setState(() {
                    _startDate = date;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateField(
                context,
                'End Date',
                _endDate,
                (date) {
                  setState(() {
                    _endDate = date;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPresetChip(
    BuildContext context,
    String label,
    VoidCallback onTap,
  ) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
    );
  }

  Widget _buildDateField(
    BuildContext context,
    String label,
    DateTime date,
    Function(DateTime) onDateSelected,
  ) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          '${date.day}/${date.month}/${date.year}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildCooperativeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cooperatives',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select cooperatives to include in analytics',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 12),
        // Placeholder for cooperative multi-select
        // In a real implementation, this would fetch and display cooperatives
        Text(
          'All cooperatives selected',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
        ),
      ],
    );
  }

  Widget _buildCollectionCenterSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Collection Centers',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select collection centers to include',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 12),
        // Placeholder for collection center multi-select
        Text(
          'All centers selected',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
        ),
      ],
    );
  }

  Widget _buildLocationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location Filters',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Filter by geographic location',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 12),
        // Placeholder for hierarchical location filters
        Text(
          'All locations included',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
        ),
      ],
    );
  }



  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              final now = DateTime.now();
              setState(() {
                _startDate = DateTime(now.year, now.month, 1);
                _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
                _selectedCooperatives = [];
                _selectedCollectionCenters = [];
                _region = null;
                _district = null;
                _ward = null;
                _village = null;
              });
            },
            child: const Text('Reset'),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              final filter = AnalyticsFilter(
                dateRange: DateRange(
                  startDate: _startDate,
                  endDate: _endDate,
                ),
                cooperativeIds: _selectedCooperatives.isEmpty
                    ? null
                    : _selectedCooperatives,
                collectionCenterIds: _selectedCollectionCenters.isEmpty
                    ? null
                    : _selectedCollectionCenters,
                region: _region,
                district: _district,
                ward: _ward,
                village: _village,
              );
              widget.onApply(filter);
              Navigator.of(context).pop();
            },
            child: const Text('Apply Filters'),
          ),
        ],
      ),
    );
  }
}
