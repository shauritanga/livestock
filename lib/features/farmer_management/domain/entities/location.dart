import 'package:equatable/equatable.dart';

/// Location entity representing hierarchical geographic structure
/// for Tanzania's administrative boundaries
class Location extends Equatable {
  final String regionId;
  final String regionName;
  final String districtId;
  final String districtName;
  final String wardId;
  final String wardName;
  final String villageId;
  final String villageName;
  final bool isUrban;

  const Location({
    required this.regionId,
    required this.regionName,
    required this.districtId,
    required this.districtName,
    required this.wardId,
    required this.wardName,
    required this.villageId,
    required this.villageName,
    required this.isUrban,
  });

  /// Computed property for backward compatibility
  /// Returns full location string: "Village, Ward, District, Region"
  String get fullLocation =>
      '$villageName, $wardName, $districtName, $regionName';

  @override
  List<Object?> get props => [
        regionId,
        regionName,
        districtId,
        districtName,
        wardId,
        wardName,
        villageId,
        villageName,
        isUrban,
      ];

  Location copyWith({
    String? regionId,
    String? regionName,
    String? districtId,
    String? districtName,
    String? wardId,
    String? wardName,
    String? villageId,
    String? villageName,
    bool? isUrban,
  }) {
    return Location(
      regionId: regionId ?? this.regionId,
      regionName: regionName ?? this.regionName,
      districtId: districtId ?? this.districtId,
      districtName: districtName ?? this.districtName,
      wardId: wardId ?? this.wardId,
      wardName: wardName ?? this.wardName,
      villageId: villageId ?? this.villageId,
      villageName: villageName ?? this.villageName,
      isUrban: isUrban ?? this.isUrban,
    );
  }

  /// Create Location from map (for deserialization)
  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      regionId: map['regionId'] as String,
      regionName: map['regionName'] as String,
      districtId: map['districtId'] as String,
      districtName: map['districtName'] as String,
      wardId: map['wardId'] as String,
      wardName: map['wardName'] as String,
      villageId: map['villageId'] as String,
      villageName: map['villageName'] as String,
      isUrban: map['isUrban'] as bool,
    );
  }

  /// Convert Location to map (for serialization)
  Map<String, dynamic> toMap() {
    return {
      'regionId': regionId,
      'regionName': regionName,
      'districtId': districtId,
      'districtName': districtName,
      'wardId': wardId,
      'wardName': wardName,
      'villageId': villageId,
      'villageName': villageName,
      'isUrban': isUrban,
    };
  }
}
