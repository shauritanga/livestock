import 'package:flutter/material.dart';
import 'package:livestock/features/analytics/domain/entities/report_template.dart';
import 'package:livestock/features/analytics/domain/entities/report_section.dart';

/// Report Generation Dialog for creating and exporting reports (Task 18.2)
/// 
/// Provides template selection, format selection, customization options, and generation.
class ReportGenerationDialog extends StatefulWidget {
  final Function(ReportTemplate template, ExportFormat format, List<String> sections)
      onGenerate;

  const ReportGenerationDialog({
    super.key,
    required this.onGenerate,
  });

  @override
  State<ReportGenerationDialog> createState() => _ReportGenerationDialogState();
}

class _ReportGenerationDialogState extends State<ReportGenerationDialog> {
  ReportTemplate? _selectedTemplate;
  ExportFormat _selectedFormat = ExportFormat.pdf;
  final Set<String> _includedSections = {};
  bool _isGenerating = false;

  final List<ReportTemplate> _templates = [
    ReportTemplate(
      id: 'monthly_summary',
      name: 'Monthly Summary',
      type: ReportType.monthlySummary,
      sections: [
        ReportSection(
          title: 'Executive Summary',
          content: '',
          visualizations: [],
          tables: [],
        ),
        ReportSection(
          title: 'Milk Production',
          content: '',
          visualizations: [],
          tables: [],
        ),
        ReportSection(
          title: 'Farmer Demographics',
          content: '',
          visualizations: [],
          tables: [],
        ),
        ReportSection(
          title: 'Financial Performance',
          content: '',
          visualizations: [],
          tables: [],
        ),
      ],
      frequency: ReportFrequency.monthly,
      defaultFormat: ExportFormat.pdf,
    ),
    ReportTemplate(
      id: 'quarterly_review',
      name: 'Quarterly Review',
      type: ReportType.quarterlyReview,
      sections: [
        ReportSection(
          title: 'Quarter Overview',
          content: '',
          visualizations: [],
          tables: [],
        ),
        ReportSection(
          title: 'Performance Trends',
          content: '',
          visualizations: [],
          tables: [],
        ),
        ReportSection(
          title: 'Comparative Analysis',
          content: '',
          visualizations: [],
          tables: [],
        ),
      ],
      frequency: ReportFrequency.quarterly,
      defaultFormat: ExportFormat.pdf,
    ),
    ReportTemplate(
      id: 'annual_report',
      name: 'Annual Report',
      type: ReportType.annualReport,
      sections: [
        ReportSection(
          title: 'Year in Review',
          content: '',
          visualizations: [],
          tables: [],
        ),
        ReportSection(
          title: 'Key Achievements',
          content: '',
          visualizations: [],
          tables: [],
        ),
        ReportSection(
          title: 'Future Outlook',
          content: '',
          visualizations: [],
          tables: [],
        ),
      ],
      frequency: ReportFrequency.annual,
      defaultFormat: ExportFormat.pdf,
    ),
    ReportTemplate(
      id: 'government_submission',
      name: 'Government Submission',
      type: ReportType.governmentSubmission,
      sections: [
        ReportSection(
          title: 'Cooperative Overview',
          content: '',
          visualizations: [],
          tables: [],
        ),
        ReportSection(
          title: 'Production Statistics',
          content: '',
          visualizations: [],
          tables: [],
        ),
        ReportSection(
          title: 'Farmer Statistics',
          content: '',
          visualizations: [],
          tables: [],
        ),
      ],
      frequency: ReportFrequency.quarterly,
      defaultFormat: ExportFormat.excel,
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (_templates.isNotEmpty) {
      _selectedTemplate = _templates.first;
      _selectedFormat = _templates.first.defaultFormat;
      _includedSections.addAll(
        _templates.first.sections.map((s) => s.title),
      );
    }
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
                    _buildTemplateSelection(context),
                    const Divider(height: 32),
                    _buildFormatSelection(context),
                    const Divider(height: 32),
                    _buildSectionCustomization(context),
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
          const Icon(Icons.description, color: Colors.white),
          const SizedBox(width: 12),
          Text(
            'Generate Report',
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

  Widget _buildTemplateSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Report Template',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select a predefined report template',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 12),
        ..._templates.map((template) {
          final isSelected = _selectedTemplate?.id == template.id;
          return Card(
            elevation: isSelected ? 4 : 1,
            color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : null,
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedTemplate = template;
                  _selectedFormat = template.defaultFormat;
                  _includedSections.clear();
                  _includedSections.addAll(
                    template.sections.map((s) => s.title),
                  );
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(
                      _getTemplateIcon(template.type),
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey[600],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            template.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                          ),
                          Text(
                            '${template.sections.length} sections',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: Theme.of(context).primaryColor,
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFormatSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Export Format',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose the file format for your report',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: ExportFormat.values.map((format) {
            final isSelected = _selectedFormat == format;
            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getFormatIcon(format),
                    size: 18,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                  const SizedBox(width: 8),
                  Text(_getFormatLabel(format)),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedFormat = format;
                  });
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSectionCustomization(BuildContext context) {
    if (_selectedTemplate == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Report Sections',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select sections to include in the report',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 12),
        ..._selectedTemplate!.sections.map((section) {
          final isIncluded = _includedSections.contains(section.title);
          return CheckboxListTile(
            title: Text(section.title),
            value: isIncluded,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _includedSections.add(section.title);
                } else {
                  _includedSections.remove(section.title);
                }
              });
            },
          );
        }),
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
            onPressed: _isGenerating ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _isGenerating || _selectedTemplate == null
                ? null
                : () async {
                    setState(() {
                      _isGenerating = true;
                    });

                    try {
                      await widget.onGenerate(
                        _selectedTemplate!,
                        _selectedFormat,
                        _includedSections.toList(),
                      );
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Report generated successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error generating report: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isGenerating = false;
                        });
                      }
                    }
                  },
            icon: _isGenerating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.download),
            label: Text(_isGenerating ? 'Generating...' : 'Generate Report'),
          ),
        ],
      ),
    );
  }

  IconData _getTemplateIcon(ReportType type) {
    switch (type) {
      case ReportType.monthlySummary:
        return Icons.calendar_month;
      case ReportType.quarterlyReview:
        return Icons.calendar_view_month;
      case ReportType.annualReport:
        return Icons.calendar_today;
      case ReportType.governmentSubmission:
        return Icons.account_balance;
      case ReportType.customReport:
        return Icons.edit_document;
    }
  }

  IconData _getFormatIcon(ExportFormat format) {
    switch (format) {
      case ExportFormat.pdf:
        return Icons.picture_as_pdf;
      case ExportFormat.excel:
        return Icons.table_chart;
      case ExportFormat.csv:
        return Icons.text_snippet;
    }
  }

  String _getFormatLabel(ExportFormat format) {
    switch (format) {
      case ExportFormat.pdf:
        return 'PDF';
      case ExportFormat.excel:
        return 'Excel';
      case ExportFormat.csv:
        return 'CSV';
    }
  }
}
