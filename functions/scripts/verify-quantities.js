#!/usr/bin/env node

/**
 * Script to verify all milk quantities are in 0.5L increments
 * Run this to check if there are any invalid quantities in Firestore
 * 
 * Usage: node functions/scripts/verify-quantities.js
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

/**
 * Check if a quantity is valid (in 0.5L increments)
 */
function isValidQuantity(quantity) {
  const remainder = (quantity * 10) % 5;
  return remainder === 0;
}

async function verifyQuantities() {
  const db = admin.firestore();

  console.log('🔍 Verifying milk delivery quantities...\n');

  try {
    const cooperativeId = 'coop_test_001';
    const centreId = 'centre_test_001';
    
    const cooperativeRef = db.collection('cooperatives').doc(cooperativeId);
    const centreRef = cooperativeRef.collection('collectionCentres').doc(centreId);

    // Get all farmers
    const farmersSnapshot = await centreRef.collection('farmers').get();
    
    let totalDeliveries = 0;
    let invalidDeliveries = 0;
    const invalidRecords = [];
    const quantitySummary = {};

    for (const farmerDoc of farmersSnapshot.docs) {
      const farmerId = farmerDoc.id;
      const farmerName = farmerDoc.data().name;

      // Get all deliveries for this farmer
      const deliveriesSnapshot = await farmerDoc.ref.collection('milkDeliveries').get();
      
      for (const deliveryDoc of deliveriesSnapshot.docs) {
        totalDeliveries++;
        const delivery = deliveryDoc.data();
        const quantity = delivery.quantityLiters;

        // Track quantity distribution
        const quantityKey = quantity.toFixed(1);
        quantitySummary[quantityKey] = (quantitySummary[quantityKey] || 0) + 1;

        // Check if quantity is valid
        if (!isValidQuantity(quantity)) {
          invalidDeliveries++;
          invalidRecords.push({
            id: deliveryDoc.id,
            farmerId: farmerId,
            farmerName: farmerName,
            quantity: quantity,
            date: delivery.deliveryDate?.toDate?.() || 'Unknown',
          });
        }
      }
    }

    console.log('═══════════════════════════════════════════════════════');
    console.log('📊 VERIFICATION RESULTS:');
    console.log('═══════════════════════════════════════════════════════');
    console.log(`   Total deliveries: ${totalDeliveries}`);
    console.log(`   Valid deliveries: ${totalDeliveries - invalidDeliveries}`);
    console.log(`   Invalid deliveries: ${invalidDeliveries}`);
    console.log('═══════════════════════════════════════════════════════\n');

    if (invalidDeliveries > 0) {
      console.log('❌ INVALID QUANTITIES FOUND:\n');
      invalidRecords.forEach((record, index) => {
        console.log(`${index + 1}. ${record.farmerName} (${record.farmerId})`);
        console.log(`   Quantity: ${record.quantity}L`);
        console.log(`   Date: ${record.date}`);
        console.log(`   Delivery ID: ${record.id}\n`);
      });
    } else {
      console.log('✅ All quantities are valid (in 0.5L increments)!\n');
    }

    // Show quantity distribution
    console.log('📈 QUANTITY DISTRIBUTION:');
    console.log('═══════════════════════════════════════════════════════');
    const sortedQuantities = Object.keys(quantitySummary).sort((a, b) => parseFloat(a) - parseFloat(b));
    sortedQuantities.forEach(qty => {
      const count = quantitySummary[qty];
      const isValid = isValidQuantity(parseFloat(qty));
      const status = isValid ? '✅' : '❌';
      console.log(`   ${status} ${qty}L: ${count} deliveries`);
    });
    console.log('═══════════════════════════════════════════════════════\n');

    // Calculate total volume
    let totalVolume = 0;
    for (const farmerDoc of farmersSnapshot.docs) {
      const deliveriesSnapshot = await farmerDoc.ref.collection('milkDeliveries').get();
      deliveriesSnapshot.docs.forEach(doc => {
        totalVolume += doc.data().quantityLiters;
      });
    }

    console.log('📊 SUMMARY:');
    console.log(`   Total volume: ${totalVolume.toFixed(1)}L`);
    console.log(`   Average per delivery: ${(totalVolume / totalDeliveries).toFixed(1)}L`);
    console.log(`   Decimal check: ${totalVolume} (raw value)`);
    
    // Check if total has unexpected decimals
    const decimalPart = (totalVolume * 10) % 10;
    if (decimalPart !== 0 && decimalPart !== 5) {
      console.log(`   ⚠️  WARNING: Total volume has unexpected decimal: .${decimalPart}`);
      console.log(`   This suggests some quantities are not in 0.5L increments!`);
    }
    
    console.log('\n');

    process.exit(0);
  } catch (error) {
    console.error('\n❌ Error verifying quantities:', error);
    process.exit(1);
  }
}

// Run the verification
verifyQuantities();
