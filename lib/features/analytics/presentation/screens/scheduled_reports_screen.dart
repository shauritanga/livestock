import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/report_template.dart';
import '../providers/report_providers.dart';

/// Scheduled reports management screen
/// Task 28.4: Implement scheduled reports
class ScheduledReportsScreen extends ConsumerWidget {
  const ScheduledReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduledReportsAsync = ref.watch(scheduledReportsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scheduled Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(context),
            tooltip: 'Help',
          ),
        ],
      ),
      body: scheduledReportsAsync.when(
        data: (reports) {
          if (reports.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildReportsList(context, ref, reports);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading scheduled reports'),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.refresh(scheduledReportsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateScheduledReportDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Schedule Report'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.schedule,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Scheduled Reports',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Create automated reports that generate on a schedule',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _showCreateScheduledReportDialog(context, null),
            icon: const Icon(Icons.add),
            label: const Text('Schedule Your First Report'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsList(
    BuildContext context,
    WidgetRef ref,
    List<ScheduledReport> reports,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return _buildReportCard(context, ref, report);
      },
    );
  }

  Widget _buildReportCard(
    BuildContext context,
    WidgetRef ref,
    ScheduledReport report,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: report.isActive
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Icon(
                _getReportIcon(report.template.type),
                color: report.isActive
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            title: Text(
              report.template.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(_getFrequencyText(report.frequency)),
                const SizedBox(height: 2),
                Text(
                  'Recipients: ${report.recipientEmails.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            trailing: Switch(
              value: report.isActive,
              onChanged: (value) {
                // TODO: Implement toggle active status
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value
                          ? 'Report schedule activated'
                          : 'Report schedule deactivated',
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Last Generated',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        report.lastGenerated != null
                            ? _formatDateTime(report.lastGenerated!)
                            : 'Never',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next Scheduled',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDateTime(report.nextScheduled),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ButtonBar(
            children: [
              TextButton.icon(
                onPressed: () => _showEditDialog(context, ref, report),
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
              ),
              TextButton.icon(
                onPressed: () => _showDeleteConfirmation(context, ref, report),
                icon: const Icon(Icons.delete),
                label: const Text('Delete'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreateScheduledReportDialog(BuildContext context, WidgetRef? ref) {
    showDialog(
      context: context,
      builder: (context) => const _ScheduleReportDialog(),
    );
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    ScheduledReport report,
  ) {
    showDialog(
      context: context,
      builder: (context) => _ScheduleReportDialog(existingReport: report),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    ScheduledReport report,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Scheduled Report'),
        content: Text(
          'Are you sure you want to delete the scheduled report "${report.template.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // TODO: Implement delete
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Scheduled report deleted')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scheduled Reports Help'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Scheduled reports are automatically generated and sent to specified recipients on a regular basis.',
              ),
              SizedBox(height: 16),
              Text(
                'Frequency Options:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Daily: Generated every day'),
              Text('• Weekly: Generated every week'),
              Text('• Monthly: Generated on the 1st of each month'),
              Text('• Quarterly: Generated every 3 months'),
              Text('• Annual: Generated once per year'),
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

  IconData _getReportIcon(ReportType type) {
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
        return Icons.description;
    }
  }

  String _getFrequencyText(ReportFrequency frequency) {
    switch (frequency) {
      case ReportFrequency.daily:
        return 'Daily';
      case ReportFrequency.weekly:
        return 'Weekly';
      case ReportFrequency.monthly:
        return 'Monthly';
      case ReportFrequency.quarterly:
        return 'Quarterly';
      case ReportFrequency.annual:
        return 'Annual';
      case ReportFrequency.onDemand:
        return 'On Demand';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

/// Dialog for creating/editing scheduled reports
class _ScheduleReportDialog extends ConsumerStatefulWidget {
  final ScheduledReport? existingReport;

  const _ScheduleReportDialog({this.existingReport});

  @override
  ConsumerState<_ScheduleReportDialog> createState() =>
      _ScheduleReportDialogState();
}

class _ScheduleReportDialogState extends ConsumerState<_ScheduleReportDialog> {
  ReportTemplate? _selectedTemplate;
  ReportFrequency _selectedFrequency = ReportFrequency.monthly;
  final List<String> _recipients = [];
  final _recipientController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingReport != null) {
      _selectedTemplate = widget.existingReport!.template;
      _selectedFrequency = widget.existingReport!.frequency;
      _recipients.addAll(widget.existingReport!.recipientEmails);
    }
  }

  @override
  void dispose() {
    _recipientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final templatesAsync = ref.watch(reportTemplatesProvider);

    return AlertDialog(
      title: Text(
        widget.existingReport == null
            ? 'Schedule New Report'
            : 'Edit Scheduled Report',
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Template selection
              Text(
                'Report Template',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              templatesAsync.when(
                data: (templates) => DropdownButtonFormField<ReportTemplate>(
                  value: _selectedTemplate,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Select a template',
                  ),
                  items: templates.map((template) {
                    return DropdownMenuItem(
                      value: template,
                      child: Text(template.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTemplate = value;
                    });
                  },
                ),
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Text('Error loading templates'),
              ),
              const SizedBox(height: 16),

              // Frequency selection
              Text(
                'Frequency',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<ReportFrequency>(
                value: _selectedFrequency,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: ReportFrequency.values
                    .where((f) => f != ReportFrequency.onDemand)
                    .map((frequency) {
                  return DropdownMenuItem(
                    value: frequency,
                    child: Text(_getFrequencyText(frequency)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFrequency = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Recipients
              Text(
                'Recipients',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _recipientController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter email address',
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _addRecipient,
                    icon: const Icon(Icons.add),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_recipients.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _recipients.map((email) {
                    return Chip(
                      label: Text(email),
                      onDeleted: () {
                        setState(() {
                          _recipients.remove(email);
                        });
                      },
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _canSave() ? _saveScheduledReport : null,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _addRecipient() {
    final email = _recipientController.text.trim();
    if (email.isNotEmpty && email.contains('@')) {
      setState(() {
        if (!_recipients.contains(email)) {
          _recipients.add(email);
        }
        _recipientController.clear();
      });
    }
  }

  bool _canSave() {
    return _selectedTemplate != null && _recipients.isNotEmpty;
  }

  Future<void> _saveScheduledReport() async {
    if (!_canSave()) return;

    try {
      await ref.read(reportGenerationProvider.notifier).scheduleReport(
            template: _selectedTemplate!,
            frequency: _selectedFrequency,
            recipientEmails: _recipients,
          );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report scheduled successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error scheduling report: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  String _getFrequencyText(ReportFrequency frequency) {
    switch (frequency) {
      case ReportFrequency.daily:
        return 'Daily';
      case ReportFrequency.weekly:
        return 'Weekly';
      case ReportFrequency.monthly:
        return 'Monthly';
      case ReportFrequency.quarterly:
        return 'Quarterly';
      case ReportFrequency.annual:
        return 'Annual';
      case ReportFrequency.onDemand:
        return 'On Demand';
    }
  }
}

/// Scheduled report entity (placeholder - should be in domain layer)
class ScheduledReport {
  final String id;
  final ReportTemplate template;
  final ReportFrequency frequency;
  final List<String> recipientEmails;
  final DateTime? lastGenerated;
  final DateTime nextScheduled;
  final bool isActive;
  final String createdBy;

  const ScheduledReport({
    required this.id,
    required this.template,
    required this.frequency,
    required this.recipientEmails,
    this.lastGenerated,
    required this.nextScheduled,
    required this.isActive,
    required this.createdBy,
  });
}

/// Scheduled reports provider (placeholder)
final scheduledReportsProvider =
    FutureProvider<List<ScheduledReport>>((ref) async {
  // TODO: Implement actual data fetching
  return [];
});
