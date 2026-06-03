/**
 * Type definitions for loan management
 */

export interface LoanApplication {
  farmerId: string;
  cooperativeId: string;
  collectionCentreId: string;
  principalAmount: number;
  interestRate: number;
  interestType: "flat" | "reducing_balance";
  termMonths: number;
  mfiPartnerId: string;
  lendingModel?: "direct" | "cooperative_intermediated";
}

export interface LoanRecord {
  id: string;
  farmerId: string;
  cooperativeId: string;
  collectionCentreId: string;
  lendingModel: "direct" | "cooperative_intermediated";
  loanType: "input_loan";
  principalAmount: number;
  interestRate: number;
  interestType: "flat" | "reducing_balance";
  termMonths: number;
  outstandingBalance: number;
  disbursementDate: FirebaseFirestore.Timestamp;
  nextPaymentDue: FirebaseFirestore.Timestamp;
  status: "pending" | "approved" | "disbursed" | "active" | "completed" | "defaulted" | "rejected";
  mfiPartnerId: string;
  insuranceVerified: boolean;
  creditScore?: number;
  createdAt: FirebaseFirestore.Timestamp;
  approvedAt?: FirebaseFirestore.Timestamp;
  rejectionReason?: string;
}

export interface LoanRepayment {
  loanId: string;
  amount: number;
  principalPaid: number;
  interestPaid: number;
  paymentDate: FirebaseFirestore.Timestamp;
  paymentMethod: "milk_deduction" | "mobile_money";
  milkDeliveryId?: string;
}

export interface MilkDelivery {
  farmerId: string;
  cooperativeId: string;
  collectionCentreId: string;
  quantityLiters: number;
  qualityGrade: string;
  pricePerLiter: number;
  totalAmount: number;
  deliveryDate: FirebaseFirestore.Timestamp;
  recordedBy: string;
}

export interface InsurancePolicy {
  farmerId: string;
  cooperativeId: string;
  insurancePartnerId: string;
  coveredCattleIds: string[];
  premiumAmount: number;
  paymentFrequency: "monthly" | "quarterly";
  policyStartDate: FirebaseFirestore.Timestamp;
  policyEndDate: FirebaseFirestore.Timestamp;
  status: "active" | "expired" | "cancelled";
  outstandingPremium: number;
}

export interface CreditScoreFactors {
  deliveryConsistency: number; // 0-100
  productionVolume: number; // 0-100
  herdComposition: number; // 0-100
  repaymentHistory: number; // 0-100
}
