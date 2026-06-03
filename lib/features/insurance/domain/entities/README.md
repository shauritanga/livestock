# Insurance Domain Entities

This directory contains all domain entities for the Insurance Management feature.

## Entities

### 1. InsurancePolicy
Represents an insurance policy for livestock coverage.

**Key Fields:**
- Policy identification (id, farmerId, cooperativeId)
- Coverage details (coveredCattleIds, insurancePartnerId)
- Premium information (totalPremium, installmentAmount, paymentFrequency)
- Policy dates (policyStartDate, policyEndDate, nextPaymentDue)
- Status tracking (status, totalPaid, outstandingPremium)

**Enums:**
- `PolicyStatus`: active, expired, suspended, cancelled
- `PaymentFrequency`: monthly, quarterly

**Helper Methods:**
- `isActive`: Check if policy is active
- `isExpiringSoon`: Check if policy expires within 30 days
- `daysUntilExpiry`: Get days until expiry
- `isPaymentOverdue`: Check if payment is overdue

### 2. InsuranceClaim
Represents an insurance claim for livestock loss.

**Key Fields:**
- Claim identification (id, policyId, cattleId, farmerId)
- Loss details (lossType, lossDate, description, claimAmount)
- Status tracking (status, statusUpdates, submittedDate)
- Settlement information (settlementAmount, settlementDate)
- Documentation (supportingDocuments, reviewComments)

**Enums:**
- `LossType`: death, theft, disease
- `ClaimStatus`: submitted, underReview, approved, rejected, settled

**Helper Classes:**
- `ClaimStatusUpdate`: Tracks status changes with date and comment

**Helper Methods:**
- `isPending`: Check if claim is pending
- `isApproved`: Check if claim is approved
- `isSettled`: Check if claim is settled
- `isRejected`: Check if claim is rejected
- `latestStatusUpdate`: Get the most recent status update

### 3. PremiumCalculation
Represents the result of a premium calculation for insurance enrollment.

**Key Fields:**
- `cattlePremiums`: List of individual cattle premiums
- `totalAnnualPremium`: Total annual premium amount
- `monthlyInstallment`: Monthly payment amount
- `quarterlyInstallment`: Quarterly payment amount

**Helper Classes:**
- `CattlePremium`: Individual cattle premium with cattleId, name, premium, and rateCategory

**Helper Methods:**
- `cattleCount`: Get number of cattle being insured
- `averagePremiumPerCattle`: Calculate average premium per cattle

### 4. PremiumPayment
Represents a premium payment made for an insurance policy.

**Key Fields:**
- Payment identification (id, policyId)
- Payment details (amount, paymentDate, paymentMethod)
- Tracking (milkDeliveryId, recordedBy)

**Enums:**
- `PaymentMethod`: milkDeduction, cash, mobileMoney

**Helper Methods:**
- `isFromMilkDeduction`: Check if payment was from milk deduction
- `isManualPayment`: Check if payment was manual (cash or mobile money)

### 5. InsuranceEligibility
Represents the insurance eligibility status for a farmer (used for loan verification).

**Key Fields:**
- `isEligible`: Boolean indicating eligibility
- `reason`: Reason for ineligibility (if applicable)
- `uncoveredCattleIds`: List of cattle IDs not covered by insurance

**Factory Constructors:**
- `InsuranceEligibility.eligible()`: Create eligible status
- `InsuranceEligibility.noActivePolicy()`: Create status for no active policy
- `InsuranceEligibility.uncoveredCattle(List<String>)`: Create status for uncovered cattle
- `InsuranceEligibility.overduePremiums()`: Create status for overdue premiums

**Helper Methods:**
- `uncoveredCattleCount`: Get number of uncovered cattle
- `hasUncoveredCattle`: Check if there are uncovered cattle

## Design Principles

All entities follow these principles:

1. **Immutability**: All entities are immutable with `const` constructors
2. **Equatable**: All entities extend Equatable for value equality
3. **CopyWith**: All entities have copyWith methods for creating modified copies
4. **Helper Methods**: Entities include computed properties and helper methods for common operations
5. **Type Safety**: Enums are used instead of strings for status and type fields
6. **Documentation**: All classes, fields, and methods are documented

## Usage

```dart
import 'package:livestock/features/insurance/domain/entities/entities.dart';

// Create a policy
final policy = InsurancePolicy(
  id: 'policy123',
  farmerId: 'farmer456',
  // ... other fields
);

// Check policy status
if (policy.isActive && policy.isExpiringSoon) {
  print('Policy expires in ${policy.daysUntilExpiry} days');
}

// Create a claim
final claim = InsuranceClaim(
  id: 'claim789',
  policyId: policy.id,
  lossType: LossType.death,
  // ... other fields
);

// Check claim status
if (claim.isPending) {
  print('Claim is ${claim.status.label}');
}
```

## Requirements Mapping

- **Task 1.1**: InsurancePolicy entity (Requirements 1.1, 1.7, 2.1)
- **Task 1.2**: InsuranceClaim entity (Requirements 5.1, 5.5, 6.1, 6.3)
- **Task 1.3**: PremiumCalculation entity (Requirements 1.4, 1.5)
- **Task 1.4**: PremiumPayment entity (Requirements 2.3, 2.4, 3.4)
- **Task 1.5**: InsuranceEligibility entity (Requirements 8.1, 8.2, 8.3)
