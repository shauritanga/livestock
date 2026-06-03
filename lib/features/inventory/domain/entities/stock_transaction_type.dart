/// Stock transaction type enumeration
enum StockTransactionType {
  addition,
  adjustment,
  sale;

  /// Get display name for the transaction type
  String get displayName {
    switch (this) {
      case StockTransactionType.addition:
        return 'Stock Addition';
      case StockTransactionType.adjustment:
        return 'Stock Adjustment';
      case StockTransactionType.sale:
        return 'Sale';
    }
  }

  /// Parse transaction type from string
  static StockTransactionType fromString(String value) {
    return StockTransactionType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => StockTransactionType.adjustment,
    );
  }
}
