#!/usr/bin/env node

/**
 * Script to fix invalid milk quantities in Firestore
 * Finds all deliveries with quantities not in 0.5L increments and rounds them
 * 
 * Usage: node functions/scripts/fix-invalid-quantities.js
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

/**
 * Round quantity to nearest 0.5L increment
 */
function roundToHalfLiter(quantity) {
  return Math.round(quantity * 2) / 2;
}

/**
 * Recalculate total amount based on new quantity
 */
function recalculateTotalAmount(quantity, pricePerLiter) {
  return quantity * pricePerLiter;
}

async function fixInvalidQuantities() {
  const db = admin.firestore();

  console.log('🔍 Searching for milk deliveries with invalid quantities...\n');

  try {
    // Get all cooperatives
    const cooperativesSnapshot = await db.collection('cooperatives').get();
    
    let totalDeliveries = 0;
    let invalidDeliveries = 0;
    let fixedDeliveries = 0;
    const invalidRecords = [];

    for (const coopDoc of cooperativesSnapshot.docs) {
      const cooperativeId = coopDoc.id;
      console.log(`📦 Checking cooperative: ${cooperativeId}`);

      // Get all collection centres
      const centresSnapshot = await coopDoc.ref.collection('collectionCentres').get();

      for (const centreDoc of centresSnapshot.docs) {
        const centreId = centreDoc.id;
        console.log(`  📍 Checking collection centre: ${centreId}`);

        // Get all milk deliveries
        const deliveriesSnapshot = await centreDoc.ref.collection('milkDeliveries').get();
        
        for (const deliveryDoc of deliveriesSnapshot.docs) {
          totalDeliveries++;
          const delivery = deliveryDoc.data();
          const quantity = delivery.quantityLiters;

          // Check if quantity is valid
          if (!isValidQuantity(quantity)) {
            invalidDeliveries++;
            const roundedQuantity = roundToHalfLiter(quantity);
            const newTotalAmount = recalculateTotalAmount(roundedQuantity, delivery.pricePerLiter);

            invalidRecords.push({
              id: deliveryDoc.id,
              path: deliveryDoc.ref.path,
              farmerId: delivery.farmerId,
              originalQuantity: quantity,
              roundedQuantity: roundedQuantity,
              originalAmount: delivery.totalAmount,
              newAmount: newTotalAmount,
              deliveryDate: delivery.deliveryDate?.toDate?.() || 'Unknown',
            });

            console.log(`    ⚠️  Invalid quantity found: ${quantity}L → ${roundedQuantity}L`);
          }
        }
      }
    }

    console.log('\n═══════════════════════════════════════════════════════');
    console.log('📊 SCAN RESULTS:');
    console.log('═══════════════════════════════════════════════════════');
    console.log(`   Total deliveries scanned: ${totalDeliveries}`);
    console.log(`   Invalid quantities found: ${invalidDeliveries}`);
    console.log('═══════════════════════════════════════════════════════\n');

    if (invalidDeliveries === 0) {
      console.log('✅ No invalid quantities found. All data is clean!\n');
      process.exit(0);
    }

    // Display invalid records
    console.log('📋 INVALID RECORDS:\n');
    invalidRecords.forEach((record, index) => {
      console.log(`${index + 1}. Delivery ID: ${record.id}`);
      console.log(`   Farmer ID: ${record.farmerId}`);
      console.log(`   Date: ${record.deliveryDate}`);
      console.log(`   Quantity: ${record.originalQuantity}L → ${record.roundedQuantity}L`);
      console.log(`   Amount: ${record.originalAmount.toFixed(2)} → ${record.newAmount.toFixed(2)}`);
      console.log(`   Path: ${record.path}\n`);
    });

    // Ask for confirmation
    console.log('⚠️  WARNING: This will update the above records in Firestore.');
    console.log('   Quantities will be rounded to the nearest 0.5L increment.');
    console.log('   Total amounts will be recalculated based on the new quantities.\n');

    // In a real scenario, you'd want to add a confirmation prompt here
    // For now, we'll proceed with the fix
    console.log('🔧 Proceeding with fixes...\n');

    // Fix each invalid record
    const batch = db.batch();
    let batchCount = 0;

    for (const record of invalidRecords) {
      const docRef = db.doc(record.path);
      
      batch.update(docRef, {
        quantityLiters: record.roundedQuantity,
        totalAmount: record.newAmount,
      });

      batchCount++;
      fixedDeliveries++;

      // Firestore batch limit is 500 operations
      if (batchCount >= 500) {
        await batch.commit();
        console.log(`   ✅ Committed batch of ${batchCount} updates`);
        batchCount = 0;
      }
    }

    // Commit remaining updates
    if (batchCount > 0) {
      await batch.commit();
      console.log(`   ✅ Committed final batch of ${batchCount} updates`);
    }

    console.log('\n═══════════════════════════════════════════════════════');
    console.log('✅ FIX COMPLETED SUCCESSFULLY!');
    console.log('═══════════════════════════════════════════════════════');
    console.log(`   Total deliveries fixed: ${fixedDeliveries}`);
    console.log('═══════════════════════════════════════════════════════\n');

    process.exit(0);
  } catch (error) {
    console.error('\n❌ Error fixing quantities:', error);
    process.exit(1);
  }
}

// Run the fix function
fixInvalidQuantities();
