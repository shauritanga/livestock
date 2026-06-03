import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:livestock/features/farmer_management/data/services/geo_data_service_impl.dart';
import 'package:livestock/features/farmer_management/domain/services/geo_data_service.dart';
import 'package:livestock/features/farmer_management/domain/entities/geo_data.dart';

/// Provider for SharedPreferences instance
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

/// Provider for GeoDataService
final geoDataServiceProvider = Provider<GeoDataService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).value;
  
  if (prefs == null) {
    throw Exception('SharedPreferences not initialized');
  }

  return GeoDataServiceImpl(
    firestore: FirebaseFirestore.instance,
    prefs: prefs,
  );
});

/// State for geographic data loading
class GeoDataState {
  final GeoData? data;
  final bool isLoading;
  final String? errorMessage;

  const GeoDataState({
    this.data,
    this.isLoading = false,
    this.errorMessage,
  });

  GeoDataState copyWith({
    GeoData? data,
    bool? isLoading,
    String? errorMessage,
  }) {
    return GeoDataState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Notifier for managing geographic data state
class GeoDataNotifier extends Notifier<GeoDataState> {
  late GeoDataService _geoDataService;

  @override
  GeoDataState build() {
    _geoDataService = ref.watch(geoDataServiceProvider);
    return const GeoDataState();
  }

  /// Load geographic data
  Future<void> loadGeoData() async {
    if (state.data != null) {
      // Data already loaded
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final data = await _geoDataService.loadGeoData();
      state = state.copyWith(data: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load geographic data: ${e.toString()}',
      );
    }
  }

  /// Clear cached data and reload
  Future<void> reloadGeoData() async {
    await _geoDataService.clearCache();
    state = const GeoDataState();
    await loadGeoData();
  }

  /// Get regions sorted alphabetically
  List<GeoRegion> getRegions() {
    return _geoDataService.getRegions();
  }

  /// Get districts for a specific region
  List<GeoDistrict> getDistrictsByRegion(String regionId) {
    return _geoDataService.getDistrictsByRegion(regionId);
  }

  /// Get wards for a specific district
  List<GeoWard> getWardsByDistrict(String districtId) {
    return _geoDataService.getWardsByDistrict(districtId);
  }

  /// Get villages for a specific ward
  List<GeoVillage> getVillagesByWard(String wardId) {
    return _geoDataService.getVillagesByWard(wardId);
  }
}

/// Provider for GeoDataNotifier
final geoDataProvider = NotifierProvider<GeoDataNotifier, GeoDataState>(() {
  return GeoDataNotifier();
});
