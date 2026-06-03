import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:livestock/features/farmer_management/data/services/geo_data_service_impl.dart';
import 'package:livestock/features/farmer_management/domain/entities/geo_data.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'geo_data_service_impl_test.mocks.dart';

@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
])
void main() {
  late GeoDataServiceImpl service;
  late MockFirebaseFirestore mockFirestore;
  late SharedPreferences prefs;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDocument;
  late MockDocumentSnapshot<Map<String, dynamic>> mockSnapshot;

  // Sample test data
  final testGeoData = {
    'regions': {
      'region1': {'name': 'Arusha'},
      'region2': {'name': 'Dar es Salaam'},
      'region3': {'name': 'Kilimanjaro'},
    },
    'districts': {
      'district1': {'name': 'Arusha City'},
      'district2': {'name': 'Meru'},
      'district3': {'name': 'Ilala'},
    },
    'wards': {
      'ward1': {'name': 'Kaloleni'},
      'ward2': {'name': 'Themi'},
      'ward3': {'name': 'Upanga'},
    },
    'villages': {
      'village1': {'name': 'Kaloleni A', 'isUrban': true},
      'village2': {'name': 'Themi Hill', 'isUrban': false},
      'village3': {'name': 'Upanga West', 'isUrban': true},
    },
    'hierarchy': {
      'byRegion': {
        'region1': {
          'districts': ['district1', 'district2']
        },
        'region2': {
          'districts': ['district3']
        },
      },
      'byDistrict': {
        'district1': {
          'wards': ['ward1', 'ward2']
        },
        'district3': {
          'wards': ['ward3']
        },
      },
      'byWard': {
        'ward1': {
          'villages': ['village1']
        },
        'ward2': {
          'villages': ['village2']
        },
        'ward3': {
          'villages': ['village3']
        },
      },
    },
  };

  setUp(() async {
    // Initialize SharedPreferences with empty data
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();

    // Setup mocks
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference<Map<String, dynamic>>();
    mockDocument = MockDocumentReference<Map<String, dynamic>>();
    mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

    service = GeoDataServiceImpl(
      firestore: mockFirestore,
      prefs: prefs,
    );
  });

  group('loadGeoData', () {
    test('should fetch from Firestore when cache is empty', () async {
      // Arrange
      when(mockFirestore.collection('locations')).thenReturn(mockCollection);
      when(mockCollection.doc('tz_geo_2025')).thenReturn(mockDocument);
      when(mockDocument.get()).thenAnswer((_) async => mockSnapshot);
      when(mockSnapshot.exists).thenReturn(true);
      when(mockSnapshot.data()).thenReturn(testGeoData);

      // Act
      final result = await service.loadGeoData();

      // Assert
      expect(result, isA<GeoData>());
      expect(result.regions.length, 3);
      expect(result.districts.length, 3);
      expect(result.wards.length, 3);
      expect(result.villages.length, 3);

      // Verify Firestore was called
      verify(mockFirestore.collection('locations')).called(1);
      verify(mockCollection.doc('tz_geo_2025')).called(1);
      verify(mockDocument.get()).called(1);

      // Verify data was cached
      final cachedData = prefs.getString('tz_geo_2025');
      expect(cachedData, isNotNull);
    });

    test('should load from SharedPreferences cache when available', () async {
      // Arrange - Pre-populate cache
      await prefs.setString('tz_geo_2025', json.encode(testGeoData));

      // Act
      final result = await service.loadGeoData();

      // Assert
      expect(result, isA<GeoData>());
      expect(result.regions.length, 3);

      // Verify Firestore was NOT called
      verifyNever(mockFirestore.collection(any));
    });

    test('should return cached data on subsequent calls', () async {
      // Arrange
      when(mockFirestore.collection('locations')).thenReturn(mockCollection);
      when(mockCollection.doc('tz_geo_2025')).thenReturn(mockDocument);
      when(mockDocument.get()).thenAnswer((_) async => mockSnapshot);
      when(mockSnapshot.exists).thenReturn(true);
      when(mockSnapshot.data()).thenReturn(testGeoData);

      // Act - First call
      await service.loadGeoData();

      // Act - Second call
      final result = await service.loadGeoData();

      // Assert
      expect(result, isA<GeoData>());

      // Verify Firestore was called only once
      verify(mockDocument.get()).called(1);
    });

    test('should throw exception when Firestore document does not exist',
        () async {
      // Arrange
      when(mockFirestore.collection('locations')).thenReturn(mockCollection);
      when(mockCollection.doc('tz_geo_2025')).thenReturn(mockDocument);
      when(mockDocument.get()).thenAnswer((_) async => mockSnapshot);
      when(mockSnapshot.exists).thenReturn(false);

      // Act & Assert
      expect(
        () => service.loadGeoData(),
        throwsA(isA<Exception>()),
      );
    });

    test('should fetch from Firestore when cache is corrupted', () async {
      // Arrange - Set corrupted cache
      await prefs.setString('tz_geo_2025', 'invalid json');

      when(mockFirestore.collection('locations')).thenReturn(mockCollection);
      when(mockCollection.doc('tz_geo_2025')).thenReturn(mockDocument);
      when(mockDocument.get()).thenAnswer((_) async => mockSnapshot);
      when(mockSnapshot.exists).thenReturn(true);
      when(mockSnapshot.data()).thenReturn(testGeoData);

      // Act
      final result = await service.loadGeoData();

      // Assert
      expect(result, isA<GeoData>());

      // Verify Firestore was called
      verify(mockDocument.get()).called(1);
    });
  });

  group('getRegions', () {
    test('should return empty list when data not loaded', () {
      // Act
      final result = service.getRegions();

      // Assert
      expect(result, isEmpty);
    });

    test('should return regions sorted alphabetically', () async {
      // Arrange
      await prefs.setString('tz_geo_2025', json.encode(testGeoData));
      await service.loadGeoData();

      // Act
      final result = service.getRegions();

      // Assert
      expect(result.length, 3);
      expect(result[0].name, 'Arusha'); // A comes first
      expect(result[1].name, 'Dar es Salaam'); // D comes second
      expect(result[2].name, 'Kilimanjaro'); // K comes third
    });
  });

  group('getDistrictsByRegion', () {
    test('should return empty list when data not loaded', () {
      // Act
      final result = service.getDistrictsByRegion('region1');

      // Assert
      expect(result, isEmpty);
    });

    test('should return districts for specified region', () async {
      // Arrange
      await prefs.setString('tz_geo_2025', json.encode(testGeoData));
      await service.loadGeoData();

      // Act
      final result = service.getDistrictsByRegion('region1');

      // Assert
      expect(result.length, 2);
      expect(result.any((d) => d.name == 'Arusha City'), true);
      expect(result.any((d) => d.name == 'Meru'), true);
    });

    test('should return empty list for non-existent region', () async {
      // Arrange
      await prefs.setString('tz_geo_2025', json.encode(testGeoData));
      await service.loadGeoData();

      // Act
      final result = service.getDistrictsByRegion('non_existent');

      // Assert
      expect(result, isEmpty);
    });

    test('should return districts sorted alphabetically', () async {
      // Arrange
      await prefs.setString('tz_geo_2025', json.encode(testGeoData));
      await service.loadGeoData();

      // Act
      final result = service.getDistrictsByRegion('region1');

      // Assert
      expect(result[0].name, 'Arusha City'); // A comes before M
      expect(result[1].name, 'Meru');
    });
  });

  group('getWardsByDistrict', () {
    test('should return empty list when data not loaded', () {
      // Act
      final result = service.getWardsByDistrict('district1');

      // Assert
      expect(result, isEmpty);
    });

    test('should return wards for specified district', () async {
      // Arrange
      await prefs.setString('tz_geo_2025', json.encode(testGeoData));
      await service.loadGeoData();

      // Act
      final result = service.getWardsByDistrict('district1');

      // Assert
      expect(result.length, 2);
      expect(result.any((w) => w.name == 'Kaloleni'), true);
      expect(result.any((w) => w.name == 'Themi'), true);
    });

    test('should return wards sorted alphabetically', () async {
      // Arrange
      await prefs.setString('tz_geo_2025', json.encode(testGeoData));
      await service.loadGeoData();

      // Act
      final result = service.getWardsByDistrict('district1');

      // Assert
      expect(result[0].name, 'Kaloleni'); // K comes before T
      expect(result[1].name, 'Themi');
    });
  });

  group('getVillagesByWard', () {
    test('should return empty list when data not loaded', () {
      // Act
      final result = service.getVillagesByWard('ward1');

      // Assert
      expect(result, isEmpty);
    });

    test('should return villages for specified ward', () async {
      // Arrange
      await prefs.setString('tz_geo_2025', json.encode(testGeoData));
      await service.loadGeoData();

      // Act
      final result = service.getVillagesByWard('ward1');

      // Assert
      expect(result.length, 1);
      expect(result[0].name, 'Kaloleni A');
      expect(result[0].isUrban, true);
    });

    test('should return villages sorted alphabetically', () async {
      // Arrange
      await prefs.setString('tz_geo_2025', json.encode(testGeoData));
      await service.loadGeoData();

      // Act
      final result = service.getVillagesByWard('ward1');

      // Assert
      expect(result[0].name, 'Kaloleni A');
    });
  });

  group('clearCache', () {
    test('should clear SharedPreferences cache and memory cache', () async {
      // Arrange
      await prefs.setString('tz_geo_2025', json.encode(testGeoData));
      await service.loadGeoData();
      expect(service.isDataLoaded(), true);

      // Act
      await service.clearCache();

      // Assert
      expect(prefs.getString('tz_geo_2025'), isNull);
      expect(service.isDataLoaded(), false);
    });
  });

  group('isDataLoaded', () {
    test('should return false when data not loaded', () {
      // Act & Assert
      expect(service.isDataLoaded(), false);
    });

    test('should return true when data is loaded', () async {
      // Arrange
      await prefs.setString('tz_geo_2025', json.encode(testGeoData));
      await service.loadGeoData();

      // Act & Assert
      expect(service.isDataLoaded(), true);
    });
  });
}
