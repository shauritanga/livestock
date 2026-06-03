/**
 * Script to seed Tanzania geographical data to Firestore
 * 
 * This script reads data.json and uploads it to:
 * Collection: locations
 * Document: tz_geo_2025
 * 
 * Prerequisites:
 * 1. Install Firebase Admin SDK: npm install firebase-admin
 * 2. Download your Firebase service account key JSON file
 * 3. Set GOOGLE_APPLICATION_CREDENTIALS environment variable
 * 
 * Usage: 
 * export GOOGLE_APPLICATION_CREDENTIALS="path/to/serviceAccountKey.json"
 * node scripts/seed_locations.js
 */

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

console.log('🌍 Tanzania Geographical Data Seeding Script');
console.log('='.repeat(50));

async function seedData() {
  try {
    // Initialize Firebase Admin
    console.log('\n📱 Initializing Firebase Admin...');
    
    // Check if service account key is set
    if (!process.env.GOOGLE_APPLICATION_CREDENTIALS) {
      console.log('⚠️  GOOGLE_APPLICATION_CREDENTIALS not set');
      console.log('   Attempting to use default credentials...');
    }
    
    admin.initializeApp({
      credential: admin.credential.applicationDefault()
    });
    
    console.log('✅ Firebase Admin initialized successfully');
    
    // Read data.json file
    console.log('\n📖 Reading data.json file...');
    const dataPath = path.join(__dirname, '..', 'data.json');
    
    if (!fs.existsSync(dataPath)) {
      console.log('❌ Error: data.json file not found at:', dataPath);
      process.exit(1);
    }
    
    const jsonData = fs.readFileSync(dataPath, 'utf8');
    const data = JSON.parse(jsonData);
    console.log('✅ Data loaded successfully');
    
    // Display data statistics
    console.log('\n📊 Data Statistics:');
    console.log(`   - Regions: ${Object.keys(data.regions).length}`);
    console.log(`   - Districts: ${Object.keys(data.districts).length}`);
    console.log(`   - Wards: ${Object.keys(data.wards).length}`);
    console.log(`   - Villages: ${Object.keys(data.villages).length}`);
    
    // Get Firestore instance
    const db = admin.firestore();
    
    // Upload to Firestore
    console.log('\n🔄 Uploading to Firestore...');
    console.log('   Collection: locations');
    console.log('   Document: tz_geo_2025');
    
    await db.collection('locations').doc('tz_geo_2025').set(data);
    
    console.log('✅ Data uploaded successfully!');
    
    // Verify the upload
    console.log('\n🔍 Verifying upload...');
    const doc = await db.collection('locations').doc('tz_geo_2025').get();
    
    if (doc.exists) {
      const uploadedData = doc.data();
      console.log('✅ Verification successful!');
      console.log(`   - Document exists: ${doc.exists}`);
      console.log(`   - Regions in Firestore: ${Object.keys(uploadedData.regions).length}`);
      console.log(`   - Districts in Firestore: ${Object.keys(uploadedData.districts).length}`);
      console.log(`   - Wards in Firestore: ${Object.keys(uploadedData.wards).length}`);
      console.log(`   - Villages in Firestore: ${Object.keys(uploadedData.villages).length}`);
      console.log(`   - Last updated: ${uploadedData.updatedAt}`);
    } else {
      console.log('⚠️  Warning: Document not found after upload');
    }
    
    console.log('\n' + '='.repeat(50));
    console.log('🎉 Seeding completed successfully!');
    console.log('='.repeat(50));
    
    process.exit(0);
    
  } catch (error) {
    console.log('\n❌ Error occurred during seeding:');
    console.log(`   ${error.message}`);
    if (error.stack) {
      console.log('\n📋 Stack trace:');
      console.log(error.stack);
    }
    process.exit(1);
  }
}

// Run the seeding function
seedData();
