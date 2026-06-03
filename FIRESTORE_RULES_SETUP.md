# Firestore Security Rules Setup

## Overview

The Firestore security rules control who can read and write data in your Firebase database. These rules are essential for protecting your data and ensuring users can only access what they're authorized to see.

## Quick Setup

### Option 1: Deploy via Firebase CLI (Recommended)

```bash
# Install Firebase CLI if you haven't already
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in your project (if not done already)
firebase init firestore

# Deploy the rules
firebase deploy --only firestore:rules
```

### Option 2: Manual Upload via Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Click on "Firestore Database" in the left menu
4. Click on the "Rules" tab
5. Copy the contents of `firestore.rules` file
6. Paste into the rules editor
7. Click "Publish"

## What the Rules Do

### Role-Based Access Control

The rules implement role-based access with these roles:
- **system_admin**: Full access to everything
- **cooperative_manager**: Access to their cooperative's data
- **collection_agent**: Access to their collection centre's data
- **farmer**: Access to their own data only
- **financial_partner**: Access to loan data
- **insurance_partner**: Access to insurance data

### Key Permissions

**Collection Agents can:**
- ✅ Read all farmers in their collection centre
- ✅ Create new farmers
- ✅ Update farmer information
- ✅ Register cattle for farmers
- ✅ Record milk deliveries
- ✅ Initiate loan and insurance applications

**Farmers can:**
- ✅ Read their own data
- ✅ Update their contact information
- ✅ View their cattle, deliveries, loans, and insurance
- ✅ Submit insurance claims

**Cooperative Managers can:**
- ✅ Access all data in their cooperative
- ✅ Manage farmers and collection centres
- ✅ View reports and analytics

## Testing the Rules

After deploying, test that:

1. **Collection agent can view farmers**:
   - Login as agent@test.com
   - Navigate to Farmers tab
   - Should see the 3 seeded farmers

2. **Collection agent can register farmers**:
   - Click "Register Farmer"
   - Fill in the form
   - Should successfully create farmer

3. **Farmers are isolated**:
   - Each agent only sees farmers in their centre
   - Farmers only see their own data

## Troubleshooting

### Error: "Caller does not have permission"

**Cause**: Security rules are blocking the request

**Solutions**:
1. **Check if rules are deployed**:
   ```bash
   firebase deploy --only firestore:rules
   ```

2. **Verify custom claims are set**:
   - The seed script should have set custom claims
   - Check in Firebase Console > Authentication > Users
   - Click on the agent user and check "Custom claims"

3. **Check user is authenticated**:
   - Make sure you're logged in
   - Try logging out and back in

4. **Verify cooperative and centre IDs match**:
   - User's custom claims should have:
     - `cooperativeId: "coop_test_001"`
     - `collectionCentreId: "centre_test_001"`
   - These should match the IDs in Firestore

### Error: "Missing or insufficient permissions"

**Cause**: User doesn't have the required custom claims

**Solution**: Re-run the seed script to ensure custom claims are set:
```bash
node scripts/seed-data.js
```

### Rules Not Taking Effect

**Cause**: Rules not deployed or cached

**Solutions**:
1. Deploy rules again:
   ```bash
   firebase deploy --only firestore:rules
   ```

2. Wait a few minutes for propagation

3. Clear app data and restart

## Security Best Practices

✅ **Do:**
- Always authenticate users before accessing data
- Use custom claims for role-based access
- Test rules thoroughly before production
- Keep rules as restrictive as possible
- Log and monitor access patterns

❌ **Don't:**
- Never allow public read/write access in production
- Don't store sensitive data in custom claims
- Don't rely on client-side validation alone
- Don't use overly permissive rules

## Rule Structure

```
cooperatives/{cooperativeId}
  └── collectionCentres/{centreId}
      └── farmers/{farmerId}
          ├── cattle/{cattleId}
          ├── milkDeliveries/{deliveryId}
          ├── loans/{loanId}
          │   └── repayments/{repaymentId}
          └── insurancePolicies/{policyId}
              └── claims/{claimId}
```

Each level has specific read/write permissions based on user role and relationship to the data.

## Custom Claims Structure

Users have these custom claims set:
```json
{
  "role": "collection_agent",
  "cooperativeId": "coop_test_001",
  "collectionCentreId": "centre_test_001"
}
```

These are checked by the security rules to determine access.

## Next Steps

1. Deploy the rules using one of the methods above
2. Test the app - farmers list should now load
3. Try creating a new farmer
4. Verify data isolation works correctly

---

For more information on Firestore Security Rules, see:
- [Firebase Security Rules Documentation](https://firebase.google.com/docs/firestore/security/get-started)
- [Security Rules Language Reference](https://firebase.google.com/docs/rules/rules-language)
