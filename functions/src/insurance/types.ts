/**
 * Insurance TypeScript Interfaces
 * Defines types for insurance-related data structures
 */

export interface InsurancePolicy {
  policyId: string;
  farmerId: string;
  cooperativeId: string;
  collectionCentreId: string;
  insurancePartnerId: string;
  coveredCattleIds: string[];
  totalPremium: number;
  installmentAmount: number;
  paymentFrequency: "monthly" | "quarterly";
  policyStartDate: FirebaseFirestore.Timestamp;
  policyEndDate: FirebaseFirestore.Timestamp;
  status: "active" | "expired" | "suspended" | "cancelled";
  nextPaymentDue: FirebaseFirestore.Timestamp;
  totalPaid: number;
  outstandingPremium: number;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  createdBy: string;
}

export interface PremiumPayment {
  paymentId: string;
  policyId: string;
  amount: number;
  paymentDate: FirebaseFirestore.Timestamp;
  paymentMethod: "milk_deduction" | "cash" | "mobile_money";
  milkDeliveryId?: string;
  recordedBy: string;
}

export interface InsuranceClaim {
  claimId: string;
  policyId: string;
  cattleId: string;
  farmerId: string;
  lossType: "death" | "theft" | "disease";
  lossDate: FirebaseFirestore.Timestamp;
  description: string;
  claimAmount: number;
  submittedDate: FirebaseFirestore.Timestamp;
  status: "submitted" | "under_review" | "approved" | "rejected" | "settled";
  statusUpdates: ClaimStatusUpdate[];
  settlementAmount?: number;
  settlementDate?: FirebaseFirestore.Timestamp;
  supportingDocuments: string[];
  submittedBy: string;
  reviewedBy?: string;
  reviewComments?: string;
}

export interface ClaimStatusUpdate {
  status: string;
  date: FirebaseFirestore.Timestamp;
  comment: string;
}

export interface PremiumRate {
  rateId: string;
  cattleAgeRange: {
    min: number;
    max: number;
  };
  breedCategory: "local" | "crossbreed" | "exotic";
  healthStatus: "healthy" | "fair" | "poor";
  baseRate: number;
  effectiveDate: FirebaseFirestore.Timestamp;
  createdBy: string;
  isActive: boolean;
}

export interface CattlePremium {
  cattleId: string;
  cattleName: string;
  premium: number;
  rateCategory: string;
}

export interface PremiumCalculation {
  cattlePremiums: CattlePremium[];
  totalAnnualPremium: number;
  monthlyInstallment: number;
  quarterlyInstallment: number;
}
