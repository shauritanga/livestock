import 'package:flutter/material.dart';
import 'package:livestock/features/analytics/domain/entities/alert.dart';

/// Alert List Widget for displaying alerts with severity grouping (Task 17.6)
/// 
/// Displays list of alerts grouped by severity with color coding, swipe-to-dismiss, and tap actions.
class AlertListWidget extends StatelessWidget {
  final List<Alert> alerts;
  final Function(Alert) onAlertTap;
  final Function(Alert) onDismiss;

  const AlertListWidget({
    super.key,
    required this.alerts,
    required this.onAlertTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return _buildEmptyState(context);
    }

    // Group alerts by severity
    final criticalAlerts = alerts
        .where((alert) => alert.severity == AlertSeverity.critical)
        .toList();
    final warningAlerts = alerts
        .where((alert) => alert.severity == AlertSeverity.warning)
        .toList();
    final infoAlerts = alerts
        .where((alert) => alert.severity == AlertSeverity.informational)
        .toList();

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        if (criticalAlerts.isNotEmpty) ...[
          _buildSectionHeader(context, 'Critical', criticalAlerts.length),
          ...criticalAlerts.map((alert) => _buildAlertItem(context, alert)),
          const SizedBox(height: 16),
        ],
        if (warningAlerts.isNotEmpty) ...[
          _buildSectionHeader(context, 'Warning', warningAlerts.length),
          ...warningAlerts.map((alert) => _buildAlertItem(context, alert)),
          const SizedBox(height: 16),
        ],
        if (infoAlerts.isNotEmpty) ...[
          _buildSectionHeader(context, 'Information', infoAlerts.length),
          ...infoAlerts.map((alert) => _buildAlertItem(context, alert)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getSeverityColor(_getSeverityFromString(title)),
                ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _getSeverityColor(_getSeverityFromString(title))
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _getSeverityColor(_getSeverityFromString(title)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(BuildContext context, Alert alert) {
    final severityColor = _getSeverityColor(alert.severity);
    final severityIcon = _getSeverityIcon(alert.severity);

    return Dismissible(
      key: Key(alert.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        onDismiss(alert);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16.0),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: InkWell(
          onTap: () => onAlertTap(alert),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    severityIcon,
                    color: severityColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              alert.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: alert.isRead
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                  ),
                            ),
                          ),
                          if (!alert.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: severityColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alert.message,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTimestamp(alert.createdAt),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[400],
                                      fontSize: 11,
                                    ),
                          ),
                          const Spacer(),
                          _buildAlertTypeChip(context, alert.type),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlertTypeChip(BuildContext context, AlertType type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getAlertTypeLabel(type),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 10,
              color: Colors.grey[700],
            ),
      ),
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
              Icons.notifications_none,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No alerts',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'re all caught up!',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return Colors.red;
      case AlertSeverity.warning:
        return Colors.orange;
      case AlertSeverity.informational:
        return Colors.blue;
    }
  }

  IconData _getSeverityIcon(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return Icons.error;
      case AlertSeverity.warning:
        return Icons.warning;
      case AlertSeverity.informational:
        return Icons.info;
    }
  }

  AlertSeverity _getSeverityFromString(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return AlertSeverity.critical;
      case 'warning':
        return AlertSeverity.warning;
      default:
        return AlertSeverity.informational;
    }
  }

  String _getAlertTypeLabel(AlertType type) {
    switch (type) {
      case AlertType.productionDrop:
        return 'Production';
      case AlertType.lowStock:
        return 'Stock';
      case AlertType.loanDefault:
        return 'Loan';
      case AlertType.insuranceLapse:
        return 'Insurance';
      case AlertType.farmerEngagement:
        return 'Engagement';
      case AlertType.qualityConcern:
        return 'Quality';
    }
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
