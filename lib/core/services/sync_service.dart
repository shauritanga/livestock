import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sync status enum
enum SyncStatus {
  synced,
  syncing,
  offline,
  error,
}

/// Sync item representing pending operations
class SyncItem {
  final String id;
  final String type; // 'farmer', 'cattle', 'milk_delivery', etc.
  final String operation; // 'create', 'update', 'delete'
  final Map<String, dynamic> data;
  final DateTime timestamp;

  SyncItem({
    required this.id,
    required this.type,
    required this.operation,
    required this.data,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'operation': operation,
        'data': data,
        'timestamp': timestamp.toIso8601String(),
      };

  factory SyncItem.fromJson(Map<String, dynamic> json) => SyncItem(
        id: json['id'] as String,
        type: json['type'] as String,
        operation: json['operation'] as String,
        data: json['data'] as Map<String, dynamic>,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}

/// Sync state
class SyncState {
  final SyncStatus status;
  final int pendingCount;
  final DateTime? lastSyncTime;
  final String? errorMessage;
  final bool isOnline;

  const SyncState({
    required this.status,
    required this.pendingCount,
    this.lastSyncTime,
    this.errorMessage,
    required this.isOnline,
  });

  SyncState copyWith({
    SyncStatus? status,
    int? pendingCount,
    DateTime? lastSyncTime,
    String? errorMessage,
    bool? isOnline,
  }) {
    return SyncState(
      status: status ?? this.status,
      pendingCount: pendingCount ?? this.pendingCount,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      errorMessage: errorMessage ?? this.errorMessage,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

/// Sync service for managing offline data synchronization
class SyncService {
  final FirebaseFirestore _firestore;
  final Connectivity _connectivity;

  StreamController<SyncState>? _syncStateController;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  SyncState _currentState = const SyncState(
    status: SyncStatus.synced,
    pendingCount: 0,
    isOnline: true,
  );

  SyncService({
    FirebaseFirestore? firestore,
    Connectivity? connectivity,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _connectivity = connectivity ?? Connectivity();

  /// Initialize the sync service
  Future<void> initialize() async {
    _syncStateController = StreamController<SyncState>.broadcast();

    // Check initial connectivity
    final connectivityResult = await _connectivity.checkConnectivity();
    final isOnline = !connectivityResult.contains(ConnectivityResult.none);

    _currentState = _currentState.copyWith(isOnline: isOnline);
    _emitState();

    // Listen to connectivity changes
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((results) {
      final wasOnline = _currentState.isOnline;
      final isNowOnline = !results.contains(ConnectivityResult.none);

      if (wasOnline != isNowOnline) {
        _currentState = _currentState.copyWith(isOnline: isNowOnline);
        _emitState();

        // Auto-sync when coming back online
        if (isNowOnline && _currentState.pendingCount > 0) {
          syncPendingData();
        }
      }
    });

    // Enable Firestore offline persistence
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  /// Get sync state stream
  Stream<SyncState> get syncStateStream {
    if (_syncStateController == null) {
      throw StateError('SyncService not initialized. Call initialize() first.');
    }
    return _syncStateController!.stream;
  }

  /// Get current sync state
  SyncState get currentState => _currentState;

  /// Manually trigger sync
  Future<void> syncPendingData() async {
    if (!_currentState.isOnline) {
      _currentState = _currentState.copyWith(
        status: SyncStatus.offline,
        errorMessage: 'No internet connection',
      );
      _emitState();
      return;
    }

    if (_currentState.status == SyncStatus.syncing) {
      return; // Already syncing
    }

    try {
      _currentState = _currentState.copyWith(
        status: SyncStatus.syncing,
        errorMessage: null,
      );
      _emitState();

      // Firestore handles offline sync automatically
      // We just need to wait for pending writes to complete
      await _firestore.waitForPendingWrites();

      _currentState = _currentState.copyWith(
        status: SyncStatus.synced,
        pendingCount: 0,
        lastSyncTime: DateTime.now(),
        errorMessage: null,
      );
      _emitState();
    } catch (e) {
      _currentState = _currentState.copyWith(
        status: SyncStatus.error,
        errorMessage: e.toString(),
      );
      _emitState();
    }
  }

  /// Check for pending writes
  Future<int> getPendingWritesCount() async {
    // Firestore doesn't expose pending writes count directly
    // We'll estimate based on offline status
    if (!_currentState.isOnline) {
      // Return estimated count (this would need to be tracked separately)
      return _currentState.pendingCount;
    }
    return 0;
  }

  /// Clear sync errors
  void clearError() {
    if (_currentState.status == SyncStatus.error) {
      _currentState = _currentState.copyWith(
        status: SyncStatus.synced,
        errorMessage: null,
      );
      _emitState();
    }
  }

  /// Update pending count (called by repositories when adding offline operations)
  void updatePendingCount(int count) {
    _currentState = _currentState.copyWith(pendingCount: count);
    _emitState();
  }

  /// Increment pending count
  void incrementPendingCount() {
    _currentState = _currentState.copyWith(
      pendingCount: _currentState.pendingCount + 1,
    );
    _emitState();
  }

  /// Decrement pending count
  void decrementPendingCount() {
    final newCount = (_currentState.pendingCount - 1).clamp(0, double.infinity).toInt();
    _currentState = _currentState.copyWith(pendingCount: newCount);
    _emitState();
  }

  void _emitState() {
    _syncStateController?.add(_currentState);
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _syncStateController?.close();
  }
}

/// Provider for sync service
final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService();
  service.initialize();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for sync state stream
final syncStateStreamProvider = StreamProvider<SyncState>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.syncStateStream;
});

/// Provider for current sync state
final currentSyncStateProvider = Provider<SyncState>((ref) {
  final asyncState = ref.watch(syncStateStreamProvider);
  return asyncState.when(
    data: (state) => state,
    loading: () => const SyncState(
      status: SyncStatus.synced,
      pendingCount: 0,
      isOnline: true,
    ),
    error: (_, __) => const SyncState(
      status: SyncStatus.error,
      pendingCount: 0,
      isOnline: false,
      errorMessage: 'Failed to load sync state',
    ),
  );
});
