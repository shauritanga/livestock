/**
 * Insurance Cloud Functions
 * Handles insurance enrollment, premium calculations, claims, and notifications
 */

import {onCall, onRequest, HttpsError} from "firebase-functions/v2/https";
import {onDocumentCreated} from "firebase-functions/v2/firestore";
import {onSchedule} from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {
  InsurancePolicy,
  PremiumPayment,
  InsuranceClaim,
  PremiumRate,
  PremiumCalculation,
} from "./types";
import {
  sendSMS,
  notifyInsurancePartner,
  calculateNextPaymentDue,
  calculateCattlePremium,
  getFarmerPhone,
  formatCurrency,
  formatDate,
} from "./helpers";

// ============================================================================
// INSURANCE ENROLLMENT
// ============================================================================

/**
 * Enroll farmer in insurance
 * Creates policy document and sends notifications
 */
export const enrollInsurance = onCall(async (request) => {
  try {
    // Verify authentication
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "User must be authenticated"
      );
    }

    const {
      farmerId,
      cooperativeId,
      collectionCentreId,
      cattleIds,
      totalPremium,
      paymentFrequency,
    } = request.data;

    // Validate inputs
    if (!farmerId || !cattleIds || cattleIds.length === 0) {
      throw new HttpsError(
        "invalid-argument",
        "Invalid enrollment data"
      );
    }

    if (!["monthly", "quarterly"].includes(paymentFrequency)) {
      throw new HttpsError(
        "invalid-argument",
        "Invalid payment frequency"
      );
    }

    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();
    const policyStartDate = now.toDate();
    const policyEndDate = new Date(policyStartDate);
    policyEndDate.setFullYear(policyEndDate.getFullYear() + 1); // 12 months

    // Calculate installment amount
    const installmentAmount = paymentFrequency === "monthly" ?
      totalPremium / 12 :
      totalPremium / 4;

    // Calculate next payment due
    const nextPaymentDue = calculateNextPaymentDue(policyStartDate, paymentFrequency);

    // Create policy document
    const policyRef = db
      .collection("cooperatives").doc(cooperativeId)
      .collection("collectionCentres").doc(collectionCentreId)
      .collection("farmers").doc(farmerId)
      .collection("insurancePolicies").doc();

    const policy: Partial<InsurancePolicy> = {
      policyId: policyRef.id,
      farmerId,
      cooperativeId,
      collectionCentreId,
      insurancePartnerId: "default_partner",
      coveredCattleIds: cattleIds,
      totalPremium,
      installmentAmount,
      paymentFrequency,
      policyStartDate: admin.firestore.Timestamp.fromDate(policyStartDate),
      policyEndDate: admin.firestore.Timestamp.fromDate(policyEndDate),
      status: "active",
      nextPaymentDue: admin.firestore.Timestamp.fromDate(nextPaymentDue),
      totalPaid: 0,
      outstandingPremium: totalPremium,
      createdAt: now,
      updatedAt: now,
      createdBy: request.auth.uid,
    };

    await policyRef.set(policy);

    // Send notification to insurance partner
    await notifyInsurancePartner("/policies", {
      policyId: policyRef.id,
      farmerId,
      cattleIds,
      totalPremium,
      paymentFrequency,
    });

    // Send SMS to farmer
    const farmerPhone = await getFarmerPhone(cooperativeId, collectionCentreId, farmerId);
    if (farmerPhone) {
      const message = `Bima yako imeandikishwa! Nambari: ${policyRef.id.substring(0, 8)}. ` +
        `Malipo: ${formatCurrency(totalPremium)}. Mzunguko: ${paymentFrequency === "monthly" ? "Kila mwezi" : "Kila robo"}. ` +
        `Ng'ombe: ${cattleIds.length}.`;
      await sendSMS(farmerPhone, message);
    }

    logger.info("Insurance policy created", {
      policyId: policyRef.id,
      farmerId,
      cattleCount: cattleIds.length,
    });

    return {
      success: true,
      policyId: policyRef.id,
      message: "Insurance policy created successfully",
    };
  } catch (error: any) {
    logger.error("Error enrolling insurance", {error});
    throw new HttpsError(
      "internal",
      error.message || "Failed to enroll insurance"
    );
  }
});

// ============================================================================
// PREMIUM CALCULATION
// ============================================================================

/**
 * Calculate insurance premium for selected cattle
 */
export const calculatePremium = onCall(async (request) => {
  try {
    // Verify authentication
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "User must be authenticated"
      );
    }

    const {farmerId, cooperativeId, collectionCentreId, cattleIds} = request.data;

    if (!cattleIds || cattleIds.length === 0) {
      throw new HttpsError(
        "invalid-argument",
        "At least one cattle must be selected"
      );
    }

    const db = admin.firestore();

    // Fetch cattle details
    const cattlePromises = cattleIds.map((id: string) =>
      db.collection("cooperatives").doc(cooperativeId)
        .collection("collectionCentres").doc(collectionCentreId)
        .collection("farmers").doc(farmerId)
        .collection("cattle").doc(id).get()
    );

    const cattleDocs = await Promise.all(cattlePromises);
    const cattle = cattleDocs
      .filter((doc) => doc.exists)
      .map((doc) => ({id: doc.id, ...doc.data()}));

    if (cattle.length === 0) {
      throw new HttpsError(
        "not-found",
        "No cattle found"
      );
    }

    // Fetch premium rates
    const ratesSnapshot = await db.collection("premiumRates")
      .where("isActive", "==", true)
      .get();

    const rates: PremiumRate[] = ratesSnapshot.docs.map((doc) => doc.data() as PremiumRate);

    // Calculate premium for each cattle
    const cattlePremiums = cattle.map((c) => calculateCattlePremium(c, rates));

    const totalAnnualPremium = cattlePremiums.reduce((sum, cp) => sum + cp.premium, 0);

    const result: PremiumCalculation = {
      cattlePremiums,
      totalAnnualPremium,
      monthlyInstallment: totalAnnualPremium / 12,
      quarterlyInstallment: totalAnnualPremium / 4,
    };

    logger.info("Premium calculated", {
      farmerId,
      cattleCount: cattle.length,
      totalPremium: totalAnnualPremium,
    });

    return result;
  } catch (error: any) {
    logger.error("Error calculating premium", {error});
    throw new HttpsError(
      "internal",
      error.message || "Failed to calculate premium"
    );
  }
});

// ============================================================================
// PREMIUM DEDUCTION
// ============================================================================

/**
 * Automatically deduct premium from milk payments
 * Triggered when milk delivery is created
 */
export const deductPremium = onDocumentCreated(
  "cooperatives/{cooperativeId}/collectionCentres/{centreId}/farmers/{farmerId}/milkDeliveries/{deliveryId}",
  async (event) => {
    try {
      const delivery = event.data?.data();
      if (!delivery) return null;

      const {cooperativeId, centreId, farmerId, deliveryId} = event.params;

      const db = admin.firestore();
      const now = new Date();

      // Get active policies with due payments
      const policiesSnapshot = await db
        .collection("cooperatives").doc(cooperativeId)
        .collection("collectionCentres").doc(centreId)
        .collection("farmers").doc(farmerId)
        .collection("insurancePolicies")
        .where("status", "==", "active")
        .where("nextPaymentDue", "<=", admin.firestore.Timestamp.fromDate(now))
        .get();

      if (policiesSnapshot.empty) {
        logger.info("No policies with due payments", {farmerId});
        return null;
      }

      // Process first policy with due payment
      const policyDoc = policiesSnapshot.docs[0];
      const policy = policyDoc.data() as InsurancePolicy;
      const policyRef = policyDoc.ref;

      // Calculate deduction amount (don't exceed delivery amount)
      const deductionAmount = Math.min(
        policy.installmentAmount,
        delivery.totalAmount || 0
      );

      if (deductionAmount <= 0) {
        logger.info("Insufficient delivery amount for deduction", {
          farmerId,
          deliveryAmount: delivery.totalAmount,
          installmentAmount: policy.installmentAmount,
        });
        return null;
      }

      // Record payment
      const paymentRef = policyRef.collection("premiumPayments").doc();
      const payment: Partial<PremiumPayment> = {
        paymentId: paymentRef.id,
        policyId: policy.policyId,
        amount: deductionAmount,
        paymentDate: admin.firestore.Timestamp.now(),
        paymentMethod: "milk_deduction",
        milkDeliveryId: deliveryId,
        recordedBy: "system",
      };

      await paymentRef.set(payment);

      // Update policy
      const nextPaymentDue = calculateNextPaymentDue(
        policy.nextPaymentDue.toDate(),
        policy.paymentFrequency
      );

      await policyRef.update({
        totalPaid: admin.firestore.FieldValue.increment(deductionAmount),
        outstandingPremium: admin.firestore.FieldValue.increment(-deductionAmount),
        nextPaymentDue: admin.firestore.Timestamp.fromDate(nextPaymentDue),
        updatedAt: admin.firestore.Timestamp.now(),
      });

      // Send SMS notification
      const farmerPhone = await getFarmerPhone(cooperativeId, centreId, farmerId);
      if (farmerPhone) {
        const message = `Malipo ya bima ya ${formatCurrency(deductionAmount)} yamekatwa. ` +
          `Yanayofuata: ${formatDate(nextPaymentDue)}. Salio: ${formatCurrency(policy.outstandingPremium - deductionAmount)}.`;
        await sendSMS(farmerPhone, message);
      }

      logger.info("Premium deducted", {
        farmerId,
        policyId: policy.policyId,
        amount: deductionAmount,
      });

      return null;
    } catch (error) {
      logger.error("Error deducting premium", {error});
      return null;
    }
  }
);

// ============================================================================
// CLAIM SUBMISSION
// ============================================================================

/**
 * Submit insurance claim for livestock loss
 */
export const submitClaim = onCall(async (request) => {
  try {
    // Verify authentication
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "User must be authenticated"
      );
    }

    const {
      policyId,
      farmerId,
      cooperativeId,
      collectionCentreId,
      cattleId,
      lossType,
      lossDate,
      description,
      supportingDocuments,
    } = request.data;

    // Validate inputs
    if (!policyId || !cattleId || !lossType) {
      throw new HttpsError(
        "invalid-argument",
        "Missing required claim data"
      );
    }

    if (!["death", "theft", "disease"].includes(lossType)) {
      throw new HttpsError(
        "invalid-argument",
        "Invalid loss type"
      );
    }

    const db = admin.firestore();

    // Validate policy is active
    const policyRef = db
      .collection("cooperatives").doc(cooperativeId)
      .collection("collectionCentres").doc(collectionCentreId)
      .collection("farmers").doc(farmerId)
      .collection("insurancePolicies").doc(policyId);

    const policyDoc = await policyRef.get();

    if (!policyDoc.exists) {
      throw new HttpsError(
        "not-found",
        "Policy not found"
      );
    }

    const policy = policyDoc.data() as InsurancePolicy;

    if (policy.status !== "active") {
      throw new HttpsError(
        "failed-precondition",
        "Policy is not active"
      );
    }

    // Check cattle is covered
    if (!policy.coveredCattleIds.includes(cattleId)) {
      throw new HttpsError(
        "failed-precondition",
        "Cattle is not covered by this policy"
      );
    }

    // Check for duplicate claims
    const existingClaimsSnapshot = await policyRef
      .collection("claims")
      .where("cattleId", "==", cattleId)
      .where("status", "in", ["submitted", "under_review", "approved"])
      .get();

    if (!existingClaimsSnapshot.empty) {
      throw new HttpsError(
        "already-exists",
        "A claim already exists for this cattle"
      );
    }

    // Create claim
    const claimRef = policyRef.collection("claims").doc();
    const now = admin.firestore.Timestamp.now();

    const claim: Partial<InsuranceClaim> = {
      claimId: claimRef.id,
      policyId,
      cattleId,
      farmerId,
      lossType,
      lossDate: admin.firestore.Timestamp.fromDate(new Date(lossDate)),
      description: description || "",
      claimAmount: 50000, // Default claim amount - should be calculated based on cattle value
      submittedDate: now,
      status: "submitted",
      statusUpdates: [{
        status: "submitted",
        date: now,
        comment: "Claim submitted",
      }],
      supportingDocuments: supportingDocuments || [],
      submittedBy: request.auth.uid,
    };

    await claimRef.set(claim);

    // Notify insurance partner
    await notifyInsurancePartner("/claims", {
      claimId: claimRef.id,
      policyId,
      cattleId,
      lossType,
      lossDate,
      supportingDocuments,
    });

    // Send SMS to farmer
    const farmerPhone = await getFarmerPhone(cooperativeId, collectionCentreId, farmerId);
    if (farmerPhone) {
      const message = `Madai yako yamewasilishwa! Nambari: ${claimRef.id.substring(0, 8)}. ` +
        `Ng'ombe: ${cattleId.substring(0, 8)}. Tutakujulisha mabadiliko.`;
      await sendSMS(farmerPhone, message);
    }

    logger.info("Claim submitted", {
      claimId: claimRef.id,
      policyId,
      cattleId,
      lossType,
    });

    return {
      success: true,
      claimId: claimRef.id,
      message: "Claim submitted successfully",
    };
  } catch (error: any) {
    logger.error("Error submitting claim", {error});
    throw new HttpsError(
      "internal",
      error.message || "Failed to submit claim"
    );
  }
});

// ============================================================================
// CLAIM STATUS UPDATE (WEBHOOK)
// ============================================================================

/**
 * Update claim status from insurance partner
 * Webhook endpoint for partner API
 */
export const updateClaimStatus = onRequest(async (req, res) => {
  try {
    // Verify API key
    const apiKey = req.headers["x-api-key"];
    // TODO: Configure API key in Firebase config
    const expectedApiKey = process.env.INSURANCE_API_KEY || "test-api-key";
    if (!apiKey || apiKey !== expectedApiKey) {
      res.status(401).send({error: "Unauthorized"});
      return;
    }

    const {claimId, status, settlementAmount, comments} = req.body;

    if (!claimId || !status) {
      res.status(400).send({error: "Missing required fields"});
      return;
    }

    const db = admin.firestore();

    // Find claim by ID (search across all policies)
    const claimsQuery = await db.collectionGroup("claims")
      .where("claimId", "==", claimId)
      .limit(1)
      .get();

    if (claimsQuery.empty) {
      res.status(404).send({error: "Claim not found"});
      return;
    }

    const claimDoc = claimsQuery.docs[0];
    const claim = claimDoc.data() as InsuranceClaim;
    const claimRef = claimDoc.ref;

    // Update claim
    const now = admin.firestore.Timestamp.now();
    const updateData: any = {
      status,
      updatedAt: now,
      statusUpdates: admin.firestore.FieldValue.arrayUnion({
        status,
        date: now,
        comment: comments || `Status updated to ${status}`,
      }),
    };

    if (settlementAmount) {
      updateData.settlementAmount = settlementAmount;
    }

    if (status === "settled") {
      updateData.settlementDate = now;
    }

    if (comments) {
      updateData.reviewComments = comments;
    }

    await claimRef.update(updateData);

    // Send SMS notification based on status
    const farmerPhone = await getFarmerPhone(
      claim.farmerId.split("/")[0], // Extract cooperativeId
      claim.farmerId.split("/")[1], // Extract collectionCentreId
      claim.farmerId
    );

    if (farmerPhone) {
      let message = "";
      switch (status) {
      case "approved":
        message = `Madai yako yameidhinishwa! Nambari: ${claimId.substring(0, 8)}. ` +
            `Kiasi: ${formatCurrency(settlementAmount || claim.claimAmount)}.`;
        break;
      case "rejected":
        message = `Madai yako yamekataliwa. Nambari: ${claimId.substring(0, 8)}. ` +
            `Sababu: ${comments || "Hakuna maelezo"}.`;
        break;
      case "settled":
        message = `Madai yako yamelipwa! Nambari: ${claimId.substring(0, 8)}. ` +
            `Kiasi: ${formatCurrency(settlementAmount || claim.claimAmount)}.`;
        break;
      default:
        message = `Madai yako: ${claimId.substring(0, 8)}. Hali: ${status}.`;
      }
      await sendSMS(farmerPhone, message);
    }

    logger.info("Claim status updated", {claimId, status});

    res.status(200).send({
      success: true,
      message: "Claim status updated successfully",
    });
  } catch (error: any) {
    logger.error("Error updating claim status", {error});
    res.status(500).send({error: error.message || "Internal server error"});
  }
});

// ============================================================================
// SCHEDULED FUNCTIONS
// ============================================================================

/**
 * Check for expiring policies and send reminders
 * Runs daily at 9 AM EAT
 */
export const checkExpiringPolicies = onSchedule(
  {
    schedule: "0 9 * * *",
    timeZone: "Africa/Nairobi",
  },
  async (event) => {
    try {
      const db = admin.firestore();
      const now = new Date();
      const thirtyDaysFromNow = new Date(now);
      thirtyDaysFromNow.setDate(thirtyDaysFromNow.getDate() + 30);

      // Query policies expiring within 30 days
      const policiesSnapshot = await db.collectionGroup("insurancePolicies")
        .where("status", "==", "active")
        .where("policyEndDate", "<=", admin.firestore.Timestamp.fromDate(thirtyDaysFromNow))
        .where("policyEndDate", ">", admin.firestore.Timestamp.fromDate(now))
        .get();

      logger.info(`Found ${policiesSnapshot.size} expiring policies`);

      for (const policyDoc of policiesSnapshot.docs) {
        const policy = policyDoc.data() as InsurancePolicy;
        const daysUntilExpiry = Math.ceil(
          (policy.policyEndDate.toDate().getTime() - now.getTime()) / (1000 * 60 * 60 * 24)
        );

        // Send SMS to farmer
        const farmerPhone = await getFarmerPhone(
          policy.cooperativeId,
          policy.collectionCentreId,
          policy.farmerId
        );

        if (farmerPhone) {
          const message = `Bima yako itaisha baada ya siku ${daysUntilExpiry}. ` +
            `Nambari: ${policy.policyId.substring(0, 8)}. Tafadhali fanya upya.`;
          await sendSMS(farmerPhone, message);
        }

        logger.info("Expiry reminder sent", {
          policyId: policy.policyId,
          daysUntilExpiry,
        });
      }

      return;
    } catch (error) {
      logger.error("Error checking expiring policies", {error});
      return;
    }
  }
);

/**
 * Check for overdue premiums and suspend policies
 * Runs daily
 */
export const checkOverduePremiums = onSchedule(
  {
    schedule: "0 10 * * *",
    timeZone: "Africa/Nairobi",
  },
  async (event) => {
    try {
      const db = admin.firestore();
      const now = new Date();
      const thirtyDaysAgo = new Date(now);
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

      // Query policies with overdue premiums > 30 days
      const policiesSnapshot = await db.collectionGroup("insurancePolicies")
        .where("status", "==", "active")
        .where("nextPaymentDue", "<", admin.firestore.Timestamp.fromDate(thirtyDaysAgo))
        .get();

      logger.info(`Found ${policiesSnapshot.size} policies with overdue premiums`);

      for (const policyDoc of policiesSnapshot.docs) {
        const policy = policyDoc.data() as InsurancePolicy;

        // Update policy status to suspended
        await policyDoc.ref.update({
          status: "suspended",
          updatedAt: admin.firestore.Timestamp.now(),
        });

        // Send SMS to farmer
        const farmerPhone = await getFarmerPhone(
          policy.cooperativeId,
          policy.collectionCentreId,
          policy.farmerId
        );

        if (farmerPhone) {
          const message = "Bima yako imesimamishwa kwa sababu ya malipo yaliyochelewa. " +
            `Nambari: ${policy.policyId.substring(0, 8)}. Lipa ${formatCurrency(policy.outstandingPremium)}.`;
          await sendSMS(farmerPhone, message);
        }

        logger.info("Policy suspended for overdue premium", {
          policyId: policy.policyId,
        });
      }

      return;
    } catch (error) {
      logger.error("Error checking overdue premiums", {error});
      return;
    }
  }
);
