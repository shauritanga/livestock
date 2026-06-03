# Insurance Cloud Functions

This directory contains all Cloud Functions for the Insurance Management feature of the Agripoa platform.

## Structure

```
insurance/
├── index.ts              # Main insurance functions
├── types.ts              # TypeScript interfaces
├── helpers.ts            # Helper functions
├── seedPremiumRates.ts   # Premium rate seeding
└── README.md             # This file
```

## Functions

### 1. enrollInsurance (HTTPS Callable)
**Purpose:** Enroll a farmer in livestock insurance

**Parameters:**
- `farmerId`: string
- `cooperativeId`: string
- `collectionCentreId`: string
- `cattleIds`: string[]
- `totalPremium`: number
- `paymentFrequency`: 'monthly' | 'quarterly'

**Returns:**
```typescript
{
  success: boolean;
  policyId: string;
  message: string;
}
```

**Features:**
- Creates policy document in Firestore
- Calculates next payment due date
- Sends SMS confirmation to farmer
- Notifies insurance partner (placeholder)

### 2. calculatePremium (HTTPS Callable)
**Purpose:** Calculate insurance premium for selected cattle

**Parameters:**
- `farmerId`: string
- `cooperativeId`: string
- `collectionCentreId`: string
- `cattleIds`: string[]

**Returns:**
```typescript
{
  cattlePremiums: CattlePremium[];
  totalAnnualPremium: number;
  monthlyInstallment: number;
  quarterlyInstallment: number;
}
```

**Features:**
- Fetches cattle details from Firestore
- Applies premium rates based on age, breed, and health
- Returns detailed breakdown per cattle

### 3. deductPremium (Firestore Trigger)
**Trigger:** onCreate on milkDeliveries collection

**Purpose:** Automatically deduct insurance premiums from milk payments

**Features:**
- Queries active policies with due payments
- Deducts premium from milk payment
- Updates policy payment status
- Sends SMS notification to farmer

### 4. submitClaim (HTTPS Callable)
**Purpose:** Submit insurance claim for livestock loss

**Parameters:**
- `policyId`: string
- `farmerId`: string
- `cooperativeId`: string
- `collectionCentreId`: string
- `cattleId`: string
- `lossType`: 'death' | 'theft' | 'disease'
- `lossDate`: Date
- `description`: string
- `supportingDocuments`: string[]

**Returns:**
```typescript
{
  success: boolean;
  claimId: string;
  message: string;
}
```

**Features:**
- Validates policy is active
- Checks for duplicate claims
- Creates claim document
- Notifies insurance partner (placeholder)
- Sends SMS confirmation

### 5. updateClaimStatus (HTTPS Request - Webhook)
**Purpose:** Receive claim status updates from insurance partner

**Authentication:** API key in `x-api-key` header

**Request Body:**
```typescript
{
  claimId: string;
  status: 'submitted' | 'under_review' | 'approved' | 'rejected' | 'settled';
  settlementAmount?: number;
  comments?: string;
}
```

**Features:**
- Verifies API key authentication
- Updates claim status in Firestore
- Sends SMS notification based on status

### 6. checkExpiringPolicies (Scheduled)
**Schedule:** Daily at 9 AM EAT

**Purpose:** Send reminders for policies expiring within 30 days

**Features:**
- Queries policies expiring soon
- Sends SMS reminders to farmers
- Logs reminder activities

### 7. checkOverduePremiums (Scheduled)
**Schedule:** Daily at 10 AM EAT

**Purpose:** Suspend policies with overdue premiums > 30 days

**Features:**
- Queries policies with overdue payments
- Updates status to suspended
- Sends SMS notifications

## Premium Rates

Premium rates are stored in the `premiumRates` collection and are based on:

- **Age ranges:** 0-24, 25-60, 61-120 months
- **Breed categories:** local, crossbreed, exotic
- **Health status:** healthy, fair, poor

**Base rates:** TZS 5,000 - 15,000 per cattle annually

### Seeding Premium Rates

**Via Cloud Function:**
```typescript
// Call from authenticated client
const result = await functions.httpsCallable('seedPremiumRates')();
```

**Via Script:**
```bash
node functions/scripts/seed-premium-rates.js
```

## Helper Functions

### sendSMS(phoneNumber, message)
Sends SMS notifications (placeholder - integrate with SMS provider)

### notifyInsurancePartner(endpoint, data)
Sends notifications to insurance partner API (placeholder)

### calculateNextPaymentDue(startDate, frequency)
Calculates next payment due date based on frequency

### findMatchingRate(cattle, rates)
Finds matching premium rate for cattle characteristics

### getFarmerPhone(cooperativeId, collectionCentreId, farmerId)
Retrieves farmer's phone number from Firestore

## Data Models

See `types.ts` for complete TypeScript interfaces:
- `InsurancePolicy`
- `PremiumPayment`
- `InsuranceClaim`
- `PremiumRate`
- `PremiumCalculation`

## Firestore Structure

```
cooperatives/{cooperativeId}/
  collectionCentres/{centreId}/
    farmers/{farmerId}/
      insurancePolicies/{policyId}
        - Policy data
        
        premiumPayments/{paymentId}
          - Payment records
        
        claims/{claimId}
          - Claim records

premiumRates/{rateId}
  - Rate configuration
```

## SMS Notifications

All SMS messages are sent in Swahili for farmer accessibility:

- **Enrollment:** Policy number, premium, payment frequency
- **Premium Deduction:** Amount deducted, next due date, balance
- **Claim Submission:** Claim number, cattle ID
- **Claim Status:** Updates on approval, rejection, settlement
- **Policy Expiry:** Reminder with days until expiry
- **Overdue Premium:** Suspension notice with amount due

## TODO

- [ ] Integrate with actual SMS provider (Twilio/Africa's Talking)
- [ ] Integrate with insurance partner API
- [ ] Configure API key for webhook authentication
- [ ] Add comprehensive error handling
- [ ] Add retry logic for failed notifications
- [ ] Implement claim amount calculation based on cattle value
- [ ] Add policy renewal functionality

## Testing

The insurance functions can be tested using:

1. **Firebase Emulator Suite:**
```bash
npm run serve --prefix functions
```

2. **Firebase Functions Shell:**
```bash
npm run shell --prefix functions
```

3. **Direct Deployment:**
```bash
npm run deploy --prefix functions
```

## Notes

- All functions use Firebase Functions v2 API
- Authentication is required for all callable functions
- Scheduled functions run in Africa/Nairobi timezone
- SMS and partner notifications are placeholders for production integration
