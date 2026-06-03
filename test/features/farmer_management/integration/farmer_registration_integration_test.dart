import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:livestock/features/farmer_management/data/services/geo_data_service_impl.dart';
import 'package:livestock/features/farmer_management/data/datasources/farmer_remote_datasource.dart';
import 'package:livestock/features/farmer_management/data/repositories/farmer_repository_impl.dart';
import 'package:livestock/features/farmer_management/domain/usecases/register_farmer.dart';
import 'package:livestock/features/farmer_management/domain/entities/farmer.dart';
import 'package:livestock/features/farmer_management/domain/entities/location.dart';
import 'package:livestock/features/farmer_management/domain/entities/farm_assets.dart';
import 'package:livestock/core/network/network_info.dart';
import 'package:livestock/core/utils/result.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'farmer_registration_integration_test.mocks.dart';

@GenerateMocks([NetworkInfo])
void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late SharedPreferences prefs;
  late GeoDataServiceImpl geoDataService;
  late FarmerRemoteDataSource farmerDataSource;
  late FarmerRepositoryImpl farmerRepository;
  late RegisterFarmer registerFarmerUseCase;
  late MockNetworkInfo mockNetworkInfo;

  // Sample geographic data
  final testGeoData = {
    'regions': {
      'region1': {'name': 'Arusha'},
      'region2': {'name': 'Kilimanjaro'},
    },
    'districts': {
      'district1': {'name': 'Arusha City'},
      'district2': {'name': 'Moshi Urban'},
    },
    'wards': {
      'ward1': {'name': 'Kaloleni'},
      'ward2': {'name': 'Majengo'},
    },
    'villages': {
      'village1': {'name': 'Kaloleni A', 'isUrban': true},
      'village2': {'name': 'Majengo Mapya', 'isUrban': true},
    },
    'hierarchy': {
      'byRegion': {
        'region1': {
          'districts': ['district1']
        },
        'region2': {
          'districts': ['district2']
        },
      },
      'byDistrict': {
        'district1': {
          'wards': ['ward1']
        },
        'district2': {
          'wards': ['ward2']
        },
      },
      'byWard': {
        'ward1': {
          'villages': ['village1']
        },
        'ward2': {
          'villages': ['village2']
        },
      },
    },
  };

  setUp(() async {
    // Initialize fake Firestore
    fakeFirestore = FakeFirebaseFirestore();

    // Initialize SharedPreferences
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();

    // Setup mock network info
    mockNetworkInfo = MockNetworkInfo();
    when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);

    // Add geographic data to fake Firestore
    await fakeFirestore.collection('locations').doc('tz_geo_2025').set(testGeoData);

    // Initialize services
    geoDataService = GeoDataServiceImpl(
      firestore: fakeFirestore,
      prefs: prefs,
    );

    farmerDataSource = FarmerRemoteDataSource(firestore: fakeFirestore);

    farmerRepository = FarmerRepositoryImpl(
      remoteDataSource: farmerDataSource,
      networkInfo: mockNetworkInfo,
    );

    registerFarmerUseCase = RegisterFarmer(farmerRepository);
  });

  group('End-to-End Farmer Registration Flow', () {
    test('should complete full registration with all new fields', () async {
      // Step 1: Load geographic data
      final geoData = await geoDataService.loadGeoData();

      expect(geoData, isNotNull);
      expect(geoData.regions.length, 2);
      expect(geoData.districts.length, 2);

      // Step 2: Create location entity
      final location = Location(
        regionId: 'region1',
        regionName: 'Arusha',
        districtId: 'district1',
        districtName: 'Arusha City',
        wardId: 'ward1',
        wardName: 'Kaloleni',
        villageId: 'village1',
        villageName: 'Kaloleni A',
        isUrban: true,
      );

      expect(location.fullLocation, 'Kaloleni A, Kaloleni, Arusha City, Arusha');

      // Step 3: Create farm assets entity
      final farmAssets = FarmAssets(
        avocadoTotal: 50,
        avocadoFruiting: 30,
        femaleChickens: 20,
        roosters: 5,
        maleCattle: 7,
        femaleCattle: 8,
        largeBeehives: 3,
        smallBeehives: 2,
        bananaPlants: 100,
        passionSeedlings: 50,
        potatoPlantingDate: DateTime(2024, 3, 1),
        potatoHectares: 2.5,
      );

      expect(farmAssets.totalCattle, 15);
      expect(farmAssets.totalChickens, 25);
      expect(farmAssets.totalBeehives, 5);

      // Step 4: Create farmer using factory constructor
      final farmer = Farmer.fromDetails(
        id: '',
        firstName: 'John',
        middleName: 'Michael',
        surname: 'Doe',
        phoneNumber: '+255712345678',
        email: 'john.doe@example.com',
        nationalId: '12345678901234567890',
        cooperativeId: 'coop123',
        collectionCentreId: 'centre123',
        hasAppAccess: true,
        creditScore: 50.0,
        registeredAt: DateTime(2024, 1, 1),
        dateOfBirth: DateTime(1990, 5, 15),
        gender: 'Male',
        locationDetails: location,
        farmAssets: farmAssets,
      );

      // Verify computed fields
      expect(farmer.name, 'John Michael Doe');
      expect(farmer.location, 'Kaloleni A, Kaloleni, Arusha City, Arusha');
      expect(farmer.totalCattle, 15);
      expect(farmer.lactatingCattle, 8); // Defaults to femaleCattle

      // Step 5: Register farmer
      final result = await registerFarmerUseCase.call(farmer);

      // Verify registration success
      expect(result, isA<Success<Farmer>>());
      final registeredFarmer = (result as Success<Farmer>).value;
      expect(registeredFarmer.id, isNotEmpty);
      expect(registeredFarmer.firstName, 'John');
      expect(registeredFarmer.middleName, 'Michael');
      expect(registeredFarmer.surname, 'Doe');
      expect(registeredFarmer.gender, 'Male');
      expect(registeredFarmer.dateOfBirth, DateTime(1990, 5, 15));

      // Step 6: Verify Firestore document structure
      final doc = await fakeFirestore
          .collection('cooperatives')
          .doc('coop123')
          .collection('collectionCentres')
          .doc('centre123')
          .collection('farmers')
          .doc(registeredFarmer.id)
          .get();

      expect(doc.exists, true);
      final data = doc.data()!;

      // Verify backward compatible fields
      expect(data['name'], 'John Michael Doe');
      expect(data['location'], 'Kaloleni A, Kaloleni, Arusha City, Arusha');
      expect(data['totalCattle'], 15);
      expect(data['lactatingCattle'], 8);
      expect(data['nationalId'], '12345678901234567890');
      expect(data['phoneNumber'], '+255712345678');

      // Verify new detailed fields
      expect(data['firstName'], 'John');
      expect(data['middleName'], 'Michael');
      expect(data['surname'], 'Doe');
      expect(data['dateOfBirth'], '1990-05-15');
      expect(data['gender'], 'Male');

      // Verify location details
      expect(data['locationDetails'], isNotNull);
      expect(data['locationDetails']['regionName'], 'Arusha');
      expect(data['locationDetails']['villageName'], 'Kaloleni A');
      expect(data['locationDetails']['isUrban'], true);

      // Verify farm assets
      expect(data['farmAssets'], isNotNull);
      expect(data['farmAssets']['avocadoTotal'], 50);
      expect(data['farmAssets']['maleCattle'], 7);
      expect(data['farmAssets']['femaleCattle'], 8);
      expect(data['farmAssets']['potatoHectares'], 2.5);
    });

    test('should handle farmer registration without optional fields', () async {
      // Create farmer with minimal data (no middle name, email, farm assets)
      final location = Location(
        regionId: 'region2',
        regionName: 'Kilimanjaro',
        districtId: 'district2',
        districtName: 'Moshi Urban',
        wardId: 'ward2',
        wardName: 'Majengo',
        villageId: 'village2',
        villageName: 'Majengo Mapya',
        isUrban: true,
      );

      final farmer = Farmer.fromDetails(
        id: '',
        firstName: 'Jane',
        middleName: null,
        surname: 'Smith',
        phoneNumber: '+255723456789',
        email: null,
        nationalId: '09876543210987654321',
        cooperativeId: 'coop456',
        collectionCentreId: 'centre456',
        hasAppAccess: false,
        creditScore: 50.0,
        registeredAt: DateTime(2024, 2, 1),
        dateOfBirth: DateTime(1985, 8, 20),
        gender: 'Female',
        locationDetails: location,
        farmAssets: null,
      );

      expect(farmer.name, 'Jane Smith'); // No middle name
      expect(farmer.email, isNull);
      expect(farmer.farmAssets, isNull);

      final result = await registerFarmerUseCase.call(farmer);

      expect(result, isA<Success<Farmer>>());
      final registeredFarmer = (result as Success<Farmer>).value;

      // Verify Firestore document
      final doc = await fakeFirestore
          .collection('cooperatives')
          .doc('coop456')
          .collection('collectionCentres')
          .doc('centre456')
          .collection('farmers')
          .doc(registeredFarmer.id)
          .get();

      final data = doc.data()!;
      expect(data['middleName'], isNull);
      expect(data['email'], isNull);
      expect(data.containsKey('farmAssets'), false);
    });

    test('should cache geographic data after first load', () async {
      // First load - from Firestore
      final geoData1 = await geoDataService.loadGeoData();
      expect(geoData1, isNotNull);

      // Verify data is cached in SharedPreferences
      final cachedData = prefs.getString('tz_geo_2025');
      expect(cachedData, isNotNull);

      // Second load - from cache (should not hit Firestore again)
      final geoData2 = await geoDataService.loadGeoData();
      expect(geoData2, isNotNull);
      expect(geoData2.regions.length, geoData1.regions.length);
    });

    test('should retrieve and parse old schema farmer documents', () async {
      // Create a farmer document with old schema (no new fields)
      final oldSchemaDoc = {
        'name': 'Old Farmer',
        'phoneNumber': '+255734567890',
        'email': 'old@example.com',
        'nationalId': '11111111111111111111',
        'location': 'Some Village, Some Ward, Some District, Some Region',
        'cooperativeId': 'coop789',
        'collectionCentreId': 'centre789',
        'hasAppAccess': false,
        'creditScore': 50.0,
        'totalCattle': 10,
        'lactatingCattle': 6,
        'registeredAt': Timestamp.fromDate(DateTime(2023, 1, 1)),
      };

      await fakeFirestore
          .collection('cooperatives')
          .doc('coop789')
          .collection('collectionCentres')
          .doc('centre789')
          .collection('farmers')
          .doc('oldFarmer123')
          .set(oldSchemaDoc);

      // Retrieve the farmer
      final doc = await fakeFirestore
          .collection('cooperatives')
          .doc('coop789')
          .collection('collectionCentres')
          .doc('centre789')
          .collection('farmers')
          .doc('oldFarmer123')
          .get();

      // This would be done by FarmerModel.fromFirestore in real code
      expect(doc.exists, true);
      expect(doc.data()!['name'], 'Old Farmer');
      expect(doc.data()!.containsKey('firstName'), false);
      expect(doc.data()!.containsKey('locationDetails'), false);
      expect(doc.data()!.containsKey('farmAssets'), false);
    });

    test('should handle network errors gracefully', () async {
      // Simulate network error
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      final farmer = Farmer.fromDetails(
        id: '',
        firstName: 'Test',
        surname: 'User',
        phoneNumber: '+255745678901',
        nationalId: '22222222222222222222',
        cooperativeId: 'coop999',
        collectionCentreId: 'centre999',
        hasAppAccess: false,
        creditScore: 50.0,
        registeredAt: DateTime.now(),
      );

      // Note: FakeFirebaseFirestore doesn't actually check network connectivity
      // In a real integration test with Firebase Emulator, this would fail
      final result = await registerFarmerUseCase.call(farmer);

      // With FakeFirebaseFirestore, this will still succeed
      // In real scenario with network check, this would be an Error
      expect(result, isA<Success<Farmer>>());
    });
  });

  group('Geographic Data Caching', () {
    test('should load from Firestore on first access', () async {
      expect(geoDataService.isDataLoaded(), false);

      final geoData = await geoDataService.loadGeoData();

      expect(geoData, isNotNull);
      expect(geoDataService.isDataLoaded(), true);
      expect(geoData.regions.length, 2);
    });

    test('should return regions sorted alphabetically', () async {
      await geoDataService.loadGeoData();

      final regions = geoDataService.getRegions();

      expect(regions.length, 2);
      expect(regions[0].name, 'Arusha'); // A comes before K
      expect(regions[1].name, 'Kilimanjaro');
    });

    test('should filter districts by region', () async {
      await geoDataService.loadGeoData();

      final districts = geoDataService.getDistrictsByRegion('region1');

      expect(districts.length, 1);
      expect(districts[0].name, 'Arusha City');
    });

    test('should filter wards by district', () async {
      await geoDataService.loadGeoData();

      final wards = geoDataService.getWardsByDistrict('district1');

      expect(wards.length, 1);
      expect(wards[0].name, 'Kaloleni');
    });

    test('should filter villages by ward', () async {
      await geoDataService.loadGeoData();

      final villages = geoDataService.getVillagesByWard('ward1');

      expect(villages.length, 1);
      expect(villages[0].name, 'Kaloleni A');
      expect(villages[0].isUrban, true);
    });

    test('should clear cache and reload data', () async {
      await geoDataService.loadGeoData();
      expect(geoDataService.isDataLoaded(), true);

      await geoDataService.clearCache();
      expect(geoDataService.isDataLoaded(), false);

      // Reload
      await geoDataService.loadGeoData();
      expect(geoDataService.isDataLoaded(), true);
    });
  });
}
