import 'package:equatable/equatable.dart';
import 'package:livestock/features/farmer_management/domain/entities/location.dart';
import 'package:livestock/features/farmer_management/domain/entities/farm_assets.dart';

/// Farmer entity representing a dairy farmer in the system
class Farmer extends Equatable {
  // Existing fields (for backward compatibility)
  final String id;
  final String name; // Computed from firstName, middleName, surname
  final String phoneNumber;
  final String? email;
  final String nationalId; // Maps to nida
  final String location; // Computed from locationDetails
  final String cooperativeId;
  final bool hasAppAccess;
  final double creditScore;
  final int totalCattle; // Computed from farmAssets or maleCattle + femaleCattle
  final int lactatingCattle; // Maps to femaleCattle or explicit value
  final DateTime registeredAt;
  final DateTime? lastDeliveryDate;
  final String? photoUrl;

  // New fields for comprehensive registration
  final String firstName;
  final String? middleName;
  final String surname;
  final DateTime? dateOfBirth;
  final String? gender; // "Male" or "Female"
  final Location? locationDetails;
  final FarmAssets? farmAssets;

  const Farmer({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.email,
    required this.nationalId,
    required this.location,
    required this.cooperativeId,
    required this.hasAppAccess,
    required this.creditScore,
    required this.totalCattle,
    required this.lactatingCattle,
    required this.registeredAt,
    this.lastDeliveryDate,
    this.photoUrl,
    required this.firstName,
    this.middleName,
    required this.surname,
    this.dateOfBirth,
    this.gender,
    this.locationDetails,
    this.farmAssets,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        phoneNumber,
        email,
        nationalId,
        location,
        cooperativeId,
        hasAppAccess,
        creditScore,
        totalCattle,
        lactatingCattle,
        registeredAt,
        lastDeliveryDate,
        photoUrl,
        firstName,
        middleName,
        surname,
        dateOfBirth,
        gender,
        locationDetails,
        farmAssets,
      ];

  Farmer copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? email,
    String? nationalId,
    String? location,
    String? cooperativeId,
    bool? hasAppAccess,
    double? creditScore,
    int? totalCattle,
    int? lactatingCattle,
    DateTime? registeredAt,
    DateTime? lastDeliveryDate,
    String? photoUrl,
    String? firstName,
    String? middleName,
    String? surname,
    DateTime? dateOfBirth,
    String? gender,
    Location? locationDetails,
    FarmAssets? farmAssets,
  }) {
    return Farmer(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      nationalId: nationalId ?? this.nationalId,
      location: location ?? this.location,
      cooperativeId: cooperativeId ?? this.cooperativeId,
      hasAppAccess: hasAppAccess ?? this.hasAppAccess,
      creditScore: creditScore ?? this.creditScore,
      totalCattle: totalCattle ?? this.totalCattle,
      lactatingCattle: lactatingCattle ?? this.lactatingCattle,
      registeredAt: registeredAt ?? this.registeredAt,
      lastDeliveryDate: lastDeliveryDate ?? this.lastDeliveryDate,
      photoUrl: photoUrl ?? this.photoUrl,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      surname: surname ?? this.surname,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      locationDetails: locationDetails ?? this.locationDetails,
      farmAssets: farmAssets ?? this.farmAssets,
    );
  }

  /// Factory constructor to create Farmer with computed fields
  /// from detailed information
  factory Farmer.fromDetails({
    required String id,
    required String firstName,
    String? middleName,
    required String surname,
    required String phoneNumber,
    String? email,
    required String nationalId,
    required String cooperativeId,
    required bool hasAppAccess,
    required double creditScore,
    required DateTime registeredAt,
    DateTime? dateOfBirth,
    String? gender,
    Location? locationDetails,
    FarmAssets? farmAssets,
    DateTime? lastDeliveryDate,
    String? photoUrl,
  }) {
    // Compute name from firstName, middleName, surname
    final name = middleName != null && middleName.isNotEmpty
        ? '$firstName $middleName $surname'
        : '$firstName $surname';

    // Compute location from locationDetails
    final location = locationDetails?.fullLocation ?? '';

    // Compute totalCattle from farmAssets
    final totalCattle = farmAssets?.totalCattle ?? 0;

    // Compute lactatingCattle from farmAssets (use femaleCattle as default)
    final lactatingCattle = farmAssets?.femaleCattle ?? 0;

    return Farmer(
      id: id,
      name: name,
      phoneNumber: phoneNumber,
      email: email,
      nationalId: nationalId,
      location: location,
      cooperativeId: cooperativeId,
      hasAppAccess: hasAppAccess,
      creditScore: creditScore,
      totalCattle: totalCattle,
      lactatingCattle: lactatingCattle,
      registeredAt: registeredAt,
      lastDeliveryDate: lastDeliveryDate,
      photoUrl: photoUrl,
      firstName: firstName,
      middleName: middleName,
      surname: surname,
      dateOfBirth: dateOfBirth,
      gender: gender,
      locationDetails: locationDetails,
      farmAssets: farmAssets,
    );
  }
}
