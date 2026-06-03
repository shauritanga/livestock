import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livestock/core/services/sync_service.dart';

/// Sync status indicator widget for app bar
class SyncStatusIndicator extends ConsumerWidget {
  final VoidCallback? onTap;

  const SyncStatusIndicator({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(currentSyncStateProvider);

    return IconButton(
      icon: _buildIcon(syncState),
      onPressed: onTap,
      tooltip: _getTooltip(syncState),
    );
  }

  Widget _buildIcon(SyncState state) {
    switch (state.status) {
      case SyncStatus.syncing:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        );

      case SyncStatus.offline:
        return Badge(
          label: Text('${state.pendingCount}'),
          isLabelVisible: state.pendingCount > 0,
          child: const Icon(Icons.cloud_off),
        );

      case SyncStatus.error:
        return Badge(
          label: const Icon(Icons.error, size: 12),
          backgroundColor: Colors.red,
          child: const Icon(Icons.sync_problem),
        );

      case SyncStatus.synced:
        if (state.pendingCount > 0) {
          return Badge(
            label: Text('${state.pendingCount}'),
            child: const Icon(Icons.cloud_queue),
          );
        }
        return const Icon(Icons.cloud_done);
    }
  }

  String _getTooltip(SyncState state) {
    switch (state.status) {
      case SyncStatus.syncing:
        return 'Syncing data...';
      case SyncStatus.offline:
        return 'Offline - ${state.pendingCount} pending';
      case SyncStatus.error:
        return 'Sync error';
      case SyncStatus.synced:
        if (state.pendingCount > 0) {
          return '${state.pendingCount} items pending';
        }
        return 'All data synced';
    }
  }
}
