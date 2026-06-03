/**
 * Insurance Helper Functions
 * Common utility functions for insurance operations
 */

import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {PremiumRate, CattlePremium} from "./types";

/**
 * Send SMS notification
 * TODO: Integrate with actual SMS provider (Twilio/Africa's Talking)
 */
export async function sendSMS(phoneNumber: string, message: string): Promise<void> {
  // Placeholder implementation
  logger.info("SMS would be sent", {phoneNumber, message});

  // In production, integrate with SMS provider:
  // const AfricasTalking = require('africastalking');
  // const sms = AfricasTalking(credentials).SMS;
  // await sms.send({ to: [phoneNumber], message });
}

/**
 * Send notification to insurance partner API
 * TODO: Integrate with actual insurance partner API
 */
export async function notifyInsurancePartner(
  endpoint: string,
  data: any
): Promise<void> {
  // Placeholder implementation
  logger.info("Insurance partner notification", {endpoint, data});

  // In production, make HTTP request to partner API:
  // const response = await fetch(partnerApiUrl + endpoint, {
  //   method: 'POST',
  //   headers: { 'Authorization': `Bearer ${apiKey}` },
  //   body: JSON.stringify(data)
  // });
}

/**
 * Calculate next payment due date based on frequency
 */
export function calculateNextPaymentDue(
  startDate: Date,
  frequency: "monthly" | "quarterly"
): Date {
  const nextDue = new Date(startDate);
  if (frequency === "monthly") {
    nextDue.setMonth(nextDue.getMonth() + 1);
  } else {
    nextDue.setMonth(nextDue.getMonth() + 3);
  }
  return nextDue;
}

/**
 * Find matching premium rate for cattle
 */
export function findMatchingRate(
  cattle: any,
  rates: PremiumRate[]
): PremiumRate | null {
  const ageInMonths = cattle.ageInMonths || 24;
  const breed = cattle.breed || "local";
  const healthStatus = cattle.healthStatus || "healthy";

  // Determine breed category
  let breedCategory: "local" | "crossbreed" | "exotic" = "local";
  if (breed.toLowerCase().includes("cross") || breed.toLowerCase().includes("hybrid")) {
    breedCategory = "crossbreed";
  } else if (breed.toLowerCase().includes("friesian") ||
             breed.toLowerCase().includes("jersey") ||
             breed.toLowerCase().includes("holstein")) {
    breedCategory = "exotic";
  }

  // Find matching rate
  const matchingRate = rates.find((r) =>
    ageInMonths >= r.cattleAgeRange.min &&
    ageInMonths <= r.cattleAgeRange.max &&
    r.breedCategory === breedCategory &&
    r.healthStatus === healthStatus &&
    r.isActive
  );

  return matchingRate || null;
}

/**
 * Get default premium rate if no specific rate found
 */
export function getDefaultRate(): number {
  return 8000; // Default annual premium per cattle in TZS
}

/**
 * Calculate premium for a single cattle
 */
export function calculateCattlePremium(
  cattle: any,
  rates: PremiumRate[]
): CattlePremium {
  const matchingRate = findMatchingRate(cattle, rates);
  const premium = matchingRate ? matchingRate.baseRate : getDefaultRate();

  return {
    cattleId: cattle.id,
    cattleName: cattle.name || cattle.tagNumber || cattle.id,
    premium,
    rateCategory: matchingRate ?
      `${matchingRate.breedCategory}-${matchingRate.cattleAgeRange.min}-${matchingRate.cattleAgeRange.max}` :
      "default",
  };
}

/**
 * Get farmer's phone number from Firestore
 */
export async function getFarmerPhone(
  cooperativeId: string,
  collectionCentreId: string,
  farmerId: string
): Promise<string | null> {
  try {
    const farmerDoc = await admin.firestore()
      .collection("cooperatives").doc(cooperativeId)
      .collection("collectionCentres").doc(collectionCentreId)
      .collection("farmers").doc(farmerId)
      .get();

    if (!farmerDoc.exists) {
      return null;
    }

    const farmer = farmerDoc.data();
    return farmer?.phoneNumber || null;
  } catch (error) {
    logger.error("Error getting farmer phone", {error, farmerId});
    return null;
  }
}

/**
 * Format currency amount
 */
export function formatCurrency(amount: number): string {
  return `TZS ${amount.toLocaleString("en-US", {minimumFractionDigits: 2, maximumFractionDigits: 2})}`;
}

/**
 * Format date for SMS
 */
export function formatDate(date: Date): string {
  return date.toLocaleDateString("en-GB", {
    day: "2-digit",
    month: "short",
    year: "numeric",
  });
}
