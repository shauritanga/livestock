import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/report_document.dart';
import '../../domain/entities/report_section.dart';
import '../../domain/entities/report_template.dart';
import '../../domain/entities/analytics_filter.dart';
import '../providers/report_providers.dart';

/// Report preview screen
/// Task 28.2: Implement report preview screen
class ReportPreviewScreen extends ConsumerStatefulWidget {
  final ReportDocument report;
  final AnalyticsFilter filter;

  const ReportPreviewScreen({
    super.key,
    required this.report,
    required this.filter,
  });

  @override
  ConsumerState<ReportPreviewScreen> createState() =>
      _ReportPreviewScreenState();
}

class _ReportPreviewScreenState extends ConsumerState<ReportPreviewScreen> {
  ExportFormat _selectedFormat = ExportFormat.pdf;
  final Set<String> _selectedSections = {};
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    // Initialize with all sections selected
    _selectedSections.addAll(
      widget.report.sections.map((section) => section.title),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.report.template.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showCustomizeDialog,
            tooltip: 'Customize Report',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _isExporting ? null : _exportReport,
            tooltip: 'Export Report',
          ),
        ],
      ),
      body: Column(
        children: [
          // Export format selector
          _buildFormatSelector(),
          const Divider(height: 1),
          // Report preview
          Expanded(
            child: _buildReportPreview(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildFormatSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          const Text(
            'Export Format:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SegmentedButton<ExportFormat>(
              segments: const [
                ButtonSegment(
                  value: ExportFormat.pdf,
                  label: Text('PDF'),
                  icon: Icon(Icons.picture_as_pdf),
                ),
                ButtonSegment(
                  value: ExportFormat.excel,
                  label: Text('Excel'),
                  icon: Icon(Icons.table_chart),
                ),
                ButtonSegment(
                  value: ExportFormat.csv,
                  label: Text('CSV'),
                  icon: Icon(Icons.text_snippet),
                ),
              ],
              selected: {_selectedFormat},
              onSelectionChanged: (Set<ExportFormat> newSelection) {
                setState(() {
                  _selectedFormat = newSelection.first;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportPreview() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Report header
        _buildReportHeader(),
        const SizedBox(height: 24),
        // Report metadata
        _buildReportMetadata(),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 24),
        // Report sections
        ...widget.report.sections.map((section) {
          final isSelected = _selectedSections.contains(section.title);
          return _buildSectionPreview(section, isSelected);
        }),
      ],
    );
  }

  Widget _buildReportHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.report.template.name,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Generated on ${_formatDateTime(widget.report.generatedAt)}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildReportMetadata() {
    final filter = widget.filter;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report Period',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            _buildMetadataRow(
              'Start Date',
              _formatDate(filter.dateRange.startDate),
            ),
            _buildMetadataRow(
              'End Date',
              _formatDate(filter.dateRange.endDate),
            ),
            if (filter.cooperativeIds != null &&
                filter.cooperativeIds!.isNotEmpty)
              _buildMetadataRow(
                'Cooperatives',
                '${filter.cooperativeIds!.length} selected',
              ),
            if (filter.collectionCenterIds != null &&
                filter.collectionCenterIds!.isNotEmpty)
              _buildMetadataRow(
                'Collection Centers',
                '${filter.collectionCenterIds!.length} selected',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionPreview(ReportSection section, bool isSelected) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile(
            value: isSelected,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _selectedSections.add(section.title);
                } else {
                  _selectedSections.remove(section.title);
                }
              });
            },
            title: Text(
              section.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            subtitle: Text(section.content),
          ),
          if (isSelected) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (section.visualizations.isNotEmpty) ...[
                    Text(
                      'Visualizations:',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: section.visualizations.map((viz) {
                        return Chip(
                          label: Text(
                            _formatVisualizationName(viz),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          avatar: const Icon(Icons.bar_chart, size: 16),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (section.tables.isNotEmpty) ...[
                    Text(
                      'Data Tables:',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: section.tables.map((table) {
                        return Chip(
                          label: Text(
                            _formatTableName(table),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          avatar: const Icon(Icons.table_chart, size: 16),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${_selectedSections.length} of ${widget.report.sections.length} sections selected',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 16),
          FilledButton.icon(
            onPressed: _isExporting ? null : _exportReport,
            icon: _isExporting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download),
            label: Text(_isExporting ? 'Exporting...' : 'Export Report'),
          ),
        ],
      ),
    );
  }

  void _showCustomizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Customize Report'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select sections to include:'),
              const SizedBox(height: 16),
              ...widget.report.sections.map((section) {
                return CheckboxListTile(
                  value: _selectedSections.contains(section.title),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedSections.add(section.title);
                      } else {
                        _selectedSections.remove(section.title);
                      }
                    });
                    Navigator.of(context).pop();
                    _showCustomizeDialog();
                  },
                  title: Text(section.title),
                  dense: true,
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportReport() async {
    if (_selectedSections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one section to export'),
        ),
      );
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      // Create a modified report with only selected sections
      final filteredReport = widget.report.copyWith(
        sections: widget.report.sections
            .where((section) => _selectedSections.contains(section.title))
            .toList(),
      );

      // Export the report
      await ref.read(reportGenerationProvider.notifier).exportReport(
            report: filteredReport,
            format: _selectedFormat,
          );

      final state = ref.read(reportGenerationProvider);
      if (state.exportedFilePath != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Report exported successfully to ${state.exportedFilePath}',
              ),
              action: SnackBarAction(
                label: 'Share',
                onPressed: () {
                  // TODO: Implement share functionality
                },
              ),
            ),
          );
        }
      } else if (state.error != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Export failed: ${state.error}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatVisualizationName(String name) {
    return name
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatTableName(dynamic table) {
    if (table is String) {
      return _formatVisualizationName(table);
    }
    return table.toString();
  }
}
