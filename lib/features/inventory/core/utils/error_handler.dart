import 'package:flutter/material.dart';
import 'package:livestock/core/errors/failures.dart';
import 'package:livestock/features/inventory/core/errors/inventory_failures.dart';

/// Utility class for handling and displaying errors in the UI
class InventoryErrorHandler {
  /// Show error snackbar with optional retry action
  static void showErrorSnackbar(
    BuildContext context,
    Failure failure, {
    VoidCallback? onRetry,
  }) {
    final message = _getErrorMessage(failure);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        action: onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Show success snackbar
  static void showSuccessSnackbar(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show error dialog for critical errors
  static Future<void> showErrorDialog(
    BuildContext context,
    Failure failure, {
    VoidCallback? onRetry,
  }) async {
    final message = _getErrorMessage(failure);
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Retry'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show confirmation dialog
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Get user-friendly error message from failure
  static String _getErrorMessage(Failure failure) {
    if (failure is InsufficientStockFailure) {
      return 'Insufficient stock. Only ${failure.available} available';
    } else if (failure is DuplicateSKUFailure) {
      return 'SKU already exists. Please use a unique SKU';
    } else if (failure is ProductNotFoundFailure) {
      return 'Product not found. It may have been deleted';
    } else if (failure is InvalidQuantityFailure) {
      return 'Quantity must be a positive number';
    } else if (failure is InvalidPriceFailure) {
      return 'Price must be a positive number';
    } else if (failure is SyncConflictFailure) {
      return 'This product was updated elsewhere. Please refresh and try again';
    } else if (failure is OfflineOperationFailure) {
      return 'You are offline. Changes will sync when connection is restored';
    } else if (failure is NetworkFailure) {
      return 'Network error. Please check your connection';
    } else if (failure is ValidationFailure) {
      return failure.message;
    } else if (failure is AuthorizationFailure) {
      return 'You do not have permission to perform this action';
    } else if (failure is NotFoundFailure) {
      return 'Resource not found';
    } else if (failure is TimeoutFailure) {
      return 'Operation timed out. Please try again';
    } else {
      return failure.message;
    }
  }

  // Private constructor to prevent instantiation
  InventoryErrorHandler._();
}
