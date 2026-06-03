/// Expense category enum for classifying expenses
enum ExpenseCategory {
  feed,
  veterinary,
  transport,
  utilities,
  salaries,
  maintenance,
  supplies,
  other;

  /// Get display name for the category
  String get displayName {
    switch (this) {
      case ExpenseCategory.feed:
        return 'Feed';
      case ExpenseCategory.veterinary:
        return 'Veterinary';
      case ExpenseCategory.transport:
        return 'Transport';
      case ExpenseCategory.utilities:
        return 'Utilities';
      case ExpenseCategory.salaries:
        return 'Salaries';
      case ExpenseCategory.maintenance:
        return 'Maintenance';
      case ExpenseCategory.supplies:
        return 'Supplies';
      case ExpenseCategory.other:
        return 'Other';
    }
  }

  /// Create category from string
  static ExpenseCategory fromString(String value) {
    return ExpenseCategory.values.firstWhere(
      (category) => category.name == value.toLowerCase(),
      orElse: () => ExpenseCategory.other,
    );
  }

  /// Get all categories as a list
  static List<ExpenseCategory> get all => ExpenseCategory.values;
}
