import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

/// Script to seed Tanzania geographical data to Firestore
/// 
/// This script reads data.json and uploads it to:
/// Collection: locations
/// Document: tz_geo_2025
/// 
/// Usage: dart run scripts/seed_locations.dart
Future<void> main() async {
  print('🌍 Tanzania Geographical Data Seeding Script');
  print('=' * 50);
  
  try {
    // Initialize Firebase
    print('\n📱 Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
    
    // Read data.json file
    print('\n📖 Reading data.json file...');
    final file = File('data.json');
    if (!await file.exists()) {
      print('❌ Error: data.json file not found!');
      exit(1);
    }
    
    final jsonString = await file.readAsString();
    final data = json.decode(jsonString) as Map<String, dynamic>;
    print('✅ Data loaded successfully');
    
    // Display data statistics
    print('\n📊 Data Statistics:');
    print('   - Regions: ${(data['regions'] as Map).length}');
    print('   - Districts: ${(data['districts'] as Map).length}');
    print('   - Wards: ${(data['wards'] as Map).length}');
    print('   - Villages: ${(data['villages'] as Map).length}');
    
    // Get Firestore instance
    final firestore = FirebaseFirestore.instance;
    
    // Upload to Firestore
    print('\n🔄 Uploading to Firestore...');
    print('   Collection: locations');
    print('   Document: tz_geo_2025');
    
    await firestore
        .collection('locations')
        .doc('tz_geo_2025')
        .set(data, SetOptions(merge: false));
    
    print('✅ Data uploaded successfully!');
    
    // Verify the upload
    print('\n🔍 Verifying upload...');
    final doc = await firestore
        .collection('locations')
        .doc('tz_geo_2025')
        .get();
    
    if (doc.exists) {
      final uploadedData = doc.data() as Map<String, dynamic>;
      print('✅ Verification successful!');
      print('   - Document exists: ${doc.exists}');
      print('   - Regions in Firestore: ${(uploadedData['regions'] as Map).length}');
      print('   - Districts in Firestore: ${(uploadedData['districts'] as Map).length}');
      print('   - Wards in Firestore: ${(uploadedData['wards'] as Map).length}');
      print('   - Villages in Firestore: ${(uploadedData['villages'] as Map).length}');
      print('   - Last updated: ${uploadedData['updatedAt']}');
    } else {
      print('⚠️  Warning: Document not found after upload');
    }
    
    print('\n' + '=' * 50);
    print('🎉 Seeding completed successfully!');
    print('=' * 50);
    
  } catch (e, stackTrace) {
    print('\n❌ Error occurred during seeding:');
    print('   $e');
    print('\n📋 Stack trace:');
    print('   $stackTrace');
    exit(1);
  }
  
  exit(0);
}
