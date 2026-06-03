# Loan Management Cloud Functions

This directory contains Cloud Functions for the Agripoa loan management system.

## Implemented Tasks

### Task 13.3: Loan Application Processing (`processLoanApplication`)
**HTTP Callable Function**

Processes loan applications with the following steps:
1. Verifies farmer has active insurance coverage
2. Calculates credit score based on:
   - Delivery consistency (40% weight)
   - Production volume (25% weight)
   - Herd composition (20% weight)
   - Repayment history (15% weight)
3. Determines lending model:
   - **Direct** (credit score ≥ 60): MFI to farmer
   - **Cooperative-intermediated** (credit score < 60): MFI to cooperative
4. Creates loan record in Firestore
5. Sends SMS notification to farmer

**Usage:**
```typescript
const result = await processLoanApplication({
  farmerId: "farmer_001",
  cooperativeId: "coop_001",
  collectionCentreId: "centre_001",
  principalAmount: 50000,
  interestRate: 2.0,  // 2% monthly
  interestType: "flat",
  termMonths: 6,
  mfiPartnerId: "mfi_001"
});
```

**Response:**
```typescript
{
  success: true,
  loanId: "loan_xyz",
  creditScore: 75,
  lendingModel: "direct",
  status: "pending",
  message: "Loan application submitted successfully"
}
```

---

### Task 13.5: Loan Disbursement (`disburseLoan`)
**HTTP Callable Function**

Disburses approved loans with the following steps:
1. Verifies loan is in approved status
2. Integrates with mobile money API (placeholder for now)
3. Updates loan status to active
4. Sends disbursement confirmation SMS

**Usage:**
```typescript
const result = await disburseLoan({
  loanId: "loan_xyz",
  cooperativeId: "coop_001",
  collectionCentreId: "centre_001",
  farmerId: "farmer_001",
  mobileMoneyNumber: "+255712345678"
});
```

**Response:**
```typescript
{
  success: true,
  loanId: "loan_xyz",
  amount: 50000,
  message: "Loan disbursed successfully"
}
```

**TODO:**
- Integrate with actual mobile money API (M-Pesa, Airtel Money, etc.)
- Add retry logic for failed disbursements
- Implement disbursement to suppliers (direct payment)

---

### Task 13.6: Automated Loan Repayment Deduction (`deductLoanRepayment`)
**Firestore Trigger**

Automatically deducts loan repayments from milk payments when a delivery is recorded.

**Trigger Path:**
```
cooperatives/{cooperativeId}/collectionCentres/{centreId}/farmers/{farmerId}/milkDeliveries/{deliveryId}
```

**Process:**
1. Gets all active loans for the farmer
2. Checks if payment is due for each loan
3. Calculates repayment amount (principal + interest)
4. Deducts from milk payment in priority order:
   - Insurance premium (handled separately)
   - Loan repayment
5. Updates loan balance
6. Records repayment transaction
7. Handles insufficient payment scenarios
8. Sends SMS notification with payment breakdown

**Repayment Priority:**
- Insurance premiums are deducted first (handled by insurance functions)
- Then loan repayments are processed
- Remaining amount is net payment to farmer

**Example Flow:**
```
Milk Payment: KES 5,000
- Insurance Premium: KES 500
- Loan Repayment: KES 2,000
= Net Payment: KES 2,500
```

**Insufficient Payment Handling:**
- If milk payment < total due, partial payment is applied
- Shortfall is carried forward to next payment cycle
- Account is flagged for review

---

### Manual Repayment Processing (`processManualRepayment`)
**HTTP Callable Function**

Processes manual loan repayments (mobile money or cash payments).

**Usage:**
```typescript
const result = await processManualRepayment({
  loanId: "loan_xyz",
  cooperativeId: "coop_001",
  collectionCentreId: "centre_001",
  farmerId: "farmer_001",
  amount: 2000,
  paymentMethod: "mobile_money"
});
```

---

## Credit Scoring Algorithm

### Factors and Weights

1. **Delivery Consistency (40%)**
   - Measures frequency of milk deliveries
   - Calculation: (Days with deliveries / Total days) × 100
   - Period: Last 90 days

2. **Production Volume (25%)**
   - Measures average daily milk production
   - Scoring: 0L = 0, 5L = 50, 10L+ = 100
   - Period: Last 90 days

3. **Herd Composition (20%)**
   - Herd size score: Up to 50 points (10+ cattle = max)
   - Lactating percentage: Up to 50 points (60%+ = max)

4. **Repayment History (15%)**
   - Perfect score (100) if no previous loans
   - Completion rate for completed loans
   - Heavy penalty for defaults (-25 per default)

### Score Ranges

- **80-100**: Excellent (low risk) - Direct lending
- **60-79**: Good (moderate risk) - Direct lending
- **40-59**: Fair (higher risk) - Cooperative-intermediated
- **0-39**: Poor (high risk) - Cooperative-intermediated

---

## Lending Models

### Direct Lending (Credit Score ≥ 60)
- MFI lends directly to farmer
- Lower interest rates
- Faster approval process
- Individual risk assessment

### Cooperative-Intermediated (Credit Score < 60)
- MFI lends to cooperative
- Cooperative distributes to farmers
- Cooperative manages risk
- Bulk loan application

---

## Interest Calculation

### Flat Interest
```
Total Interest = Principal × Rate × Term
Total Repayment = Principal + Total Interest
Monthly Payment = Total Repayment / Term
```

**Example:**
- Principal: KES 50,000
- Rate: 2% per month
- Term: 6 months
- Total Interest: 50,000 × 0.02 × 6 = KES 6,000
- Total Repayment: KES 56,000
- Monthly Payment: KES 9,333

### Reducing Balance
```
Monthly Payment = P × r × (1 + r)^n / ((1 + r)^n - 1)
Where:
  P = Principal
  r = Monthly interest rate
  n = Number of months
```

---

## SMS Notifications

### Application Submitted
```
Agripoa: Your loan application for KES 50,000 has been submitted. 
Lending model: direct. You will be notified once approved.
```

### Loan Disbursed
```
Agripoa: Your loan of KES 50,000 has been disbursed. 
Repayments will be deducted from your milk payments. 
Thank you for choosing Agripoa!
```

### Repayment Deducted
```
Agripoa: Milk payment KES 5,000.00. 
Loan deduction: KES 2,000.00. 
Net payment: KES 3,000.00.
```

---

## Database Structure

### Loan Document
```typescript
cooperatives/{cooperativeId}/
  collectionCentres/{centreId}/
    farmers/{farmerId}/
      loans/{loanId}
        {
          farmerId: string
          cooperativeId: string
          collectionCentreId: string
          lendingModel: 'direct' | 'cooperative_intermediated'
          loanType: 'input_loan'
          principalAmount: number
          interestRate: number
          interestType: 'flat' | 'reducing_balance'
          termMonths: number
          outstandingBalance: number
          disbursementDate: Timestamp
          nextPaymentDue: Timestamp
          status: 'pending' | 'approved' | 'disbursed' | 'active' | 'completed' | 'defaulted' | 'rejected'
          mfiPartnerId: string
          insuranceVerified: boolean
          creditScore: number
          createdAt: Timestamp
          approvedAt?: Timestamp
          rejectionReason?: string
        }
```

### Repayment Document
```typescript
cooperatives/{cooperativeId}/
  collectionCentres/{centreId}/
    farmers/{farmerId}/
      loans/{loanId}/
        repayments/{repaymentId}
          {
            loanId: string
            amount: number
            principalPaid: number
            interestPaid: number
            paymentDate: Timestamp
            paymentMethod: 'milk_deduction' | 'mobile_money'
            milkDeliveryId?: string
          }
```

---

## Testing

### Test Loan Application
```bash
# Using Firebase CLI
firebase functions:shell

# In the shell
processLoanApplication({
  farmerId: "farmer_001",
  cooperativeId: "coop_test_001",
  collectionCentreId: "centre_test_001",
  principalAmount: 50000,
  interestRate: 2.0,
  interestType: "flat",
  termMonths: 6,
  mfiPartnerId: "mfi_001"
})
```

### Test Disbursement
```bash
disburseLoan({
  loanId: "loan_xyz",
  cooperativeId: "coop_test_001",
  collectionCentreId: "centre_test_001",
  farmerId: "farmer_001"
})
```

### Test Repayment Deduction
Create a milk delivery and the trigger will automatically process repayments.

---

## Future Enhancements

1. **Mobile Money Integration**
   - Integrate with M-Pesa API
   - Add Airtel Money support
   - Implement Tigo Pesa integration

2. **MFI Partner API Integration**
   - Real-time loan approval workflow
   - Automated disbursement coordination
   - Portfolio reporting

3. **Advanced Credit Scoring**
   - Machine learning model
   - External credit bureau integration
   - Social scoring factors

4. **Loan Products**
   - Equipment loans
   - Working capital loans
   - Emergency loans

5. **Repayment Flexibility**
   - Grace periods
   - Loan restructuring
   - Early repayment discounts

---

## Error Handling

All functions implement comprehensive error handling:
- Input validation
- Authentication checks
- Business logic validation
- Graceful error messages
- Detailed logging for debugging

---

## Security

- All functions require authentication
- Role-based access control via custom claims
- Data isolation by cooperative
- Secure SMS delivery
- Audit logging for all transactions

---

## Monitoring

Key metrics to monitor:
- Loan application success rate
- Average credit score
- Disbursement success rate
- Repayment collection rate
- Default rate
- SMS delivery success rate

---

## Support

For issues or questions:
- Check Firebase Functions logs
- Review error messages in responses
- Contact development team

---

Last Updated: 2024
