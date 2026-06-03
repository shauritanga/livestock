import '../errors/failures.dart';

/// Result type for operations that can fail
/// Similar to Either<Failure, T> but simpler
sealed class Result<T> {
  const Result();
}

/// Success result containing a value
class Success<T> extends Result<T> {
  final T value;
  
  const Success(this.value);
  
  @override
  String toString() => 'Success($value)';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> &&
          runtimeType == other.runtimeType &&
          value == other.value;
  
  @override
  int get hashCode => value.hashCode;
}

/// Failure result containing an error
class Error<T> extends Result<T> {
  final Failure failure;
  
  const Error(this.failure);
  
  @override
  String toString() => 'Error($failure)';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Error<T> &&
          runtimeType == other.runtimeType &&
          failure == other.failure;
  
  @override
  int get hashCode => failure.hashCode;
}

/// Extension methods for Result
extension ResultExtension<T> on Result<T> {
  /// Check if result is success
  bool get isSuccess => this is Success<T>;
  
  /// Check if result is error
  bool get isError => this is Error<T>;
  
  /// Get value if success, null otherwise
  T? get valueOrNull => this is Success<T> ? (this as Success<T>).value : null;
  
  /// Get failure if error, null otherwise
  Failure? get failureOrNull => this is Error<T> ? (this as Error<T>).failure : null;
  
  /// Fold result into a single value
  R fold<R>({
    required R Function(Failure failure) onError,
    required R Function(T value) onSuccess,
  }) {
    return switch (this) {
      Success(value: final value) => onSuccess(value),
      Error(failure: final failure) => onError(failure),
    };
  }
  
  /// Map success value to another type
  Result<R> map<R>(R Function(T value) transform) {
    return switch (this) {
      Success(value: final value) => Success(transform(value)),
      Error(failure: final failure) => Error(failure),
    };
  }
  
  /// FlatMap for chaining operations
  Result<R> flatMap<R>(Result<R> Function(T value) transform) {
    return switch (this) {
      Success(value: final value) => transform(value),
      Error(failure: final failure) => Error(failure),
    };
  }
}
