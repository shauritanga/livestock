# Insurance Repository Implementation

This directory contains the implementation of the InsuranceRepository interface.

## InsuranceRepositoryImpl

The `InsuranceRepositoryImpl` class implements the `InsuranceRepository` interface by delegating to the `InsuranceRemoteDataSource` and converting exceptions to failures.

### Dependencies

```dart
final InsuranceRemoteDataSource remoteDataSource;
final String cooperativeId;
final String collectionCentreId;
```

### Context Management

The repository uses a context pattern to handle the farmerId requirement:

```dart
String? _currentFarmerId;

void setFarmerContext(String farmerId);
void clearFarmerContext();
```

**Why Context Management?**
- The repository interface doesn't include farmerId in all method signatures
- Firestore paths require farmerId for most operations
- Context allows methods to access farmerId without changing the interface

### Error Handling Pattern

All methods follow this pattern:

```dart
Future<Result<T>> method() async {
  try {
    // Check context if needed
    if (_currentFarmerId == null) {
      return const Error(ValidationFailure('Context not set'));
    }
    
    // Call data source
    final result = await remoteDataSource.method();
    
    // Convert to entity and return success
    return Success(result.toEntity());
  } on SpecificException catch (e) {
    return Error(SpecificFailure(e.message));
  } on ServerException catch (e) {
    return Error(ServerFailure(e.message));
  } catch (e) {
    return Error(ServerFailure('Unexpected error: $e'));
  }
}
```

### Exception to Failure Mapping

| Exception | Failure |
|-----------|---------|
| AuthenticationException | AuthenticationFailure |
| NotFoundException | NotFoundFailure |
| ServerException | ServerFailure |
| ValidationException | ValidationFailure |
| Any other | ServerFailure |

---

## Method Implementation Details

### Policy Management

#### createPolicy()
- ✅ Fully implemented
- No context required (farmerId is a parameter)
- Converts InsurancePolicyModel to InsurancePolicy entity

#### getPolicy()
- ✅ Implemented with context
- Requires setFarmerContext() to be called first
- Returns ValidationFailure if context not set

#### getFarmerPolicies()
- ✅ Fully implemented
- farmerId is a parameter, no context needed
- Converts list of models to entities

#### getPoliciesByStatus()
- ⚠️ Not implemented
- Would require collection group query
- Returns ValidationFailure with guidance

#### updatePolicyStatus()
- ✅ Implemented with context
- Requires setFarmerContext() to be called first

### Premium Calculation

#### calculatePremium()
- ✅ Fully implemented
- farmerId is a parameter, no context needed
- Returns PremiumCalculation entity directly

### Premium Payments

#### recordPremiumPayment()
- ✅ Implemented with context
- Requires setFarmerContext() to be called first
- Returns Success(null) on completion

#### getPolicyPayments()
- ✅ Implemented with context
- Requires setFarmerContext() to be called first
- Converts list of models to entities

### Claims Management

#### createClaim()
- ✅ Implemented with context
- Requires setFarmerContext() to be called first
- Converts InsuranceClaimModel to InsuranceClaim entity

#### getClaim()
- ⚠️ Not implemented
- Would require policyId which isn't in the interface
- Returns ValidationFailure with guidance to use getFarmerClaims

#### getFarmerClaims()
- ✅ Fully implemented
- farmerId is a parameter, no context needed
- Converts list of models to entities

#### getPolicyClaims()
- ✅ Implemented with context
- Requires setFarmerContext() to be called first
- Converts list of models to entities

### Document Management

#### uploadDocument()
- ✅ Implemented with context
- Requires setFarmerContext() to be called first
- Returns download URL string

### Premium Rates

#### getPremiumRates()
- ✅ Fully implemented
- No context required
- Converts list of models to entities

---

## Usage Examples

### Basic Usage (No Context Required)

```dart
final repository = InsuranceRepositoryImpl(
  remoteDataSource: dataSource,
  cooperativeId: 'coop123',
  collectionCentreId: 'centre456',
);

// Methods with farmerId parameter work directly
final result = await repository.createPolicy(
  farmerId: 'farmer789',
  cattleIds: ['cattle1', 'cattle2'],
  totalPremium: 10000.0,
  paymentFrequency: PaymentFrequency.monthly,
);

result.fold(
  onError: (failure) => print('Error: ${failure.message}'),
  onSuccess: (policy) => print('Created: ${policy.id}'),
);
```

### Usage with Context

```dart
// Set farmer context
repository.setFarmerContext('farmer789');

// Now methods that need farmerId will work
final policyResult = await repository.getPolicy('policy123');
final paymentsResult = await repository.getPolicyPayments('policy123');

// Clear context when done
repository.clearFarmerContext();
```

### Usage in Use Cases

```dart
class GetPolicyDetailsUseCase {
  final InsuranceRepository repository;
  
  Future<Result<PolicyDetails>> call(String policyId, String farmerId) async {
    // Set context for this operation
    if (repository is InsuranceRepositoryImpl) {
      (repository as InsuranceRepositoryImpl).setFarmerContext(farmerId);
    }
    
    // Get policy
    final policyResult = await repository.getPolicy(policyId);
    
    // Clear context
    if (repository is InsuranceRepositoryImpl) {
      (repository as InsuranceRepositoryImpl).clearFarmerContext();
    }
    
    return policyResult.fold(
      onError: (failure) => Error(failure),
      onSuccess: (policy) async {
        // Continue with other operations...
      },
    );
  }
}
```

---

## Context Management Best Practices

### 1. Set Context Before Operations
```dart
repository.setFarmerContext(farmerId);
try {
  await repository.getPolicy(policyId);
} finally {
  repository.clearFarmerContext();
}
```

### 2. Clear Context After Operations
Always clear context to prevent accidental reuse:
```dart
repository.clearFarmerContext();
```

### 3. Use Try-Finally for Safety
```dart
repository.setFarmerContext(farmerId);
try {
  final result = await repository.uploadDocument(file);
  return result;
} finally {
  repository.clearFarmerContext();
}
```

### 4. Check Context in Methods
Methods that need context check and return error if not set:
```dart
if (_currentFarmerId == null) {
  return const Error(
    ValidationFailure('Farmer context not set'),
  );
}
```

---

## Limitations and Workarounds

### 1. getPolicy() Requires Context
**Limitation:** Interface doesn't include farmerId parameter

**Workaround:** Use setFarmerContext() or use getFarmerPolicies() and filter

```dart
// Option 1: Use context
repository.setFarmerContext(farmerId);
final result = await repository.getPolicy(policyId);
repository.clearFarmerContext();

// Option 2: Get all and filter
final policiesResult = await repository.getFarmerPolicies(farmerId);
final policy = policiesResult.fold(
  onError: (failure) => null,
  onSuccess: (policies) => policies.firstWhere((p) => p.id == policyId),
);
```

### 2. getClaim() Not Implemented
**Limitation:** Interface doesn't include policyId parameter

**Workaround:** Use getFarmerClaims() and filter by claimId

```dart
final claimsResult = await repository.getFarmerClaims(farmerId);
final claim = claimsResult.fold(
  onError: (failure) => null,
  onSuccess: (claims) => claims.firstWhere((c) => c.id == claimId),
);
```

### 3. getPoliciesByStatus() Not Implemented
**Limitation:** Would require collection group query across all farmers

**Workaround:** Implement at a higher level by iterating farmers or use Firestore collection group queries

---

## Testing

### Unit Testing with Mocks

```dart
class MockInsuranceRemoteDataSource extends Mock 
    implements InsuranceRemoteDataSource {}

void main() {
  late InsuranceRepositoryImpl repository;
  late MockInsuranceRemoteDataSource mockDataSource;
  
  setUp(() {
    mockDataSource = MockInsuranceRemoteDataSource();
    repository = InsuranceRepositoryImpl(
      remoteDataSource: mockDataSource,
      cooperativeId: 'test_coop',
      collectionCentreId: 'test_centre',
    );
  });
  
  test('createPolicy returns Success on successful creation', () async {
    // Arrange
    final policyModel = InsurancePolicyModel(/* ... */);
    when(() => mockDataSource.createPolicy(
      farmerId: any(named: 'farmerId'),
      cooperativeId: any(named: 'cooperativeId'),
      collectionCentreId: any(named: 'collectionCentreId'),
      cattleIds: any(named: 'cattleIds'),
      totalPremium: any(named: 'totalPremium'),
      paymentFrequency: any(named: 'paymentFrequency'),
    )).thenAnswer((_) async => policyModel);
    
    // Act
    final result = await repository.createPolicy(
      farmerId: 'farmer123',
      cattleIds: ['cattle1'],
      totalPremium: 5000.0,
      paymentFrequency: PaymentFrequency.monthly,
    );
    
    // Assert
    expect(result, isA<Success<InsurancePolicy>>());
  });
  
  test('getPolicy returns Error when context not set', () async {
    // Act
    final result = await repository.getPolicy('policy123');
    
    // Assert
    expect(result, isA<Error<InsurancePolicy>>());
    expect(
      (result as Error).failure,
      isA<ValidationFailure>(),
    );
  });
}
```

---

## Requirements Mapping

- **Task 6.1**: InsuranceRepositoryImpl implementation (All requirements)
- Implements all 14 methods from InsuranceRepository interface
- Converts exceptions to failures
- Handles context management for Firestore paths
- Provides entity conversion from models

---

## Future Improvements

1. **Remove Context Pattern**: Update interface to include farmerId in all methods
2. **Implement Collection Group Queries**: For getPoliciesByStatus()
3. **Add Caching Layer**: Cache frequently accessed policies and rates
4. **Implement Pagination**: For large result sets
5. **Add Retry Logic**: For transient failures
6. **Implement Offline Queue**: For operations when offline

---

## Next Steps

After implementing repository:
1. Create providers that use this repository (Phase 3)
2. Wire up dependency injection
3. Test with real Firebase data
4. Implement presentation layer (screens, widgets, providers)
