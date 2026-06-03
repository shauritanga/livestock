import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livestock/core/services/sync_service.dart';
import 'package:livestock/l10n/app_localizations.dart';

/// Sync details screen showing sync status and management options
class SyncDetailsScreen extends ConsumerWidget {
  const SyncDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(currentSyncStateProvider);
    final syncService = ref.watch(syncServiceProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.syncStatus),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildStatusIcon(syncState),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getStatusTitle(syncState, l10n),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getStatusSubtitle(syncState, l10n),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (syncState.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              syncState.errorMessage!,
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Connection Status
          _InfoTile(
            icon: Icons.wifi,
            title: l10n.connectionStatus,
            value: syncState.isOnline ? l10n.online : l10n.offline,
            valueColor: syncState.isOnline ? Colors.green : Colors.orange,
          ),
          const SizedBox(height: 12),

          // Pending Items
          _InfoTile(
            icon: Icons.pending_actions,
            title: l10n.pendingItems,
            value: '${syncState.pendingCount}',
            valueColor: syncState.pendingCount > 0 ? Colors.orange : Colors.green,
          ),
          const SizedBox(height: 12),

          // Last Sync Time
          _InfoTile(
            icon: Icons.access_time,
            title: l10n.lastSync,
            value: syncState.lastSyncTime != null
                ? _formatLastSync(syncState.lastSyncTime!, l10n)
                : l10n.never,
            valueColor: Colors.grey[700],
          ),
          const SizedBox(height: 32),

          // Manual Sync Button
          if (syncState.isOnline)
            ElevatedButton.icon(
              onPressed: syncState.status == SyncStatus.syncing
                  ? null
                  : () async {
                      await syncService.syncPendingData();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.syncCompleted)),
                        );
                      }
                    },
              icon: syncState.status == SyncStatus.syncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.sync),
              label: Text(
                syncState.status == SyncStatus.syncing
                    ? l10n.syncing
                    : l10n.syncNow,
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

          if (!syncState.isOnline) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.offlineMessage,
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Info Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Text(
                        l10n.aboutSync,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.syncDescription,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(SyncState state) {
    Color color;
    IconData icon;

    switch (state.status) {
      case SyncStatus.syncing:
        color = Colors.blue;
        icon = Icons.sync;
      case SyncStatus.offline:
        color = Colors.orange;
        icon = Icons.cloud_off;
      case SyncStatus.error:
        color = Colors.red;
        icon = Icons.sync_problem;
      case SyncStatus.synced:
        color = Colors.green;
        icon = Icons.cloud_done;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 32),
    );
  }

  String _getStatusTitle(SyncState state, AppLocalizations l10n) {
    switch (state.status) {
      case SyncStatus.syncing:
        return l10n.syncing;
      case SyncStatus.offline:
        return l10n.offline;
      case SyncStatus.error:
        return l10n.syncError;
      case SyncStatus.synced:
        return state.pendingCount > 0 ? l10n.pendingSync : l10n.allSynced;
    }
  }

  String _getStatusSubtitle(SyncState state, AppLocalizations l10n) {
    switch (state.status) {
      case SyncStatus.syncing:
        return l10n.syncingData;
      case SyncStatus.offline:
        return l10n.offlineSubtitle(state.pendingCount);
      case SyncStatus.error:
        return l10n.syncErrorSubtitle;
      case SyncStatus.synced:
        if (state.pendingCount > 0) {
          return l10n.pendingSyncSubtitle(state.pendingCount);
        }
        return l10n.allSyncedSubtitle;
    }
  }

  String _formatLastSync(DateTime time, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return l10n.justNow;
    } else if (difference.inMinutes < 60) {
      return l10n.minutesAgo(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return l10n.hoursAgo(difference.inHours);
    } else {
      return l10n.daysAgo(difference.inDays);
    }
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? valueColor;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        trailing: Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.grey[700],
          ),
        ),
      ),
    );
  }
}
