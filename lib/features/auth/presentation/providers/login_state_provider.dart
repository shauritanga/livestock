import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/user.dart';
import 'auth_providers.dart';

/// Login state
sealed class LoginState {
  const LoginState();
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  final User user;
  
  const LoginSuccess(this.user);
}

class LoginFailure extends LoginState {
  final String message;
  
  const LoginFailure(this.message);
}

/// Login state notifier
class LoginNotifier extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginInitial();
  
  /// Sign in with email and password
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const LoginLoading();
    
    final signInUseCase = ref.read(signInWithEmailProvider);
    final result = await signInUseCase(email: email, password: password);
    
    state = result.fold(
      onError: (failure) => LoginFailure(failure.message),
      onSuccess: (user) => LoginSuccess(user),
    );
  }
  
  /// Sign in with phone and password
  Future<void> signInWithPhone({
    required String phoneNumber,
    required String password,
  }) async {
    state = const LoginLoading();
    
    final signInUseCase = ref.read(signInWithPhoneProvider);
    final result = await signInUseCase(
      phoneNumber: phoneNumber,
      password: password,
    );
    
    state = result.fold(
      onError: (failure) => LoginFailure(failure.message),
      onSuccess: (user) => LoginSuccess(user),
    );
  }
  
  /// Reset state
  void reset() {
    state = const LoginInitial();
  }
}

/// Provider for login state
final loginStateProvider = NotifierProvider<LoginNotifier, LoginState>(
  LoginNotifier.new,
);
