import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/app_initialization_service.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/error_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/onboarding_provider.dart';

/// Splash screen that handles app initialization and routing
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Wait for app initialization to complete (with timeout)
      await ref.read(appInitializationProvider.future).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          // Continue even if initialization times out
          print('App initialization timed out, continuing anyway');
        },
      );
      
      if (!mounted) return;
      
      // Navigate to next screen
      await _navigateToNextScreen();
    } catch (e) {
      print('Initialization error: $e');
      // Continue to navigation even if there's an error
      if (mounted) {
        await _navigateToNextScreen();
      }
    }
  }

  Future<void> _navigateToNextScreen() async {
    try {
      // Check if user has seen onboarding
      final hasSeenOnboarding = await ref.read(hasSeenOnboardingProvider.future);
      
      if (!mounted) return;
      
      if (!hasSeenOnboarding) {
        // First time user - show onboarding
        context.go('/onboarding');
      } else {
        // Check current user directly from Firebase (synchronous check)
        final getCurrentUserUseCase = ref.read(getCurrentUserProvider);
        final userResult = await getCurrentUserUseCase();
        
        if (!mounted) return;
        
        // Check if user is authenticated
        final isAuthenticated = userResult.fold(
          onError: (_) => false,
          onSuccess: (user) => user != null,
        );
        
        if (isAuthenticated) {
          // User is authenticated - go to dashboard
          context.go('/dashboard');
        } else {
          // User is not authenticated - go to login
          context.go('/login');
        }
      }
    } catch (e) {
      print('Navigation error: $e');
      // Default to login on error
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final initState = ref.watch(appInitializationProvider);
    
    return initState.when(
      data: (_) => const LoadingScreen(message: 'Starting...'),
      loading: () => const LoadingScreen(message: 'Starting...'),
      error: (error, stack) => ErrorScreen(
        message: error.toString(),
        onRetry: () {
          ref.invalidate(appInitializationProvider);
          _initializeApp();
        },
      ),
    );
  }
}
