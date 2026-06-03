/// Off-taker account status
enum OffTakerStatus {
  active,
  inactive,
  suspended;

  String get displayName {
    switch (this) {
      case OffTakerStatus.active:
        return 'Active';
      case OffTakerStatus.inactive:
        return 'Inactive';
      case OffTakerStatus.suspended:
        return 'Suspended';
    }
  }

  static OffTakerStatus fromString(String value) {
    return OffTakerStatus.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => OffTakerStatus.active,
    );
  }
}
