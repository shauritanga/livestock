import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/firebase_service.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/change_password.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/send_password_reset_email.dart';
import '../../domain/usecases/send_password_reset_sms.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/sign_in_with_phone.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/update_profile.dart';

/// Provider for AuthRemoteDataSource
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  );
});

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
  );
});

/// Provider for GetCurrentUser use case
final getCurrentUserProvider = Provider<GetCurrentUser>((ref) {
  return GetCurrentUser(ref.watch(authRepositoryProvider));
});

/// Provider for SignInWithEmail use case
final signInWithEmailProvider = Provider<SignInWithEmail>((ref) {
  return SignInWithEmail(ref.watch(authRepositoryProvider));
});

/// Provider for SignInWithPhone use case
final signInWithPhoneProvider = Provider<SignInWithPhone>((ref) {
  return SignInWithPhone(ref.watch(authRepositoryProvider));
});

/// Provider for SignOut use case
final signOutProvider = Provider<SignOut>((ref) {
  return SignOut(ref.watch(authRepositoryProvider));
});

/// Provider for SendPasswordResetEmail use case
final sendPasswordResetEmailProvider = Provider<SendPasswordResetEmail>((ref) {
  return SendPasswordResetEmail(ref.watch(authRepositoryProvider));
});

/// Provider for SendPasswordResetSMS use case
final sendPasswordResetSMSProvider = Provider<SendPasswordResetSMS>((ref) {
  return SendPasswordResetSMS(ref.watch(authRepositoryProvider));
});

/// Provider for ChangePassword use case
final changePasswordProvider = Provider<ChangePassword>((ref) {
  return ChangePassword(ref.watch(authRepositoryProvider));
});

/// Provider for UpdateProfile use case
final updateProfileProvider = Provider<UpdateProfile>((ref) {
  return UpdateProfile(ref.watch(authRepositoryProvider));
});

/// Provider for authentication state stream
final authStateProvider = StreamProvider<User?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});

/// Provider for current user (synchronous)
final currentAuthUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentAuthUserProvider);
  return user != null;
});
