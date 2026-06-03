import 'package:equatable/equatable.dart';

/// Geographic distribution statistics
class GeographicDistribution extends Equatable {
  final Map<String, int> regionBreakdown;
  final Map<String, int> districtBreakdown;
  final Map<String, int> wardBreakdown;
  final Map<String, int> villageBreakdown;

  const GeographicDistribution({
    required this.regionBreakdown,
    required this.districtBreakdown,
    required this.wardBreakdown,
    required this.villageBreakdown,
  });

  /// Total count across all regions
  int get totalRegions => regionBreakdown.values.fold(0, (sum, count) => sum + count);

  /// Get percentage for a specific region
  double getRegionPercentage(String region) {
    if (totalRegions == 0) return 0;
    final count = regionBreakdown[region] ?? 0;
    return (count / totalRegions) * 100;
  }

  /// Get top N regions by count
  List<MapEntry<String, int>> getTopRegions(int n) {
    final sorted = regionBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(n).toList();
  }

  @override
  List<Object?> get props => [
        regionBreakdown,
        districtBreakdown,
        wardBreakdown,
        villageBreakdown,
      ];

  GeographicDistribution copyWith({
    Map<String, int>? regionBreakdown,
    Map<String, int>? districtBreakdown,
    Map<String, int>? wardBreakdown,
    Map<String, int>? villageBreakdown,
  }) {
    return GeographicDistribution(
      regionBreakdown: regionBreakdown ?? this.regionBreakdown,
      districtBreakdown: districtBreakdown ?? this.districtBreakdown,
      wardBreakdown: wardBreakdown ?? this.wardBreakdown,
      villageBreakdown: villageBreakdown ?? this.villageBreakdown,
    );
  }
}
