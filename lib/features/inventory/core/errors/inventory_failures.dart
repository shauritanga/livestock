import 'package:livestock/core/errors/failures.dart';

/// Insufficient stock failure
class InsufficientStockFailure extends Failure {
  final double available;
  final double requested;
  
  const InsufficientStockFailure({
    required this.available,
    required this.requested,
  }) : super('Insufficient stock. Only $available available, but $requested requested');
  
  @override
  List<Object?> get props => [message, available, requested];
}

/// Duplicate SKU failure
class DuplicateSKUFailure extends ValidationFailure {
  const DuplicateSKUFailure([super.message = 'SKU already exists']);
}

/// Product not found failure
class ProductNotFoundFailure extends NotFoundFailure {
  const ProductNotFoundFailure([super.message = 'Product not found']);
}

/// Invalid quantity failure
class InvalidQuantityFailure extends ValidationFailure {
  const InvalidQuantityFailure([super.message = 'Quantity must be a positive number']);
}

/// Invalid price failure
class InvalidPriceFailure extends ValidationFailure {
  const InvalidPriceFailure([super.message = 'Price must be a positive number']);
}

/// Sync conflict failure
class SyncConflictFailure extends Failure {
  const SyncConflictFailure([super.message = 'Data was updated elsewhere. Please refresh and try again']);
}

/// Offline operation failure
class OfflineOperationFailure extends NetworkFailure {
  const OfflineOperationFailure([super.message = 'Operation queued for sync when online']);
}
