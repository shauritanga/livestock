/// Off-taker business category
enum OffTakerCategory {
  processor,
  retailer,
  exporter,
  distributor,
  wholesaler,
  other;

  String get displayName {
    switch (this) {
      case OffTakerCategory.processor:
        return 'Processor';
      case OffTakerCategory.retailer:
        return 'Retailer';
      case OffTakerCategory.exporter:
        return 'Exporter';
      case OffTakerCategory.distributor:
        return 'Distributor';
      case OffTakerCategory.wholesaler:
        return 'Wholesaler';
      case OffTakerCategory.other:
        return 'Other';
    }
  }

  static OffTakerCategory fromString(String value) {
    return OffTakerCategory.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => OffTakerCategory.other,
    );
  }
}
