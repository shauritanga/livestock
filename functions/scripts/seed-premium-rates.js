/**
 * Seed Premium Rates Script
 * Populates the premiumRates collection with initial insurance premium data
 * 
 * Usage: node functions/scripts/seed-premium-rates.js
 */

const admin = require('firebase-admin');
const serviceAccount = require('../serviceAccountKey.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function seedPremiumRates() {
  try {
    console.log('Starting premium rates seeding...');

    const now = admin.firestore.Timestamp.now();

    // Define premium rates for different cattle characteristics
    const rates = [
      // Young cattle (0-24 months) - Lower risk
      {
        cattleAgeRange: {min: 0, max: 24},
        breedCategory: 'local',
        healthStatus: 'healthy',
        baseRate: 5000,
        effectiveDate: now,
        createdBy: 'system',
        isActive: true,
      },
      {
        cattleAgeRange: {min: 0, max: 24},
        breedCategory: 'crossbreed',
        healthStatus: 'healthy',
        baseRate: 7000,
        effectiveDate: now,
        createdBy: 'system',
        isActive: true,
      },
      {
        cattleAgeRange: {min: 0, max: 24},
        breedCategory: 'exotic',
        healthStatus: 'healthy',
        baseRate: 10000,
        effectiveDate: now,
        createdBy: 'system',
        isActive: true,
      },

      // Prime age cattle (25-60 months) - Optimal productivity
      {
        cattleAgeRange: {min: 25, max: 60},
        breedCategory: 'local',
        healthStatus: 'healthy',
        baseRate: 6000,
        effectiveDate: now,
        createdBy: 'system',
        isActive: true,
      },
      {
        cattleAgeRange: {min: 25, max: 60},
        breedCategory: 'crossbreed',
        healthStatus: 'healthy',
        baseRate: 8000,
        effectiveDate: now,
        createdBy: 'system',
        isActive: true,
      },
      {
        cattleAgeRange: {min: 25, max: 60},
        breedCategory: 'exotic',
        healthStatus: 'healthy',
        baseRate: 12000,
        effectiveDate: now,
        createdBy: 'system',
        isActive: true,
      },

      // Older cattle (61-120 months) - Higher risk
      {
        cattleAgeRange: {min: 61, max: 120},
        breedCategory: 'local',
        healthStatus: 'healthy',
        baseRate: 7000,
        effectiveDate: now,
        createdBy: 'system',
        isActive: true,
      },
      {
        cattleAgeRange: {min: 61, max: 120},
        breedCategory: 'crossbreed',
        healthStatus: 'healthy',
        baseRate: 9000,
        effectiveDate: now,
        createdBy: 'system',
        isActive: true,
      },
      {
        cattleAgeRange: {min: 61, max: 120},
        breedCategory: 'exotic',
        healthStatus: 'healthy',
        baseRate: 13000,
        effectiveDate: now,
        createdBy: 'system',
        isActive: true,
      },

      // Fair health status - Increased rates
      {
        cattleAgeRange: {min: 0, max: 24},
        breedCategory: 'local',
        healthStatus: 'fair',
        baseRate: 6000,
        effectiveDate: now,
        createdBy: 'system',
        isActive: true,
      },
      {
        cattleAgeRange: {min: 25, max: 60},
        breedCategory: 'local',
        healthStatus: 'fair',
        baseRate: 7500,
        effectiveDate: now,
        createdBy: 'system',
        isActive: true,
      },
      {
        cattleAgeRange: {min: 61, max: 120},
        breedCategory: 'local',
        healthStatus: 'fair',
        baseRate: 9000,
        effectiveDate: now,
        createdBy: 'system',
        isActive: true,
      },

      // Poor health status - Significantly increased rates
      {
        cattleAgeRange: {min: 0, max: 24},
        breedCategory: 'local',
        healthStatus: 'poor',
        baseRate: 8000,
        effectiveDate: now,
        createdBy: 'system',
        isActive: true,
      },
      {
        cattleAgeRange: {min: 25, max: 60},
        breedCategory: 'local',
        healthStatus: 'poor',
        baseRate: 10000,
        effectiveDate: now,
        createdBy: 'system',
        isActive: true,
      },
      {
        cattleAgeRange: {min: 61, max: 120},
        breedCategory: 'local',
        healthStatus: 'poor',
        baseRate: 12000,
        effectiveDate: now,
        createdBy: 'system',
        isActive: true,
      },

      // Crossbreed fair health
      {
        cattleAgeRange: {min: 25, max: 60},
        breedCategory: 'crossbreed',
        healthStatus: 'fair',
        baseRate: 10000,
        effectiveDate: now,
        createdBy: 'system',
        isActive: true,
      },

      // Exotic fair health
      {
        cattleAgeRange: {min: 25, max: 60},
        breedCategory: 'exotic',
        healthStatus: 'fair',
        baseRate: 15000,
        effectiveDate: now,
        createdBy: 'system',
        isActive: true,
      },
    ];

    // Create batch write
    const batch = db.batch();
    let count = 0;

    for (const rate of rates) {
      const rateRef = db.collection('premiumRates').doc();
      const rateData = {
        ...rate,
        rateId: rateRef.id,
      };
      batch.set(rateRef, rateData);
      count++;
    }

    await batch.commit();

    console.log(`✅ Successfully seeded ${count} premium rates`);
    console.log('\nPremium Rate Summary:');
    console.log('- Age ranges: 0-24, 25-60, 61-120 months');
    console.log('- Breed categories: local, crossbreed, exotic');
    console.log('- Health statuses: healthy, fair, poor');
    console.log('- Base rates: TZS 5,000 - 15,000 per cattle annually');

    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding premium rates:', error);
    process.exit(1);
  }
}

// Run the seeding function
seedPremiumRates();
