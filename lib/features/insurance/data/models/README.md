# Insurance Data Models

This directory contains all data models for the Insurance Management feature. These models handle Firestore serialization and deserialization, converting between domain entities and Firestore documents.

## Models Overview

### 1. InsurancePolicyModel
**Purpose:** Firestore serialization for InsurancePolicy entity

**Key Features:**
- Extends InsurancePolicy entity
- Handles timestamp conversions (DateTime ↔ Firestore Timestamp)
- Serializes enums (PolicyStatus, PaymentFrequency)
- Handles list serialization (coveredCattleIds)

**Methods:**
- `fromFirestore(DocumentSnapshot)` - Convert Firestore document to model
- `toFirestore()` - Convert model to Firestore map
- `fromEntity(InsurancePolicy)` - Convert entity to model
- `toEntity()` - Convert model to entity

**Firestore Structure:**
```json
{
  "farmerId": "string",
  "cooperativeId": "string",
  "collectionCentreId": "string",
  "insurancePartnerId": "string",
  "coveredCattleIds": ["string"],
  "totalPremium": 50000.0,
  "installmentAmount": 4166.67,
  "paymentFrequency": "monthly",
  "policyStartDate": Timestamp,
  "policyEndDate": Timestamp,
  "status": "active",
  "nextPaymentDue": Timestamp,
  "totalPaid": 0.0,
  "outstandingPremium": 50000.0,
  "createdAt": Timestamp,
  "updatedAt": Timestamp,
  "createdBy": "string"
}
```

---

### 2. InsuranceClaimModel
**Purpose:** Firestore serialization for InsuranceClaim entity

**Key Features:**
- Extends InsuranceClaim entity
- Handles complex nested data (statusUpdates array)
- Serializes enums (LossType, ClaimStatus)
- Handles optional fields (settlementAmount, settlementDate)
- Handles list serialization (supportingDocuments)

**Methods:**
- `fromFirestore(DocumentSnapshot)` - Convert Firestore document to model
- `toFirestore()` - Convert model to Firestore map
- `fromEntity(InsuranceClaim)` - Convert entity to model
- `toEntity()` - Convert model to entity

**Firestore Structure:**
```json
{
  "policyId": "string",
  "cattleId": "string",
  "farmerId": "string",
  "lossType": "death",
  "lossDate": Timestamp,
  "description": "string",
  "claimAmount": 50000.0,
  "submittedDate": Timestamp,
  "status": "submitted",
  "statusUpdates": [
    {
      "status": "submitted",
      "date": Timestamp,
      "comment": "string"
    }
  ],
  "settlementAmount": 50000.0,
  "settlementDate": Timestamp,
  "supportingDocuments": ["url1", "url2"],
  "submittedBy": "string",
  "reviewedBy": "string",
  "reviewComments": "string"
}
```

**Special Handling:**
- `statusUpdates` array is parsed into `ClaimStatusUpdate` objects
- Null safety for optional fields (settlementAmount, settlementDate, reviewedBy, reviewComments)

---

### 3. PremiumPaymentModel
**Purpose:** Firestore serialization for PremiumPayment entity

**Key Features:**
- Extends PremiumPayment entity
- Handles timestamp conversions
- Serializes PaymentMethod enum
- Handles optional milkDeliveryId

**Methods:**
- `fromFirestore(DocumentSnapshot)` - Convert Firestore document to model
- `toFirestore()` - Convert model to Firestore map
- `fromEntity(PremiumPayment)` - Convert entity to model
- `toEntity()` - Convert model to entity

**Firestore Structure:**
```json
{
  "policyId": "string",
  "amount": 4166.67,
  "paymentDate": Timestamp,
  "paymentMethod": "milkDeduction",
  "milkDeliveryId": "string",
  "recordedBy": "string"
}
```

---

### 4. PremiumRateModel
**Purpose:** Firestore serialization for PremiumRate

**Key Features:**
- Extends PremiumRate class
- Handles nested age range object
- Stores breed and health categories as strings
- Handles timestamp conversions

**Methods:**
- `fromFirestore(DocumentSnapshot)` - Convert Firestore document to model
- `toFirestore()` - Convert model to Firestore map
- `fromEntity(PremiumRate)` - Convert entity to model
- `toEntity()` - Convert model to entity

**Firestore Structure:**
```json
{
  "cattleAgeRange": {
    "min": 0,
    "max": 24
  },
  "breedCategory": "local",
  "healthStatus": "healthy",
  "baseRate": 5000.0,
  "effectiveDate": Timestamp,
  "isActive": true
}
```

---

## Design Patterns

### 1. Model Extends Entity
All models extend their corresponding domain entities. This provides:
- Type safety
- Automatic inheritance of entity properties
- No need for duplicate field definitions

```dart
class InsurancePolicyModel extends InsurancePolicy {
  const InsurancePolicyModel({
    required super.id,
    required super.farmerId,
    // ... all entity fields
  });
}
```

### 2. Three-Way Conversion
Each model supports three conversion methods:

**From Firestore:**
```dart
factory InsurancePolicyModel.fromFirestore(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;
  return InsurancePolicyModel(/* ... */);
}
```

**To Firestore:**
```dart
Map<String, dynamic> toFirestore() {
  return {
    'farmerId': farmerId,
    // ... all fields
  };
}
```

**Entity Conversion:**
```dart
// Entity → Model
factory InsurancePolicyModel.fromEntity(InsurancePolicy policy) {
  return InsurancePolicyModel(/* ... */);
}

// Model → Entity
InsurancePolicy toEntity() {
  return InsurancePolicy(/* ... */);
}
```

### 3. Enum Serialization
Enums are serialized using their `name` property:

```dart
// To Firestore
'status': status.name,  // "active"

// From Firestore
status: PolicyStatus.values.firstWhere(
  (e) => e.name == data['status'],
  orElse: () => PolicyStatus.active,
),
```

### 4. Timestamp Handling
DateTime objects are converted to/from Firestore Timestamps:

```dart
// To Firestore
'createdAt': Timestamp.fromDate(createdAt),

// From Firestore
createdAt: (data['createdAt'] as Timestamp).toDate(),
```

### 5. Null Safety
Optional fields are handled with null checks:

```dart
settlementAmount: data['settlementAmount'] != null
    ? (data['settlementAmount'] as num).toDouble()
    : null,
```

### 6. List Handling
Lists are converted using `List.from()`:

```dart
// To Firestore
'coveredCattleIds': coveredCattleIds,

// From Firestore
coveredCattleIds: List<String>.from(data['coveredCattleIds'] as List),
```

---

## Usage Examples

### Creating and Saving a Policy

```dart
// Create entity
final policy = InsurancePolicy(
  id: 'policy123',
  farmerId: 'farmer456',
  // ... other fields
);

// Convert to model
final model = InsurancePolicyModel.fromEntity(policy);

// Save to Firestore
await firestore
    .collection('insurancePolicies')
    .doc(policy.id)
    .set(model.toFirestore());
```

### Reading from Firestore

```dart
// Get document
final doc = await firestore
    .collection('insurancePolicies')
    .doc('policy123')
    .get();

// Convert to model
final model = InsurancePolicyModel.fromFirestore(doc);

// Convert to entity
final policy = model.toEntity();
```

### Querying and Converting

```dart
// Query Firestore
final snapshot = await firestore
    .collection('insurancePolicies')
    .where('farmerId', isEqualTo: 'farmer456')
    .get();

// Convert all documents to entities
final policies = snapshot.docs
    .map((doc) => InsurancePolicyModel.fromFirestore(doc).toEntity())
    .toList();
```

---

## Error Handling

Models include safe enum parsing with fallback values:

```dart
status: PolicyStatus.values.firstWhere(
  (e) => e.name == data['status'],
  orElse: () => PolicyStatus.active,  // Fallback
),
```

This prevents crashes if Firestore contains invalid enum values.

---

## Testing

Models can be tested independently:

```dart
test('InsurancePolicyModel serialization', () {
  final policy = InsurancePolicy(/* ... */);
  final model = InsurancePolicyModel.fromEntity(policy);
  final map = model.toFirestore();
  
  expect(map['farmerId'], equals(policy.farmerId));
  expect(map['status'], equals('active'));
});
```

---

## Requirements Mapping

- **Task 4.1**: InsurancePolicyModel (Requirements 1.7)
- **Task 4.2**: InsuranceClaimModel (Requirements 5.5, 6.3)
- **Task 4.3**: PremiumPaymentModel (Requirements 2.4, 3.4)
- **Task 4.4**: PremiumRateModel (Requirements 9.1, 9.2)

---

## Next Steps

After creating models:
1. Create data sources that use these models (Task 5)
2. Implement repository that uses data sources (Task 6)
3. Test Firestore operations with real data
