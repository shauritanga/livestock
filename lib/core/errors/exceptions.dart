/// Base class for all exceptions in the application
class AppException implements Exception {
  final String message;
  
  const AppException(this.message);
  
  @override
  String toString() => message;
}

/// Server-related exceptions
class ServerException extends AppException {
  const ServerException([super.message = 'Server error occurred']);
}

/// Network-related exceptions
class NetworkException extends AppException {
  const NetworkException([super.message = 'Network connection failed']);
}

/// Authentication exceptions
class AuthenticationException extends AppException {
  const AuthenticationException([super.message = 'Authentication failed']);
}

/// Authorization exceptions
class AuthorizationException extends AppException {
  const AuthorizationException([super.message = 'Access denied']);
}

/// Validation exceptions
class ValidationException extends AppException {
  const ValidationException([super.message = 'Validation failed']);
}

/// Cache exceptions
class CacheException extends AppException {
  const CacheException([super.message = 'Cache operation failed']);
}

/// Not found exceptions
class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Resource not found']);
}

/// Timeout exceptions
class TimeoutException extends AppException {
  const TimeoutException([super.message = 'Operation timed out']);
}
