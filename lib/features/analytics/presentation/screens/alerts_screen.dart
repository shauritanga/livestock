import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/analytics_providers.dart';
import '../../domain/entities/alert.dart';

/// Alerts Screen (Task 27.1)
/// 
/// Displays all alerts grouped by severity with filtering and actions.
class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  AlertSeverity? _selectedSeverity;
  bool _showUnreadOnly = false;

  @override
  Widget build(BuildContext context) {
    final alertsAsync = ref.watch(alertsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts & Notifications'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
            onSelected: (value) {
              setState(() {
                if (value == 'all') {
                  _selectedSeverity = null;
                } else if (value == 'critical') {
                  _selectedSeverity = AlertSeverity.critical;
                } else if (value == 'warning') {
                  _selectedSeverity = AlertSeverity.warning;
                } else if (value == 'info') {
                  _selectedSeverity = AlertSeverity.informational;
                } else if (value == 'unread') {
                  _showUnreadOnly = !_showUnreadOnly;
                }
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Alerts')),
              const PopupMenuItem(
                  value: 'critical', child: Text('Critical Only')),
              const PopupMenuItem(
                  value: 'warning', child: Text('Warning Only')),
              const PopupMenuItem(value: 'info', child: Text('Info Only')),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'unread',
                child: Row(
                  children: [
                    Checkbox(
                      value: _showUnreadOnly,
                      onChanged: null,
                    ),
                    const Text('Unread Only'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: alertsAsync.when(
        data: (alerts) {
          final filteredAlerts = _filterAlerts(alerts);
          if (filteredAlerts.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildAlertsList(context, filteredAlerts);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(alertsStreamProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Alert> _filterAlerts(List<Alert> alerts) {
    var filtered = alerts;

    if (_selectedSeverity != null) {
      filtered =
          filtered.where((alert) => alert.severity == _selectedSeverity).toList();
    }

    if (_showUnreadOnly) {
      filtered = filtered.where((alert) => !alert.isRead).toList();
    }

    return filtered;
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No alerts to display',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsList(BuildContext context, List<Alert> alerts) {
    // Group alerts by severity
    final criticalAlerts =
        alerts.where((a) => a.severity == AlertSeverity.critical).toList();
    final warningAlerts =
        alerts.where((a) => a.severity == AlertSeverity.warning).toList();
    final infoAlerts =
        alerts.where((a) => a.severity == AlertSeverity.informational).toList();

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(alertsStreamProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_selectedSeverity == null) _buildFilterSummary(context, alerts),
          if (_selectedSeverity == null) const SizedBox(height: 16),
          if (criticalAlerts.isNotEmpty) ...[
            _buildSeveritySection(
              context,
              'Critical Alerts',
              criticalAlerts,
              Colors.red,
              Icons.error,
            ),
            const SizedBox(height: 16),
          ],
          if (warningAlerts.isNotEmpty) ...[
            _buildSeveritySection(
              context,
              'Warning Alerts',
              warningAlerts,
              Colors.orange,
              Icons.warning,
            ),
            const SizedBox(height: 16),
          ],
          if (infoAlerts.isNotEmpty) ...[
            _buildSeveritySection(
              context,
              'Informational Alerts',
              infoAlerts,
              Colors.blue,
              Icons.info,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterSummary(BuildContext context, List<Alert> alerts) {
    final unreadCount = alerts.where((a) => !a.isRead).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Alerts',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alerts.length.toString(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.circle, size: 8, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(
                    '$unreadCount Unread',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeveritySection(
    BuildContext context,
    String title,
    List<Alert> alerts,
    Color color,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                alerts.length.toString(),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...alerts.map((alert) => _buildAlertCard(context, alert, color)),
      ],
    );
  }

  Widget _buildAlertCard(BuildContext context, Alert alert, Color color) {
    return Dismissible(
      key: Key(alert.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        _dismissAlert(alert);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Alert dismissed: ${alert.title}'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                // Undo dismiss action
              },
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        color: alert.isRead ? null : color.withValues(alpha: 0.05),
        child: InkWell(
          onTap: () => _showAlertDetails(context, alert),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (!alert.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    if (!alert.isRead) const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        alert.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    _buildAlertTypeIcon(alert.type),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  alert.message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatTimestamp(alert.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                    ),
                    if (!alert.isRead)
                      TextButton(
                        onPressed: () => _markAsRead(alert),
                        child: const Text('Mark as Read'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlertTypeIcon(AlertType type) {
    IconData icon;
    Color color;

    switch (type) {
      case AlertType.productionDrop:
        icon = Icons.trending_down;
        color = Colors.red;
        break;
      case AlertType.lowStock:
        icon = Icons.inventory_2;
        color = Colors.orange;
        break;
      case AlertType.loanDefault:
        icon = Icons.money_off;
        color = Colors.red;
        break;
      case AlertType.insuranceLapse:
        icon = Icons.shield;
        color = Colors.orange;
        break;
      case AlertType.farmerEngagement:
        icon = Icons.people;
        color = Colors.blue;
        break;
      case AlertType.qualityConcern:
        icon = Icons.warning;
        color = Colors.orange;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }

  void _showAlertDetails(BuildContext context, Alert alert) {
    // Mark as read when viewing details
    if (!alert.isRead) {
      _markAsRead(alert);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            _buildAlertTypeIcon(alert.type),
            const SizedBox(width: 12),
            Expanded(
              child: Text(alert.title),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(alert.message),
              const SizedBox(height: 16),
              if (alert.metadata.isNotEmpty) ...[
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Additional Details',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                ...alert.metadata.entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('${entry.key}: ${entry.value}'),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                'Created: ${_formatTimestamp(alert.createdAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
        actions: [
          if (alert.actionUrl != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to action URL
              },
              child: const Text('Take Action'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _markAsRead(Alert alert) {
    // Call repository to mark alert as read
    // This would be implemented through a provider
    ref.invalidate(alertsStreamProvider);
  }

  void _dismissAlert(Alert alert) {
    // Call repository to dismiss/delete alert
    // This would be implemented through a provider
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
