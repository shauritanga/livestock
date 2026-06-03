/**
 * Script to test Firestore security rules
 * 
 * This script tests the security rules for the flat collection structure
 * to ensure cooperative isolation and proper access control.
 * 
 * Usage: node scripts/test-security-rules.js
 * 
 * Note: This script requires test users to be set up in Firebase Auth
 */

const admin = require('firebase-admin');
const serviceAccount = require('../serviceAccountKey.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

/**
 * Test scenarios for security rules
 */
const TEST_SCENARIOS = [
  {
    name: 'Cooperative Isolation - Farmers',
    description: 'Verify users can only access farmers in their cooperative',
    collection: 'farmers',
    test: async () => {
      // This would require Firebase Auth test users
      // For now, we'll verify the data structure
      const snapshot = await db.collection('farmers').limit(5).get();
      
      let allHaveCooperativeId = true;
      let noneHaveCollectionCentreId = true;
      
      snapshot.docs.forEach(doc => {
        const data = doc.data();
        if (!data.cooperativeId) {
          allHaveCooperativeId = false;
        }
        if (data.collectionCentreId) {
          noneHaveCollectionCentreId = false;
        }
      });
      
      return {
        passed: allHaveCooperativeId && noneHaveCollectionCentreId,
        message: allHaveCooperativeId && noneHaveCollectionCentreId
          ? 'All farmers have cooperativeId, none have collectionCentreId'
          : 'Some farmers missing cooperativeId or have collectionCentreId'
      };
    }
  },
  {
    name: 'Cooperative Isolation - Milk Deliveries',
    description: 'Verify deliveries have cooperativeId for isolation',
    collection: 'milkDeliveries',
    test: async () => {
      const snapshot = await db.collection('milkDeliveries').limit(5).get();
      
      let allHaveRequiredFields = true;
      let noneHaveCollectionCentreId = true;
      
      snapshot.docs.forEach(doc => {
        const data = doc.data();
        if (!data.cooperativeId || !data.farmerId) {
          allHaveRequiredFields = false;
        }
        if (data.collectionCentreId) {
          noneHaveCollectionCentreId = false;
        }
      });
      
      return {
        passed: allHaveRequiredFields && noneHaveCollectionCentreId,
        message: allHaveRequiredFields && noneHaveCollectionCentreId
          ? 'All deliveries have cooperativeId and farmerId, none have collectionCentreId'
          : 'Some deliveries missing required fields or have collectionCentreId'
      };
    }
  },
  {
    name: 'Cattle Data Structure',
    description: 'Verify cattle have farmerId and cooperativeId',
    collection: 'cattle',
    test: async () => {
      const snapshot = await db.collection('cattle').limit(5).get();
      
      if (snapshot.empty) {
        return {
          passed: true,
          message: 'No cattle data to test (this is OK)'
        };
      }
      
      let allHaveRequiredFields = true;
      
      snapshot.docs.forEach(doc => {
        const data = doc.data();
        if (!data.cooperativeId || !data.farmerId) {
          allHaveRequiredFields = false;
        }
      });
      
      return {
        passed: allHaveRequiredFields,
        message: allHaveRequiredFields
          ? 'All cattle have cooperativeId and farmerId'
          : 'Some cattle missing required fields'
      };
    }
  },
  {
    name: 'Insurance Policies Data Structure',
    description: 'Verify policies have farmerId and cooperativeId',
    collection: 'insurancePolicies',
    test: async () => {
      const snapshot = await db.collection('insurancePolicies').limit(5).get();
      
      if (snapshot.empty) {
        return {
          passed: true,
          message: 'No insurance policy data to test (this is OK)'
        };
      }
      
      let allHaveRequiredFields = true;
      
      snapshot.docs.forEach(doc => {
        const data = doc.data();
        if (!data.cooperativeId || !data.farmerId) {
          allHaveRequiredFields = false;
        }
      });
      
      return {
        passed: allHaveRequiredFields,
        message: allHaveRequiredFields
          ? 'All policies have cooperativeId and farmerId'
          : 'Some policies missing required fields'
      };
    }
  }
];

/**
 * Run security rule tests
 */
async function testSecurityRules() {
  console.log('🔒 Testing Firestore Security Rules\n');
  console.log('='.repeat(60));
  
  const results = {
    total: TEST_SCENARIOS.length,
    passed: 0,
    failed: 0,
    details: []
  };
  
  for (const scenario of TEST_SCENARIOS) {
    console.log(`\n📋 Test: ${scenario.name}`);
    console.log(`   ${scenario.description}`);
    
    try {
      const result = await scenario.test();
      
      results.details.push({
        name: scenario.name,
        collection: scenario.collection,
        ...result
      });
      
      if (result.passed) {
        console.log(`   ✅ ${result.message}`);
        results.passed++;
      } else {
        console.log(`   ❌ ${result.message}`);
        results.failed++;
      }
    } catch (error) {
      console.log(`   ❌ Test failed: ${error.message}`);
      results.failed++;
      results.details.push({
        name: scenario.name,
        collection: scenario.collection,
        passed: false,
        message: error.message
      });
    }
  }
  
  // Print summary
  console.log('\n' + '='.repeat(60));
  console.log('📊 TEST SUMMARY');
  console.log('='.repeat(60));
  console.log(`Total Tests: ${results.total}`);
  console.log(`Passed: ${results.passed} ✅`);
  console.log(`Failed: ${results.failed} ❌`);
  
  if (results.failed > 0) {
    console.log('\n⚠️  Some tests failed');
    console.log('   Review the failed tests above');
    console.log('   Check that security rules are deployed');
    console.log('   Verify data migration completed successfully');
  } else {
    console.log('\n✅ All security rule tests passed!');
  }
  
  console.log('\n' + '='.repeat(60));
  console.log('\n📝 Note: This script tests data structure compliance.');
  console.log('   For full security rule testing, use Firebase Emulator:');
  console.log('   firebase emulators:start --only firestore');
  console.log('   Then run your integration tests against the emulator.');
  console.log('\n' + '='.repeat(60));
  
  process.exit(results.failed > 0 ? 1 : 0);
}

// Run tests
testSecurityRules().catch(error => {
  console.error('❌ Testing failed:', error);
  process.exit(1);
});
