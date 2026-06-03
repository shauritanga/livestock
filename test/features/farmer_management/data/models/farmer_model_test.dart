import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livestock/features/farmer_management/data/models/farmer_model.dart';
import 'package:livestock/features/farmer_management/domain/entities/location.dart';
import 'package:livestock/features/farmer_management/domain/entities/farm_assets.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'farmer_model_test.mocks.dart';

@GenerateMocks([DocumentSnapshot])
void main() {
  late MockDocumentSnapshot<Map<String, dynamic>> mockSnapshot;

  setUp(() {
    mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
  });

  group('FarmerModel.fromFirestore', () {
    test('should parse old schema documents correctly', () {
      // Arrange - Old schema data
      final oldSchemaData = {
        'name': 'John Doe',
        'phoneNumber': '+255712345678',
        'email': 'john@example.com',
        'nationalId': '12345678901234567890',
        'location': 'Kaloleni, Arusha City, Arusha',
        'cooperativeId': 'coop123',
        'collectionCentreId': 'centre123',
        'hasAppAccess': true,
        'creditScore': 75.5,
        'totalCattle': 10,
        'lactatingCattle': 6,
        'registeredAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
        'photoUrl': 'https://example.com/photo.jpg',
      };

      when(mockSnapshot.id).thenReturn('farmer123');
      when(mockSnapshot.data()).thenReturn(oldSchemaData);

      // Act
      final result = FarmerModel.fromFirestore(mockSnapshot);

      // Assert
      expect(result.id, 'farmer123');
      expect(result.name, 'John Doe');
      expect(result.firstName, 'John'); // Extracted from name
      expect(result.surname, 'Doe'); // Extracted from name
      expect(result.middleName, isNull);
      expect(result.phoneNumber, '+255712345678');
      expect(result.email, 'john@example.com');
      expect(result.nationalId, '12345678901234567890');
      expect(result.location, 'Kaloleni, Arusha City, Arusha');
      expect(result.locationDetails, isNull); // Not in old schema
      expect(result.cooperativeId, 'coop123');
      expect(result.collectionCentreId, 'centre123');
      expect(result.hasAppAccess, true);
      expect(result.creditScore, 75.5);
      expect(result.totalCattle, 10);
      expect(result.lactatingCattle, 6);
      expect(result.dateOfBirth, isNull); // Not in old schema
      expect(result.gender, isNull); // Not in old schema
      expect(result.farmAssets, isNull); // Not in old schema
    });

    test('should parse new schema documents correctly', () {
      // Arrange - New schema data
      final newSchemaData = {
        'name': 'John Michael Doe',
        'phoneNumber': '+255712345678',
        'email': 'john@example.com',
        'nationalId': '12345678901234567890',
        'location': 'Kaloleni A, Kaloleni, Arusha City, Arusha',
        'cooperativeId': 'coop123',
        'collectionCentreId': 'centre123',
        'hasAppAccess': true,
        'creditScore': 75.5,
        'totalCattle': 15,
        'lactatingCattle': 8,
        'registeredAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
        'photoUrl': 'https://example.com/photo.jpg',
        'firstName': 'John',
        'middleName': 'Michael',
        'surname': 'Doe',
        'dateOfBirth': '1990-05-15',
        'gender': 'Male',
        'locationDetails': {
          'regionId': 'region1',
          'regionName': 'Arusha',
          'districtId': 'district1',
          'districtName': 'Arusha City',
          'wardId': 'ward1',
          'wardName': 'Kaloleni',
          'villageId': 'village1',
          'villageName': 'Kaloleni A',
          'isUrban': true,
        },
        'farmAssets': {
          'avocadoTotal': 50,
          'avocadoFruiting': 30,
          'femaleChickens': 20,
          'roosters': 5,
          'maleCattle': 7,
          'femaleCattle': 8,
          'largeBeehives': 3,
          'smallBeehives': 2,
          'bananaPlants': 100,
          'passionSeedlings': 50,
          'potatoPlantingDate': '2024-03-01',
          'potatoHectares': 2.5,
        },
      };

      when(mockSnapshot.id).thenReturn('farmer456');
      when(mockSnapshot.data()).thenReturn(newSchemaData);

      // Act
      final result = FarmerModel.fromFirestore(mockSnapshot);

      // Assert
      expect(result.id, 'farmer456');
      expect(result.name, 'John Michael Doe');
      expect(result.firstName, 'John');
      expect(result.middleName, 'Michael');
      expect(result.surname, 'Doe');
      expect(result.dateOfBirth, DateTime(1990, 5, 15));
      expect(result.gender, 'Male');
      expect(result.locationDetails, isNotNull);
      expect(result.locationDetails!.regionName, 'Arusha');
      expect(result.locationDetails!.villageName, 'Kaloleni A');
      expect(result.farmAssets, isNotNull);
      expect(result.farmAssets!.avocadoTotal, 50);
      expect(result.farmAssets!.totalCattle, 15); // 7 + 8
    });

    test('should handle missing optional fields gracefully', () {
      // Arrange - Minimal data
      final minimalData = {
        'name': 'Jane Smith',
        'phoneNumber': '+255723456789',
        'nationalId': '09876543210987654321',
        'location': 'Dar es Salaam',
        'cooperativeId': 'coop456',
        'collectionCentreId': 'centre456',
        'registeredAt': Timestamp.fromDate(DateTime(2024, 2, 1)),
      };

      when(mockSnapshot.id).thenReturn('farmer789');
      when(mockSnapshot.data()).thenReturn(minimalData);

      // Act
      final result = FarmerModel.fromFirestore(mockSnapshot);

      // Assert
      expect(result.id, 'farmer789');
      expect(result.name, 'Jane Smith');
      expect(result.firstName, 'Jane');
      expect(result.surname, 'Smith');
      expect(result.email, isNull);
      expect(result.hasAppAccess, false); // Default value
      expect(result.creditScore, 50.0); // Default value
      expect(result.totalCattle, 0); // Default value
      expect(result.lactatingCattle, 0); // Default value
      expect(result.photoUrl, isNull);
      expect(result.dateOfBirth, isNull);
      expect(result.gender, isNull);
      expect(result.locationDetails, isNull);
      expect(result.farmAssets, isNull);
    });

    test('should extract first name from single word name', () {
      // Arrange
      final data = {
        'name': 'Madonna',
        'phoneNumber': '+255734567890',
        'nationalId': '11111111111111111111',
        'location': 'Mwanza',
        'cooperativeId': 'coop789',
        'collectionCentreId': 'centre789',
        'registeredAt': Timestamp.fromDate(DateTime(2024, 3, 1)),
      };

      when(mockSnapshot.id).thenReturn('farmer999');
      when(mockSnapshot.data()).thenReturn(data);

      // Act
      final result = FarmerModel.fromFirestore(mockSnapshot);

      // Assert
      expect(result.firstName, 'Madonna');
      expect(result.surname, 'Madonna'); // Same as first name for single word
    });
  });

  group('FarmerModel.toFirestore', () {
    test('should include both old and new fields', () {
      // Arrange
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

      final farmer = FarmerModel(
        id: 'farmer123',
        name: 'John Michael Doe',
        phoneNumber: '+255712345678',
        email: 'john@example.com',
        nationalId: '12345678901234567890',
        location: 'Kaloleni A, Kaloleni, Arusha City, Arusha',
        cooperativeId: 'coop123',
        collectionCentreId: 'centre123',
        hasAppAccess: true,
        creditScore: 75.5,
        totalCattle: 15,
        lactatingCattle: 8,
        registeredAt: DateTime(2024, 1, 1),
        photoUrl: 'https://example.com/photo.jpg',
        firstName: 'John',
        middleName: 'Michael',
        surname: 'Doe',
        dateOfBirth: DateTime(1990, 5, 15),
        gender: 'Male',
        locationDetails: location,
        farmAssets: farmAssets,
      );

      // Act
      final result = farmer.toFirestore();

      // Assert - Backward compatible fields
      expect(result['name'], 'John Michael Doe');
      expect(result['phoneNumber'], '+255712345678');
      expect(result['email'], 'john@example.com');
      expect(result['nationalId'], '12345678901234567890');
      expect(result['location'], 'Kaloleni A, Kaloleni, Arusha City, Arusha');
      expect(result['cooperativeId'], 'coop123');
      expect(result['collectionCentreId'], 'centre123');
      expect(result['hasAppAccess'], true);
      expect(result['creditScore'], 75.5);
      expect(result['totalCattle'], 15);
      expect(result['lactatingCattle'], 8);
      expect(result['registeredAt'], isA<Timestamp>());
      expect(result['photoUrl'], 'https://example.com/photo.jpg');

      // Assert - New fields
      expect(result['firstName'], 'John');
      expect(result['middleName'], 'Michael');
      expect(result['surname'], 'Doe');
      expect(result['dateOfBirth'], '1990-05-15');
      expect(result['gender'], 'Male');
      expect(result['locationDetails'], isA<Map<String, dynamic>>());
      expect(result['locationDetails']['regionName'], 'Arusha');
      expect(result['farmAssets'], isA<Map<String, dynamic>>());
      expect(result['farmAssets']['avocadoTotal'], 50);
    });

    test('should handle null optional fields', () {
      // Arrange
      final farmer = FarmerModel(
        id: 'farmer456',
        name: 'Jane Smith',
        phoneNumber: '+255723456789',
        email: null,
        nationalId: '09876543210987654321',
        location: 'Dar es Salaam',
        cooperativeId: 'coop456',
        collectionCentreId: 'centre456',
        hasAppAccess: false,
        creditScore: 50.0,
        totalCattle: 0,
        lactatingCattle: 0,
        registeredAt: DateTime(2024, 2, 1),
        photoUrl: null,
        firstName: 'Jane',
        middleName: null,
        surname: 'Smith',
        dateOfBirth: null,
        gender: null,
        locationDetails: null,
        farmAssets: null,
      );

      // Act
      final result = farmer.toFirestore();

      // Assert
      expect(result['email'], isNull);
      expect(result['middleName'], isNull);
      expect(result['dateOfBirth'], isNull);
      expect(result['gender'], isNull);
      expect(result['photoUrl'], isNull);
      expect(result['lastDeliveryDate'], isNull);
      expect(result.containsKey('locationDetails'), false);
      expect(result.containsKey('farmAssets'), false);
    });
  });

  group('Computed fields', () {
    test('should compute name from firstName, middleName, and surname', () {
      // Arrange
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

      final farmer = FarmerModel(
        id: 'farmer123',
        name: 'John Michael Doe',
        phoneNumber: '+255712345678',
        nationalId: '12345678901234567890',
        location: location.fullLocation,
        cooperativeId: 'coop123',
        collectionCentreId: 'centre123',
        hasAppAccess: true,
        creditScore: 75.5,
        totalCattle: 15,
        lactatingCattle: 8,
        registeredAt: DateTime(2024, 1, 1),
        firstName: 'John',
        middleName: 'Michael',
        surname: 'Doe',
        locationDetails: location,
      );

      // Assert
      expect(farmer.name, 'John Michael Doe');
      expect(farmer.location, 'Kaloleni A, Kaloleni, Arusha City, Arusha');
    });

    test('should compute totalCattle from farmAssets', () {
      // Arrange
      final farmAssets = FarmAssets(
        maleCattle: 7,
        femaleCattle: 8,
      );

      final farmer = FarmerModel(
        id: 'farmer123',
        name: 'John Doe',
        phoneNumber: '+255712345678',
        nationalId: '12345678901234567890',
        location: 'Arusha',
        cooperativeId: 'coop123',
        collectionCentreId: 'centre123',
        hasAppAccess: true,
        creditScore: 75.5,
        totalCattle: 15,
        lactatingCattle: 8,
        registeredAt: DateTime(2024, 1, 1),
        firstName: 'John',
        surname: 'Doe',
        farmAssets: farmAssets,
      );

      // Assert
      expect(farmer.totalCattle, 15);
      expect(farmer.farmAssets!.totalCattle, 15); // Computed in FarmAssets
    });
  });
}
