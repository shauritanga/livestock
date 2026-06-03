# Insurance Data Sources

This directory contains data sources for the Insurance Management feature. Data sources handle direct communication with Firebase services (Firestore, Storage, Auth).

## InsuranceRemoteDataSource

The `InsuranceRemoteDataSource` class provides all Firebase operations for insurance management.

### Dependencies

```dart
final FirebaseFirestore firestore;
final FirebaseStorage storage;
final FirebaseAuth auth;
```

### Method Categories

#### 1. Policy Management (4 methods)

**createPolicy()**
- Creates new insurance policy in Firestore
- Calculates installment amounts and payment dates
- Sets initial policy status to active
- Returns InsurancePolicyModel

**getPolicy()**
- Retrieves specific policy by ID
- Throws NotFoundException if policy doesn't exist
- Returns InsurancePolicyModel

**getFarmerPolicies()**
- Retrieves all policies for a farmer
- Orders by creation date (newest first)
- Returns List<InsurancePolicyModel>

**updatePolicyStatus()**
- Updates policy status (active, expired, suspended, cancelled)
- Updates updatedAt timestamp
- Returns updated InsurancePolicyModel

#### 2. Premium Calculation (1 method)

**calculatePremium()**
- Fetches cattle details from Firestore
- Fetches active premium rates
- Matches cattle to appropriate rates based on age and breed
- Calculates premium for each cattle
- Returns PremiumCalculation with breakdown

**Helper Methods:**
- `_findMatchingRate()` - Finds premium rate for cattle
- `_getBreedCategory()` - Categorizes breed (local, crossbreed, exotic)

#### 3. Premium Payments (2 methods)

**recordPremiumPayment()**
- Creates payment record in subcollection
- Updates policy totalPaid and outstandingPremium
- Calculates and updates nextPaymentDue
- Returns void

**getPolicyPayments()**
- Retrieves all payments for a policy
- Orders by payment date (newest first)
- Returns List<PremiumPaymentModel>

#### 4. Claims Management (4 methods)

**createClaim()**
- Creates new claim in Firestore
- Initializes with 'submitted' status
- Creates initial status update
- Returns InsuranceClaimModel

**getClaim()**
- Retrieves specific claim by ID
- Throws NotFoundException if claim doesn't exist
- Returns InsuranceClaimModel

**getFarmerClaims()**
- Retrieves all claims across all farmer's policies
- Aggregates claims from multiple policies
- Sorts by submission date (newest first)
- Returns List<InsuranceClaimModel>

**getPolicyClaims()**
- Retrieves all claims for a specific policy
- Orders by submission date (newest first)
- Returns List<InsuranceClaimModel>

#### 5. Document Management (1 method)

**uploadDocument()**
- Uploads file to Firebase Storage
- Stores in `insurance_documents/{farmerId}/` path
- Generates unique filename with timestamp
- Returns download URL string

#### 6. Premium Rates (1 method)

**getPremiumRates()**
- Retrieves all active premium rates
- Orders by effective date (newest first)
- Returns List<PremiumRateModel>

---

## Firestore Structure

### Policy Path
```
cooperatives/{cooperativeId}/
  collectionCentres/{collectionCentreId}/
    farmers/{farmerId}/
      insurancePolicies/{policyId}
        premiumPayments/{paymentId}
        claims/{claimId}
```

### Premium Rates Path
```
premiumRates/{rateId}
```

### Storage Path
```
insurance_documents/{farmerId}/{timestamp}_{filename}
```

---

## Error Handling

The data source throws specific exceptions:

### ServerException
- Thrown for Firebase operation failures
- Contains error message from Firebase or generic message

### AuthenticationException
- Thrown when user is not authenticated
- Occurs when auth.currentUser is null

### NotFoundException
- Thrown when requested resource doesn't exist
- Used for policies, claims, and cattle

### Example
```dart
try {
  final policy = await dataSource.getPolicy(
    policyId,
    farmerId,
    cooperativeId,
    collectionCentreId,
  );
} on NotFoundException catch (e) {
  print('Policy not found: ${e.message}');
} on ServerException catch (e) {
  print('Server error: ${e.message}');
}
```

---

## Premium Calculation Logic

### Breed Categorization
```dart
String _getBreedCategory(String breed) {
  final breedLower = breed.toLowerCase();
  if (breedLower.contains('friesian') ||
      breedLower.contains('jersey') ||
      breedLower.contains('ayrshire')) {
    return 'exotic';
  } else if (breedLower.contains('cross')) {
    return 'crossbreed';
  } else {
    return 'local';
  }
}
```

### Rate Matching
1. Fetches all active premium rates
2. Filters rates by:
   - Age range (cattle age between min and max)
   - Breed category match
3. Returns first matching rate
4. Falls back to default rate (5000.0) if no match

### Default Rate
```dart
PremiumRateModel(
  id: 'default',
  minAge: 0,
  maxAge: 999,
  breedCategory: 'default',
  healthStatus: 'healthy',
  baseRate: 5000.0,
  effectiveDate: DateTime.now(),
  isActive: true,
)
```

---

## Usage Examples

### Creating a Policy
```dart
final dataSource = InsuranceRemoteDataSource(
  firestore: FirebaseFirestore.instance,
  storage: FirebaseStorage.instance,
  auth: FirebaseAuth.instance,
);

final policy = await dataSource.createPolicy(
  farmerId: 'farmer123',
  cooperativeId: 'coop456',
  collectionCentreId: 'centre789',
  cattleIds: ['cattle1', 'cattle2'],
  totalPremium: 10000.0,
  paymentFrequency: PaymentFrequency.monthly,
);
```

### Calculating Premium
```dart
final calculation = await dataSource.calculatePremium(
  farmerId: 'farmer123',
  cooperativeId: 'coop456',
  collectionCentreId: 'centre789',
  cattleIds: ['cattle1', 'cattle2'],
);

print('Total: ${calculation.totalAnnualPremium}');
print('Monthly: ${calculation.monthlyInstallment}');
```

### Uploading Document
```dart
final file = File('/path/to/document.pdf');
final url = await dataSource.uploadDocument(file, 'farmer123');
print('Document URL: $url');
```

### Getting Farmer Claims
```dart
final claims = await dataSource.getFarmerClaims(
  'farmer123',
  'coop456',
  'centre789',
);

for (final claim in claims) {
  print('Claim ${claim.id}: ${claim.status.label}');
}
```

---

## Authentication

Most write operations require authentication:
- createPolicy
- recordPremiumPayment
- createClaim
- uploadDocument

The data source checks `auth.currentUser` and throws `AuthenticationException` if null.

---

## Offline Support

Firestore operations automatically support offline mode:
- Reads return cached data when offline
- Writes are queued and synced when online
- No additional code needed

---

## Performance Considerations

### Batch Operations
For multiple cattle premium calculations, the data source fetches all cattle in parallel using `Future.wait()`.

### Indexing
Firestore indexes required:
- `insurancePolicies` ordered by `createdAt`
- `premiumPayments` ordered by `paymentDate`
- `claims` ordered by `submittedDate`
- `premiumRates` where `isActive == true` ordered by `effectiveDate`

### Pagination
Currently not implemented. For large datasets, consider adding:
- Limit parameter
- Cursor-based pagination
- Last document tracking

---

## Requirements Mapping

- **Task 5.1**: Interface definition (implicit in class structure)
- **Task 5.2**: Policy management methods (Requirements 1.7, 3.2)
- **Task 5.3**: Premium calculation (Requirements 1.4, 9.1, 9.2)
- **Task 5.4**: Premium payment methods (Requirements 2.3, 2.4)
- **Task 5.5**: Claim methods (Requirements 5.5, 6.1, 6.2)
- **Task 5.6**: Document upload (Requirements 5.4)

---

## Testing

Data sources can be tested with Firebase Emulator:

```dart
test('createPolicy creates policy in Firestore', () async {
  final firestore = FakeFirebaseFirestore();
  final storage = MockFirebaseStorage();
  final auth = MockFirebaseAuth();
  
  final dataSource = InsuranceRemoteDataSource(
    firestore: firestore,
    storage: storage,
    auth: auth,
  );
  
  final policy = await dataSource.createPolicy(
    farmerId: 'test',
    cooperativeId: 'test',
    collectionCentreId: 'test',
    cattleIds: ['cattle1'],
    totalPremium: 5000.0,
    paymentFrequency: PaymentFrequency.monthly,
  );
  
  expect(policy.totalPremium, equals(5000.0));
  expect(policy.status, equals(PolicyStatus.active));
});
```

---

## Next Steps

After implementing data source:
1. Create repository implementation that uses this data source (Task 6)
2. Handle error conversion (Exception → Failure)
3. Add caching layer if needed
4. Implement pagination for large datasets
