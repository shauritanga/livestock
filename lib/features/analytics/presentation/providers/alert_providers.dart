import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/alert.dart';
import '../../core/result.dart';
import 'analytics_providers.dart';

// ============================================================================
// Alert Actions State (Task 16.5)
// ============================================================================

/// State for alert actions
class AlertActionsState {
  final bool isProcessing;
  final String? error;
  final String? successMessage;

  const AlertActionsState({
    this.isProcessing = false,
    this.error,
    this.successMessage,
  });

  AlertActionsState copyWith({
    bool? isProcessing,
    String? error,
    String? successMessage,
  }) {
    return AlertActionsState(
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
      successMessage: successMessage,
    );
  }
}

/// Alert actions notifier (Task 16.5)
class AlertActionsNotifier extends Notifier<AlertActionsState> {
  @override
  AlertActionsState build() => const AlertActionsState();

  /// Mark alert as read (Task 16.5)
  Future<void> markAsRead(String alertId) async {
    state = state.copyWith(isProcessing: true, error: null);

    try {
      final repository = await ref.read(analyticsRepositoryProvider.future);
      final result = await repository.markAlertAsRead(alertId);

      if (result.isSuccess) {
        state = state.copyWith(
          isProcessing: false,
          successMessage: 'Alert marked as read',
        );
      } else {
        state = state.copyWith(
          isProcessing: false,
          error: result.errorOrNull ?? 'Failed to mark alert as read',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: 'Failed to mark alert as read: $e',
      );
    }
  }

  /// Mark multiple alerts as read
  Future<void> markMultipleAsRead(List<String> alertIds) async {
    state = state.copyWith(isProcessing: true, error: null);

    try {
      final repository = await ref.read(analyticsRepositoryProvider.future);
      
      for (final alertId in alertIds) {
        await repository.markAlertAsRead(alertId);
      }

      state = state.copyWith(
        isProcessing: false,
        successMessage: '${alertIds.length} alerts marked as read',
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: 'Failed to mark alerts as read: $e',
      );
    }
  }

  /// Dismiss alert (same as mark as read for now)
  Future<void> dismissAlert(String alertId) async {
    await markAsRead(alertId);
  }

  /// Clear messages
  void clearMessages() {
    state = state.copyWith(error: null, successMessage: null);
  }
}

// ============================================================================
// Alert Providers (Task 16.5)
// ============================================================================

/// Alert actions provider (Task 16.5)
final alertActionsProvider = NotifierProvider<AlertActionsNotifier, AlertActionsState>(() {
  return AlertActionsNotifier();
});

/// Filter for alert severity
final alertSeverityFilterProvider = Provider<AlertSeverity?>((ref) => null);

/// Filter for unread only
final alertUnreadOnlyFilterProvider = Provider<bool>((ref) => false);

/// Filtered alerts provider
final filteredAlertsProvider = Provider<List<Alert>>((ref) {
  final alertsAsync = ref.watch(alertsStreamProvider);
  final severityFilter = ref.watch(alertSeverityFilterProvider);
  final unreadOnly = ref.watch(alertUnreadOnlyFilterProvider);

  return alertsAsync.when(
    data: (alerts) {
      var filtered = alerts;

      // Filter by severity
      if (severityFilter != null) {
        filtered = filtered.where((alert) {
          // Show alerts of the selected severity and higher priority
          final severityIndex = AlertSeverity.values.indexOf(alert.severity);
          final filterIndex = AlertSeverity.values.indexOf(severityFilter);
          return severityIndex <= filterIndex;
        }).toList();
      }

      // Filter by read status
      if (unreadOnly) {
        filtered = filtered.where((alert) => !alert.isRead).toList();
      }

      return filtered;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Critical alerts provider (unread critical alerts only)
final criticalAlertsProvider = Provider<List<Alert>>((ref) {
  final alertsAsync = ref.watch(alertsStreamProvider);

  return alertsAsync.when(
    data: (alerts) => alerts
        .where((alert) => 
            alert.severity == AlertSeverity.critical && !alert.isRead)
        .toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Critical alerts count provider
final criticalAlertsCountProvider = Provider<int>((ref) {
  return ref.watch(criticalAlertsProvider).length;
});

/// Alerts by type provider
final alertsByTypeProvider = Provider<Map<AlertType, List<Alert>>>((ref) {
  final alertsAsync = ref.watch(alertsStreamProvider);

  return alertsAsync.when(
    data: (alerts) {
      final Map<AlertType, List<Alert>> grouped = {};
      
      for (final alert in alerts) {
        if (!grouped.containsKey(alert.type)) {
          grouped[alert.type] = [];
        }
        grouped[alert.type]!.add(alert);
      }
      
      return grouped;
    },
    loading: () => {},
    error: (_, __) => {},
  );
});

/// Alert statistics provider
final alertStatisticsProvider = Provider<Map<String, int>>((ref) {
  final alertsAsync = ref.watch(alertsStreamProvider);

  return alertsAsync.when(
    data: (alerts) {
      return {
        'total': alerts.length,
        'unread': alerts.where((a) => !a.isRead).length,
        'critical': alerts.where((a) => a.severity == AlertSeverity.critical).length,
        'warning': alerts.where((a) => a.severity == AlertSeverity.warning).length,
        'info': alerts.where((a) => a.severity == AlertSeverity.informational).length,
      };
    },
    loading: () => {
      'total': 0,
      'unread': 0,
      'critical': 0,
      'warning': 0,
      'info': 0,
    },
    error: (_, __) => {
      'total': 0,
      'unread': 0,
      'critical': 0,
      'warning': 0,
      'info': 0,
    },
  );
});
