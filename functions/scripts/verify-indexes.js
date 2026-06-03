/**
 * Script to verify Firestore indexes are built and enabled
 * 
 * This script checks the status of all required composite indexes
 * for the flat collection structure.
 * 
 * Usage: node scripts/verify-indexes.js
 */

const admin = require('firebase-admin');
const serviceAccount = require('../serviceAccountKey.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Required indexes for flat structure
const REQUIRED_INDEXES = [
  {
    collection: 'farmers',
    fields: ['cooperativeId', 'name'],
    description: 'List farmers by cooperative (sorted by name)'
  },
  {
    collection: 'farmers',
    fields: ['cooperativeId', 'registeredAt'],
    description: 'List farmers by cooperative (sorted by registration date)'
  },
  {
    collection: 'milkDeliveries',
    fields: ['cooperativeId', 'deliveryDate'],
    description: 'Get deliveries by cooperative and date range'
  },
  {
    collection: 'milkDeliveries',
    fields: ['farmerId', 'deliveryDate'],
    description: 'Get delivery history for a farmer'
  },
  {
    collection: 'cattle',
    fields: ['farmerId', 'isActive'],
    description: 'Get active cattle for a farmer'
  },
  {
    collection: 'cattle',
    fields: ['cooperativeId', 'lactationStatus'],
    description: 'Get cattle by cooperative and lactation status'
  },
  {
    collection: 'insurancePolicies',
    fields: ['farmerId', 'status'],
    description: 'Get insurance policies for a farmer by status'
  },
  {
    collection: 'insurancePolicies',
    fields: ['cooperativeId', 'status'],
    description: 'Get insurance policies by cooperative and status'
  }
];

/**
 * Test a specific query to verify index is working
 */
async function testQuery(collection, fields, testData) {
  try {
    console.log(`\n  Testing query: ${collection} where ${fields.join(', ')}`);
    
    let query = db.collection(collection);
    
    // Build query with test data
    if (testData[fields[0]]) {
      query = query.where(fields[0], '==', testData[fields[0]]);
    }
    
    // Add orderBy for second field
    if (fields[1]) {
      query = query.orderBy(fields[1]);
    }
    
    // Limit to 1 for quick test
    query = query.limit(1);
    
    const startTime = Date.now();
    const snapshot = await query.get();
    const duration = Date.now() - startTime;
    
    console.log(`  ✅ Query executed successfully (${duration}ms)`);
    console.log(`  📊 Results: ${snapshot.size} documents`);
    
    return { success: true, duration, count: snapshot.size };
  } catch (error) {
    console.log(`  ❌ Query failed: ${error.message}`);
    
    if (error.message.includes('index')) {
      console.log(`  ⚠️  Index may not be built yet`);
    }
    
    return { success: false, error: error.message };
  }
}

/**
 * Get sample data for testing queries
 */
async function getSampleData() {
  console.log('\n📋 Getting sample data for testing...');
  
  const sampleData = {
    cooperativeId: null,
    farmerId: null
  };
  
  // Get a sample cooperative
  const coopSnapshot = await db.collection('cooperatives').limit(1).get();
  if (!coopSnapshot.empty) {
    sampleData.cooperativeId = coopSnapshot.docs[0].id;
    console.log(`  Found sample cooperative: ${sampleData.cooperativeId}`);
  }
  
  // Get a sample farmer
  const farmerSnapshot = await db.collection('farmers').limit(1).get();
  if (!farmerSnapshot.empty) {
    sampleData.farmerId = farmerSnapshot.docs[0].id;
    console.log(`  Found sample farmer: ${sampleData.farmerId}`);
  }
  
  return sampleData;
}

/**
 * Verify all required indexes
 */
async function verifyIndexes() {
  console.log('🔍 Verifying Firestore Indexes\n');
  console.log('=' .repeat(60));
  
  const results = {
    total: REQUIRED_INDEXES.length,
    passed: 0,
    failed: 0,
    details: []
  };
  
  // Get sample data for testing
  const sampleData = await getSampleData();
  
  console.log('\n' + '='.repeat(60));
  console.log('Testing Required Indexes');
  console.log('='.repeat(60));
  
  for (const index of REQUIRED_INDEXES) {
    console.log(`\n📌 Index: ${index.collection} (${index.fields.join(', ')})`);
    console.log(`   Description: ${index.description}`);
    
    const result = await testQuery(index.collection, index.fields, sampleData);
    
    results.details.push({
      collection: index.collection,
      fields: index.fields,
      description: index.description,
      ...result
    });
    
    if (result.success) {
      results.passed++;
    } else {
      results.failed++;
    }
  }
  
  // Print summary
  console.log('\n' + '='.repeat(60));
  console.log('📊 VERIFICATION SUMMARY');
  console.log('='.repeat(60));
  console.log(`Total Indexes: ${results.total}`);
  console.log(`Passed: ${results.passed} ✅`);
  console.log(`Failed: ${results.failed} ❌`);
  
  if (results.failed > 0) {
    console.log('\n⚠️  Some indexes are not ready or queries failed');
    console.log('   This is normal if indexes are still building');
    console.log('   Check Firebase Console → Firestore → Indexes');
    console.log('   Wait for all indexes to show "Enabled" status');
  } else {
    console.log('\n✅ All indexes are working correctly!');
  }
  
  // Print failed indexes
  if (results.failed > 0) {
    console.log('\n❌ Failed Indexes:');
    results.details
      .filter(r => !r.success)
      .forEach(r => {
        console.log(`\n  ${r.collection} (${r.fields.join(', ')})`);
        console.log(`  Error: ${r.error}`);
      });
  }
  
  console.log('\n' + '='.repeat(60));
  
  process.exit(results.failed > 0 ? 1 : 0);
}

// Run verification
verifyIndexes().catch(error => {
  console.error('❌ Verification failed:', error);
  process.exit(1);
});
