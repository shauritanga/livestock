import 'package:flutter/material.dart';
import 'package:livestock/features/analytics/domain/entities/analytics_filter.dart';

/// Saved filter model
class SavedFilter {
  final String id;
  final String name;
  final AnalyticsFilter filter;
  final DateTime createdAt;

  const SavedFilter({
    required this.id,
    required this.name,
    required this.filter,
    required this.createdAt,
  });
}

/// Saved Filters Dialog for managing saved filter combinations (Task 18.3)
/// 
/// Allows users to save, load, and delete custom filter combinations.
class SavedFiltersDialog extends StatefulWidget {
  final AnalyticsFilter currentFilter;
  final Function(AnalyticsFilter) onLoad;
  final List<SavedFilter> savedFilters;
  final Function(String name, AnalyticsFilter filter) onSave;
  final Function(String id) onDelete;

  const SavedFiltersDialog({
    super.key,
    required this.currentFilter,
    required this.onLoad,
    required this.savedFilters,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<SavedFiltersDialog> createState() => _SavedFiltersDialogState();
}

class _SavedFiltersDialogState extends State<SavedFiltersDialog> {
  final TextEditingController _nameController = TextEditingController();
  bool _showSaveForm = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: widget.savedFilters.isEmpty
                  ? _buildEmptyState(context)
                  : _buildFilterList(context),
            ),
            if (_showSaveForm) _buildSaveForm(context),
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
          const Icon(Icons.bookmark, color: Colors.white),
          const SizedBox(width: 12),
          Text(
            'Saved Filters',
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

  Widget _buildFilterList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: widget.savedFilters.length,
      itemBuilder: (context, index) {
        final filter = widget.savedFilters[index];
        return _buildFilterCard(context, filter);
      },
    );
  }

  Widget _buildFilterCard(BuildContext context, SavedFilter savedFilter) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    savedFilter.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  color: Colors.red,
                  onPressed: () {
                    _showDeleteConfirmation(context, savedFilter);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildFilterSummary(context, savedFilter.filter),
            const SizedBox(height: 8),
            Text(
              'Saved ${_formatDate(savedFilter.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  widget.onLoad(savedFilter.filter);
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.filter_alt),
                label: const Text('Apply Filter'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSummary(BuildContext context, AnalyticsFilter filter) {
    final summaryItems = <String>[];

    // Date range
    summaryItems.add(
      '${_formatDate(filter.dateRange.startDate)} - ${_formatDate(filter.dateRange.endDate)}',
    );

    // Cooperatives
    if (filter.cooperativeIds != null && filter.cooperativeIds!.isNotEmpty) {
      summaryItems.add('${filter.cooperativeIds!.length} cooperatives');
    }

    // Collection centers
    if (filter.collectionCenterIds != null &&
        filter.collectionCenterIds!.isNotEmpty) {
      summaryItems.add('${filter.collectionCenterIds!.length} centers');
    }

    // Location filters
    if (filter.region != null) {
      summaryItems.add('Region: ${filter.region}');
    }
    if (filter.district != null) {
      summaryItems.add('District: ${filter.district}');
    }
    if (filter.ward != null) {
      summaryItems.add('Ward: ${filter.ward}');
    }
    if (filter.village != null) {
      summaryItems.add('Village: ${filter.village}');
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: summaryItems.map((item) {
        return Chip(
          label: Text(
            item,
            style: const TextStyle(fontSize: 11),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No saved filters',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Save your current filter to quickly access it later',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Save Current Filter',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Filter Name',
              hintText: 'e.g., Q1 2024 Report',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _showSaveForm = false;
                    _nameController.clear();
                  });
                },
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  if (_nameController.text.trim().isNotEmpty) {
                    widget.onSave(
                      _nameController.text.trim(),
                      widget.currentFilter,
                    );
                    setState(() {
                      _showSaveForm = false;
                      _nameController.clear();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Filter saved successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    if (_showSaveForm) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _showSaveForm = true;
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('Save Current Filter'),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, SavedFilter filter) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Filter'),
        content: Text('Are you sure you want to delete "${filter.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.onDelete(filter.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Filter deleted'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
