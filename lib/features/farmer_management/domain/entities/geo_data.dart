import 'package:equatable/equatable.dart';

/// Geographic region entity
class GeoRegion extends Equatable {
  final String id;
  final String name;

  const GeoRegion({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];

  factory GeoRegion.fromMap(String id, Map<String, dynamic> map) {
    return GeoRegion(
      id: id,
      name: map['name'] as String,
    );
  }
}

/// Geographic district entity
class GeoDistrict extends Equatable {
  final String id;
  final String name;

  const GeoDistrict({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];

  factory GeoDistrict.fromMap(String id, Map<String, dynamic> map) {
    return GeoDistrict(
      id: id,
      name: map['name'] as String,
    );
  }
}

/// Geographic ward entity
class GeoWard extends Equatable {
  final String id;
  final String name;

  const GeoWard({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];

  factory GeoWard.fromMap(String id, Map<String, dynamic> map) {
    return GeoWard(
      id: id,
      name: map['name'] as String,
    );
  }
}

/// Geographic village entity
class GeoVillage extends Equatable {
  final String id;
  final String name;
  final bool isUrban;

  const GeoVillage({
    required this.id,
    required this.name,
    required this.isUrban,
  });

  @override
  List<Object?> get props => [id, name, isUrban];

  factory GeoVillage.fromMap(String id, Map<String, dynamic> map) {
    return GeoVillage(
      id: id,
      name: map['name'] as String,
      isUrban: map['isUrban'] as bool? ?? false,
    );
  }
}

/// Complete geographic data structure
class GeoData extends Equatable {
  final Map<String, GeoRegion> regions;
  final Map<String, GeoDistrict> districts;
  final Map<String, GeoWard> wards;
  final Map<String, GeoVillage> villages;
  final Map<String, List<String>> regionToDistricts;
  final Map<String, List<String>> districtToWards;
  final Map<String, List<String>> wardToVillages;

  const GeoData({
    required this.regions,
    required this.districts,
    required this.wards,
    required this.villages,
    required this.regionToDistricts,
    required this.districtToWards,
    required this.wardToVillages,
  });

  @override
  List<Object?> get props => [
        regions,
        districts,
        wards,
        villages,
        regionToDistricts,
        districtToWards,
        wardToVillages,
      ];

  /// Parse GeoData from Firestore document
  factory GeoData.fromFirestore(Map<String, dynamic> data) {
    // Parse regions
    final regionsMap = <String, GeoRegion>{};
    final regionsData = data['regions'] as Map<String, dynamic>? ?? {};
    regionsData.forEach((id, value) {
      regionsMap[id] = GeoRegion.fromMap(id, value as Map<String, dynamic>);
    });

    // Parse districts
    final districtsMap = <String, GeoDistrict>{};
    final districtsData = data['districts'] as Map<String, dynamic>? ?? {};
    districtsData.forEach((id, value) {
      districtsMap[id] = GeoDistrict.fromMap(id, value as Map<String, dynamic>);
    });

    // Parse wards
    final wardsMap = <String, GeoWard>{};
    final wardsData = data['wards'] as Map<String, dynamic>? ?? {};
    wardsData.forEach((id, value) {
      wardsMap[id] = GeoWard.fromMap(id, value as Map<String, dynamic>);
    });

    // Parse villages
    final villagesMap = <String, GeoVillage>{};
    final villagesData = data['villages'] as Map<String, dynamic>? ?? {};
    villagesData.forEach((id, value) {
      villagesMap[id] = GeoVillage.fromMap(id, value as Map<String, dynamic>);
    });

    // Parse hierarchy
    final hierarchy = data['hierarchy'] as Map<String, dynamic>? ?? {};

    final regionToDistricts = <String, List<String>>{};
    final byRegion = hierarchy['byRegion'] as Map<String, dynamic>? ?? {};
    byRegion.forEach((regionId, value) {
      final regionData = value as Map<String, dynamic>;
      regionToDistricts[regionId] =
          List<String>.from(regionData['districts'] as List? ?? []);
    });

    final districtToWards = <String, List<String>>{};
    final byDistrict = hierarchy['byDistrict'] as Map<String, dynamic>? ?? {};
    byDistrict.forEach((districtId, value) {
      final districtData = value as Map<String, dynamic>;
      districtToWards[districtId] =
          List<String>.from(districtData['wards'] as List? ?? []);
    });

    final wardToVillages = <String, List<String>>{};
    final byWard = hierarchy['byWard'] as Map<String, dynamic>? ?? {};
    byWard.forEach((wardId, value) {
      final wardData = value as Map<String, dynamic>;
      wardToVillages[wardId] =
          List<String>.from(wardData['villages'] as List? ?? []);
    });

    return GeoData(
      regions: regionsMap,
      districts: districtsMap,
      wards: wardsMap,
      villages: villagesMap,
      regionToDistricts: regionToDistricts,
      districtToWards: districtToWards,
      wardToVillages: wardToVillages,
    );
  }
}
