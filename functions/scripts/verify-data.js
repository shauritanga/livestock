/**
 * Script to verify the seeded data structure
 * This helps debug why data might not show on the dashboard
 * 
 * Usage: node scripts/verify-data.js
 */

const admin = require('firebase-admin');
const serviceAccount = require('../serviceAccountKey.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function verifyData() {
  console.log('🔍 Verifying seeded data structure...\n');

  try {
    const cooperativeId = 'coop_test_001';
    const centreId = 'centre_test_001';

    // Check cooperative
    const coopDoc = await db.collection('cooperatives').doc(cooperativeId).get();
    console.log(`✅ Cooperative exists: ${coopDoc.exists}`);
    if (coopDoc.exists) {
      console.log(`   Name: ${coopDoc.data().name}`);
    }

    // Check collection centre
    const centreDoc = await db
      .collection('cooperatives').doc(cooperativeId)
      .collection('collectionCentres').doc(centreId)
      .get();
    console.log(`✅ Collection Centre exists: ${centreDoc.exists}`);
    if (centreDoc.exists) {
      console.log(`   Name: ${centreDoc.data().name}`);
    }

    // Check farmers
    const farmersSnapshot = await db
      .collection('cooperatives').doc(cooperativeId)
      .collection('collectionCentres').doc(centreId)
      .collection('farmers')
      .get();
    console.log(`✅ Farmers count: ${farmersSnapshot.size}`);

    // Check deliveries for each farmer
    let totalDeliveries = 0;
    let todayDeliveries = 0;
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    for (const farmerDoc of farmersSnapshot.docs) {
      const deliveriesSnapshot = await farmerDoc.ref.collection('milkDeliveries').get();
      totalDeliveries += deliveriesSnapshot.size;

      // Count today's deliveries
      for (const deliveryDoc of deliveriesSnapshot.docs) {
        const deliveryData = deliveryDoc.data();
        const deliveryDate = deliveryData.deliveryDate.toDate();
        deliveryDate.setHours(0, 0, 0, 0);
        
        if (deliveryDate.getTime() === today.getTime()) {
          todayDeliveries++;
        }
      }

      console.log(`   Farmer ${farmerDoc.data().name}: ${deliveriesSnapshot.size} deliveries`);
    }

    console.log(`\n📊 Total deliveries: ${totalDeliveries}`);
    console.log(`📅 Today's deliveries: ${todayDeliveries}`);

    // Sample a delivery to check structure
    if (farmersSnapshot.size > 0) {
      const firstFarmer = farmersSnapshot.docs[0];
      const sampleDelivery = await firstFarmer.ref.collection('milkDeliveries').limit(1).get();
      
      if (!sampleDelivery.empty) {
        console.log('\n📦 Sample delivery structure:');
        const deliveryData = sampleDelivery.docs[0].data();
        console.log(JSON.stringify(deliveryData, null, 2));
      }
    }

    // Check user
    const usersSnapshot = await db.collection('users').where('email', '==', 'agent@test.com').get();
    if (!usersSnapshot.empty) {
      const userData = usersSnapshot.docs[0].data();
      console.log('\n👤 Test agent user:');
      console.log(`   Email: ${userData.email}`);
      console.log(`   Role: ${userData.role}`);
      console.log(`   Cooperative ID: ${userData.cooperativeId}`);
      console.log(`   Collection Centre ID: ${userData.collectionCentreId}`);
    }

    console.log('\n✅ Data verification complete!\n');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error verifying data:', error);
    process.exit(1);
  }
}

verifyData();
