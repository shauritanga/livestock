import 'package:equatable/equatable.dart';

/// Lactation status of cattle
enum LactationStatus {
  lactating,
  dry,
  pregnant,
  calf,
}

/// Gender of cattle
enum CattleGender {
  male,
  female,
}

/// Cattle entity representing a cow/bull in the system
class Cattle extends Equatable {
  final String id;
  final String farmerId;
  final String cooperativeId;
  final CattleGender gender;
  final int ageMonths;
  final String breed;
  final LactationStatus lactationStatus;
  final String healthStatus;
  final DateTime acquisitionDate;
  final String? biometricId;
  final String? muzzleImageUrl;
  final DateTime? lastProductionDate;
  final double averageDailyProduction;
  final DateTime? lastStatusChangeDate;

  const Cattle({
    required this.id,
    required this.farmerId,
    required this.cooperativeId,
    required this.gender,
    required this.ageMonths,
    required this.breed,
    required this.lactationStatus,
    required this.healthStatus,
    required this.acquisitionDate,
    this.biometricId,
    this.muzzleImageUrl,
    this.lastProductionDate,
    required this.averageDailyProduction,
    this.lastStatusChangeDate,
  });

  @override
  List<Object?> get props => [
        id,
        farmerId,
        cooperativeId,
        gender,
        ageMonths,
        breed,
        lactationStatus,
        healthStatus,
        acquisitionDate,
        biometricId,
        muzzleImageUrl,
        lastProductionDate,
        averageDailyProduction,
        lastStatusChangeDate,
      ];

  Cattle copyWith({
    String? id,
    String? farmerId,
    String? cooperativeId,
    CattleGender? gender,
    int? ageMonths,
    String? breed,
    LactationStatus? lactationStatus,
    String? healthStatus,
    DateTime? acquisitionDate,
    String? biometricId,
    String? muzzleImageUrl,
    DateTime? lastProductionDate,
    double? averageDailyProduction,
    DateTime? lastStatusChangeDate,
  }) {
    return Cattle(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      cooperativeId: cooperativeId ?? this.cooperativeId,
      gender: gender ?? this.gender,
      ageMonths: ageMonths ?? this.ageMonths,
      breed: breed ?? this.breed,
      lactationStatus: lactationStatus ?? this.lactationStatus,
      healthStatus: healthStatus ?? this.healthStatus,
      acquisitionDate: acquisitionDate ?? this.acquisitionDate,
      biometricId: biometricId ?? this.biometricId,
      muzzleImageUrl: muzzleImageUrl ?? this.muzzleImageUrl,
      lastProductionDate: lastProductionDate ?? this.lastProductionDate,
      averageDailyProduction:
          averageDailyProduction ?? this.averageDailyProduction,
      lastStatusChangeDate: lastStatusChangeDate ?? this.lastStatusChangeDate,
    );
  }

  /// Check if cattle is productive (lactating)
  bool get isProductive => lactationStatus == LactationStatus.lactating;

  /// Check if cattle is female
  bool get isFemale => gender == CattleGender.female;

  /// Get age in years
  double get ageYears => ageMonths / 12;
}
