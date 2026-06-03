import '../../domain/entities/livestock_metrics.dart';
import '../../domain/entities/farm_assets_metrics.dart';
import '../../domain/entities/age_distribution.dart';

class LivestockMetricsModel extends LivestockMetrics {
  const LivestockMetricsModel({
    required super.totalCattle,
    required super.maleCattle,
    required super.femaleCattle,
    required super.lactatingCattle,
    required super.breedDistribution,
    required super.healthStatusDistribution,
    required super.cattleAgeDistribution,
    required super.farmAssets,
    required super.totalFarmers,
  });

  factory LivestockMetricsModel.fromJson(Map<String, dynamic> json) {
    return LivestockMetricsModel(
      totalCattle: json['totalCattle'] as int,
      maleCattle: json['maleCattle'] as int,
      femaleCattle: json['femaleCattle'] as int,
      lactatingCattle: json['lactatingCattle'] as int,
      breedDistribution: Map<String, int>.from(json['breedDistribution'] as Map),
      healthStatusDistribution: Map<String, int>.from(json['healthStatusDistribution'] as Map),
      cattleAgeDistribution: AgeDistribution(
        age18to25: json['cattleAgeDistribution']['age18to25'] as int,
        age26to35: json['cattleAgeDistribution']['age26to35'] as int,
        age36to45: json['cattleAgeDistribution']['age36to45'] as int,
        age46to55: json['cattleAgeDistribution']['age46to55'] as int,
        age56to65: json['cattleAgeDistribution']['age56to65'] as int,
        age65Plus: json['cattleAgeDistribution']['age65Plus'] as int,
      ),
      farmAssets: FarmAssetsMetrics(
        totalAvocadoTrees: json['farmAssets']['totalAvocadoTrees'] as int,
        totalFruitingAvocados: json['farmAssets']['totalFruitingAvocados'] as int? ?? 0,
        totalChickens: json['farmAssets']['totalChickens'] as int,
        totalRoosters: json['farmAssets']['totalRoosters'] as int? ?? 0,
        totalBeehives: json['farmAssets']['totalBeehives'] as int,
        totalLargeBeehives: json['farmAssets']['totalLargeBeehives'] as int? ?? 0,
        totalSmallBeehives: json['farmAssets']['totalSmallBeehives'] as int? ?? 0,
        totalBananaPlants: json['farmAssets']['totalBananaPlants'] as int,
        totalPassionSeedlings: json['farmAssets']['totalPassionSeedlings'] as int,
        totalPotatoHectares: (json['farmAssets']['totalPotatoHectares'] as num).toDouble(),
        totalFarmersWithAssets: json['farmAssets']['totalFarmersWithAssets'] as int? ?? 0,
      ),
      totalFarmers: json['totalFarmers'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCattle': totalCattle,
      'maleCattle': maleCattle,
      'femaleCattle': femaleCattle,
      'lactatingCattle': lactatingCattle,
      'lactationRate': lactationRate,
      'breedDistribution': breedDistribution,
      'healthStatusDistribution': healthStatusDistribution,
      'cattleAgeDistribution': {
        'age18to25': cattleAgeDistribution.age18to25,
        'age26to35': cattleAgeDistribution.age26to35,
        'age36to45': cattleAgeDistribution.age36to45,
        'age46to55': cattleAgeDistribution.age46to55,
        'age56to65': cattleAgeDistribution.age56to65,
        'age65Plus': cattleAgeDistribution.age65Plus,
      },
      'farmAssets': {
        'totalAvocadoTrees': farmAssets.totalAvocadoTrees,
        'totalFruitingAvocados': farmAssets.totalFruitingAvocados,
        'totalChickens': farmAssets.totalChickens,
        'totalRoosters': farmAssets.totalRoosters,
        'totalBeehives': farmAssets.totalBeehives,
        'totalLargeBeehives': farmAssets.totalLargeBeehives,
        'totalSmallBeehives': farmAssets.totalSmallBeehives,
        'totalBananaPlants': farmAssets.totalBananaPlants,
        'totalPassionSeedlings': farmAssets.totalPassionSeedlings,
        'totalPotatoHectares': farmAssets.totalPotatoHectares,
        'totalFarmersWithAssets': farmAssets.totalFarmersWithAssets,
        'averageAvocadoTreesPerFarmer': farmAssets.averageAvocadoTreesPerFarmer,
        'averageChickensPerFarmer': farmAssets.averageChickensPerFarmer,
        'averageBeehivesPerFarmer': farmAssets.averageBeehivesPerFarmer,
        'averageBananaPlantsPerFarmer': farmAssets.averageBananaPlantsPerFarmer,
        'averagePassionSeedlingsPerFarmer': farmAssets.averagePassionSeedlingsPerFarmer,
        'averagePotatoHectaresPerFarmer': farmAssets.averagePotatoHectaresPerFarmer,
      },
      'totalFarmers': totalFarmers,
    };
  }
}
