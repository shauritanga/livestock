/**
 * Loan Management Cloud Functions
 *
 * Implements:
 * - Task 13.3: Loan application processing
 * - Task 13.5: Loan disbursement
 * - Task 13.6: Automated loan repayment deduction
 */

import {onCall, HttpsError} from "firebase-functions/v2/https";
import {onDocumentCreated} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {
  LoanApplication,
  LoanRecord,
  LoanRepayment,
  MilkDelivery,
} from "./types";
import {
  verifyInsurance,
  calculateCreditScore,
  determineLendingModel,
  calculateMonthlyInstallment,
  sendSMS,
  getActiveLoans,
} from "./helpers";

// ============================================================================
// TASK 13.3: LOAN APPLICATION PROCESSING
// ============================================================================

/**
 * HTTP Callable Function: Process loan application
 *
 * Steps:
 * 1. Verify farmer has active insurance
 * 2. Calculate credit score
 * 3. Determine lending model (direct vs cooperative-intermediated)
 * 4. Create loan record in Firestore
 * 5. Send application notification
 */
export const processLoanApplication = onCall(async (request) => {
  try {
    // Verify authentication
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "Must be authenticated to apply for loans"
      );
    }

    const application: LoanApplication = request.data;

    // Validate required fields
    if (!application.farmerId || !application.cooperativeId ||
        !application.collectionCentreId || !application.principalAmount ||
        !application.interestRate || !application.termMonths) {
      throw new HttpsError(
        "invalid-argument",
        "Missing required loan application fields"
      );
    }

    logger.info("Processing loan application", {
      farmerId: application.farmerId,
      amount: application.principalAmount,
    });

    // Step 1: Verify insurance
    const insuranceCheck = await verifyInsurance(
      application.cooperativeId,
      application.collectionCentreId,
      application.farmerId
    );

    if (!insuranceCheck.verified) {
      throw new HttpsError(
        "failed-precondition",
        "Farmer must have active insurance to apply for loans"
      );
    }

    // Step 2: Calculate credit score
    const creditScore = await calculateCreditScore(
      application.cooperativeId,
      application.collectionCentreId,
      application.farmerId
    );

    // Step 3: Determine lending model
    const lendingModel = application.lendingModel ||
                        determineLendingModel(creditScore);

    // Step 4: Create loan record
    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();
    const disbursementDate = now;
    const nextPaymentDue = admin.firestore.Timestamp.fromDate(
      new Date(Date.now() + 30 * 24 * 60 * 60 * 1000) // 30 days from now
    );

    const loanData: Omit<LoanRecord, "id"> = {
      farmerId: application.farmerId,
      cooperativeId: application.cooperativeId,
      collectionCentreId: application.collectionCentreId,
      lendingModel: lendingModel,
      loanType: "input_loan",
      principalAmount: application.principalAmount,
      interestRate: application.interestRate,
      interestType: application.interestType || "flat",
      termMonths: application.termMonths,
      outstandingBalance: application.principalAmount,
      disbursementDate: disbursementDate,
      nextPaymentDue: nextPaymentDue,
      status: "pending",
      mfiPartnerId: application.mfiPartnerId || "default_mfi",
      insuranceVerified: true,
      creditScore: creditScore,
      createdAt: now,
    };

    const loanRef = await db
      .collection("cooperatives")
      .doc(application.cooperativeId)
      .collection("collectionCentres")
      .doc(application.collectionCentreId)
      .collection("farmers")
      .doc(application.farmerId)
      .collection("loans")
      .add(loanData);

    // Step 5: Send notification
    const farmerDoc = await db
      .collection("cooperatives")
      .doc(application.cooperativeId)
      .collection("collectionCentres")
      .doc(application.collectionCentreId)
      .collection("farmers")
      .doc(application.farmerId)
      .get();

    const farmer = farmerDoc.data();
    if (farmer?.phoneNumber) {
      await sendSMS(
        farmer.phoneNumber,
        `Agripoa: Your loan application for KES ${application.principalAmount} ` +
        `has been submitted. Lending model: ${lendingModel}. ` +
        "You will be notified once approved."
      );
    }

    logger.info("Loan application processed", {
      loanId: loanRef.id,
      farmerId: application.farmerId,
      creditScore,
      lendingModel,
    });

    return {
      success: true,
      loanId: loanRef.id,
      creditScore,
      lendingModel,
      status: "pending",
      message: "Loan application submitted successfully",
    };
  } catch (error: any) {
    logger.error("Error processing loan application", {error});

    if (error instanceof HttpsError) {
      throw error;
    }

    throw new HttpsError(
      "internal",
      error.message || "Failed to process loan application"
    );
  }
});

// ============================================================================
// TASK 13.5: LOAN DISBURSEMENT
// ============================================================================

/**
 * HTTP Callable Function: Disburse approved loan
 *
 * Steps:
 * 1. Verify loan is approved
 * 2. Integrate with mobile money API (placeholder)
 * 3. Update loan status to active
 * 4. Send disbursement confirmation SMS
 */
export const disburseLoan = onCall(async (request) => {
  try {
    // Verify authentication
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "Must be authenticated to disburse loans"
      );
    }

    const {loanId, cooperativeId, collectionCentreId, farmerId, mobileMoneyNumber} = request.data;

    // Validate required fields
    if (!loanId || !cooperativeId || !collectionCentreId || !farmerId) {
      throw new HttpsError(
        "invalid-argument",
        "Missing required fields for loan disbursement"
      );
    }

    logger.info("Disbursing loan", {loanId, farmerId});

    const db = admin.firestore();
    const loanRef = db
      .collection("cooperatives")
      .doc(cooperativeId)
      .collection("collectionCentres")
      .doc(collectionCentreId)
      .collection("farmers")
      .doc(farmerId)
      .collection("loans")
      .doc(loanId);

    // Get loan document
    const loanDoc = await loanRef.get();
    if (!loanDoc.exists) {
      throw new HttpsError("not-found", "Loan not found");
    }

    const loan = loanDoc.data() as LoanRecord;

    // Verify loan is approved
    if (loan.status !== "approved") {
      throw new HttpsError(
        "failed-precondition",
        `Loan must be approved before disbursement. Current status: ${loan.status}`
      );
    }

    // Step 2: Integrate with mobile money API
    // TODO: Implement actual mobile money integration
    // For now, simulate successful disbursement
    const disbursementSuccess = await simulateMobileMoneyDisbursement(
      mobileMoneyNumber || "placeholder",
      loan.principalAmount
    );

    if (!disbursementSuccess) {
      throw new HttpsError(
        "internal",
        "Mobile money disbursement failed"
      );
    }

    // Step 3: Update loan status
    await loanRef.update({
      status: "active",
      disbursementDate: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Step 4: Send confirmation SMS
    const farmerDoc = await db
      .collection("cooperatives")
      .doc(cooperativeId)
      .collection("collectionCentres")
      .doc(collectionCentreId)
      .collection("farmers")
      .doc(farmerId)
      .get();

    const farmer = farmerDoc.data();
    if (farmer?.phoneNumber) {
      await sendSMS(
        farmer.phoneNumber,
        `Agripoa: Your loan of KES ${loan.principalAmount} has been disbursed. ` +
        "Repayments will be deducted from your milk payments. " +
        "Thank you for choosing Agripoa!"
      );
    }

    logger.info("Loan disbursed successfully", {loanId, farmerId});

    return {
      success: true,
      loanId,
      amount: loan.principalAmount,
      message: "Loan disbursed successfully",
    };
  } catch (error: any) {
    logger.error("Error disbursing loan", {error});

    if (error instanceof HttpsError) {
      throw error;
    }

    throw new HttpsError(
      "internal",
      error.message || "Failed to disburse loan"
    );
  }
});

/**
 * Simulate mobile money disbursement
 * TODO: Replace with actual mobile money API integration
 */
async function simulateMobileMoneyDisbursement(
  phoneNumber: string,
  amount: number
): Promise<boolean> {
  logger.info("Simulating mobile money disbursement", {phoneNumber, amount});

  // In production, integrate with:
  // - M-Pesa API
  // - Airtel Money API
  // - Tigo Pesa API
  // - Or use aggregator like Flutterwave or DPO

  return true; // Simulate success
}

// ============================================================================
// TASK 13.6: AUTOMATED LOAN REPAYMENT DEDUCTION
// ============================================================================

/**
 * Firestore Trigger: Automatically deduct loan repayments from milk payments
 *
 * Triggered when a milk delivery is created
 *
 * Steps:
 * 1. Get active loans for the farmer
 * 2. Calculate repayment amount due
 * 3. Deduct from milk payment
 * 4. Update loan balance
 * 5. Record repayment transaction
 * 6. Handle insufficient payment scenarios
 */
export const deductLoanRepayment = onDocumentCreated(
  "cooperatives/{cooperativeId}/collectionCentres/{centreId}/farmers/{farmerId}/milkDeliveries/{deliveryId}",
  async (event) => {
    try {
      const delivery = event.data?.data() as MilkDelivery;
      if (!delivery) return;

      const {cooperativeId, centreId, farmerId} = event.params;

      logger.info("Processing loan repayment deduction", {
        farmerId,
        deliveryId: event.data?.id,
        milkPayment: delivery.totalAmount,
      });

      // Step 1: Get active loans
      const activeLoans = await getActiveLoans(cooperativeId, centreId, farmerId);

      if (activeLoans.length === 0) {
        logger.info("No active loans for farmer", {farmerId});
        return;
      }

      const db = admin.firestore();
      let remainingPayment = delivery.totalAmount;
      const repayments: LoanRepayment[] = [];

      // Step 2-5: Process each loan
      for (const loan of activeLoans) {
        if (remainingPayment <= 0) break;

        // Check if payment is due
        const now = new Date();
        const nextDue = loan.nextPaymentDue.toDate();

        if (now < nextDue) {
          logger.info("Payment not yet due for loan", {
            loanId: loan.id,
            nextDue: nextDue.toISOString(),
          });
          continue;
        }

        // Calculate installment amount
        const monthlyInstallment = calculateMonthlyInstallment(
          loan.principalAmount,
          loan.interestRate,
          loan.termMonths,
          loan.interestType
        );

        // Calculate principal and interest portions
        const totalInterest = loan.principalAmount * (loan.interestRate / 100) * loan.termMonths;
        const interestPortion = totalInterest / loan.termMonths;
        const principalPortion = monthlyInstallment - interestPortion;

        // Determine actual payment amount
        const paymentAmount = Math.min(remainingPayment, monthlyInstallment);
        const actualPrincipal = Math.min(principalPortion, paymentAmount);
        const actualInterest = paymentAmount - actualPrincipal;

        // Step 3: Deduct from remaining payment
        remainingPayment -= paymentAmount;

        // Step 4: Update loan balance
        const newBalance = loan.outstandingBalance - actualPrincipal;
        const newStatus = newBalance <= 0 ? "completed" : "active";
        const nextPayment = new Date(nextDue);
        nextPayment.setMonth(nextPayment.getMonth() + 1);

        const loanRef = db
          .collection("cooperatives")
          .doc(cooperativeId)
          .collection("collectionCentres")
          .doc(centreId)
          .collection("farmers")
          .doc(farmerId)
          .collection("loans")
          .doc(loan.id);

        await loanRef.update({
          outstandingBalance: newBalance,
          status: newStatus,
          nextPaymentDue: admin.firestore.Timestamp.fromDate(nextPayment),
        });

        // Step 5: Record repayment transaction
        const repaymentData: LoanRepayment = {
          loanId: loan.id,
          amount: paymentAmount,
          principalPaid: actualPrincipal,
          interestPaid: actualInterest,
          paymentDate: admin.firestore.Timestamp.now(),
          paymentMethod: "milk_deduction",
          milkDeliveryId: event.data?.id,
        };

        await loanRef.collection("repayments").add(repaymentData);
        repayments.push(repaymentData);

        logger.info("Loan repayment processed", {
          loanId: loan.id,
          amount: paymentAmount,
          newBalance,
          status: newStatus,
        });
      }

      // Step 6: Handle insufficient payment
      if (repayments.length > 0) {
        // Update delivery document with deduction info
        await db
          .collection("cooperatives")
          .doc(cooperativeId)
          .collection("collectionCentres")
          .doc(centreId)
          .collection("farmers")
          .doc(farmerId)
          .collection("milkDeliveries")
          .doc(event.data?.id || "")
          .update({
            loanDeductions: repayments.map((r) => ({
              loanId: r.loanId,
              amount: r.amount,
            })),
            netPayment: remainingPayment,
          });

        // Send SMS notification
        const farmerDoc = await db
          .collection("cooperatives")
          .doc(cooperativeId)
          .collection("collectionCentres")
          .doc(centreId)
          .collection("farmers")
          .doc(farmerId)
          .get();

        const farmer = farmerDoc.data();
        if (farmer?.phoneNumber) {
          const totalDeducted = repayments.reduce((sum, r) => sum + r.amount, 0);
          await sendSMS(
            farmer.phoneNumber,
            `Agripoa: Milk payment KES ${delivery.totalAmount.toFixed(2)}. ` +
            `Loan deduction: KES ${totalDeducted.toFixed(2)}. ` +
            `Net payment: KES ${remainingPayment.toFixed(2)}.`
          );
        }
      }

      logger.info("Loan repayment deduction completed", {
        farmerId,
        repaymentsProcessed: repayments.length,
        totalDeducted: repayments.reduce((sum, r) => sum + r.amount, 0),
        netPayment: remainingPayment,
      });
    } catch (error) {
      logger.error("Error processing loan repayment deduction", {error});
      // Don't throw - we don't want to block milk delivery recording
    }
  }
);

/**
 * HTTP Callable Function: Manually process loan repayment
 * For mobile money or cash payments
 */
export const processManualRepayment = onCall(async (request) => {
  try {
    // Verify authentication
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "Must be authenticated to process repayments"
      );
    }

    const {
      loanId,
      cooperativeId,
      collectionCentreId,
      farmerId,
      amount,
      paymentMethod,
    } = request.data;

    // Validate required fields
    if (!loanId || !cooperativeId || !collectionCentreId ||
        !farmerId || !amount || !paymentMethod) {
      throw new HttpsError(
        "invalid-argument",
        "Missing required fields for manual repayment"
      );
    }

    logger.info("Processing manual loan repayment", {loanId, amount});

    const db = admin.firestore();
    const loanRef = db
      .collection("cooperatives")
      .doc(cooperativeId)
      .collection("collectionCentres")
      .doc(collectionCentreId)
      .collection("farmers")
      .doc(farmerId)
      .collection("loans")
      .doc(loanId);

    // Get loan document
    const loanDoc = await loanRef.get();
    if (!loanDoc.exists) {
      throw new HttpsError("not-found", "Loan not found");
    }

    const loan = loanDoc.data() as LoanRecord;

    // Calculate principal and interest portions
    const monthlyInstallment = calculateMonthlyInstallment(
      loan.principalAmount,
      loan.interestRate,
      loan.termMonths,
      loan.interestType
    );

    const totalInterest = loan.principalAmount * (loan.interestRate / 100) * loan.termMonths;
    const interestPortion = totalInterest / loan.termMonths;
    const principalPortion = monthlyInstallment - interestPortion;

    const actualPrincipal = Math.min(principalPortion, amount);
    const actualInterest = amount - actualPrincipal;

    // Update loan balance
    const newBalance = loan.outstandingBalance - actualPrincipal;
    const newStatus = newBalance <= 0 ? "completed" : "active";

    await loanRef.update({
      outstandingBalance: newBalance,
      status: newStatus,
    });

    // Record repayment
    const repaymentData: LoanRepayment = {
      loanId: loanId,
      amount: amount,
      principalPaid: actualPrincipal,
      interestPaid: actualInterest,
      paymentDate: admin.firestore.Timestamp.now(),
      paymentMethod: paymentMethod,
    };

    await loanRef.collection("repayments").add(repaymentData);

    logger.info("Manual repayment processed", {
      loanId,
      amount,
      newBalance,
      status: newStatus,
    });

    return {
      success: true,
      loanId,
      amount,
      newBalance,
      status: newStatus,
      message: "Repayment processed successfully",
    };
  } catch (error: any) {
    logger.error("Error processing manual repayment", {error});

    if (error instanceof HttpsError) {
      throw error;
    }

    throw new HttpsError(
      "internal",
      error.message || "Failed to process repayment"
    );
  }
});
