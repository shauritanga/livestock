# Insurance Repository Interface

This directory contains the repository interface for the Insurance Management feature.

## InsuranceRepository

The `InsuranceRepository` is an abstract interface that defines all data operations for insurance management. It follows the Repository Pattern from Clean Architecture, providing a contract between the domain layer and data layer.

### Design Principles

1. **Abstraction**: The interface defines what operations are available, not how they're implemented
2. **Result Type**: All methods return `Result<T>` for consistent error handling
3. **Async Operations**: All methods are asynchronous (Future-based) for Firebase operations
4. **Comprehensive Documentation**: Each method includes detailed documentation
5. **Type Safety**: Uses domain entities and enums for type-safe operations

### Method Categories

#### 1. Policy Management (5 methods)
- `createPolicy()` - Create new insurance policy
- `getPolicy()` - Get policy by ID
- `getFarmerPolicies()` - Get all policies for a farmer
- `getPoliciesByStatus()` - Get policies by status (active, expired, etc.)
- `updatePolicyStatus()` - Update policy status

#### 2. Premium Calculation (1 method)
- `calculatePremium()` - Calculate premium for selected cattle

#### 3. Premium Payments (2 methods)
- `recordPremiumPayment()` - Record a premium payment
- `getPolicyPayments()` - Get payment history for a policy

#### 4. Claims Management (4 methods)
- `createClaim()` - Create new insurance claim
- `getClaim()` - Get claim by ID
- `getFarmerClaims()` - Get all claims for a farmer
- `getPolicyClaims()` - Get all claims for a policy

#### 5. Document Management (1 method)
- `uploadDocument()` - Upload supporting documents to Firebase Storage

#### 6. Premium Rates (1 method)
- `getPremiumRates()` - Get active premium rate configurations

### Error Handling

All methods return `Result<T>` which can be either:
- `Success<T>` - Contains the successful result value
- `Error<T>` - Contains a `Failure` object with error details

Common failure types:
- `ValidationFailure` - Invalid input parameters
- `NotFoundFailure` - Resource doesn't exist
- `ServerFailure` - Server/Firebase operation failed
- `NetworkFailure` - Network connectivity issues

### Usage Example

```dart
// In a use case
class EnrollInsuranceUseCase {
  final InsuranceRepository repository;

  EnrollInsuranceUseCase(this.repository);

  Future<Result<InsurancePolicy>> call({
    required String farmerId,
    required List<String> cattleIds,
    required PaymentFrequency paymentFrequency,
  }) async {
    // Calculate premium
    final premiumResult = await repository.calculatePremium(
      farmerId: farmerId,
      cattleIds: cattleIds,
    );

    // Handle result
    return premiumResult.fold(
      onError: (failure) => Error(failure),
      onSuccess: (calculation) async {
        // Create policy
        return await repository.createPolicy(
          farmerId: farmerId,
          cattleIds: cattleIds,
          totalPremium: calculation.totalAnnualPremium,
          paymentFrequency: paymentFrequency,
        );
      },
    );
  }
}
```

### Implementation

The concrete implementation of this interface will be in the data layer:
- `InsuranceRepositoryImpl` - Implements all methods using Firebase services
- Located in: `lib/features/insurance/data/repositories/`

### PremiumRate Class

The repository includes a simple `PremiumRate` class for premium rate configurations. This is a lightweight domain representation. The full model with Firestore serialization will be in the data layer.

**Fields:**
- `id` - Unique identifier
- `minAge` / `maxAge` - Age range in months
- `breedCategory` - Breed category (local, crossbreed, exotic)
- `healthStatus` - Health status (healthy, fair, poor)
- `baseRate` - Annual premium amount
- `effectiveDate` - When this rate became effective
- `isActive` - Whether this rate is currently active

### Requirements Mapping

This repository interface covers all requirements:
- **Requirements 1.x**: Policy enrollment and management
- **Requirements 2.x**: Premium payment tracking
- **Requirements 3.x**: Policy viewing for farmers
- **Requirements 5.x**: Claim submission
- **Requirements 6.x**: Claim status tracking
- **Requirements 8.x**: Insurance eligibility verification
- **Requirements 9.x**: Premium rate configuration

### Next Steps

After defining this interface:
1. Create use cases that use this repository (Task 3)
2. Implement the repository in the data layer (Task 6)
3. Create data sources for Firebase operations (Task 5)
4. Create data models for Firestore serialization (Task 4)
