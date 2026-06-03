/**
 * Helper functions for loan management
 */

import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {CreditScoreFactors, InsurancePolicy, LoanRecord} from "./types";

/**
 * Verify that farmer has active insurance coverage
 */
export async function verifyInsurance(
  cooperativeId: string,
  collectionCentreId: string,
  farmerId: string
): Promise<{verified: boolean; policies: InsurancePolicy[]}> {
  try {
    const db = admin.firestore();

    // Get all active insurance policies for the farmer
    const policiesSnapshot = await db
      .collection("cooperatives")
      .doc(cooperativeId)
      .collection("collectionCentres")
      .doc(collectionCentreId)
      .collection("farmers")
      .doc(farmerId)
      .collection("insurancePolicies")
      .where("status", "==", "active")
      .get();

    const policies: InsurancePolicy[] = [];
    policiesSnapshot.forEach((doc) => {
      policies.push(doc.data() as InsurancePolicy);
    });

    // Check if farmer has at least one active policy
    const verified = policies.length > 0;

    logger.info("Insurance verification", {
      farmerId,
      verified,
      policiesCount: policies.length,
    });

    return {verified, policies};
  } catch (error) {
    logger.error("Error verifying insurance", {error, farmerId});
    return {verified: false, policies: []};
  }
}

/**
 * Calculate credit score for a farmer
 * Based on delivery consistency, production volume, herd composition, and repayment history
 */
export async function calculateCreditScore(
  cooperativeId: string,
  collectionCentreId: string,
  farmerId: string
): Promise<number> {
  try {
    const db = admin.firestore();
    const farmerRef = db
      .collection("cooperatives")
      .doc(cooperativeId)
      .collection("collectionCentres")
      .doc(collectionCentreId)
      .collection("farmers")
      .doc(farmerId);

    // Get farmer data
    const farmerDoc = await farmerRef.get();
    if (!farmerDoc.exists) {
      logger.warn("Farmer not found for credit score", {farmerId});
      return 50; // Default neutral score
    }

    const farmer = farmerDoc.data();

    // Calculate delivery consistency (40% weight)
    const deliveryConsistency = await calculateDeliveryConsistency(
      farmerRef,
      90 // Last 90 days
    );

    // Calculate production volume (25% weight)
    const productionVolume = await calculateProductionVolume(
      farmerRef,
      90 // Last 90 days
    );

    // Calculate herd composition (20% weight)
    const herdComposition = calculateHerdComposition(farmer);

    // Calculate repayment history (15% weight)
    const repaymentHistory = await calculateRepaymentHistory(farmerRef);

    // Calculate weighted score
    const factors: CreditScoreFactors = {
      deliveryConsistency,
      productionVolume,
      herdComposition,
      repaymentHistory,
    };

    const score = Math.round(
      deliveryConsistency * 0.40 +
      productionVolume * 0.25 +
      herdComposition * 0.20 +
      repaymentHistory * 0.15
    );

    logger.info("Credit score calculated", {
      farmerId,
      score,
      factors,
    });

    return score;
  } catch (error) {
    logger.error("Error calculating credit score", {error, farmerId});
    return 50; // Default neutral score on error
  }
}

/**
 * Calculate delivery consistency score (0-100)
 */
async function calculateDeliveryConsistency(
  farmerRef: FirebaseFirestore.DocumentReference,
  days: number
): Promise<number> {
  const cutoffDate = new Date();
  cutoffDate.setDate(cutoffDate.getDate() - days);

  const deliveriesSnapshot = await farmerRef
    .collection("milkDeliveries")
    .where("deliveryDate", ">=", admin.firestore.Timestamp.fromDate(cutoffDate))
    .get();

  const deliveryDays = deliveriesSnapshot.size;
  const consistencyRate = (deliveryDays / days) * 100;

  return Math.min(100, consistencyRate);
}

/**
 * Calculate production volume score (0-100)
 */
async function calculateProductionVolume(
  farmerRef: FirebaseFirestore.DocumentReference,
  days: number
): Promise<number> {
  const cutoffDate = new Date();
  cutoffDate.setDate(cutoffDate.getDate() - days);

  const deliveriesSnapshot = await farmerRef
    .collection("milkDeliveries")
    .where("deliveryDate", ">=", admin.firestore.Timestamp.fromDate(cutoffDate))
    .get();

  let totalLiters = 0;
  deliveriesSnapshot.forEach((doc) => {
    const delivery = doc.data();
    totalLiters += delivery.quantityLiters || 0;
  });

  const averageDaily = totalLiters / days;

  // Score based on average daily production
  // 0L = 0, 5L = 50, 10L+ = 100
  const score = Math.min(100, (averageDaily / 10) * 100);

  return score;
}

/**
 * Calculate herd composition score (0-100)
 */
function calculateHerdComposition(farmer: any): number {
  const totalCattle = farmer?.totalCattle || 0;
  const lactatingCattle = farmer?.lactatingCattle || 0;

  if (totalCattle === 0) return 0;

  // Score based on herd size and lactating percentage
  const herdSizeScore = Math.min(50, (totalCattle / 10) * 50); // Max 50 points for 10+ cattle
  const lactatingPercentage = (lactatingCattle / totalCattle) * 100;
  const lactatingScore = Math.min(50, (lactatingPercentage / 60) * 50); // Max 50 points for 60%+ lactating

  return herdSizeScore + lactatingScore;
}

/**
 * Calculate repayment history score (0-100)
 */
async function calculateRepaymentHistory(
  farmerRef: FirebaseFirestore.DocumentReference
): Promise<number> {
  // Get all loans
  const loansSnapshot = await farmerRef.collection("loans").get();

  if (loansSnapshot.empty) {
    return 100; // No loans = perfect score
  }

  let totalLoans = 0;
  let completedLoans = 0;
  let defaultedLoans = 0;

  loansSnapshot.forEach((doc) => {
    const loan = doc.data();
    totalLoans++;

    if (loan.status === "completed") {
      completedLoans++;
    } else if (loan.status === "defaulted") {
      defaultedLoans++;
    }
  });

  // Penalize defaults heavily
  if (defaultedLoans > 0) {
    return Math.max(0, 50 - (defaultedLoans * 25));
  }

  // Reward completed loans
  const completionRate = (completedLoans / totalLoans) * 100;
  return completionRate;
}

/**
 * Determine lending model based on credit score
 */
export function determineLendingModel(creditScore: number): "direct" | "cooperative_intermediated" {
  // Score >= 60: Direct lending (lower risk)
  // Score < 60: Cooperative-intermediated (higher risk)
  return creditScore >= 60 ? "direct" : "cooperative_intermediated";
}

/**
 * Calculate monthly installment amount
 */
export function calculateMonthlyInstallment(
  principalAmount: number,
  interestRate: number,
  termMonths: number,
  interestType: "flat" | "reducing_balance"
): number {
  if (interestType === "flat") {
    // Flat interest: Total interest = Principal × Rate × Term
    const totalInterest = principalAmount * (interestRate / 100) * termMonths;
    const totalRepayment = principalAmount + totalInterest;
    return totalRepayment / termMonths;
  } else {
    // Reducing balance: Use standard loan formula
    const monthlyRate = interestRate / 100;
    const numerator = principalAmount * monthlyRate * Math.pow(1 + monthlyRate, termMonths);
    const denominator = Math.pow(1 + monthlyRate, termMonths) - 1;
    return numerator / denominator;
  }
}

/**
 * Send SMS notification
 */
export async function sendSMS(phoneNumber: string, message: string): Promise<void> {
  // Placeholder implementation
  // TODO: Integrate with Twilio or Africa's Talking
  logger.info("SMS would be sent", {phoneNumber, message});
}

/**
 * Get active loans for a farmer
 */
export async function getActiveLoans(
  cooperativeId: string,
  collectionCentreId: string,
  farmerId: string
): Promise<LoanRecord[]> {
  const db = admin.firestore();

  const loansSnapshot = await db
    .collection("cooperatives")
    .doc(cooperativeId)
    .collection("collectionCentres")
    .doc(collectionCentreId)
    .collection("farmers")
    .doc(farmerId)
    .collection("loans")
    .where("status", "in", ["active", "disbursed"])
    .get();

  const loans: LoanRecord[] = [];
  loansSnapshot.forEach((doc) => {
    loans.push({id: doc.id, ...doc.data()} as LoanRecord);
  });

  return loans;
}
