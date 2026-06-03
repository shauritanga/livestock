import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/result.dart';
import 'auth_providers.dart';

/// Base state for forgot password flow
sealed class ForgotPasswordState {
  const ForgotPasswordState();
}

/// Initial state before any action
class ForgotPasswordInitial extends ForgotPasswordState {
  const ForgotPasswordInitial();
}

/// Loading state while sending reset request
class ForgotPasswordLoading extends ForgotPasswordState {
  const ForgotPasswordLoading();
}

/// Success state after reset request sent
class ForgotPasswordSuccess extends ForgotPasswordState {
  final String message;
  final bool isEmail;

  const ForgotPasswordSuccess({
    required this.message,
    required this.isEmail,
  });
}

/// Failure state when reset request fails
class ForgotPasswordFailure extends ForgotPasswordState {
  final String message;

  const ForgotPasswordFailure(this.message);
}

/// Notifier for managing forgot password flow
class ForgotPasswordNotifier extends Notifier<ForgotPasswordState> {
  @override
  ForgotPasswordState build() => const ForgotPasswordInitial();

  /// Send password reset email
  Future<void> sendResetEmail(String email) async {
    state = const ForgotPasswordLoading();

    final sendPasswordResetEmail = ref.read(sendPasswordResetEmailProvider);
    final result = await sendPasswordResetEmail(email: email);

    state = result.fold(
      onError: (failure) => ForgotPasswordFailure(failure.message),
      onSuccess: (_) => const ForgotPasswordSuccess(
        message: 'Password reset email sent! Check your inbox for instructions.',
        isEmail: true,
      ),
    );
  }

  /// Send password reset SMS
  Future<void> sendResetSMS(String phoneNumber) async {
    state = const ForgotPasswordLoading();

    final sendPasswordResetSMS = ref.read(sendPasswordResetSMSProvider);
    final result = await sendPasswordResetSMS(phoneNumber: phoneNumber);

    state = result.fold(
      onError: (failure) => ForgotPasswordFailure(failure.message),
      onSuccess: (_) => const ForgotPasswordSuccess(
        message: 'Password reset code sent! Check your messages for instructions.',
        isEmail: false,
      ),
    );
  }

  /// Reset state to initial
  void reset() {
    state = const ForgotPasswordInitial();
  }
}

/// Provider for ForgotPasswordNotifier
final forgotPasswordStateProvider =
    NotifierProvider<ForgotPasswordNotifier, ForgotPasswordState>(
  ForgotPasswordNotifier.new,
);
