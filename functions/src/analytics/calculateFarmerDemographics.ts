import * as admin from "firebase-admin";
import {onCall, HttpsError} from "firebase-functions/v2/https";

/**
 * Cloud Function to calculate farmer demographics
 * Task 29.2: Create calculateFarmerDemographics Cloud Function
 */
export const calculateFarmerDemographics = onCall(
  async (request) => {
    // Verify authentication
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "User must be authenticated to access analytics"
      );
    }

    const {filter} = request.data;
    const {
      cooperativeIds,
      region,
      district,
      ward,
      village,
      dateRange,
    } = filter;

    try {
      const db = admin.firestore();

      // Query flat farmers collection
      let farmersQuery = db.collection("farmers") as admin.firestore.Query;

      // Filter by cooperativeIds if provided
      if (cooperativeIds && cooperativeIds.length > 0) {
        farmersQuery = farmersQuery.where("cooperativeId", "in", cooperativeIds.slice(0, 10));
      }

      // Apply location filters
      if (region) {
        farmersQuery = farmersQuery.where("region", "==", region);
      }
      if (district) {
        farmersQuery = farmersQuery.where("district", "==", district);
      }
      if (ward) {
        farmersQuery = farmersQuery.where("ward", "==", ward);
      }
      if (village) {
        farmersQuery = farmersQuery.where("village", "==", village);
      }

      const farmersSnapshot = await farmersQuery.get();
      const farmers = farmersSnapshot.docs.map((doc) => doc.data());
      const totalFarmers = farmers.length;

      console.log(`Total farmers collected: ${totalFarmers}`);

      // Gender distribution
      const genderDistribution = {
        male: 0,
        female: 0,
        other: 0,
      };

      farmers.forEach((farmer) => {
        const gender = farmer.gender?.toLowerCase() || "other";
        if (gender === "male" || gender === "m") {
          genderDistribution.male++;
        } else if (gender === "female" || gender === "f") {
          genderDistribution.female++;
        } else {
          genderDistribution.other++;
        }
      });

      // Age distribution
      const ageDistribution = {
        "18-25": 0,
        "26-35": 0,
        "36-45": 0,
        "46-55": 0,
        "56-65": 0,
        "65+": 0,
      };

      const currentYear = new Date().getFullYear();
      farmers.forEach((farmer) => {
        if (farmer.dateOfBirth) {
          const birthYear = farmer.dateOfBirth.toDate ?
            farmer.dateOfBirth.toDate().getFullYear() :
            new Date(farmer.dateOfBirth).getFullYear();
          const age = currentYear - birthYear;

          if (age >= 18 && age <= 25) {
            ageDistribution["18-25"]++;
          } else if (age >= 26 && age <= 35) {
            ageDistribution["26-35"]++;
          } else if (age >= 36 && age <= 45) {
            ageDistribution["36-45"]++;
          } else if (age >= 46 && age <= 55) {
            ageDistribution["46-55"]++;
          } else if (age >= 56 && age <= 65) {
            ageDistribution["56-65"]++;
          } else if (age > 65) {
            ageDistribution["65+"]++;
          }
        }
      });

      // Geographic distribution
      const geographicDistribution = {
        byRegion: {} as { [key: string]: number },
        byDistrict: {} as { [key: string]: number },
        byWard: {} as { [key: string]: number },
        byVillage: {} as { [key: string]: number },
      };

      farmers.forEach((farmer) => {
        if (farmer.region) {
          geographicDistribution.byRegion[farmer.region] =
            (geographicDistribution.byRegion[farmer.region] || 0) + 1;
        }
        if (farmer.district) {
          geographicDistribution.byDistrict[farmer.district] =
            (geographicDistribution.byDistrict[farmer.district] || 0) + 1;
        }
        if (farmer.ward) {
          geographicDistribution.byWard[farmer.ward] =
            (geographicDistribution.byWard[farmer.ward] || 0) + 1;
        }
        if (farmer.village) {
          geographicDistribution.byVillage[farmer.village] =
            (geographicDistribution.byVillage[farmer.village] || 0) + 1;
        }
      });

      // App access
      const farmersWithAppAccess = farmers.filter(
        (farmer) => farmer.hasAppAccess === true || farmer.userId
      ).length;

      // Credit score distribution
      const creditScoreDistribution = {
        "0-300": 0,
        "301-500": 0,
        "501-700": 0,
        "701-850": 0,
      };

      farmers.forEach((farmer) => {
        const score = farmer.creditScore || 0;
        if (score >= 0 && score <= 300) {
          creditScoreDistribution["0-300"]++;
        } else if (score >= 301 && score <= 500) {
          creditScoreDistribution["301-500"]++;
        } else if (score >= 501 && score <= 700) {
          creditScoreDistribution["501-700"]++;
        } else if (score >= 701 && score <= 850) {
          creditScoreDistribution["701-850"]++;
        }
      });

      // Registration trend (last 12 months)
      const registrationTrend: Array<{ date: string; value: number }> = [];
      const monthlyRegistrations = new Map<string, number>();

      farmers.forEach((farmer) => {
        if (farmer.registeredAt) {
          const date = farmer.registeredAt.toDate ?
            farmer.registeredAt.toDate() :
            new Date(farmer.registeredAt);
          const monthKey = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}`;
          monthlyRegistrations.set(
            monthKey,
            (monthlyRegistrations.get(monthKey) || 0) + 1
          );
        }
      });

      // Get last 12 months
      const now = new Date();
      for (let i = 11; i >= 0; i--) {
        const date = new Date(now.getFullYear(), now.getMonth() - i, 1);
        const monthKey = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}`;
        registrationTrend.push({
          date: monthKey,
          value: monthlyRegistrations.get(monthKey) || 0,
        });
      }

      // New farmers this period
      let newFarmersThisPeriod = 0;
      if (dateRange?.startDate && dateRange?.endDate) {
        const start = new Date(dateRange.startDate);
        const end = new Date(dateRange.endDate);
        newFarmersThisPeriod = farmers.filter((farmer) => {
          if (!farmer.registeredAt) return false;
          const regDate = farmer.registeredAt.toDate ?
            farmer.registeredAt.toDate() :
            new Date(farmer.registeredAt);
          return regDate >= start && regDate <= end;
        }).length;
      }

      return {
        totalFarmers,
        newFarmersThisPeriod,
        genderDistribution,
        ageDistribution,
        geographicDistribution,
        farmersWithAppAccess,
        creditScoreDistribution,
        registrationTrend,
      };
    } catch (error) {
      console.error("Error calculating farmer demographics:", error);
      throw new HttpsError(
        "internal",
        "Failed to calculate farmer demographics"
      );
    }
  }
);
