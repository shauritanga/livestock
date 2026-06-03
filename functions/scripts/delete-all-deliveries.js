#!/usr/bin/env node

/**
 * Script to delete ALL milk deliveries from Firestore
 * Use this before reseeding to ensure clean data
 * 
 * Usage: node functions/scripts/delete-all-deliveries.js
 */

const admin = require('firebase-admin');
const path = require('path');

// Initialize Firebase Admin with service account
const serviceAccountPath = path.join(__dirname, '../serviceAccountKey.json');

try {
  const serviceAccount = require(serviceAccountPath);
  
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });

  console.log('✅ Firebase Admin initialized\n');
} catch (error) {
  console.error('❌ Error: Could not find serviceAccountKey.json');
  console.error('   Please download it from Firebase Console and place it in functions/ directory\n');
  process.exit(1);
}

async function deleteAllDeliveries() {
  const db = admin.firestore();

  console.log('🗑️  Deleting all milk deliveries...\n');
  console.log('⚠️  WARNING: This will delete ALL delivery data!\n');

  try {
    const cooperativeId = 'coop_test_001';
    const centreId = 'centre_test_001';
    
    const cooperativeRef = db.collection('cooperatives').doc(cooperativeId);
    const centreRef = cooperativeRef.collection('collectionCentres').doc(centreId);

    // Get all farmers
    const farmersSnapshot = await centreRef.collection('farmers').get();
    
    if (farmersSnapshot.empty) {
      console.log('❌ No farmers found.');
      process.exit(1);
    }

    let totalDeleted = 0;

    for (const farmerDoc of farmersSnapshot.docs) {
      const farmerId = farmerDoc.id;
      const farmerName = farmerDoc.data().name;

      console.log(`🔍 Processing ${farmerName} (${farmerId})...`);

      // Get all deliveries for this farmer
      const deliveriesSnapshot = await farmerDoc.ref.collection('milkDeliveries').get();
      
      if (deliveriesSnapshot.empty) {
        console.log(`   No deliveries found`);
        continue;
      }

      // Delete in batches of 500 (Firestore limit)
      const batchSize = 500;
      let batch = db.batch();
      let batchCount = 0;
      let farmerTotal = 0;

      for (const deliveryDoc of deliveriesSnapshot.docs) {
        batch.delete(deliveryDoc.ref);
        batchCount++;
        farmerTotal++;

        if (batchCount >= batchSize) {
          await batch.commit();
          console.log(`   Deleted ${batchCount} deliveries...`);
          batch = db.batch();
          batchCount = 0;
        }
      }

      // Commit remaining deletions
      if (batchCount > 0) {
        await batch.commit();
      }

      console.log(`   ✅ Deleted ${farmerTotal} deliveries for ${farmerName}`);
      totalDeleted += farmerTotal;

      // Reset farmer's last delivery date
      await farmerDoc.ref.update({
        lastDeliveryDate: null,
      });
    }

    console.log('\n═══════════════════════════════════════════════════════');
    console.log('✅ DELETION COMPLETED!');
    console.log('═══════════════════════════════════════════════════════');
    console.log(`   Total deliveries deleted: ${totalDeleted}`);
    console.log('═══════════════════════════════════════════════════════\n');
    console.log('💡 You can now run seed-milk-deliveries.js to create fresh data\n');

    process.exit(0);
  } catch (error) {
    console.error('\n❌ Error deleting deliveries:', error);
    process.exit(1);
  }
}

// Run the deletion
deleteAllDeliveries();
