/**
 * Seed Premium Rates
 * Populates the premiumRates collection with initial data
 */

import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {PremiumRate} from "./types";

/**
 * Seed premium rates into Firestore
 */
export async function seedPremiumRates(): Promise<{success: boolean; count: number}> {
  try {
    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();

    // Define premium rates for different cattle characteristics
    const rates: Omit<PremiumRate, "rateId">[] = [
      // Young cattle (0-24 months) - Lower risk
      {
        cattleAgeRange: {min: 0, max: 24},
        breedCategory: "local",
        healthStatus: "healthy",
        baseRate: 5000,
        effectiveDate: now,
        createdBy: "system",
        isActive: true,
      },
      {
        cattleAgeRange: {min: 0, max: 24},
        breedCategory: "crossbreed",
        healthStatus: "healthy",
        baseRate: 7000,
        effectiveDate: now,
        createdBy: "system",
        isActive: true,
      },
      {
        cattleAgeRange: {min: 0, max: 24},
        breedCategory: "exotic",
        healthStatus: "healthy",
        baseRate: 10000,
        effectiveDate: now,
        createdBy: "system",
        isActive: true,
      },

      // Prime age cattle (25-60 months) - Optimal productivity
      {
        cattleAgeRange: {min: 25, max: 60},
        breedCategory: "local",
        healthStatus: "healthy",
        baseRate: 6000,
        effectiveDate: now,
        createdBy: "system",
        isActive: true,
      },
      {
        cattleAgeRange: {min: 25, max: 60},
        breedCategory: "crossbreed",
        healthStatus: "healthy",
        baseRate: 8000,
        effectiveDate: now,
        createdBy: "system",
        isActive: true,
      },
      {
        cattleAgeRange: {min: 25, max: 60},
        breedCategory: "exotic",
        healthStatus: "healthy",
        baseRate: 12000,
        effectiveDate: now,
        createdBy: "system",
        isActive: true,
      },

      // Older cattle (61-120 months) - Higher risk
      {
        cattleAgeRange: {min: 61, max: 120},
        breedCategory: "local",
        healthStatus: "healthy",
        baseRate: 7000,
        effectiveDate: now,
        createdBy: "system",
        isActive: true,
      },
      {
        cattleAgeRange: {min: 61, max: 120},
        breedCategory: "crossbreed",
        healthStatus: "healthy",
        baseRate: 9000,
        effectiveDate: now,
        createdBy: "system",
        isActive: true,
      },
      {
        cattleAgeRange: {min: 61, max: 120},
        breedCategory: "exotic",
        healthStatus: "healthy",
        baseRate: 13000,
        effectiveDate: now,
        createdBy: "system",
        isActive: true,
      },

      // Fair health status - Increased rates
      {
        cattleAgeRange: {min: 0, max: 24},
        breedCategory: "local",
        healthStatus: "fair",
        baseRate: 6000,
        effectiveDate: now,
        createdBy: "system",
        isActive: true,
      },
      {
        cattleAgeRange: {min: 25, max: 60},
        breedCategory: "local",
        healthStatus: "fair",
        baseRate: 7500,
        effectiveDate: now,
        createdBy: "system",
        isActive: true,
      },
      {
        cattleAgeRange: {min: 61, max: 120},
        breedCategory: "local",
        healthStatus: "fair",
        baseRate: 9000,
        effectiveDate: now,
        createdBy: "system",
        isActive: true,
      },

      // Poor health status - Significantly increased rates
      {
        cattleAgeRange: {min: 0, max: 24},
        breedCategory: "local",
        healthStatus: "poor",
        baseRate: 8000,
        effectiveDate: now,
        createdBy: "system",
        isActive: true,
      },
      {
        cattleAgeRange: {min: 25, max: 60},
        breedCategory: "local",
        healthStatus: "poor",
        baseRate: 10000,
        effectiveDate: now,
        createdBy: "system",
        isActive: true,
      },
      {
        cattleAgeRange: {min: 61, max: 120},
        breedCategory: "local",
        healthStatus: "poor",
        baseRate: 12000,
        effectiveDate: now,
        createdBy: "system",
        isActive: true,
      },

      // Crossbreed fair health
      {
        cattleAgeRange: {min: 25, max: 60},
        breedCategory: "crossbreed",
        healthStatus: "fair",
        baseRate: 10000,
        effectiveDate: now,
        createdBy: "system",
        isActive: true,
      },

      // Exotic fair health
      {
        cattleAgeRange: {min: 25, max: 60},
        breedCategory: "exotic",
        healthStatus: "fair",
        baseRate: 15000,
        effectiveDate: now,
        createdBy: "system",
        isActive: true,
      },
    ];

    // Create batch write
    const batch = db.batch();
    let count = 0;

    for (const rate of rates) {
      const rateRef = db.collection("premiumRates").doc();
      const rateData: PremiumRate = {
        ...rate,
        rateId: rateRef.id,
      };
      batch.set(rateRef, rateData);
      count++;
    }

    await batch.commit();

    logger.info("Premium rates seeded successfully", {count});

    return {success: true, count};
  } catch (error) {
    logger.error("Error seeding premium rates", {error});
    throw error;
  }
}

/**
 * Cleanup premium rates (for testing)
 */
export async function cleanupPremiumRates(): Promise<{success: boolean; count: number}> {
  try {
    const db = admin.firestore();
    const ratesSnapshot = await db.collection("premiumRates").get();

    const batch = db.batch();
    let count = 0;

    for (const doc of ratesSnapshot.docs) {
      batch.delete(doc.ref);
      count++;
    }

    await batch.commit();

    logger.info("Premium rates cleaned up", {count});

    return {success: true, count};
  } catch (error) {
    logger.error("Error cleaning up premium rates", {error});
    throw error;
  }
}
