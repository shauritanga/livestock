import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livestock/features/farmer_management/domain/entities/farmer.dart';
import 'package:livestock/features/farmer_management/domain/entities/location.dart';
import 'package:livestock/features/farmer_management/domain/entities/farm_assets.dart';

/// Farmer model for Firestore serialization
class FarmerModel extends Farmer {
  const FarmerModel({
    required super.id,
    required super.name,
    required super.phoneNumber,
    super.email,
    required super.nationalId,
    required super.location,
    required super.cooperativeId,
    required super.hasAppAccess,
    required super.creditScore,
    required super.totalCattle,
    required super.lactatingCattle,
    required super.registeredAt,
    super.lastDeliveryDate,
    super.photoUrl,
    required super.firstName,
    super.middleName,
    required super.surname,
    super.dateOfBirth,
    super.gender,
    super.locationDetails,
    super.farmAssets,
  });

  /// Convert Firestore document to FarmerModel
  /// Handles both old and new schema for backward compatibility
  factory FarmerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Handle new schema fields (if available)
    final firstName = data['firstName'] as String? ?? _extractFirstName(data['name'] as String);
    final middleName = data['middleName'] as String?;
    final surname = data['surname'] as String? ?? _extractSurname(data['name'] as String);
    final dateOfBirth = data['dateOfBirth'] != null
        ? DateTime.parse(data['dateOfBirth'] as String)
        : null;
    final gender = data['gender'] as String?;

    // Parse location details if available, otherwise parse from location string
    final locationDetails = data['locationDetails'] != null
        ? Location.fromMap(data['locationDetails'] as Map<String, dynamic>)
        : null;

    // Parse farm assets if available
    final farmAssets = data['farmAssets'] != null
        ? FarmAssets.fromMap(data['farmAssets'] as Map<String, dynamic>)
        : null;

    return FarmerModel(
      id: doc.id,
      name: data['name'] as String,
      phoneNumber: data['phoneNumber'] as String,
      email: data['email'] as String?,
      nationalId: data['nationalId'] as String,
      location: data['location'] as String,
      cooperativeId: data['cooperativeId'] as String,
      hasAppAccess: data['hasAppAccess'] as bool? ?? false,
      creditScore: (data['creditScore'] as num?)?.toDouble() ?? 50.0,
      totalCattle: data['totalCattle'] as int? ?? 0,
      lactatingCattle: data['lactatingCattle'] as int? ?? 0,
      registeredAt: (data['registeredAt'] as Timestamp).toDate(),
      lastDeliveryDate: data['lastDeliveryDate'] != null
          ? (data['lastDeliveryDate'] as Timestamp).toDate()
          : null,
      photoUrl: data['photoUrl'] as String?,
      firstName: firstName,
      middleName: middleName,
      surname: surname,
      dateOfBirth: dateOfBirth,
      gender: gender,
      locationDetails: locationDetails,
      farmAssets: farmAssets,
    );
  }

  /// Extract first name from full name (for old schema)
  static String _extractFirstName(String fullName) {
    final parts = fullName.trim().split(' ');
    return parts.isNotEmpty ? parts.first : fullName;
  }

  /// Extract surname from full name (for old schema)
  static String _extractSurname(String fullName) {
    final parts = fullName.trim().split(' ');
    return parts.length > 1 ? parts.last : fullName;
  }

  /// Convert FarmerModel to Firestore map
  /// Writes both old fields (for backward compatibility) and new fields
  Map<String, dynamic> toFirestore() {
    final map = <String, dynamic>{
      // Core fields
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'nationalId': nationalId,
      'location': location,
      'cooperativeId': cooperativeId,
      'hasAppAccess': hasAppAccess,
      'creditScore': creditScore,
      'totalCattle': totalCattle,
      'lactatingCattle': lactatingCattle,
      'registeredAt': Timestamp.fromDate(registeredAt),
      'lastDeliveryDate':
          lastDeliveryDate != null ? Timestamp.fromDate(lastDeliveryDate!) : null,
      'photoUrl': photoUrl,

      // Detailed fields
      'firstName': firstName,
      'middleName': middleName,
      'surname': surname,
      'dateOfBirth': dateOfBirth?.toIso8601String().split('T')[0],
      'gender': gender,
    };

    // Add locationDetails if available
    if (locationDetails != null) {
      map['locationDetails'] = locationDetails!.toMap();
    }

    // Add farmAssets if available
    if (farmAssets != null) {
      map['farmAssets'] = farmAssets!.toMap();
    }

    return map;
  }

  /// Convert Farmer entity to FarmerModel
  factory FarmerModel.fromEntity(Farmer farmer) {
    return FarmerModel(
      id: farmer.id,
      name: farmer.name,
      phoneNumber: farmer.phoneNumber,
      email: farmer.email,
      nationalId: farmer.nationalId,
      location: farmer.location,
      cooperativeId: farmer.cooperativeId,
      hasAppAccess: farmer.hasAppAccess,
      creditScore: farmer.creditScore,
      totalCattle: farmer.totalCattle,
      lactatingCattle: farmer.lactatingCattle,
      registeredAt: farmer.registeredAt,
      lastDeliveryDate: farmer.lastDeliveryDate,
      photoUrl: farmer.photoUrl,
      firstName: farmer.firstName,
      middleName: farmer.middleName,
      surname: farmer.surname,
      dateOfBirth: farmer.dateOfBirth,
      gender: farmer.gender,
      locationDetails: farmer.locationDetails,
      farmAssets: farmer.farmAssets,
    );
  }
}
