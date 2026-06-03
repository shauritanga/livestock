/**
 * Migration Script: Nested to Flat Firestore Structure
 * 
 * This script migrates data from the nested structure:
 *   cooperatives/{id}/collectionCentres/{id}/farmers/{id}
 * 
 * To the flat structure:
 *   farmers/{id}
 *   milkDeliveries/{id}
 *   cattle/{id}
 *   insurancePolicies/{id}
 * 
 * Features:
 * - Batch processing (500 documents per batch)
 * - Error logging and tracking
 * - Progress reporting
 * - Data integrity verification
 * - Dry-run mode for testing
 * 
 * Usage:
 *   node scripts/migrate-to-flat-structure.js [--dry-run] [--cooperative=<id>]
 * 
 * Options:
 *   --dry-run: Run without making changes (test mode)
 *   --cooperative=<id>: Migrate only specific cooperative
 */

const admin = require('firebase-admin');
const serviceAccount = require('../serviceAccountKey.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Configuration
const BATCH_SIZE = 500;
const DRY_RUN = process.argv.includes('--dry-run');
const SPECIFIC_COOP = process.argv.find(arg => arg.startsWith('--cooperative='))?.split('=')[1];

// Migration statistics
const stats = {
  cooperatives: 0,
  collectionCentres: 0,
  farmers: { total: 0, migrated: 0, errors: 0 },
  milkDeliveries: { total: 0, migrated: 0, errors: 0 },
  cattle: { total: 0, migrated: 0, errors: 0 },
  insurancePolicies: { total: 0, migrated: 0, errors: 0 },
  errors: []
};

/**
 * Log error with context
 */
function logError(collection, documentId, error, context = {}) {
  const errorEntry = {
    collection,
    documentId,
    error: error.message,
    context,
    timestamp: new Date().toISOString()
  };
  stats.errors.push(errorEntry);
  console.error(`❌ Error in ${collection}/${documentId}:`, error.message);
}

/**
 * Migrate farmers from nested to flat structure
 */
async function migrateFarmers(cooperativeId, collectionCentreId) {
  console.log(`\n📋 Migrating farmers for cooperative ${cooperativeId}...`);
  
  try {
    const farmersSnapshot = await db
      .collection('cooperatives').doc(cooperativeId)
      .collection('collectionCentres').doc(collectionCentreId)
      .collection('farmers')
      .get();

    stats.farmers.total += farmersSnapshot.size;
    console.log(`   Found ${farmersSnapshot.size} farmers`);

    if (farmersSnapshot.empty) {
      return [];
    }

    const farmerIds = [];
    let batch = db.batch();
    let batchCount = 0;

    for (const farmerDoc of farmersSnapshot.docs) {
      try {
        const farmerData = farmerDoc.data();
        const farmerId = farmerDoc.id;
        farmerIds.push(farmerId);

        // Remove collectionCentreId from farmer data
        const { collectionCentreId: _, ...cleanedData } = farmerData;

        // Ensure cooperativeId is present
        if (!cleanedData.cooperativeId) {
          cleanedData.cooperativeId = cooperativeId;
        }

        if (!DRY_RUN) {
          const newFarmerRef = db.collection('farmers').doc(farmerId);
          batch.set(newFarmerRef, cleanedData);
          batchCount++;

          // Commit batch if it reaches the limit
          if (batchCount >= BATCH_SIZE) {
            await batch.commit();
            batch = db.batch();
            batchCount = 0;
          }
        }

        stats.farmers.migrated++;
      } catch (error) {
        stats.farmers.errors++;
        logError('farmers', farmerDoc.id, error, { cooperativeId, collectionCentreId });
      }
    }

    // Commit remaining batch
    if (!DRY_RUN && batchCount > 0) {
      await batch.commit();
    }

    console.log(`   ✅ Migrated ${stats.farmers.migrated} farmers`);
    return farmerIds;
  } catch (error) {
    console.error(`   ❌ Error migrating farmers:`, error);
    throw error;
  }
}

/**
 * Migrate milk deliveries from nested to flat structure
 */
async function migrateMilkDeliveries(cooperativeId, collectionCentreId, farmerIds) {
  console.log(`\n🥛 Migrating milk deliveries...`);
  
  let totalDeliveries = 0;

  for (const farmerId of farmerIds) {
    try {
      const deliveriesSnapshot = await db
        .collection('cooperatives').doc(cooperativeId)
        .collection('collectionCentres').doc(collectionCentreId)
        .collection('farmers').doc(farmerId)
        .collection('milkDeliveries')
        .get();

      stats.milkDeliveries.total += deliveriesSnapshot.size;
      totalDeliveries += deliveriesSnapshot.size;

      if (deliveriesSnapshot.empty) {
        continue;
      }

      let batch = db.batch();
      let batchCount = 0;

      for (const deliveryDoc of deliveriesSnapshot.docs) {
        try {
          const deliveryData = deliveryDoc.data();
          const deliveryId = deliveryDoc.id;

          // Remove collectionCentreId from delivery data
          const { collectionCentreId: _, ...cleanedData } = deliveryData;

          // Ensure required fields are present
          if (!cleanedData.farmerId) {
            cleanedData.farmerId = farmerId;
          }
          if (!cleanedData.cooperativeId) {
            cleanedData.cooperativeId = cooperativeId;
          }

          if (!DRY_RUN) {
            const newDeliveryRef = db.collection('milkDeliveries').doc(deliveryId);
            batch.set(newDeliveryRef, cleanedData);
            batchCount++;

            // Commit batch if it reaches the limit
            if (batchCount >= BATCH_SIZE) {
              await batch.commit();
              batch = db.batch();
              batchCount = 0;
            }
          }

          stats.milkDeliveries.migrated++;
        } catch (error) {
          stats.milkDeliveries.errors++;
          logError('milkDeliveries', deliveryDoc.id, error, { cooperativeId, collectionCentreId, farmerId });
        }
      }

      // Commit remaining batch
      if (!DRY_RUN && batchCount > 0) {
        await batch.commit();
      }
    } catch (error) {
      console.error(`   ❌ Error migrating deliveries for farmer ${farmerId}:`, error);
    }
  }

  console.log(`   ✅ Migrated ${stats.milkDeliveries.migrated} milk deliveries`);
}

/**
 * Migrate cattle from nested to flat structure
 */
async function migrateCattle(cooperativeId, collectionCentreId, farmerIds) {
  console.log(`\n🐄 Migrating cattle...`);
  
  let totalCattle = 0;

  for (const farmerId of farmerIds) {
    try {
      const cattleSnapshot = await db
        .collection('cooperatives').doc(cooperativeId)
        .collection('collectionCentres').doc(collectionCentreId)
        .collection('farmers').doc(farmerId)
        .collection('cattle')
        .get();

      stats.cattle.total += cattleSnapshot.size;
      totalCattle += cattleSnapshot.size;

      if (cattleSnapshot.empty) {
        continue;
      }

      let batch = db.batch();
      let batchCount = 0;

      for (const cattleDoc of cattleSnapshot.docs) {
        try {
          const cattleData = cattleDoc.data();
          const cattleId = cattleDoc.id;

          // Ensure required fields are present
          if (!cattleData.farmerId) {
            cattleData.farmerId = farmerId;
          }
          if (!cattleData.cooperativeId) {
            cattleData.cooperativeId = cooperativeId;
          }

          if (!DRY_RUN) {
            const newCattleRef = db.collection('cattle').doc(cattleId);
            batch.set(newCattleRef, cattleData);
            batchCount++;

            // Commit batch if it reaches the limit
            if (batchCount >= BATCH_SIZE) {
              await batch.commit();
              batch = db.batch();
              batchCount = 0;
            }
          }

          stats.cattle.migrated++;
        } catch (error) {
          stats.cattle.errors++;
          logError('cattle', cattleDoc.id, error, { cooperativeId, collectionCentreId, farmerId });
        }
      }

      // Commit remaining batch
      if (!DRY_RUN && batchCount > 0) {
        await batch.commit();
      }
    } catch (error) {
      console.error(`   ❌ Error migrating cattle for farmer ${farmerId}:`, error);
    }
  }

  console.log(`   ✅ Migrated ${stats.cattle.migrated} cattle`);
}

/**
 * Migrate insurance policies from nested to flat structure
 */
async function migrateInsurancePolicies(cooperativeId, collectionCentreId, farmerIds) {
  console.log(`\n🛡️  Migrating insurance policies...`);
  
  let totalPolicies = 0;

  for (const farmerId of farmerIds) {
    try {
      const policiesSnapshot = await db
        .collection('cooperatives').doc(cooperativeId)
        .collection('collectionCentres').doc(collectionCentreId)
        .collection('farmers').doc(farmerId)
        .collection('insurancePolicies')
        .get();

      stats.insurancePolicies.total += policiesSnapshot.size;
      totalPolicies += policiesSnapshot.size;

      if (policiesSnapshot.empty) {
        continue;
      }

      for (const policyDoc of policiesSnapshot.docs) {
        try {
          const policyData = policyDoc.data();
          const policyId = policyDoc.id;

          // Ensure required fields are present
          if (!policyData.farmerId) {
            policyData.farmerId = farmerId;
          }
          if (!policyData.cooperativeId) {
            policyData.cooperativeId = cooperativeId;
          }

          if (!DRY_RUN) {
            const newPolicyRef = db.collection('insurancePolicies').doc(policyId);
            await newPolicyRef.set(policyData);

            // Migrate subcollections (premiumPayments and claims)
            await migrateSubcollection(policyDoc.ref, newPolicyRef, 'premiumPayments');
            await migrateSubcollection(policyDoc.ref, newPolicyRef, 'claims');
          }

          stats.insurancePolicies.migrated++;
        } catch (error) {
          stats.insurancePolicies.errors++;
          logError('insurancePolicies', policyDoc.id, error, { cooperativeId, collectionCentreId, farmerId });
        }
      }
    } catch (error) {
      console.error(`   ❌ Error migrating insurance policies for farmer ${farmerId}:`, error);
    }
  }

  console.log(`   ✅ Migrated ${stats.insurancePolicies.migrated} insurance policies`);
}

/**
 * Migrate subcollection (premiumPayments or claims)
 */
async function migrateSubcollection(oldParentRef, newParentRef, subcollectionName) {
  const subcollectionSnapshot = await oldParentRef.collection(subcollectionName).get();
  
  if (subcollectionSnapshot.empty) {
    return;
  }

  let batch = db.batch();
  let batchCount = 0;

  for (const doc of subcollectionSnapshot.docs) {
    const newDocRef = newParentRef.collection(subcollectionName).doc(doc.id);
    batch.set(newDocRef, doc.data());
    batchCount++;

    if (batchCount >= BATCH_SIZE) {
      await batch.commit();
      batch = db.batch();
      batchCount = 0;
    }
  }

  if (batchCount > 0) {
    await batch.commit();
  }
}

/**
 * Migrate a single collection centre
 */
async function migrateCollectionCentre(cooperativeId, collectionCentreId) {
  console.log(`\n🏢 Migrating collection centre: ${collectionCentreId}`);
  stats.collectionCentres++;

  // Migrate farmers first (returns farmer IDs)
  const farmerIds = await migrateFarmers(cooperativeId, collectionCentreId);

  if (farmerIds.length === 0) {
    console.log(`   ⚠️  No farmers found, skipping related collections`);
    return;
  }

  // Migrate related collections
  await migrateMilkDeliveries(cooperativeId, collectionCentreId, farmerIds);
  await migrateCattle(cooperativeId, collectionCentreId, farmerIds);
  await migrateInsurancePolicies(cooperativeId, collectionCentreId, farmerIds);
}

/**
 * Migrate a single cooperative
 */
async function migrateCooperative(cooperativeId) {
  console.log(`\n🏛️  Migrating cooperative: ${cooperativeId}`);
  stats.cooperatives++;

  try {
    const collectionCentresSnapshot = await db
      .collection('cooperatives').doc(cooperativeId)
      .collection('collectionCentres')
      .get();

    console.log(`   Found ${collectionCentresSnapshot.size} collection centres`);

    for (const centreDoc of collectionCentresSnapshot.docs) {
      await migrateCollectionCentre(cooperativeId, centreDoc.id);
    }
  } catch (error) {
    console.error(`   ❌ Error migrating cooperative ${cooperativeId}:`, error);
    throw error;
  }
}

/**
 * Verify migrated data integrity
 */
async function verifyMigration() {
  console.log(`\n🔍 Verifying migration...`);

  try {
    // Count documents in flat collections
    const farmersCount = (await db.collection('farmers').count().get()).data().count;
    const deliveriesCount = (await db.collection('milkDeliveries').count().get()).data().count;
    const cattleCount = (await db.collection('cattle').count().get()).data().count;
    const policiesCount = (await db.collection('insurancePolicies').count().get()).data().count;

    console.log(`\n📊 Verification Results:`);
    console.log(`   Farmers: ${farmersCount} (expected: ${stats.farmers.total})`);
    console.log(`   Milk Deliveries: ${deliveriesCount} (expected: ${stats.milkDeliveries.total})`);
    console.log(`   Cattle: ${cattleCount} (expected: ${stats.cattle.total})`);
    console.log(`   Insurance Policies: ${policiesCount} (expected: ${stats.insurancePolicies.total})`);

    // Sample verification - check a few documents
    const sampleFarmer = await db.collection('farmers').limit(1).get();
    if (!sampleFarmer.empty) {
      const farmerData = sampleFarmer.docs[0].data();
      console.log(`\n✅ Sample farmer structure:`);
      console.log(`   Has cooperativeId: ${!!farmerData.cooperativeId}`);
      console.log(`   Has collectionCentreId: ${!!farmerData.collectionCentreId} (should be false)`);
    }

    const sampleDelivery = await db.collection('milkDeliveries').limit(1).get();
    if (!sampleDelivery.empty) {
      const deliveryData = sampleDelivery.docs[0].data();
      console.log(`\n✅ Sample milk delivery structure:`);
      console.log(`   Has farmerId: ${!!deliveryData.farmerId}`);
      console.log(`   Has cooperativeId: ${!!deliveryData.cooperativeId}`);
      console.log(`   Has collectionCentreId: ${!!deliveryData.collectionCentreId} (should be false)`);
    }

    return {
      farmersMatch: farmersCount === stats.farmers.total,
      deliveriesMatch: deliveriesCount === stats.milkDeliveries.total,
      cattleMatch: cattleCount === stats.cattle.total,
      policiesMatch: policiesCount === stats.insurancePolicies.total
    };
  } catch (error) {
    console.error(`❌ Error during verification:`, error);
    return null;
  }
}

/**
 * Main migration function
 */
async function runMigration() {
  console.log('🚀 Starting Firestore Migration: Nested to Flat Structure\n');
  console.log(`Mode: ${DRY_RUN ? '🧪 DRY RUN (no changes will be made)' : '⚡ LIVE MIGRATION'}`);
  
  if (SPECIFIC_COOP) {
    console.log(`Scope: Single cooperative (${SPECIFIC_COOP})`);
  } else {
    console.log(`Scope: All cooperatives`);
  }

  const startTime = Date.now();

  try {
    let cooperativeIds = [];

    if (SPECIFIC_COOP) {
      cooperativeIds = [SPECIFIC_COOP];
    } else {
      // Get all cooperatives
      const cooperativesSnapshot = await db.collection('cooperatives').get();
      cooperativeIds = cooperativesSnapshot.docs.map(doc => doc.id);
      console.log(`\nFound ${cooperativeIds.length} cooperatives to migrate`);
    }

    // Migrate each cooperative
    for (const cooperativeId of cooperativeIds) {
      await migrateCooperative(cooperativeId);
    }

    // Verify migration if not dry run
    let verification = null;
    if (!DRY_RUN) {
      verification = await verifyMigration();
    }

    // Print summary
    const duration = ((Date.now() - startTime) / 1000).toFixed(2);
    console.log(`\n${'='.repeat(60)}`);
    console.log(`📈 MIGRATION SUMMARY`);
    console.log(`${'='.repeat(60)}`);
    console.log(`Duration: ${duration}s`);
    console.log(`Mode: ${DRY_RUN ? 'DRY RUN' : 'LIVE'}`);
    console.log(`\nCooperatives: ${stats.cooperatives}`);
    console.log(`Collection Centres: ${stats.collectionCentres}`);
    console.log(`\nFarmers:`);
    console.log(`  Total: ${stats.farmers.total}`);
    console.log(`  Migrated: ${stats.farmers.migrated}`);
    console.log(`  Errors: ${stats.farmers.errors}`);
    console.log(`\nMilk Deliveries:`);
    console.log(`  Total: ${stats.milkDeliveries.total}`);
    console.log(`  Migrated: ${stats.milkDeliveries.migrated}`);
    console.log(`  Errors: ${stats.milkDeliveries.errors}`);
    console.log(`\nCattle:`);
    console.log(`  Total: ${stats.cattle.total}`);
    console.log(`  Migrated: ${stats.cattle.migrated}`);
    console.log(`  Errors: ${stats.cattle.errors}`);
    console.log(`\nInsurance Policies:`);
    console.log(`  Total: ${stats.insurancePolicies.total}`);
    console.log(`  Migrated: ${stats.insurancePolicies.migrated}`);
    console.log(`  Errors: ${stats.insurancePolicies.errors}`);

    if (stats.errors.length > 0) {
      console.log(`\n⚠️  ${stats.errors.length} errors occurred during migration`);
      console.log(`\nError details:`);
      stats.errors.forEach((err, index) => {
        console.log(`\n${index + 1}. ${err.collection}/${err.documentId}`);
        console.log(`   Error: ${err.error}`);
        console.log(`   Context: ${JSON.stringify(err.context)}`);
      });
    }

    if (verification) {
      console.log(`\n✅ Verification:`);
      console.log(`  Farmers: ${verification.farmersMatch ? '✅' : '❌'}`);
      console.log(`  Deliveries: ${verification.deliveriesMatch ? '✅' : '❌'}`);
      console.log(`  Cattle: ${verification.cattleMatch ? '✅' : '❌'}`);
      console.log(`  Policies: ${verification.policiesMatch ? '✅' : '❌'}`);
    }

    console.log(`\n${'='.repeat(60)}`);
    console.log(`✅ Migration completed successfully!`);
    console.log(`${'='.repeat(60)}\n`);

    process.exit(0);
  } catch (error) {
    console.error('\n❌ Migration failed:', error);
    process.exit(1);
  }
}

// Run migration
runMigration();
