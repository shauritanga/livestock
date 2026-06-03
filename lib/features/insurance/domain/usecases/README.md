# Insurance Use Cases

This directory contains all use cases for the Insurance Management feature. Use cases represent the business logic and application-specific rules for insurance operations.

## Use Cases Overview

### 1. EnrollInsuranceUseCase
**Purpose:** Enroll a farmer in livestock insurance

**Process:**
1. Validates at least one cattle is selected
2. Calculates premium for selected cattle
3. Creates insurance policy

**Parameters:**
- `farmerId` - The farmer to enroll
- `cattleIds` - List of cattle to cover
- `paymentFrequency` - Monthly or quarterly

**Returns:** `Result<InsurancePolicy>`

**Requirements:** 1.1, 1.2, 1.3, 1.7

**Example:**
```dart
final useCase = EnrollInsuranceUseCase(repository);
final result = await useCase(
  farmerId: 'farmer123',
  cattleIds: ['cattle1', 'cattle2'],
  paymentFrequency: PaymentFrequency.monthly,
);
```

---

### 2. CalculatePremiumUseCase
**Purpose:** Calculate insurance premium for selected cattle

**Process:**
- Fetches cattle details and premium rates
- Calculates premium based on age, breed, health status
- Returns breakdown per cattle and totals

**Parameters:**
- `farmerId` - The farmer
- `cattleIds` - List of cattle to calculate for

**Returns:** `Result<PremiumCalculation>`

**Requirements:** 1.4

**Example:**
```dart
final useCase = CalculatePremiumUseCase(repository);
final result = await useCase(
  farmerId: 'farmer123',
  cattleIds: ['cattle1', 'cattle2'],
);

result.fold(
  onError: (failure) => print('Error: ${failure.message}'),
  onSuccess: (calculation) {
    print('Total: ${calculation.totalAnnualPremium}');
    print('Monthly: ${calculation.monthlyInstallment}');
  },
);
```

---

### 3. GetFarmerPoliciesUseCase
**Purpose:** Retrieve all insurance policies for a farmer

**Process:**
- Fetches all policies (active, expired, suspended, cancelled)

**Parameters:**
- `farmerId` - The farmer

**Returns:** `Result<List<InsurancePolicy>>`

**Requirements:** 3.2, 3.3

**Example:**
```dart
final useCase = GetFarmerPoliciesUseCase(repository);
final result = await useCase('farmer123');

result.fold(
  onError: (failure) => print('Error: ${failure.message}'),
  onSuccess: (policies) {
    final active = policies.where((p) => p.isActive).toList();
    print('Active policies: ${active.length}');
  },
);
```

---

### 4. GetPolicyDetailsUseCase
**Purpose:** Retrieve complete policy details including cattle and payment history

**Process:**
1. Fetches the insurance policy
2. Fetches covered cattle details
3. Fetches premium payment history
4. Combines into PolicyDetails object

**Parameters:**
- `policyId` - The policy ID

**Returns:** `Result<PolicyDetails>`

**Requirements:** 3.2, 3.3, 3.4

**Dependencies:**
- InsuranceRepository
- CattleRepository

**Example:**
```dart
final useCase = GetPolicyDetailsUseCase(
  insuranceRepository: insuranceRepo,
  cattleRepository: cattleRepo,
);
final result = await useCase('policy123');

result.fold(
  onError: (failure) => print('Error: ${failure.message}'),
  onSuccess: (details) {
    print('Policy: ${details.policy.id}');
    print('Covered cattle: ${details.coveredCattle.length}');
    print('Payments: ${details.paymentHistory.length}');
  },
);
```

---

### 5. SubmitClaimUseCase
**Purpose:** Submit an insurance claim for livestock loss

**Process:**
1. Validates policy is active
2. Verifies cattle is covered
3. Uploads supporting documents
4. Creates claim record

**Parameters:**
- `policyId` - The policy ID
- `cattleId` - The lost cattle ID
- `lossType` - Death, theft, or disease
- `lossDate` - When the loss occurred
- `description` - Detailed description
- `supportingDocuments` - List of files to upload

**Returns:** `Result<InsuranceClaim>`

**Requirements:** 5.1, 5.2, 5.3, 5.4, 5.5

**Example:**
```dart
final useCase = SubmitClaimUseCase(repository);
final result = await useCase(
  policyId: 'policy123',
  cattleId: 'cattle1',
  lossType: LossType.death,
  lossDate: DateTime.now(),
  description: 'Cattle died due to illness',
  supportingDocuments: [File('photo.jpg'), File('report.pdf')],
);
```

---

### 6. GetFarmerClaimsUseCase
**Purpose:** Retrieve all insurance claims for a farmer

**Process:**
- Fetches all claims (submitted, under review, approved, rejected, settled)

**Parameters:**
- `farmerId` - The farmer

**Returns:** `Result<List<InsuranceClaim>>`

**Requirements:** 6.1, 6.2

**Example:**
```dart
final useCase = GetFarmerClaimsUseCase(repository);
final result = await useCase('farmer123');

result.fold(
  onError: (failure) => print('Error: ${failure.message}'),
  onSuccess: (claims) {
    final pending = claims.where((c) => c.isPending).toList();
    print('Pending claims: ${pending.length}');
  },
);
```

---

### 7. VerifyInsuranceEligibilityUseCase
**Purpose:** Verify if a farmer is eligible for loans based on insurance coverage

**Process:**
1. Checks farmer has at least one active policy
2. Verifies all productive cattle (lactating/pregnant) are covered
3. Checks for overdue premiums (>30 days)

**Parameters:**
- `farmerId` - The farmer to verify

**Returns:** `Result<InsuranceEligibility>`

**Requirements:** 8.1, 8.2, 8.3, 8.4

**Dependencies:**
- InsuranceRepository
- CattleRepository

**Example:**
```dart
final useCase = VerifyInsuranceEligibilityUseCase(
  insuranceRepository: insuranceRepo,
  cattleRepository: cattleRepo,
);
final result = await useCase('farmer123');

result.fold(
  onError: (failure) => print('Error: ${failure.message}'),
  onSuccess: (eligibility) {
    if (eligibility.isEligible) {
      print('Farmer is eligible for loans');
    } else {
      print('Not eligible: ${eligibility.reason}');
      if (eligibility.hasUncoveredCattle) {
        print('Uncovered cattle: ${eligibility.uncoveredCattleCount}');
      }
    }
  },
);
```

---

### 8. RecordPremiumPaymentUseCase
**Purpose:** Record a manual premium payment

**Process:**
1. Validates payment amount is positive
2. Records payment in repository
3. Updates policy payment status

**Parameters:**
- `policyId` - The policy ID
- `amount` - Payment amount
- `paymentMethod` - Cash or mobile money
- `milkDeliveryId` - Optional, if from milk deduction

**Returns:** `Result<void>`

**Requirements:** 2.3, 2.4, 2.8

**Note:** Automatic deductions from milk payments are handled by Cloud Functions, not this use case.

**Example:**
```dart
final useCase = RecordPremiumPaymentUseCase(repository);
final result = await useCase(
  policyId: 'policy123',
  amount: 5000.0,
  paymentMethod: PaymentMethod.cash,
);
```

---

## Design Principles

All use cases follow these principles:

1. **Single Responsibility**: Each use case handles one specific business operation
2. **Dependency Injection**: Use cases receive repositories through constructor injection
3. **Result Type**: All use cases return `Result<T>` for consistent error handling
4. **Validation**: Input validation happens in use cases before calling repositories
5. **Business Logic**: Use cases contain application-specific business rules
6. **Composition**: Complex use cases can call multiple repository methods
7. **Error Handling**: Use cases handle and transform errors appropriately

## Usage Pattern

```dart
// 1. Create use case with dependencies
final enrollUseCase = EnrollInsuranceUseCase(insuranceRepository);

// 2. Call use case
final result = await enrollUseCase(
  farmerId: farmerId,
  cattleIds: selectedCattleIds,
  paymentFrequency: PaymentFrequency.monthly,
);

// 3. Handle result
result.fold(
  onError: (failure) {
    // Handle error
    if (failure is ValidationFailure) {
      showError(failure.message);
    } else if (failure is ServerFailure) {
      showError('Server error occurred');
    }
  },
  onSuccess: (policy) {
    // Handle success
    showSuccess('Policy created: ${policy.id}');
    navigateToDetails(policy);
  },
);
```

## Testing

Use cases are highly testable because they:
- Accept repositories through constructor injection
- Have no direct dependencies on Flutter or Firebase
- Return predictable Result types
- Contain pure business logic

**Example Test:**
```dart
test('EnrollInsuranceUseCase returns error when no cattle selected', () async {
  final mockRepo = MockInsuranceRepository();
  final useCase = EnrollInsuranceUseCase(mockRepo);

  final result = await useCase(
    farmerId: 'farmer123',
    cattleIds: [], // Empty list
    paymentFrequency: PaymentFrequency.monthly,
  );

  expect(result, isA<Error>());
  expect((result as Error).failure, isA<ValidationFailure>());
});
```

## Dependencies Between Use Cases

Some use cases depend on multiple repositories:

- **GetPolicyDetailsUseCase**: InsuranceRepository + CattleRepository
- **VerifyInsuranceEligibilityUseCase**: InsuranceRepository + CattleRepository

This is acceptable in Clean Architecture as use cases orchestrate multiple domain operations.

## Next Steps

After implementing use cases:
1. Create data layer (models, data sources, repository implementation)
2. Create presentation layer (providers, screens, widgets)
3. Wire everything together with dependency injection
