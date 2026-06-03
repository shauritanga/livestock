/**
 * Script to seed milk delivery data from January 1, 2025 to November 23, 2025
 * This will query ALL cooperatives and collection centers and generate deliveries
 * for all existing farmers.
 * 
 * Usage: node scripts/seed-milk-deliveries.js
 * 
 * Note: This will take several minutes to complete as it generates ~11 months of data
 */

const admin = require('firebase-admin');
const serviceAccount = require('../serviceAccountKey.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

/**
 * Create a single milk delivery with realistic data
 */
async function createDelivery(centreRef, farmer, cooperativeId, centreId, deliveryDate, timeOfDay) {
  const farmerRef = centreRef.collection('farmers').doc(farmer.id);
  const deliveryRef = farmerRef.collection('milkDeliveries').doc();

  // Generate realistic quantity (morning deliveries are typically larger)
  // IMPORTANT: Quantities must be in 0.5L increments (0.5, 1.0, 1.5, 2.0, etc.)
  const baseQuantity = timeOfDay === 'morning' ? 15 : 8;
  const variation = Math.random() * 10 - 5; // +/- 5 liters
  const rawQuantity = Math.max(5, baseQuantity + variation); // Minimum 5 liters
  
  // Round to nearest 0.5L increment
  const quantity = Math.round(rawQuantity * 2) / 2;

  // Quality grade distribution: 70% standard, 20% premium, 10% substandard
  const qualityRandom = Math.random();
  let qualityGrade;
  if (qualityRandom < 0.2) {
    qualityGrade = 'premium';
  } else if (qualityRandom < 0.9) {
    qualityGrade = 'standard';
  } else {
    qualityGrade = 'substandard';
  }

  // Calculate price based on quality
  const basePrice = 1200; // TZS per liter (Tanzania)
  const qualityMultiplier = qualityGrade === 'premium' ? 1.1 : qualityGrade === 'substandard' ? 0.9 : 1.0;
  const pricePerLiter = basePrice * qualityMultiplier;
  const totalAmount = quantity * pricePerLiter;

  // Create delivery document
  await deliveryRef.set({
    farmerId: farmer.id,
    cattleId: null,
    cooperativeId: cooperativeId,
    collectionCentreId: centreId,
    quantityLiters: quantity, // Already rounded to 0.5L increment
    qualityGrade: qualityGrade,
    pricePerLiter: parseFloat(pricePerLiter.toFixed(2)),
    totalAmount: parseFloat(totalAmount.toFixed(2)),
    deliveryDate: admin.firestore.Timestamp.fromDate(deliveryDate),
    recordedBy: 'seed_script',
    createdAt: admin.firestore.Timestamp.fromDate(deliveryDate),
  });

  // Update farmer's last delivery date
  await farmerRef.update({
    lastDeliveryDate: admin.firestore.Timestamp.fromDate(deliveryDate),
  });
}

/**
 * Main function to seed milk deliveries from January 2025 to today
 */
async function seedMilkDeliveries() {
  console.log('🥛 Starting milk delivery data seeding from January 2025 to today...\n');

  try {
    // Get all cooperatives
    const cooperativesSnapshot = await db.collection('cooperatives').get();
    
    if (cooperativesSnapshot.empty) {
      console.log('❌ No cooperatives found. Please add cooperatives first.');
      process.exit(1);
    }

    console.log(`📊 Found ${cooperativesSnapshot.size} cooperatives\n`);

    let totalFarmers = 0;
    let totalDeliveries = 0;

    // Date range: January 1, 2025 to November 23, 2025
    const startDate = new Date('2025-01-01');
    const endDate = new Date('2025-11-23');
    const totalDays = Math.ceil((endDate.getTime() - startDate.getTime()) / (1000 * 60 * 60 * 24)) + 1;

    console.log(`📅 Generating deliveries for ${totalDays} days (Jan 1 - Nov 23, 2025)\n`);

    // Process each cooperative
    for (const coopDoc of cooperativesSnapshot.docs) {
      const cooperativeId = coopDoc.id;
      console.log(`🏢 Processing cooperative: ${cooperativeId}`);

      // Get all collection centres in this cooperative
      const centresSnapshot = await coopDoc.ref.collection('collectionCentres').get();

      if (centresSnapshot.empty) {
        console.log(`   ⚠️  No collection centres found in ${cooperativeId}\n`);
        continue;
      }

      console.log(`   📍 Found ${centresSnapshot.size} collection centres`);

      // Process each collection centre
      for (const centreDoc of centresSnapshot.docs) {
        const centreId = centreDoc.id;
        console.log(`   📍 Processing centre: ${centreId}`);

        // Get all farmers in this centre
        const farmersSnapshot = await centreDoc.ref.collection('farmers').get();

        if (farmersSnapshot.empty) {
          console.log(`      ⚠️  No farmers found in ${centreId}`);
          continue;
        }

        const farmers = farmersSnapshot.docs.map(doc => ({
          id: doc.id,
          ...doc.data()
        }));

        totalFarmers += farmers.length;
        console.log(`      👨‍🌾 Found ${farmers.length} farmers`);
        console.log(`      🔄 Generating ${totalDays} days of deliveries...`);

        // Generate deliveries for each day
        let centreDeliveries = 0;
        for (let dayOffset = 0; dayOffset < totalDays; dayOffset++) {
          const deliveryDate = new Date(startDate);
          deliveryDate.setDate(startDate.getDate() + dayOffset);
          deliveryDate.setHours(6, 0, 0, 0); // Morning delivery time

          // Each farmer delivers 1-2 times per day with some randomness
          for (const farmer of farmers) {
            // 80% chance of delivery on any given day
            if (Math.random() < 0.8) {
              // Morning delivery
              await createDelivery(
                centreDoc.ref,
                farmer,
                cooperativeId,
                centreId,
                deliveryDate,
                'morning'
              );
              centreDeliveries++;

              // 40% chance of evening delivery
              if (Math.random() < 0.4) {
                const eveningDate = new Date(deliveryDate);
                eveningDate.setHours(18, 0, 0, 0);
                
                await createDelivery(
                  centreDoc.ref,
                  farmer,
                  cooperativeId,
                  centreId,
                  eveningDate,
                  'evening'
                );
                centreDeliveries++;
              }
            }
          }

          // Progress indicator every 30 days
          if ((dayOffset + 1) % 30 === 0) {
            const progress = Math.round(((dayOffset + 1) / totalDays) * 100);
            console.log(`      [${progress}%] Progress: ${dayOffset + 1}/${totalDays} days completed`);
          }
        }

        totalDeliveries += centreDeliveries;
        console.log(`      ✅ Created ${centreDeliveries} deliveries for ${centreId}\n`);
      }
    }

    const avgDeliveriesPerDay = (totalDeliveries / totalDays).toFixed(1);

    console.log('🎉 Milk delivery seeding completed successfully!\n');
    console.log('📊 Statistics:');
    console.log(`   Total Farmers: ${totalFarmers}`);
    console.log(`   Total Deliveries: ${totalDeliveries}`);
    console.log(`   Average per Day: ${avgDeliveriesPerDay}`);
    console.log(`   Days Seeded: ${totalDays}`);
    console.log(`   Date Range: ${startDate.toDateString()} to ${endDate.toDateString()}`);
    console.log('\n✨ You can now see the collection trends on the dashboard!\n');

    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding milk deliveries:', error);
    process.exit(1);
  }
}

// Run the script
seedMilkDeliveries();
