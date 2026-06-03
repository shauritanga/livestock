import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:livestock/features/farmer_management/domain/entities/geo_data.dart';
import 'package:livestock/features/farmer_management/domain/services/geo_data_service.dart';

/// Implementation of GeoDataService with Firestore and SharedPreferences caching
class GeoDataServiceImpl implements GeoDataService {
  final FirebaseFirestore _firestore;
  final SharedPreferences _prefs;

  static const String _cacheKey = 'tz_geo_2025';
  static const String _collectionName = 'locations';
  static const String _documentId = 'tz_geo_2025';

  GeoData? _cachedGeoData;

  GeoDataServiceImpl({
    required FirebaseFirestore firestore,
    required SharedPreferences prefs,
  })  : _firestore = firestore,
        _prefs = prefs;

  @override
  Future<GeoData> loadGeoData() async {
    // Return cached data if already loaded in memory
    if (_cachedGeoData != null) {
      return _cachedGeoData!;
    }

    // Try to load from SharedPreferences cache
    final cachedJson = _prefs.getString(_cacheKey);
    if (cachedJson != null) {
      try {
        final data = json.decode(cachedJson) as Map<String, dynamic>;
        _cachedGeoData = GeoData.fromFirestore(data);
        return _cachedGeoData!;
      } catch (e) {
        // If cache is corrupted, clear it and fetch from Firestore
        await _prefs.remove(_cacheKey);
      }
    }

    // Fetch from Firestore
    final doc = await _firestore
        .collection(_collectionName)
        .doc(_documentId)
        .get();

    if (!doc.exists) {
      throw Exception('Geographic data not found in Firestore');
    }

    final data = doc.data() as Map<String, dynamic>;

    // Cache in SharedPreferences
    await _prefs.setString(_cacheKey, json.encode(data));

    // Cache in memory
    _cachedGeoData = GeoData.fromFirestore(data);

    return _cachedGeoData!;
  }

  @override
  List<GeoRegion> getRegions() {
    if (_cachedGeoData == null) {
      return [];
    }

    final regions = _cachedGeoData!.regions.values.toList();

    // Sort alphabetically by name
    regions.sort((a, b) => a.name.compareTo(b.name));

    return regions;
  }

  @override
  List<GeoDistrict> getDistrictsByRegion(String regionId) {
    if (_cachedGeoData == null) {
      return [];
    }

    final districtIds = _cachedGeoData!.regionToDistricts[regionId] ?? [];

    final districts = districtIds
        .map((id) => _cachedGeoData!.districts[id])
        .whereType<GeoDistrict>()
        .toList();

    // Sort alphabetically by name
    districts.sort((a, b) => a.name.compareTo(b.name));

    return districts;
  }

  @override
  List<GeoWard> getWardsByDistrict(String districtId) {
    if (_cachedGeoData == null) {
      return [];
    }

    final wardIds = _cachedGeoData!.districtToWards[districtId] ?? [];

    final wards = wardIds
        .map((id) => _cachedGeoData!.wards[id])
        .whereType<GeoWard>()
        .toList();

    // Sort alphabetically by name
    wards.sort((a, b) => a.name.compareTo(b.name));

    return wards;
  }

  @override
  List<GeoVillage> getVillagesByWard(String wardId) {
    if (_cachedGeoData == null) {
      return [];
    }

    final villageIds = _cachedGeoData!.wardToVillages[wardId] ?? [];

    final villages = villageIds
        .map((id) => _cachedGeoData!.villages[id])
        .whereType<GeoVillage>()
        .toList();

    // Sort alphabetically by name
    villages.sort((a, b) => a.name.compareTo(b.name));

    return villages;
  }

  @override
  Future<void> clearCache() async {
    await _prefs.remove(_cacheKey);
    _cachedGeoData = null;
  }

  @override
  bool isDataLoaded() {
    return _cachedGeoData != null;
  }
}
