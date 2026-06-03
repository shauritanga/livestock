# Firestore Restructuring - Deployment Guide

This guide provides step-by-step instructions for deploying the Firestore restructuring changes to production.

## Prerequisites

Before starting deployment:

- [ ] All code changes reviewed and tested
- [ ] Staging environment tested successfully
- [ ] Team members notified of deployment schedule
- [ ] Rollback plan reviewed ([MIGRATION_ROLLBACK.md](functions/scripts/MIGRATION_ROLLBACK.md))
- [ ] Database backup completed
- [ ] Monitoring tools ready

## Deployment Timeline

**Estimated Total Time: 2-4 hours**

- Phase 1 (Indexes): 30-60 minutes
- Phase 2 (Security Rules): 10 minutes
- Phase 3 (Migration): 30-90 minutes (depends on data size)
- Phase 4 (Functions): 15-30 minutes
- Phase 5 (Application): 30-60 minutes

## Phase 1: Deploy Firestore Indexes (30-60 minutes)

### Task 12.1: Deploy firestore.indexes.json

**Objective:** Deploy composite indexes required for flat collection queries.

#### Step 1: Review Index Configuration

```bash
# Review the indexes to be deployed
cat firestore.indexes.json
```

Verify the following indexes are defined:
- `farmers`: (cooperativeId, name), (cooperativeId, registeredAt)
- `milkDeliveries`: (cooperativeId, deliveryDate), (farmerId, deliveryDate)
- `cattle`: (farmerId, isActive), (cooperativeId, lactationStatus)
- `insurancePolicies`: (farmerId, status), (cooperativeId, status)

#### Step 2: Deploy Indexes

```bash
# Deploy indexes to Firebase
firebase deploy --only firestore:indexes

# Expected output:
# ✔  firestore: deployed indexes in firestore.indexes.json successfully
```

#### Step 3: Monitor Index Building

1. Open Firebase Console: https://console.firebase.google.com
2. Navigate to: Firestore Database → Indexes
3. Monitor index build status

**Index States:**
- 🟡 **Building**: Index is being created (wait)
- 🟢 **Enabled**: Index is ready to use
- 🔴 **Error**: Index failed to build (investigate)

**Expected Wait Time:**
- Small datasets (< 10k docs): 5-15 minutes
- Medium datasets (10k-100k docs): 15-30 minutes
- Large datasets (> 100k docs): 30-60 minutes

#### Step 4: Verify Indexes

Once all indexes show "Enabled" status:

```bash
cd functions
node scripts/verify-indexes.js
```

**Expected Output:**
```
🔍 Verifying Firestore Indexes
============================================================
Testing Required Indexes
============================================================

📌 Index: farmers (cooperativeId, name)
   Description: List farmers by cooperative (sorted by name)
  Testing query: farmers where cooperativeId, name
  ✅ Query executed successfully (245ms)
  📊 Results: 1 documents

[... more indexes ...]

============================================================
📊 VERIFICATION SUMMARY
============================================================
Total Indexes: 8
Passed: 8 ✅
Failed: 0 ❌

✅ All indexes are working correctly!
```

**If indexes fail:**
- Wait longer for indexes to build
- Check Firebase Console for error messages
- Verify firestore.indexes.json syntax
- Check Firestore quotas and limits

---

## Phase 2: Deploy Security Rules (10 minutes)

### Task 12.2: Deploy Updated Security Rules

**Objective:** Deploy security rules for flat collection structure with cooperative isolation.

#### Step 1: Review Security Rules

```bash
# Review the security rules
cat firestore.rules
```

Verify key changes:
- ✅ Removed `belongsToCollectionCentre` function
- ✅ Updated farmers match path: `/farmers/{farmerId}`
- ✅ Updated milkDeliveries match path: `/milkDeliveries/{deliveryId}`
- ✅ Updated cattle match path: `/cattle/{cattleId}`
- ✅ Updated insurancePolicies match path: `/insurancePolicies/{policyId}`
- ✅ All rules use `resource.data.cooperativeId` for isolation

#### Step 2: Test Rules in Emulator (Optional but Recommended)

```bash
# Start Firebase emulator
firebase emulators:start --only firestore

# In another terminal, run your integration tests
flutter test integration_test/
```

#### Step 3: Deploy Security Rules

```bash
# Deploy security rules to Firebase
firebase deploy --only firestore:rules

# Expected output:
# ✔  firestore: released rules firestore.rules to cloud.firestore
```

#### Step 4: Verify Security Rules

```bash
cd functions
node scripts/test-security-rules.js
```

**Expected Output:**
```
🔒 Testing Firestore Security Rules
============================================================

📋 Test: Cooperative Isolation - Farmers
   Verify users can only access farmers in their cooperative
   ✅ All farmers have cooperativeId, none have collectionCentreId

[... more tests ...]

============================================================
📊 TEST SUMMARY
============================================================
Total Tests: 4
Passed: 4 ✅
Failed: 0 ❌

✅ All security rule tests passed!
```

**If tests fail:**
- Verify security rules deployed correctly
- Check that data migration hasn't run yet (collectionCentreId should still exist in old data)
- Review error messages for specific issues

---

## Phase 3: Run Data Migration (30-90 minutes)

### Task 12.3: Execute Migration Script

**Objective:** Migrate data from nested to flat structure.

#### Step 1: Backup Database

```bash
# Create backup before migration
firebase firestore:export gs://your-bucket/firestore-backup-$(date +%Y%m%d-%H%M%S)

# Wait for backup to complete
# Check Firebase Console → Storage for backup
```

#### Step 2: Test Migration (Dry Run)

```bash
cd functions

# Run dry-run to see what would be migrated
node scripts/migrate-to-flat-structure.js --dry-run
```

Review the output carefully:
- Check document counts
- Verify no unexpected errors
- Confirm cooperatives to be migrated

#### Step 3: Test with Single Cooperative (Optional)

```bash
# Migrate a single test cooperative first
node scripts/migrate-to-flat-structure.js --cooperative=test_coop_001

# Verify the migration
node scripts/verify-indexes.js
node scripts/test-security-rules.js
```

#### Step 4: Run Full Migration

**⚠️ IMPORTANT: Put application in maintenance mode before this step**

```bash
# Run full migration
node scripts/migrate-to-flat-structure.js
```

**Monitor the output:**
```
🚀 Starting Firestore Migration: Nested to Flat Structure

Mode: ⚡ LIVE MIGRATION
Scope: All cooperatives

Found 3 cooperatives to migrate

🏛️  Migrating cooperative: coop_001
🏢 Migrating collection centre: centre_001

📋 Migrating farmers for cooperative coop_001...
   Found 150 farmers
   ✅ Migrated 150 farmers

🥛 Migrating milk deliveries...
   ✅ Migrated 3,450 milk deliveries

[... more output ...]

============================================================
📈 MIGRATION SUMMARY
============================================================
Duration: 45.32s
Mode: LIVE

Cooperatives: 3
Collection Centres: 5

Farmers:
  Total: 450
  Migrated: 450
  Errors: 0

[... more statistics ...]

✅ Verification:
  Farmers: ✅
  Deliveries: ✅
  Cattle: ✅
  Policies: ✅

============================================================
✅ Migration completed successfully!
============================================================
```

#### Step 5: Verify Migration

```bash
# Verify data integrity
node scripts/verify-indexes.js
node scripts/test-security-rules.js

# Check document counts in Firebase Console
# Compare with migration output
```

**If migration fails:**
1. Review error log in migration output
2. Check specific failed documents
3. Fix data issues
4. Re-run migration for affected cooperatives:
   ```bash
   node scripts/migrate-to-flat-structure.js --cooperative=<failed-coop-id>
   ```

---

## Phase 4: Deploy Cloud Functions (15-30 minutes)

### Task 12.4: Deploy Updated Cloud Functions

**Objective:** Deploy Cloud Functions that query flat collections.

#### Step 1: Build Functions

```bash
cd functions

# Install dependencies (if not already done)
npm install

# Build TypeScript functions
npm run build

# Expected output:
# > tsc
# (no errors)
```

#### Step 2: Test Functions Locally (Optional)

```bash
# Start functions emulator
firebase emulators:start --only functions,firestore

# Test functions using Firebase Console or API calls
```

#### Step 3: Deploy Functions

```bash
# Deploy all functions
firebase deploy --only functions

# Or deploy specific functions
firebase deploy --only functions:calculateMilkProductionMetrics,calculateFarmerDemographics,calculateFinancialMetrics,calculateLivestockMetrics

# Expected output:
# ✔  functions: Finished running predeploy script.
# ✔  functions[calculateMilkProductionMetrics(us-central1)]: Successful update operation.
# [... more functions ...]
```

#### Step 4: Monitor Function Logs

```bash
# Watch function logs in real-time
firebase functions:log --only calculateMilkProductionMetrics

# Or view logs in Firebase Console
# Functions → Logs
```

#### Step 5: Test Analytics Calculations

Test each analytics function:

```bash
# Test milk production metrics
# Use Firebase Console → Functions → Test function
# Or use API client to call functions

# Verify:
# - Functions execute without errors
# - Query times are improved
# - Results are accurate
```

**Expected Performance Improvements:**
- Query time: 10-20x faster
- Execution time: 5-10x faster
- Memory usage: Similar or lower

---

## Phase 5: Deploy Flutter Application (30-60 minutes)

### Task 12.5: Deploy Updated Flutter Application

**Objective:** Deploy Flutter app that uses flat collection structure.

#### Step 1: Test Locally

```bash
# Run app locally
flutter run

# Test key features:
# - Farmer registration (no collectionCentreId)
# - Milk delivery recording
# - Farmer list loading
# - Dashboard metrics
# - Analytics reports
```

#### Step 2: Run Tests

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Expected: All tests pass
```

#### Step 3: Build Release

```bash
# Build Android APK
flutter build apk --release

# Build iOS (if applicable)
flutter build ios --release

# Build for web (if applicable)
flutter build web --release
```

#### Step 4: Deploy to Staging

```bash
# Deploy to staging environment
# (Process depends on your deployment setup)

# Test in staging:
# - Register new farmer
# - Record milk delivery
# - View dashboard
# - Generate reports
# - Test with multiple users
```

#### Step 5: Deploy to Production

```bash
# Deploy to production
# (Process depends on your deployment setup)

# For app stores:
# - Upload to Google Play Console
# - Upload to Apple App Store
# - Submit for review

# For web:
# - Deploy to hosting service
# - Update DNS if needed
```

#### Step 6: Remove Maintenance Mode

Once application is deployed and verified:
- Remove maintenance banner
- Enable write operations
- Notify users that system is back online

---

## Phase 6: Monitor and Verify (Ongoing)

### Task 12.6: Monitor Application Performance

**Objective:** Ensure system is working correctly with flat structure.

#### Monitoring Checklist

**First Hour:**
- [ ] Check error rates in Firebase Console
- [ ] Monitor function execution times
- [ ] Verify query performance
- [ ] Check user reports/feedback
- [ ] Monitor app crash rates

**First 24 Hours:**
- [ ] Review all error logs
- [ ] Check data consistency
- [ ] Verify analytics accuracy
- [ ] Monitor performance metrics
- [ ] Collect user feedback

**First Week:**
- [ ] Compare performance before/after
- [ ] Review query latency trends
- [ ] Check for any data issues
- [ ] Verify all features working
- [ ] Document any issues found

#### Key Metrics to Monitor

1. **Query Performance**
   ```
   Firebase Console → Firestore → Usage
   - Read operations per second
   - Query latency (P50, P95, P99)
   ```

2. **Function Performance**
   ```
   Firebase Console → Functions → Dashboard
   - Invocations per minute
   - Execution time
   - Error rate
   ```

3. **Application Metrics**
   ```
   - App crash rate
   - API error rate
   - User session duration
   - Feature usage
   ```

4. **Data Integrity**
   ```bash
   # Run verification scripts daily
   cd functions
   node scripts/verify-indexes.js
   node scripts/test-security-rules.js
   ```

#### Performance Comparison

Expected improvements:

| Metric | Before | After | Target |
|--------|--------|-------|--------|
| Farmer list load time | 2-5s | 200-500ms | < 1s |
| Delivery history | 1-3s | 100-300ms | < 500ms |
| Dashboard load | 5-10s | 500ms-1s | < 2s |
| Analytics query | 30-60s | 3-5s | < 10s |

---

## Rollback Procedure

If critical issues are discovered:

1. **Immediate Actions:**
   ```bash
   # Revert application code
   git revert <commit-hash>
   flutter build apk --release
   # Redeploy previous version
   
   # Revert Cloud Functions
   git checkout <previous-commit> functions/
   cd functions
   npm run build
   firebase deploy --only functions
   
   # Revert security rules
   git checkout <previous-commit> firestore.rules
   firebase deploy --only firestore:rules
   ```

2. **Data Cleanup (if needed):**
   - See [MIGRATION_ROLLBACK.md](functions/scripts/MIGRATION_ROLLBACK.md)
   - Original nested data is still intact
   - Can delete flat collections if needed

3. **Verification:**
   - Test that old application works
   - Verify data access
   - Check all features
   - Monitor for 24 hours

---

## Post-Deployment Checklist

After successful deployment:

- [ ] All indexes built and enabled
- [ ] Security rules deployed and tested
- [ ] Data migration completed successfully
- [ ] Cloud Functions deployed and working
- [ ] Flutter application deployed
- [ ] Monitoring tools configured
- [ ] Performance metrics collected
- [ ] User feedback collected
- [ ] Documentation updated
- [ ] Team notified of completion

---

## Cleanup Schedule

**Week 1:**
- Monitor system closely
- Collect performance data
- Address any issues

**Week 2:**
- Archive old nested data
  ```bash
  firebase firestore:export gs://your-bucket/firestore-archive-nested-$(date +%Y%m%d)
  ```

**Week 4:**
- If no issues, can delete old nested collections
- Keep backup for 30 days minimum

---

## Support Contacts

**During Deployment:**
- Technical Lead: [Contact Info]
- Database Admin: [Contact Info]
- DevOps Team: [Contact Info]

**Emergency Escalation:**
- On-Call Engineer: [Contact Info]
- CTO: [Contact Info]

---

## Appendix: Useful Commands

### Firebase Commands

```bash
# Check current project
firebase projects:list
firebase use <project-id>

# View deployed indexes
firebase firestore:indexes

# View deployed rules
firebase firestore:rules

# View function logs
firebase functions:log

# Export data
firebase firestore:export gs://bucket/path

# Import data
firebase firestore:import gs://bucket/path
```

### Verification Commands

```bash
# Verify indexes
cd functions
node scripts/verify-indexes.js

# Test security rules
node scripts/test-security-rules.js

# Run migration (dry-run)
node scripts/migrate-to-flat-structure.js --dry-run

# Verify data
node scripts/verify-data.js
```

### Flutter Commands

```bash
# Run tests
flutter test
flutter test integration_test/

# Build release
flutter build apk --release
flutter build ios --release
flutter build web --release

# Analyze code
flutter analyze

# Check for issues
flutter doctor
```

---

**Document Version:** 1.0  
**Last Updated:** November 23, 2025  
**Status:** Ready for Deployment
