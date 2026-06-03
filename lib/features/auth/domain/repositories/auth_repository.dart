import '../../../../core/utils/result.dart';
import '../entities/user.dart';

/// Repository interface for authentication operations
abstract class AuthRepository {
  /// Get current authenticated user
  Future<Result<User?>> getCurrentUser();
  
  /// Stream of authentication state changes
  Stream<User?> get authStateChanges;
  
  /// Sign in with email and password
  Future<Result<User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  
  /// Sign in with phone number and password
  Future<Result<User>> signInWithPhoneAndPassword({
    required String phoneNumber,
    required String password,
  });
  
  /// Sign out current user
  Future<Result<void>> signOut();
  
  /// Send password reset email
  Future<Result<void>> sendPasswordResetEmail({
    required String email,
  });
  
  /// Send password reset SMS
  Future<Result<void>> sendPasswordResetSMS({
    required String phoneNumber,
  });
  
  /// Change password for current user
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  
  /// Update user profile
  Future<Result<User>> updateProfile({
    String? displayName,
    String? photoUrl,
  });
  
  /// Verify email address
  Future<Result<void>> sendEmailVerification();
  
  /// Check if email is verified
  Future<Result<bool>> isEmailVerified();
  
  /// Refresh authentication token
  Future<Result<void>> refreshToken();
}
