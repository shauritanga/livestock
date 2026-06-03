import 'package:equatable/equatable.dart';
import 'package:livestock/features/analytics/domain/entities/age_distribution.dart';
import 'package:livestock/features/analytics/domain/entities/farm_assets_metrics.dart';

/// Comprehensive livestock and farm assets analytics
class LivestockMetrics extends Equatable {
  final int totalCattle;
  final int maleCattle;
  final int femaleCattle;
  final int lactatingCattle;
  final Map<String, int> breedDistribution;
  final Map<String, int> healthStatusDistribution;
  final AgeDistribution cattleAgeDistribution;
  final FarmAssetsMetrics farmAssets;
  final int totalFarmers;

  const LivestockMetrics({
    required this.totalCattle,
    required this.maleCattle,
    required this.femaleCattle,
    required this.lactatingCattle,
    required this.breedDistribution,
    required this.healthStatusDistribution,
    required this.cattleAgeDistribution,
    required this.farmAssets,
    required this.totalFarmers,
  });

  /// Lactation rate (percentage of cattle that are lactating)
  double get lactationRate =>
      totalCattle > 0 ? (lactatingCattle / totalCattle) * 100 : 0;

  /// Female cattle percentage
  double get femaleCattlePercentage =>
      totalCattle > 0 ? (femaleCattle / totalCattle) * 100 : 0;

  /// Male cattle percentage
  double get maleCattlePercentage =>
      totalCattle > 0 ? (maleCattle / totalCattle) * 100 : 0;

  /// Average cattle per farmer
  double get averageCattlePerFarmer =>
      totalFarmers > 0 ? totalCattle / totalFarmers : 0;

  /// Average lactating cattle per farmer
  double get averageLactatingCattlePerFarmer =>
      totalFarmers > 0 ? lactatingCattle / totalFarmers : 0;

  /// Most common breed
  String? get dominantBreed {
    if (breedDistribution.isEmpty) return null;

    var maxCount = 0;
    String? dominant;

    breedDistribution.forEach((breed, count) {
      if (count > maxCount) {
        maxCount = count;
        dominant = breed;
      }
    });

    return dominant;
  }

  /// Healthy cattle count
  int get healthyCattleCount =>
      healthStatusDistribution['Healthy'] ??
      healthStatusDistribution['healthy'] ??
      0;

  /// Healthy cattle percentage
  double get healthyCattlePercentage =>
      totalCattle > 0 ? (healthyCattleCount / totalCattle) * 100 : 0;

  /// Get breed percentage
  double getBreedPercentage(String breed) {
    if (totalCattle == 0) return 0;
    final count = breedDistribution[breed] ?? 0;
    return (count / totalCattle) * 100;
  }

  /// Get health status percentage
  double getHealthStatusPercentage(String status) {
    if (totalCattle == 0) return 0;
    final count = healthStatusDistribution[status] ?? 0;
    return (count / totalCattle) * 100;
  }

  @override
  List<Object?> get props => [
        totalCattle,
        maleCattle,
        femaleCattle,
        lactatingCattle,
        breedDistribution,
        healthStatusDistribution,
        cattleAgeDistribution,
        farmAssets,
        totalFarmers,
      ];

  LivestockMetrics copyWith({
    int? totalCattle,
    int? maleCattle,
    int? femaleCattle,
    int? lactatingCattle,
    Map<String, int>? breedDistribution,
    Map<String, int>? healthStatusDistribution,
    AgeDistribution? cattleAgeDistribution,
    FarmAssetsMetrics? farmAssets,
    int? totalFarmers,
  }) {
    return LivestockMetrics(
      totalCattle: totalCattle ?? this.totalCattle,
      maleCattle: maleCattle ?? this.maleCattle,
      femaleCattle: femaleCattle ?? this.femaleCattle,
      lactatingCattle: lactatingCattle ?? this.lactatingCattle,
      breedDistribution: breedDistribution ?? this.breedDistribution,
      healthStatusDistribution:
          healthStatusDistribution ?? this.healthStatusDistribution,
      cattleAgeDistribution:
          cattleAgeDistribution ?? this.cattleAgeDistribution,
      farmAssets: farmAssets ?? this.farmAssets,
      totalFarmers: totalFarmers ?? this.totalFarmers,
    );
  }
}
