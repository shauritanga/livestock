import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livestock/core/services/connectivity_service.dart';
import 'package:livestock/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:livestock/features/inventory/presentation/providers/inventory_providers.dart';

/// Sync service for inventory offline transactions
class InventorySyncService {
  final InventoryRepository _repository;
  final ConnectivityService _connectivityService;
  Timer? _syncTimer;
  StreamSubscription? _connectivitySubscription;

  InventorySyncService({
    required InventoryRepository repository,
    required ConnectivityService connectivityService,
  })  : _repository = repository,
        _connectivityService = connectivityService {
    _initializeSync();
  }

  /// Initialize sync service
  void _initializeSync() {
    // Listen to connectivity changes
    _connectivitySubscription =
        _connectivityService.onConnectivityChanged.listen((isOnline) {
      if (isOnline) {
        // Trigger sync when connection is restored
        syncPendingTransactions();
      }
    });

    // Set up periodic sync (every 15 minutes)
    _syncTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) => syncPendingTransactions(),
    );
  }

  /// Sync pending transactions
  Future<SyncResult> syncPendingTransactions() async {
    try {
      // Check if online
      final isOnline = await _connectivityService.isOnline();
      if (!isOnline) {
        return SyncResult(
          success: false,
          message: 'Device is offline',
          syncedCount: 0,
        );
      }

      // Check if there are pending transactions
      final hasPending = await _repository.hasPendingTransactions();
      if (!hasPending) {
        return SyncResult(
          success: true,
          message: 'No pending transactions',
          syncedCount: 0,
        );
      }

      // Sync pending transactions
      await _repository.syncPendingTransactions();

      return SyncResult(
        success: true,
        message: 'Sync completed successfully',
        syncedCount: 0, // Repository doesn't return count yet
      );
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Sync failed: ${e.toString()}',
        syncedCount: 0,
      );
    }
  }

  /// Manually trigger sync
  Future<SyncResult> manualSync() async {
    return await syncPendingTransactions();
  }

  /// Dispose resources
  void dispose() {
    _syncTimer?.cancel();
    _connectivitySubscription?.cancel();
  }
}

/// Sync result model
class SyncResult {
  final bool success;
  final String message;
  final int syncedCount;

  SyncResult({
    required this.success,
    required this.message,
    required this.syncedCount,
  });
}

/// Provider for inventory sync service
final inventorySyncServiceProvider = FutureProvider<InventorySyncService>((ref) async {
  final repository = await ref.watch(inventoryRepositoryProvider.future);
  final connectivityService = ref.watch(connectivityServiceProvider);

  final service = InventorySyncService(
    repository: repository,
    connectivityService: connectivityService,
  );

  ref.onDispose(() => service.dispose());

  return service;
});

/// Provider for sync status
final syncStatusProvider = StreamProvider<SyncStatus>((ref) async* {
  final service = await ref.watch(inventorySyncServiceProvider.future);
  final repository = await ref.watch(inventoryRepositoryProvider.future);
  final connectivityService = ref.watch(connectivityServiceProvider);

  // Initial status
  yield SyncStatus(
    isOnline: await ref.watch(isOnlineProvider.future),
    hasPendingTransactions: await repository.hasPendingTransactions(),
    lastSyncTime: null,
    isSyncing: false,
  );

  // Listen to connectivity changes
  await for (final isOnline in connectivityService.onConnectivityChanged) {
    final hasPending = await repository.hasPendingTransactions();

    yield SyncStatus(
      isOnline: isOnline,
      hasPendingTransactions: hasPending,
      lastSyncTime: null,
      isSyncing: false,
    );

    // Auto-sync when coming online
    if (isOnline && hasPending) {
      yield SyncStatus(
        isOnline: isOnline,
        hasPendingTransactions: hasPending,
        lastSyncTime: null,
        isSyncing: true,
      );

      await service.syncPendingTransactions();

      yield SyncStatus(
        isOnline: isOnline,
        hasPendingTransactions: await repository.hasPendingTransactions(),
        lastSyncTime: DateTime.now(),
        isSyncing: false,
      );
    }
  }
});

/// Sync status model
class SyncStatus {
  final bool isOnline;
  final bool hasPendingTransactions;
  final DateTime? lastSyncTime;
  final bool isSyncing;

  SyncStatus({
    required this.isOnline,
    required this.hasPendingTransactions,
    required this.lastSyncTime,
    required this.isSyncing,
  });

  String get statusMessage {
    if (isSyncing) return 'Syncing...';
    if (!isOnline) return 'Offline';
    if (hasPendingTransactions) return 'Pending sync';
    return 'All synced';
  }
}
