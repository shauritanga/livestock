import 'package:firebase_auth/firebase_auth.dart';
import '../errors/failures.dart';

/// Handles Firebase errors and converts them to application failures
class FirebaseErrorHandler {
  /// Convert FirebaseAuthException to Failure
  static Failure handleAuthException(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'user-not-found':
        return const AuthenticationFailure('No user found with this email');
      case 'wrong-password':
        return const AuthenticationFailure('Incorrect password');
      case 'email-already-in-use':
        return const AuthenticationFailure('Email is already registered');
      case 'invalid-email':
        return const ValidationFailure('Invalid email address');
      case 'weak-password':
        return const ValidationFailure('Password is too weak');
      case 'user-disabled':
        return const AuthorizationFailure('This account has been disabled');
      case 'too-many-requests':
        return const ServerFailure('Too many attempts. Please try again later');
      case 'operation-not-allowed':
        return const AuthorizationFailure('Operation not allowed');
      case 'network-request-failed':
        return const NetworkFailure('Network connection failed');
      default:
        return AuthenticationFailure(
          exception.message ?? 'Authentication failed',
        );
    }
  }

  /// Convert FirebaseException to Failure
  static Failure handleFirestoreException(FirebaseException exception) {
    switch (exception.code) {
      case 'permission-denied':
        return const AuthorizationFailure('Access denied');
      case 'not-found':
        return const NotFoundFailure('Resource not found');
      case 'already-exists':
        return const ValidationFailure('Resource already exists');
      case 'resource-exhausted':
        return const ServerFailure('Resource limit exceeded');
      case 'failed-precondition':
        return const ValidationFailure('Operation requirements not met');
      case 'aborted':
        return const ServerFailure('Operation aborted');
      case 'out-of-range':
        return const ValidationFailure('Value out of range');
      case 'unimplemented':
        return const ServerFailure('Feature not implemented');
      case 'internal':
        return const ServerFailure('Internal server error');
      case 'unavailable':
        return const NetworkFailure('Service unavailable');
      case 'data-loss':
        return const ServerFailure('Data loss occurred');
      case 'unauthenticated':
        return const AuthenticationFailure('Authentication required');
      case 'deadline-exceeded':
        return const TimeoutFailure('Operation timed out');
      case 'cancelled':
        return const ServerFailure('Operation cancelled');
      default:
        return ServerFailure(
          exception.message ?? 'Server error occurred',
        );
    }
  }

  /// Convert generic Exception to Failure
  static Failure handleGenericException(Exception exception) {
    if (exception is FirebaseAuthException) {
      return handleAuthException(exception);
    } else if (exception is FirebaseException) {
      return handleFirestoreException(exception);
    } else {
      return UnknownFailure(exception.toString());
    }
  }

  // Private constructor to prevent instantiation
  FirebaseErrorHandler._();
}
