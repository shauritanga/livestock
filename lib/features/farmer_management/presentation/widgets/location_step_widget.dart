import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livestock/features/farmer_management/domain/entities/geo_data.dart';
import 'package:livestock/features/farmer_management/presentation/providers/geo_data_provider.dart';

/// Step widget for hierarchical location selection
class LocationStepWidget extends ConsumerStatefulWidget {
  final String? selectedRegionId;
  final String? selectedDistrictId;
  final String? selectedWardId;
  final String? selectedVillageId;
  final Function(String?) onRegionChanged;
  final Function(String?) onDistrictChanged;
  final Function(String?) onWardChanged;
  final Function(String?) onVillageChanged;

  const LocationStepWidget({
    super.key,
    this.selectedRegionId,
    this.selectedDistrictId,
    this.selectedWardId,
    this.selectedVillageId,
    required this.onRegionChanged,
    required this.onDistrictChanged,
    required this.onWardChanged,
    required this.onVillageChanged,
  });

  @override
  ConsumerState<LocationStepWidget> createState() => _LocationStepWidgetState();
}

class _LocationStepWidgetState extends ConsumerState<LocationStepWidget> {
  @override
  void initState() {
    super.initState();
    // Load geographic data when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(geoDataProvider.notifier).loadGeoData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final geoDataState = ref.watch(geoDataProvider);

    // Show loading indicator while data is loading
    if (geoDataState.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading location data...'),
          ],
        ),
      );
    }

    // Show error message if loading failed
    if (geoDataState.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              geoDataState.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(geoDataProvider.notifier).loadGeoData();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Show form when data is loaded
    if (geoDataState.data == null) {
      return const Center(
        child: Text('No location data available'),
      );
    }

    final notifier = ref.read(geoDataProvider.notifier);
    final regions = notifier.getRegions();
    final districts = widget.selectedRegionId != null
        ? notifier.getDistrictsByRegion(widget.selectedRegionId!)
        : <GeoDistrict>[];
    final wards = widget.selectedDistrictId != null
        ? notifier.getWardsByDistrict(widget.selectedDistrictId!)
        : <GeoWard>[];
    final villages = widget.selectedWardId != null
        ? notifier.getVillagesByWard(widget.selectedWardId!)
        : <GeoVillage>[];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Location',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select the farmer\'s location using the hierarchical structure',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),

          // Region Dropdown
          DropdownButtonFormField<String>(
            initialValue: widget.selectedRegionId,
            decoration: InputDecoration(
              labelText: 'Region *',
              prefixIcon: const Icon(Icons.location_city),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            hint: const Text('Select region'),
            items: regions
                .map((region) => DropdownMenuItem(
                      value: region.id,
                      child: Text(region.name),
                    ))
                .toList(),
            onChanged: (value) {
              widget.onRegionChanged(value);
              // Clear downstream selections
              widget.onDistrictChanged(null);
              widget.onWardChanged(null);
              widget.onVillageChanged(null);
            },
            validator: (value) =>
                value == null ? 'Please select a region' : null,
          ),
          const SizedBox(height: 16),

          // District Dropdown
          DropdownButtonFormField<String>(
            initialValue: widget.selectedDistrictId,
            decoration: InputDecoration(
              labelText: 'District *',
              prefixIcon: const Icon(Icons.location_on),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            hint: const Text('Select district'),
            items: districts
                .map((district) => DropdownMenuItem(
                      value: district.id,
                      child: Text(district.name),
                    ))
                .toList(),
            onChanged: widget.selectedRegionId == null
                ? null
                : (value) {
                    widget.onDistrictChanged(value);
                    // Clear downstream selections
                    widget.onWardChanged(null);
                    widget.onVillageChanged(null);
                  },
            validator: (value) =>
                value == null ? 'Please select a district' : null,
          ),
          const SizedBox(height: 16),

          // Ward Dropdown
          DropdownButtonFormField<String>(
            initialValue: widget.selectedWardId,
            decoration: InputDecoration(
              labelText: 'Ward *',
              prefixIcon: const Icon(Icons.place),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            hint: const Text('Select ward'),
            items: wards
                .map((ward) => DropdownMenuItem(
                      value: ward.id,
                      child: Text(ward.name),
                    ))
                .toList(),
            onChanged: widget.selectedDistrictId == null
                ? null
                : (value) {
                    widget.onWardChanged(value);
                    // Clear downstream selection
                    widget.onVillageChanged(null);
                  },
            validator: (value) => value == null ? 'Please select a ward' : null,
          ),
          const SizedBox(height: 16),

          // Village/Street Dropdown
          DropdownButtonFormField<String>(
            initialValue: widget.selectedVillageId,
            decoration: InputDecoration(
              labelText: 'Village / Street *',
              prefixIcon: const Icon(Icons.home),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            hint: const Text('Select village or street'),
            items: villages
                .map((village) => DropdownMenuItem(
                      value: village.id,
                      child: Row(
                        children: [
                          Text(village.name),
                          if (village.isUrban) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Urban',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ))
                .toList(),
            onChanged: widget.selectedWardId == null
                ? null
                : widget.onVillageChanged,
            validator: (value) =>
                value == null ? 'Please select a village/street' : null,
          ),
          const SizedBox(height: 16),

          // Selected Location Summary
          if (widget.selectedRegionId != null &&
              widget.selectedDistrictId != null &&
              widget.selectedWardId != null &&
              widget.selectedVillageId != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Selected Location',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _buildLocationString(
                      regions,
                      districts,
                      wards,
                      villages,
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Info box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Select location from top to bottom: Region → District → Ward → Village',
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _buildLocationString(
    List<GeoRegion> regions,
    List<GeoDistrict> districts,
    List<GeoWard> wards,
    List<GeoVillage> villages,
  ) {
    final region = regions.firstWhere(
      (r) => r.id == widget.selectedRegionId,
      orElse: () => const GeoRegion(id: '', name: ''),
    );
    final district = districts.firstWhere(
      (d) => d.id == widget.selectedDistrictId,
      orElse: () => const GeoDistrict(id: '', name: ''),
    );
    final ward = wards.firstWhere(
      (w) => w.id == widget.selectedWardId,
      orElse: () => const GeoWard(id: '', name: ''),
    );
    final village = villages.firstWhere(
      (v) => v.id == widget.selectedVillageId,
      orElse: () => const GeoVillage(id: '', name: '', isUrban: false),
    );

    return '${village.name}, ${ward.name}, ${district.name}, ${region.name}';
  }
}
