import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_service.dart';
import '../../features/analytics/presentation/providers/analytics_providers.dart' as analytics;

/// Service for handling app initialization tasks
class AppInitializationService {
  final FirebaseFirestore _firestore;
  final FirebaseMessaging _messaging;
  final Ref? _ref;
  
  AppInitializationService({
    required FirebaseFirestore firestore,
    required FirebaseMessaging messaging,
    Ref? ref,
  })  : _firestore = firestore,
        _messaging = messaging,
        _ref = ref;
  
  /// Initialize all app services
  Future<void> initialize() async {
    // Configure Firestore settings
    await _configureFirestore();
    
    // Request notification permissions in background (non-blocking)
    _requestNotificationPermissions().catchError((e) {
      print('Notification permission request failed: $e');
    });
    
    // Initialize analytics cache in background (non-blocking)
    if (_ref != null) {
      _initializeAnalytics().catchError((e) {
        print('Analytics initialization failed: $e');
      });
    }
    
    // Add any other initialization tasks here
  }
  
  /// Initialize analytics cache and pre-load common data
  Future<void> _initializeAnalytics() async {
    if (_ref == null) return;
    
    try {
      // Pre-load analytics cache manager
      await _ref.read(analytics.analyticsLocalDataSourceProvider.future);
      await _ref.read(analytics.cacheManagerProvider.future);
      
      // Pre-fetch today's analytics summary in background
      // This will populate the cache for faster initial load
      // Using unawaited since we don't want to block initialization
      unawaited(_ref.read(analytics.analyticsSummaryProvider.future).then(
        (_) => print('Analytics summary pre-fetched successfully'),
        onError: (e) => print('Failed to pre-fetch analytics summary: $e'),
      ));
    } catch (e) {
      // Analytics initialization is optional, so we don't throw
      print('Analytics initialization error: $e');
    }
  }
  
  /// Configure Firestore settings
  Future<void> _configureFirestore() async {
    // Enable offline persistence (already set in provider, but ensuring it's configured)
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }
  
  /// Request notification permissions
  Future<void> _requestNotificationPermissions() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Get FCM token for this device
        final token = await _messaging.getToken();
        // TODO: Store token in Firestore for push notifications
        print('FCM Token: $token');
      }
    } catch (e) {
      // Notification permission is optional, so we don't throw
      print('Failed to request notification permissions: $e');
    }
  }
}

/// Provider for AppInitializationService
final appInitializationServiceProvider = Provider<AppInitializationService>((ref) {
  return AppInitializationService(
    firestore: ref.watch(firestoreProvider),
    messaging: ref.watch(firebaseMessagingProvider),
    ref: ref,
  );
});

/// Provider for app initialization state
final appInitializationProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(appInitializationServiceProvider);
  await service.initialize();
});
