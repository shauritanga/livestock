import 'package:equatable/equatable.dart';

/// Farm assets entity representing diverse agricultural assets
/// owned by a farmer
class FarmAssets extends Equatable {
  // Avocado
  final int avocadoTotal;
  final int avocadoFruiting;

  // Poultry
  final int femaleChickens;
  final int roosters;

  // Cattle (for detailed tracking)
  final int maleCattle;
  final int femaleCattle;

  // Beekeeping
  final int largeBeehives;
  final int smallBeehives;

  // Crops
  final int bananaPlants;
  final int passionSeedlings;
  final DateTime? potatoPlantingDate;
  final double potatoHectares;

  const FarmAssets({
    this.avocadoTotal = 0,
    this.avocadoFruiting = 0,
    this.femaleChickens = 0,
    this.roosters = 0,
    this.maleCattle = 0,
    this.femaleCattle = 0,
    this.largeBeehives = 0,
    this.smallBeehives = 0,
    this.bananaPlants = 0,
    this.passionSeedlings = 0,
    this.potatoPlantingDate,
    this.potatoHectares = 0.0,
  });

  /// Computed property: total cattle count
  int get totalCattle => maleCattle + femaleCattle;

  /// Computed property: total chickens count
  int get totalChickens => femaleChickens + roosters;

  /// Computed property: total beehives count
  int get totalBeehives => largeBeehives + smallBeehives;

  @override
  List<Object?> get props => [
        avocadoTotal,
        avocadoFruiting,
        femaleChickens,
        roosters,
        maleCattle,
        femaleCattle,
        largeBeehives,
        smallBeehives,
        bananaPlants,
        passionSeedlings,
        potatoPlantingDate,
        potatoHectares,
      ];

  FarmAssets copyWith({
    int? avocadoTotal,
    int? avocadoFruiting,
    int? femaleChickens,
    int? roosters,
    int? maleCattle,
    int? femaleCattle,
    int? largeBeehives,
    int? smallBeehives,
    int? bananaPlants,
    int? passionSeedlings,
    DateTime? potatoPlantingDate,
    double? potatoHectares,
  }) {
    return FarmAssets(
      avocadoTotal: avocadoTotal ?? this.avocadoTotal,
      avocadoFruiting: avocadoFruiting ?? this.avocadoFruiting,
      femaleChickens: femaleChickens ?? this.femaleChickens,
      roosters: roosters ?? this.roosters,
      maleCattle: maleCattle ?? this.maleCattle,
      femaleCattle: femaleCattle ?? this.femaleCattle,
      largeBeehives: largeBeehives ?? this.largeBeehives,
      smallBeehives: smallBeehives ?? this.smallBeehives,
      bananaPlants: bananaPlants ?? this.bananaPlants,
      passionSeedlings: passionSeedlings ?? this.passionSeedlings,
      potatoPlantingDate: potatoPlantingDate ?? this.potatoPlantingDate,
      potatoHectares: potatoHectares ?? this.potatoHectares,
    );
  }

  /// Create FarmAssets from map (for deserialization)
  factory FarmAssets.fromMap(Map<String, dynamic> map) {
    return FarmAssets(
      avocadoTotal: map['avocadoTotal'] as int? ?? 0,
      avocadoFruiting: map['avocadoFruiting'] as int? ?? 0,
      femaleChickens: map['femaleChickens'] as int? ?? 0,
      roosters: map['roosters'] as int? ?? 0,
      maleCattle: map['maleCattle'] as int? ?? 0,
      femaleCattle: map['femaleCattle'] as int? ?? 0,
      largeBeehives: map['largeBeehives'] as int? ?? 0,
      smallBeehives: map['smallBeehives'] as int? ?? 0,
      bananaPlants: map['bananaPlants'] as int? ?? 0,
      passionSeedlings: map['passionSeedlings'] as int? ?? 0,
      potatoPlantingDate: map['potatoPlantingDate'] != null
          ? DateTime.parse(map['potatoPlantingDate'] as String)
          : null,
      potatoHectares: (map['potatoHectares'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Convert FarmAssets to map (for serialization)
  Map<String, dynamic> toMap() {
    return {
      'avocadoTotal': avocadoTotal,
      'avocadoFruiting': avocadoFruiting,
      'femaleChickens': femaleChickens,
      'roosters': roosters,
      'maleCattle': maleCattle,
      'femaleCattle': femaleCattle,
      'largeBeehives': largeBeehives,
      'smallBeehives': smallBeehives,
      'bananaPlants': bananaPlants,
      'passionSeedlings': passionSeedlings,
      'potatoPlantingDate':
          potatoPlantingDate?.toIso8601String().split('T')[0],
      'potatoHectares': potatoHectares,
    };
  }
}
