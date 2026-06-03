/// Result type for handling success and failure cases
sealed class Result<T> {
  const Result();
}

/// Success result containing data
class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

/// Failure result containing error
class Failure<T> extends Result<T> {
  final String message;
  final Exception? exception;
  
  const Failure(this.message, [this.exception]);
}

/// Extension methods for Result
extension ResultExtension<T> on Result<T> {
  /// Fold the result into a single value
  R fold<R>(
    R Function(Failure<T> failure) onFailure,
    R Function(Success<T> success) onSuccess,
  ) {
    if (this is Success<T>) {
      return onSuccess(this as Success<T>);
    } else {
      return onFailure(this as Failure<T>);
    }
  }

  /// Check if result is success
  bool get isSuccess => this is Success<T>;

  /// Check if result is failure
  bool get isFailure => this is Failure<T>;

  /// Get data or null
  T? get dataOrNull => this is Success<T> ? (this as Success<T>).data : null;

  /// Get error message or null
  String? get errorOrNull =>
      this is Failure<T> ? (this as Failure<T>).message : null;
}
