/**
 * Script to cleanup all milk delivery data
 * Use with caution - this deletes all deliveries!
 * 
 * Usage: node scripts/cleanup-milk-deliveries.js
 */

const admin = require('firebase-admin');
const serviceAccount = require('../serviceAccountKey.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

/**
 * Main function to cleanup milk deliveries
 */
async function cleanupMilkDeliveries() {
  console.log('🧹 Starting cleanup of milk deliveries...\n');

  try {
    const cooperativeId = 'coop_test_001';
    const centreId = 'centre_test_001';
    const cooperativeRef = db.collection('cooperatives').doc(cooperativeId);
    const centreRef = cooperativeRef.collection('collectionCentres').doc(centreId);

    // Get all farmers
    const farmersSnapshot = await centreRef.collection('farmers').get();
    
    if (farmersSnapshot.empty) {
      console.log('ℹ️  No farmers found.');
      process.exit(0);
    }

    console.log(`📊 Found ${farmersSnapshot.size} farmers\n`);
    
    let totalDeleted = 0;
    let farmerCount = 0;

    for (const farmerDoc of farmersSnapshot.docs) {
      farmerCount++;
      const deliveriesSnapshot = await farmerDoc.ref.collection('milkDeliveries').get();
      
      if (!deliveriesSnapshot.empty) {
        // Delete all deliveries for this farmer
        const deletePromises = deliveriesSnapshot.docs.map(doc => doc.ref.delete());
        await Promise.all(deletePromises);
        
        totalDeleted += deliveriesSnapshot.size;
        console.log(`[${farmerCount}/${farmersSnapshot.size}] Deleted ${deliveriesSnapshot.size} deliveries for farmer ${farmerDoc.id}`);

        // Reset last delivery date
        await farmerDoc.ref.update({
          lastDeliveryDate: null,
        });
      } else {
        console.log(`[${farmerCount}/${farmersSnapshot.size}] No deliveries found for farmer ${farmerDoc.id}`);
      }
    }

    console.log(`\n✅ Deleted ${totalDeleted} milk deliveries`);
    console.log('\n🎉 Cleanup completed successfully!\n');

    process.exit(0);
  } catch (error) {
    console.error('❌ Error cleaning up milk deliveries:', error);
    process.exit(1);
  }
}

// Run the script
cleanupMilkDeliveries();
