/// Inventory-specific error messages
class InventoryErrors {
  // Product validation errors
  static const String productNameRequired = 'Product name is required';
  static const String productNameTooShort = 'Product name must be at least 2 characters';
  static const String productNameTooLong = 'Product name must not exceed 100 characters';
  
  static const String skuRequired = 'SKU is required';
  static const String skuInvalid = 'SKU must contain only alphanumeric characters, hyphens, and underscores';
  static const String skuAlreadyExists = 'SKU already exists. Please use a unique SKU.';
  
  static const String unitPriceRequired = 'Unit price is required';
  static const String unitPriceMustBePositive = 'Unit price must be a positive number';
  
  static const String reorderPointRequired = 'Reorder point is required';
  static const String reorderPointCannotBeNegative = 'Reorder point cannot be negative';
  
  static const String initialStockCannotBeNegative = 'Initial stock cannot be negative';
  static const String currentStockCannotBeNegative = 'Current stock cannot be negative';
  
  // Stock operation errors
  static const String quantityRequired = 'Quantity is required';
  static const String quantityMustBePositive = 'Quantity must be a positive number';
  static const String reasonRequired = 'Reason is required for stock adjustments';
  static const String reasonTooLong = 'Reason must not exceed 500 characters';
  
  static const String insufficientStock = 'Insufficient stock. Only {available} {unit} available.';
  static const String productNotFound = 'Product not found. It may have been deleted.';
  static const String productNotActive = 'Product is not active';
  
  // Sale operation errors
  static const String productIdRequired = 'Product ID is required';
  static const String customerNameTooLong = 'Customer name must not exceed 100 characters';
  static const String notesTooLong = 'Notes must not exceed 500 characters';
  
  // Network errors
  static const String networkError = 'Unable to connect. Changes will sync when online.';
  static const String syncConflict = 'This product was updated elsewhere. Please review changes.';
  static const String syncFailed = 'Sync failed. Please try again.';
  
  // General errors
  static const String userNotAuthenticated = 'User not authenticated';
  static const String unknownError = 'An unknown error occurred';
  
  /// Format insufficient stock error with actual values
  static String insufficientStockFormatted(double available, String unit) {
    return 'Insufficient stock. Only ${available.toStringAsFixed(1)} $unit available.';
  }
}
