import * as admin from "firebase-admin";

/**
 * Seed data script to create test cooperative, collection centre, and agent
 * Run this once to set up test data for mobile app testing
 */

export async function seedTestData() {
  const db = admin.firestore();
  const auth = admin.auth();

  console.log("🌱 Starting seed data creation...");

  try {
    // 1. Create Test Cooperative
    const cooperativeId = "coop_test_001";
    const cooperativeRef = db.collection("cooperatives").doc(cooperativeId);

    await cooperativeRef.set({
      name: "Nairobi Dairy Cooperative",
      location: "Nairobi, Kenya",
      contactInfo: {
        phone: "+254712345678",
        email: "info@nairobidairy.co.ke",
        address: "Westlands, Nairobi",
      },
      farmerPaymentPrice: 45, // KES per liter paid to farmers
      offtakerSalesPrice: 55, // KES per liter charged to offtakers
      pricingLastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      status: "active",
    });
    console.log("✅ Created cooperative:", cooperativeId);

    // 2. Create Test Collection Centre
    const centreId = "centre_test_001";
    const centreRef = cooperativeRef.collection("collectionCentres").doc(centreId);

    await centreRef.set({
      name: "Westlands Collection Centre",
      location: "Westlands, Nairobi",
      cooperativeId: cooperativeId,
      agentIds: [], // Will be updated after creating agent
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    console.log("✅ Created collection centre:", centreId);

    // 3. Create Test Collection Agent User
    const agentEmail = "agent@test.com";
    const agentPassword = "Test123456";

    let agentUser;
    try {
      // Try to get existing user first
      agentUser = await auth.getUserByEmail(agentEmail);
      console.log("ℹ️  Agent user already exists:", agentUser.uid);
    } catch (error) {
      // Create new user if doesn't exist
      agentUser = await auth.createUser({
        email: agentEmail,
        password: agentPassword,
        displayName: "John Kamau",
        emailVerified: true,
      });
      console.log("✅ Created agent user:", agentUser.uid);
    }

    // 4. Set Custom Claims for Agent
    await auth.setCustomUserClaims(agentUser.uid, {
      role: "collection_agent",
      cooperativeId: cooperativeId,
      collectionCentreId: centreId,
    });
    console.log("✅ Set custom claims for agent");

    // 5. Create User Document in Firestore
    await db.collection("users").doc(agentUser.uid).set({
      email: agentEmail,
      displayName: "John Kamau",
      phoneNumber: "+254712345678",
      role: "collection_agent",
      cooperativeId: cooperativeId,
      collectionCentreId: centreId,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      lastLogin: admin.firestore.FieldValue.serverTimestamp(),
    });
    console.log("✅ Created user document in Firestore");

    // 6. Update Collection Centre with Agent ID
    await centreRef.update({
      agentIds: admin.firestore.FieldValue.arrayUnion(agentUser.uid),
    });
    console.log("✅ Updated collection centre with agent ID");

    // 7. Create Sample Farmers (optional)
    console.log("🌱 Creating sample farmers...");

    const farmers = [
      {
        id: "farmer_001",
        name: "Peter Mwangi",
        phoneNumber: "+254722111222",
        nationalId: "ID12345678",
        location: "Kiambu",
      },
      {
        id: "farmer_002",
        name: "Mary Wanjiku",
        phoneNumber: "+254733222333",
        nationalId: "ID87654321",
        location: "Limuru",
      },
      {
        id: "farmer_003",
        name: "James Omondi",
        phoneNumber: "+254744333444",
        nationalId: "ID11223344",
        location: "Kikuyu",
      },
    ];

    for (const farmer of farmers) {
      const farmerRef = centreRef.collection("farmers").doc(farmer.id);
      await farmerRef.set({
        name: farmer.name,
        phoneNumber: farmer.phoneNumber,
        email: null,
        nationalId: farmer.nationalId,
        location: farmer.location,
        cooperativeId: cooperativeId,
        collectionCentreId: centreId,
        hasAppAccess: false,
        creditScore: 50,
        totalCattle: 0,
        lactatingCattle: 0,
        registeredAt: admin.firestore.FieldValue.serverTimestamp(),
        lastDeliveryDate: null,
      });
      console.log(`✅ Created farmer: ${farmer.name}`);
    }

    console.log("\n🎉 Seed data creation completed successfully!\n");
    console.log("📱 Test Credentials:");
    console.log("   Email: agent@test.com");
    console.log("   Password: Test123456");
    console.log("   Role: Collection Agent");
    console.log("\n📊 Test Data:");
    console.log(`   Cooperative: Nairobi Dairy Cooperative (${cooperativeId})`);
    console.log(`   Collection Centre: Westlands Collection Centre (${centreId})`);
    console.log(`   Sample Farmers: ${farmers.length} farmers created`);
    console.log("\n✨ You can now login to the mobile app with the above credentials!\n");

    return {
      success: true,
      data: {
        cooperativeId,
        centreId,
        agentEmail,
        agentPassword,
        agentUid: agentUser.uid,
      },
    };
  } catch (error) {
    console.error("❌ Error seeding data:", error);
    throw error;
  }
}

/**
 * Clean up test data (use with caution!)
 */
export async function cleanupTestData() {
  const db = admin.firestore();
  const auth = admin.auth();

  console.log("🧹 Starting cleanup of test data...");

  try {
    // Delete test cooperative and all subcollections
    const cooperativeId = "coop_test_001";
    const cooperativeRef = db.collection("cooperatives").doc(cooperativeId);

    // Delete farmers
    const farmersSnapshot = await cooperativeRef
      .collection("collectionCentres")
      .doc("centre_test_001")
      .collection("farmers")
      .get();

    const farmerDeletePromises = farmersSnapshot.docs.map((doc) =>
      doc.ref.delete()
    );
    await Promise.all(farmerDeletePromises);
    console.log("✅ Deleted farmers");

    // Delete collection centre
    await cooperativeRef
      .collection("collectionCentres")
      .doc("centre_test_001")
      .delete();
    console.log("✅ Deleted collection centre");

    // Delete cooperative
    await cooperativeRef.delete();
    console.log("✅ Deleted cooperative");

    // Delete agent user
    try {
      const agentUser = await auth.getUserByEmail("agent@test.com");
      await auth.deleteUser(agentUser.uid);
      await db.collection("users").doc(agentUser.uid).delete();
      console.log("✅ Deleted agent user");
    } catch (error) {
      console.log("ℹ️  Agent user not found or already deleted");
    }

    console.log("\n🎉 Cleanup completed successfully!\n");
  } catch (error) {
    console.error("❌ Error cleaning up data:", error);
    throw error;
  }
}
