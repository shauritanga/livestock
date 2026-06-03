import 'package:equatable/equatable.dart';

/// Farm assets metrics aggregated across farmers
class FarmAssetsMetrics extends Equatable {
  final int totalAvocadoTrees;
  final int totalFruitingAvocados;
  final int totalChickens;
  final int totalRoosters;
  final int totalBeehives;
  final int totalLargeBeehives;
  final int totalSmallBeehives;
  final int totalBananaPlants;
  final int totalPassionSeedlings;
  final double totalPotatoHectares;
  final int totalFarmersWithAssets;

  const FarmAssetsMetrics({
    required this.totalAvocadoTrees,
    required this.totalFruitingAvocados,
    required this.totalChickens,
    required this.totalRoosters,
    required this.totalBeehives,
    required this.totalLargeBeehives,
    required this.totalSmallBeehives,
    required this.totalBananaPlants,
    required this.totalPassionSeedlings,
    required this.totalPotatoHectares,
    required this.totalFarmersWithAssets,
  });

  /// Average avocado trees per farmer
  double get averageAvocadoTreesPerFarmer =>
      totalFarmersWithAssets > 0
          ? totalAvocadoTrees / totalFarmersWithAssets
          : 0;

  /// Average chickens per farmer
  double get averageChickensPerFarmer =>
      totalFarmersWithAssets > 0 ? totalChickens / totalFarmersWithAssets : 0;

  /// Average beehives per farmer
  double get averageBeehivesPerFarmer =>
      totalFarmersWithAssets > 0 ? totalBeehives / totalFarmersWithAssets : 0;

  /// Average banana plants per farmer
  double get averageBananaPlantsPerFarmer =>
      totalFarmersWithAssets > 0
          ? totalBananaPlants / totalFarmersWithAssets
          : 0;

  /// Average passion seedlings per farmer
  double get averagePassionSeedlingsPerFarmer =>
      totalFarmersWithAssets > 0
          ? totalPassionSeedlings / totalFarmersWithAssets
          : 0;

  /// Average potato hectares per farmer
  double get averagePotatoHectaresPerFarmer =>
      totalFarmersWithAssets > 0
          ? totalPotatoHectares / totalFarmersWithAssets
          : 0;

  /// Total poultry (chickens + roosters)
  int get totalPoultry => totalChickens + totalRoosters;

  /// Avocado fruiting percentage
  double get avocadoFruitingPercentage =>
      totalAvocadoTrees > 0
          ? (totalFruitingAvocados / totalAvocadoTrees) * 100
          : 0;

  @override
  List<Object?> get props => [
        totalAvocadoTrees,
        totalFruitingAvocados,
        totalChickens,
        totalRoosters,
        totalBeehives,
        totalLargeBeehives,
        totalSmallBeehives,
        totalBananaPlants,
        totalPassionSeedlings,
        totalPotatoHectares,
        totalFarmersWithAssets,
      ];

  FarmAssetsMetrics copyWith({
    int? totalAvocadoTrees,
    int? totalFruitingAvocados,
    int? totalChickens,
    int? totalRoosters,
    int? totalBeehives,
    int? totalLargeBeehives,
    int? totalSmallBeehives,
    int? totalBananaPlants,
    int? totalPassionSeedlings,
    double? totalPotatoHectares,
    int? totalFarmersWithAssets,
  }) {
    return FarmAssetsMetrics(
      totalAvocadoTrees: totalAvocadoTrees ?? this.totalAvocadoTrees,
      totalFruitingAvocados:
          totalFruitingAvocados ?? this.totalFruitingAvocados,
      totalChickens: totalChickens ?? this.totalChickens,
      totalRoosters: totalRoosters ?? this.totalRoosters,
      totalBeehives: totalBeehives ?? this.totalBeehives,
      totalLargeBeehives: totalLargeBeehives ?? this.totalLargeBeehives,
      totalSmallBeehives: totalSmallBeehives ?? this.totalSmallBeehives,
      totalBananaPlants: totalBananaPlants ?? this.totalBananaPlants,
      totalPassionSeedlings:
          totalPassionSeedlings ?? this.totalPassionSeedlings,
      totalPotatoHectares: totalPotatoHectares ?? this.totalPotatoHectares,
      totalFarmersWithAssets:
          totalFarmersWithAssets ?? this.totalFarmersWithAssets,
    );
  }
}
