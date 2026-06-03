import * as admin from "firebase-admin";
import {onCall, HttpsError} from "firebase-functions/v2/https";

/**
 * Cloud Function to calculate livestock metrics
 * Task 29.3: Create calculateLivestockMetrics Cloud Function
 */
export const calculateLivestockMetrics = onCall(
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Authentication required");
    }

    const {filter} = request.data;
    const {cooperativeIds} = filter;

    try {
      const db = admin.firestore();

      // Query flat cattle collection
      let cattleQuery = db.collection("cattle") as admin.firestore.Query;
      if (cooperativeIds && cooperativeIds.length > 0) {
        cattleQuery = cattleQuery.where("cooperativeId", "in", cooperativeIds.slice(0, 10));
      }

      const cattleSnapshot = await cattleQuery.get();
      const cattle = cattleSnapshot.docs.map((doc) => doc.data());

      // Query flat farmers collection
      let farmersQuery = db.collection("farmers") as admin.firestore.Query;
      if (cooperativeIds && cooperativeIds.length > 0) {
        farmersQuery = farmersQuery.where("cooperativeId", "in", cooperativeIds.slice(0, 10));
      }

      const farmersSnapshot = await farmersQuery.get();
      const farmers = farmersSnapshot.docs.map((doc) => doc.data());

      const totalCattle = cattle.length;
      const maleCattle = cattle.filter((c) => c.gender?.toLowerCase() === "male").length;
      const femaleCattle = cattle.filter((c) => c.gender?.toLowerCase() === "female").length;
      const lactatingCattle = cattle.filter((c) => c.lactationStatus === "lactating").length;
      const lactationRate = totalCattle > 0 ? (lactatingCattle / totalCattle) * 100 : 0;

      // Breed distribution
      const breedDistribution: { [key: string]: number } = {};
      cattle.forEach((c) => {
        const breed = c.breed || "Unknown";
        breedDistribution[breed] = (breedDistribution[breed] || 0) + 1;
      });

      // Health status distribution
      const healthStatusDistribution: { [key: string]: number } = {};
      cattle.forEach((c) => {
        const status = c.healthStatus || "Unknown";
        healthStatusDistribution[status] = (healthStatusDistribution[status] || 0) + 1;
      });

      // Cattle age distribution
      const cattleAgeDistribution = {
        "0-1": 0,
        "1-3": 0,
        "3-5": 0,
        "5-10": 0,
        "10+": 0,
      };

      const currentYear = new Date().getFullYear();
      cattle.forEach((c) => {
        if (c.dateOfBirth) {
          const birthYear = c.dateOfBirth.toDate ?
            c.dateOfBirth.toDate().getFullYear() :
            new Date(c.dateOfBirth).getFullYear();
          const age = currentYear - birthYear;

          if (age <= 1) cattleAgeDistribution["0-1"]++;
          else if (age <= 3) cattleAgeDistribution["1-3"]++;
          else if (age <= 5) cattleAgeDistribution["3-5"]++;
          else if (age <= 10) cattleAgeDistribution["5-10"]++;
          else cattleAgeDistribution["10+"]++;
        }
      });

      // Farm assets
      const farmAssets = {
        totalAvocadoTrees: 0,
        totalChickens: 0,
        totalBeehives: 0,
        totalBananaPlants: 0,
        totalPassionSeedlings: 0,
        totalPotatoHectares: 0,
      };

      farmers.forEach((f) => {
        farmAssets.totalAvocadoTrees += f.avocadoTrees || 0;
        farmAssets.totalChickens += f.chickens || 0;
        farmAssets.totalBeehives += f.beehives || 0;
        farmAssets.totalBananaPlants += f.bananaPlants || 0;
        farmAssets.totalPassionSeedlings += f.passionSeedlings || 0;
        farmAssets.totalPotatoHectares += f.potatoHectares || 0;
      });

      const averageCattlePerFarmer = farmers.length > 0 ? totalCattle / farmers.length : 0;

      return {
        totalCattle,
        maleCattle,
        femaleCattle,
        lactatingCattle,
        lactationRate,
        breedDistribution,
        healthStatusDistribution,
        cattleAgeDistribution,
        farmAssets,
        averageCattlePerFarmer,
      };
    } catch (error) {
      console.error("Error calculating livestock metrics:", error);
      throw new HttpsError("internal", "Failed to calculate livestock metrics");
    }
  }
);
