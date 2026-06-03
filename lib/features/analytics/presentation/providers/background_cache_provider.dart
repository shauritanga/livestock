import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/background_cache_service.dart';
import 'analytics_providers.dart';

/// Provider for background cache service
final backgroundCacheServiceProvider = FutureProvider<BackgroundCacheService>((ref) async {
  final analyticsRepository = await ref.watch(analyticsRepositoryProvider.future);
  return BackgroundCacheService(analyticsRepository);
});

/// Provider to initialize and manage background cache refresh
final backgroundCacheInitializerProvider = FutureProvider<void>((ref) async {
  final service = await ref.watch(backgroundCacheServiceProvider.future);
  
  // Start periodic refresh when app starts
  service.startPeriodicRefresh();
  
  // Pre-fetch common analytics
  await service.preFetchCommonAnalytics();
  
  // Cleanup when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });
});
