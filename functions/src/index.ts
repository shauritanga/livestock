/**
 * Agripoa Platform Cloud Functions
 *
 * This file contains all Cloud Functions for the Agripoa platform including:
 * - User management (farmer credential creation)
 * - SMS notifications (delivery confirmations)
 * - Payment calculations
 * - Transaction recording
 */

import {setGlobalOptions} from "firebase-functions/v2";
import {onCall, HttpsError} from "firebase-functions/v2/https";
import {onDocumentCreated} from "firebase-functions/v2/firestore";
import {beforeUserCreated} from "firebase-functions/v2/identity";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";

// Initialize Firebase Admin
admin.initializeApp();

// Set global options for cost control
setGlobalOptions({maxInstances: 10});

// ============================================================================
// USER MANAGEMENT FUNCTIONS
// ============================================================================

/**
 * Trigger: When a new user is created
 * Purpose: Assign custom claims based on role
 */
export const onUserCreate = beforeUserCreated(async (event) => {
  try {
    const user = event.data;
    if (!user) return;

    logger.info("New user created", {uid: user.uid, email: user.email});

    // Get user document from Firestore to determine role
    const userDoc = await admin.firestore()
      .collection("users")
      .doc(user.uid)
      .get();

    if (!userDoc.exists) {
      logger.warn("User document not found", {uid: user.uid});
      return;
    }

    const userData = userDoc.data();
    const customClaims: Record<string, any> = {
      role: userData?.role || "farmer",
    };

    // Add cooperative and collection centre IDs if available
    if (userData?.cooperativeId) {
      customClaims.cooperativeId = userData.cooperativeId;
    }
    if (userData?.collectionCentreId) {
      customClaims.collectionCentreId = userData.collectionCentreId;
    }

    // Set custom claims
    await admin.auth().setCustomUserClaims(user.uid, customClaims);

    logger.info("Custom claims set", {uid: user.uid, claims: customClaims});
  } catch (error) {
    logger.error("Error setting custom claims", {error});
  }
});

/**
 * HTTP Function: Create farmer account with credentials
 * Purpose: Generate temporary password and send via SMS
 */
export const createFarmerAccount = onCall(async (request) => {
  try {
    // Verify caller is authenticated and has permission
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "Must be authenticated to create farmer accounts"
      );
    }

    const {phoneNumber, name, cooperativeId, collectionCentreId} = request.data;

    // Validate input
    if (!phoneNumber || !name || !cooperativeId || !collectionCentreId) {
      throw new HttpsError(
        "invalid-argument",
        "Missing required fields"
      );
    }

    // Generate temporary password
    const tempPassword = generateTemporaryPassword();

    // Create user account
    const userRecord = await admin.auth().createUser({
      phoneNumber: phoneNumber,
      password: tempPassword,
      displayName: name,
    });

    // Create user document in Firestore
    await admin.firestore().collection("users").doc(userRecord.uid).set({
      phoneNumber: phoneNumber,
      displayName: name,
      role: "farmer",
      cooperativeId: cooperativeId,
      collectionCentreId: collectionCentreId,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      requirePasswordChange: true,
    });

    // Send SMS with credentials (placeholder - integrate with SMS provider)
    await sendSMS(phoneNumber,
      `Welcome to Agripoa! Your temporary password is: ${tempPassword}. ` +
      "Please change it on first login."
    );

    logger.info("Farmer account created", {
      uid: userRecord.uid,
      phoneNumber: phoneNumber,
    });

    return {
      success: true,
      uid: userRecord.uid,
      message: "Farmer account created successfully",
    };
  } catch (error: any) {
    logger.error("Error creating farmer account", {error});
    throw new HttpsError(
      "internal",
      error.message || "Failed to create farmer account"
    );
  }
});

// ============================================================================
// SMS NOTIFICATION FUNCTIONS
// ============================================================================

/**
 * Firestore Trigger: Send SMS when milk delivery is recorded
 * Purpose: Notify farmer of delivery confirmation and payment
 */
export const onMilkDeliveryCreated = onDocumentCreated(
  "cooperatives/{cooperativeId}/collectionCentres/{centreId}/farmers/{farmerId}/milkDeliveries/{deliveryId}",
  async (event) => {
    try {
      const delivery = event.data?.data();
      if (!delivery) return;

      const {farmerId} = event.params;

      // Get farmer details
      const farmerDoc = await admin.firestore()
        .collection("cooperatives")
        .doc(event.params.cooperativeId)
        .collection("collectionCentres")
        .doc(event.params.centreId)
        .collection("farmers")
        .doc(farmerId)
        .get();

      if (!farmerDoc.exists) {
        logger.warn("Farmer not found", {farmerId});
        return;
      }

      const farmer = farmerDoc.data();
      const phoneNumber = farmer?.phoneNumber;

      if (!phoneNumber) {
        logger.warn("Farmer has no phone number", {farmerId});
        return;
      }

      // Format SMS message
      const message =
        "Agripoa: Milk delivery recorded! " +
        `Quantity: ${delivery.quantityLiters}L, ` +
        `Payment: KES ${delivery.totalAmount.toFixed(2)}. ` +
        "Thank you!";

      // Send SMS
      await sendSMS(phoneNumber, message);

      logger.info("Delivery SMS sent", {
        farmerId,
        deliveryId: event.data?.id,
        phoneNumber,
      });
    } catch (error) {
      logger.error("Error sending delivery SMS", {error});
    }
  }
);

/**
 * HTTP Function: Send password reset SMS
 * Purpose: Send password reset link via SMS
 */
export const sendPasswordResetSMS = onCall(async (request) => {
  try {
    const {phoneNumber} = request.data;

    if (!phoneNumber) {
      throw new HttpsError(
        "invalid-argument",
        "Phone number is required"
      );
    }

    // Generate password reset link
    const resetLink = await admin.auth().generatePasswordResetLink(phoneNumber);

    // Send SMS
    await sendSMS(
      phoneNumber,
      `Agripoa: Reset your password using this link: ${resetLink}`
    );

    logger.info("Password reset SMS sent", {phoneNumber});

    return {success: true, message: "Password reset SMS sent"};
  } catch (error: any) {
    logger.error("Error sending password reset SMS", {error});
    throw new HttpsError(
      "internal",
      error.message || "Failed to send password reset SMS"
    );
  }
});

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

/**
 * Generate a random temporary password
 */
function generateTemporaryPassword(): string {
  const length = 8;
  const charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  let password = "";
  for (let i = 0; i < length; i++) {
    password += charset.charAt(Math.floor(Math.random() * charset.length));
  }
  return password;
}

/**
 * Send SMS using configured SMS provider
 * TODO: Integrate with Twilio or Africa's Talking
 */
async function sendSMS(phoneNumber: string, message: string): Promise<void> {
  // Placeholder implementation
  // In production, integrate with SMS provider:

  // Option 1: Twilio
  // const twilio = require('twilio');
  // const client = twilio(accountSid, authToken);
  // await client.messages.create({
  //   body: message,
  //   from: twilioPhoneNumber,
  //   to: phoneNumber
  // });

  // Option 2: Africa's Talking
  // const AfricasTalking = require('africastalking');
  // const sms = AfricasTalking(credentials).SMS;
  // await sms.send({
  //   to: [phoneNumber],
  //   message: message
  // });

  logger.info("SMS would be sent", {phoneNumber, message});

  // For now, just log the SMS
  // Remove this in production and uncomment actual SMS sending above
}

// ============================================================================
// SEED DATA FUNCTIONS (FOR TESTING)
// ============================================================================

// Import seed functions
import {seedMilkDeliveries as seedDeliveries} from "./seedMilkDeliveries";
import {cleanupMilkDeliveries as cleanupMilkDeliveriesFunc} from "./seedMilkDeliveries";

// Import insurance functions
import {
  enrollInsurance as enrollInsuranceFunc,
  calculatePremium as calculatePremiumFunc,
  deductPremium as deductPremiumFunc,
  submitClaim as submitClaimFunc,
  updateClaimStatus as updateClaimStatusFunc,
  checkExpiringPolicies as checkExpiringPoliciesFunc,
  checkOverduePremiums as checkOverduePremiumsFunc,
} from "./insurance";
import {
  seedPremiumRates as seedPremiumRatesFunc,
  cleanupPremiumRates as cleanupPremiumRatesFunc,
} from "./insurance/seedPremiumRates";

// Import loan functions
import {
  processLoanApplication as processLoanApplicationFunc,
  disburseLoan as disburseLoanFunc,
  deductLoanRepayment as deductLoanRepaymentFunc,
  processManualRepayment as processManualRepaymentFunc,
} from "./loans";

// Import analytics functions
import {
  calculateMilkProductionMetrics as calculateMilkProductionMetricsFunc,
  calculateFarmerDemographics as calculateFarmerDemographicsFunc,
  calculateLivestockMetrics as calculateLivestockMetricsFunc,
  calculateFinancialMetrics as calculateFinancialMetricsFunc,
  calculateInventoryMetrics as calculateInventoryMetricsFunc,
  generateComparativeAnalytics as generateComparativeAnalyticsFunc,
  generatePredictiveAnalytics as generatePredictiveAnalyticsFunc,
  generateReport as generateReportFunc,
  scheduledReportGenerator as scheduledReportGeneratorFunc,
  alertGenerator as alertGeneratorFunc,
} from "./analytics";

// Export insurance functions
export const enrollInsurance = enrollInsuranceFunc;
export const calculatePremium = calculatePremiumFunc;
export const deductPremium = deductPremiumFunc;
export const submitClaim = submitClaimFunc;
export const updateClaimStatus = updateClaimStatusFunc;
export const checkExpiringPolicies = checkExpiringPoliciesFunc;
export const checkOverduePremiums = checkOverduePremiumsFunc;

// Export loan functions
export const processLoanApplication = processLoanApplicationFunc;
export const disburseLoan = disburseLoanFunc;
export const deductLoanRepayment = deductLoanRepaymentFunc;
export const processManualRepayment = processManualRepaymentFunc;

// Export analytics functions
export const calculateMilkProductionMetrics = calculateMilkProductionMetricsFunc;
export const calculateFarmerDemographics = calculateFarmerDemographicsFunc;
export const calculateLivestockMetrics = calculateLivestockMetricsFunc;
export const calculateFinancialMetrics = calculateFinancialMetricsFunc;
export const calculateInventoryMetrics = calculateInventoryMetricsFunc;
export const generateComparativeAnalytics = generateComparativeAnalyticsFunc;
export const generatePredictiveAnalytics = generatePredictiveAnalyticsFunc;
export const generateReport = generateReportFunc;
export const scheduledReportGenerator = scheduledReportGeneratorFunc;
export const alertGenerator = alertGeneratorFunc;

/**
 * HTTP Callable Function to seed test data
 * Purpose: Create test cooperative, collection centre, and agent for testing
 * Usage: Call once to set up test environment
 */
export const seedTestData = onCall(async (request) => {
  try {
    // Only allow authenticated users to seed data
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "Must be authenticated to seed data"
      );
    }

    logger.info("Starting seed data creation");

    const db = admin.firestore();
    const auth = admin.auth();

    // 1. Create Test Cooperative
    const cooperativeId = "coop_test_001";
    const cooperativeRef = db.collection("cooperatives").doc(cooperativeId);

    await cooperativeRef.set({
      name: "Dar es Salaam Dairy Cooperative",
      location: "Dar es Salaam, Tanzania",
      contactInfo: {
        phone: "+255712345678",
        email: "info@dardairy.co.tz",
        address: "Kinondoni, Dar es Salaam",
      },
      farmerPaymentPrice: 1200, // TZS per liter paid to farmers
      offtakerSalesPrice: 1500, // TZS per liter charged to offtakers
      pricingLastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      status: "active",
    });

    // 2. Create Test Collection Centre
    const centreId = "centre_test_001";
    const centreRef = cooperativeRef.collection("collectionCentres").doc(centreId);

    await centreRef.set({
      name: "Kinondoni Collection Centre",
      location: "Kinondoni, Dar es Salaam",
      cooperativeId: cooperativeId,
      agentIds: [],
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // 3. Create Test Collection Agent User
    const agentEmail = "agent@test.com";
    const agentPassword = "Test123456";

    let agentUser;
    try {
      agentUser = await auth.getUserByEmail(agentEmail);
      logger.info("Agent user already exists", {uid: agentUser.uid});
    } catch (error) {
      agentUser = await auth.createUser({
        email: agentEmail,
        password: agentPassword,
        displayName: "Juma Mwinyimkuu",
        emailVerified: true,
      });
      logger.info("Created agent user", {uid: agentUser.uid});
    }

    // 4. Set Custom Claims for Agent
    await auth.setCustomUserClaims(agentUser.uid, {
      role: "collection_agent",
      cooperativeId: cooperativeId,
      collectionCentreId: centreId,
    });

    // 5. Create User Document in Firestore
    await db.collection("users").doc(agentUser.uid).set({
      email: agentEmail,
      displayName: "Juma Mwinyimkuu",
      phoneNumber: "+255712345678",
      role: "collection_agent",
      cooperativeId: cooperativeId,
      collectionCentreId: centreId,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      lastLogin: admin.firestore.FieldValue.serverTimestamp(),
    });

    // 6. Update Collection Centre with Agent ID
    await centreRef.update({
      agentIds: admin.firestore.FieldValue.arrayUnion(agentUser.uid),
    });

    // 7. Create Sample Farmers
    const farmers = [
      {
        id: "farmer_001",
        name: "Hassan Mbwana",
        phoneNumber: "+255754111222",
        nationalId: "TZ12345678",
        location: "Bagamoyo",
      },
      {
        id: "farmer_002",
        name: "Fatuma Ally",
        phoneNumber: "+255765222333",
        nationalId: "TZ87654321",
        location: "Kibaha",
      },
      {
        id: "farmer_003",
        name: "Omari Selemani",
        phoneNumber: "+255776333444",
        nationalId: "TZ11223344",
        location: "Morogoro",
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
    }

    logger.info("Seed data creation completed");

    return {
      success: true,
      message: "Test data created successfully",
      credentials: {
        email: agentEmail,
        password: agentPassword,
        role: "collection_agent",
      },
      data: {
        cooperativeId,
        centreId,
        agentUid: agentUser.uid,
        farmersCount: farmers.length,
      },
    };
  } catch (error: any) {
    logger.error("Error seeding data", {error});
    throw new HttpsError(
      "internal",
      error.message || "Failed to seed data"
    );
  }
});


/**
 * HTTP Callable Function to seed milk delivery data
 * Purpose: Create sample milk deliveries for the past 30 days
 * Usage: Call after seedTestData to populate dashboard with data
 */
export const seedMilkDeliveries = onCall(async (request) => {
  try {
    // Only allow authenticated users to seed data
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "Must be authenticated to seed data"
      );
    }

    logger.info("Starting milk delivery seeding");

    const result = await seedDeliveries();

    logger.info("Milk delivery seeding completed", result);

    return result;
  } catch (error: any) {
    logger.error("Error seeding milk deliveries", {error});
    throw new HttpsError(
      "internal",
      error.message || "Failed to seed milk deliveries"
    );
  }
});

/**
 * HTTP Callable Function to cleanup milk delivery data
 * Purpose: Remove all milk deliveries (for testing)
 * Usage: Use with caution - deletes all delivery data
 */
export const cleanupMilkDeliveries = onCall(async (request) => {
  try {
    // Only allow authenticated users to cleanup data
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "Must be authenticated to cleanup data"
      );
    }

    logger.info("Starting milk delivery cleanup");

    const result = await cleanupMilkDeliveriesFunc();

    logger.info("Milk delivery cleanup completed", result);

    return result;
  } catch (error: any) {
    logger.error("Error cleaning up milk deliveries", {error});
    throw new HttpsError(
      "internal",
      error.message || "Failed to cleanup milk deliveries"
    );
  }
});

// ============================================================================
// INSURANCE SEED DATA FUNCTIONS
// ============================================================================

/**
 * HTTP Callable Function to seed premium rates
 * Purpose: Populate premiumRates collection with initial data
 * Usage: Call once to set up insurance premium rates
 */
export const seedPremiumRates = onCall(async (request) => {
  try {
    // Only allow authenticated users to seed data
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "Must be authenticated to seed data"
      );
    }

    logger.info("Starting premium rates seeding");

    const result = await seedPremiumRatesFunc();

    logger.info("Premium rates seeding completed", result);

    return result;
  } catch (error: any) {
    logger.error("Error seeding premium rates", {error});
    throw new HttpsError(
      "internal",
      error.message || "Failed to seed premium rates"
    );
  }
});

/**
 * HTTP Callable Function to cleanup premium rates
 * Purpose: Remove all premium rates (for testing)
 * Usage: Use with caution - deletes all premium rate data
 */
export const cleanupPremiumRates = onCall(async (request) => {
  try {
    // Only allow authenticated users to cleanup data
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "Must be authenticated to cleanup data"
      );
    }

    logger.info("Starting premium rates cleanup");

    const result = await cleanupPremiumRatesFunc();

    logger.info("Premium rates cleanup completed", result);

    return result;
  } catch (error: any) {
    logger.error("Error cleaning up premium rates", {error});
    throw new HttpsError(
      "internal",
      error.message || "Failed to cleanup premium rates"
    );
  }
});
