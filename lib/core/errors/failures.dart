import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);
  
  @override
  List<Object?> get props => [message];
}

/// Server-related failures
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network connection failed']);
}

/// Authentication failures
class AuthenticationFailure extends Failure {
  const AuthenticationFailure([super.message = 'Authentication failed']);
}

/// Authorization failures
class AuthorizationFailure extends Failure {
  const AuthorizationFailure([super.message = 'Access denied']);
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation failed']);
}

/// Cache failures
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache operation failed']);
}

/// Not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found']);
}

/// Timeout failures
class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Operation timed out']);
}

/// Unknown failures
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unknown error occurred']);
}
