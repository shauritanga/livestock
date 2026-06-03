/// Validators for inventory forms
class InventoryValidators {
  /// Validate product name
  static String? validateProductName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Product name is required';
    }
    if (value.trim().length < 2) {
      return 'Product name must be at least 2 characters';
    }
    if (value.trim().length > 100) {
      return 'Product name must not exceed 100 characters';
    }
    return null;
  }

  /// Validate SKU
  static String? validateSKU(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'SKU is required';
    }
    if (!RegExp(r'^[a-zA-Z0-9-_]+$').hasMatch(value)) {
      return 'SKU can only contain letters, numbers, hyphens, and underscores';
    }
    if (value.length > 50) {
      return 'SKU must not exceed 50 characters';
    }
    return null;
  }

  /// Validate unit price
  static String? validateUnitPrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Unit price is required';
    }
    final price = double.tryParse(value);
    if (price == null) {
      return 'Please enter a valid number';
    }
    if (price <= 0) {
      return 'Price must be greater than zero';
    }
    if (price > 999999999) {
      return 'Price is too large';
    }
    return null;
  }

  /// Validate quantity
  static String? validateQuantity(String? value, {double? maxAvailable}) {
    if (value == null || value.trim().isEmpty) {
      return 'Quantity is required';
    }
    final quantity = double.tryParse(value);
    if (quantity == null) {
      return 'Please enter a valid number';
    }
    if (quantity <= 0) {
      return 'Quantity must be greater than zero';
    }
    if (maxAvailable != null && quantity > maxAvailable) {
      return 'Only $maxAvailable available';
    }
    return null;
  }

  /// Validate reorder point
  static String? validateReorderPoint(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Reorder point is required';
    }
    final reorderPoint = double.tryParse(value);
    if (reorderPoint == null) {
      return 'Please enter a valid number';
    }
    if (reorderPoint < 0) {
      return 'Reorder point cannot be negative';
    }
    return null;
  }

  /// Validate initial stock
  static String? validateInitialStock(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    final stock = double.tryParse(value);
    if (stock == null) {
      return 'Please enter a valid number';
    }
    if (stock < 0) {
      return 'Stock cannot be negative';
    }
    return null;
  }

  /// Validate customer name
  static String? validateCustomerName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    if (value.trim().length > 100) {
      return 'Customer name must not exceed 100 characters';
    }
    return null;
  }

  /// Validate notes
  static String? validateNotes(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    if (value.trim().length > 500) {
      return 'Notes must not exceed 500 characters';
    }
    return null;
  }

  /// Validate reason for stock adjustment
  static String? validateReason(String? value, {bool required = false}) {
    if (required && (value == null || value.trim().isEmpty)) {
      return 'Reason is required for stock adjustments';
    }
    if (value != null && value.trim().length > 500) {
      return 'Reason must not exceed 500 characters';
    }
    return null;
  }

  // Private constructor to prevent instantiation
  InventoryValidators._();
}
