/// Product category enumeration for inventory classification
enum ProductCategory {
  animalFeed,
  veterinarySupplies,
  farmEquipment,
  seeds,
  fertilizers,
  other;

  /// Get display name for the category
  String get displayName {
    switch (this) {
      case ProductCategory.animalFeed:
        return 'Animal Feed';
      case ProductCategory.veterinarySupplies:
        return 'Veterinary Supplies';
      case ProductCategory.farmEquipment:
        return 'Farm Equipment';
      case ProductCategory.seeds:
        return 'Seeds';
      case ProductCategory.fertilizers:
        return 'Fertilizers';
      case ProductCategory.other:
        return 'Other';
    }
  }

  /// Parse category from string
  static ProductCategory fromString(String value) {
    return ProductCategory.values.firstWhere(
      (category) => category.name == value,
      orElse: () => ProductCategory.other,
    );
  }
}
