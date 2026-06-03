import 'package:livestock/features/farmer_management/domain/entities/geo_data.dart';

/// Service interface for loading and querying geographic data
abstract class GeoDataService {
  /// Load geographic data from cache or Firestore
  /// Returns cached data if available, otherwise fetches from Firestore
  Future<GeoData> loadGeoData();

  /// Get all regions sorted alphabetically by name
  List<GeoRegion> getRegions();

  /// Get districts for a specific region
  List<GeoDistrict> getDistrictsByRegion(String regionId);

  /// Get wards for a specific district
  List<GeoWard> getWardsByDistrict(String districtId);

  /// Get villages for a specific ward
  List<GeoVillage> getVillagesByWard(String wardId);

  /// Clear cached geographic data
  Future<void> clearCache();

  /// Check if geographic data is loaded
  bool isDataLoaded();
}
