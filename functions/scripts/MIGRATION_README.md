# Firestore Migration: Nested to Flat Structure

This directory contains scripts for migrating the Firestore database from a nested structure to a flat structure.

## Overview

### Current Structure (Nested)
```
cooperatives/{cooperativeId}
  └── collectionCentres/{centreId}
      └── farmers/{farmerId}
          ├── cattle/{cattleId}
          ├── milkDeliveries/{deliveryId}
          └── insurancePolicies/{policyId}
              ├── premiumPayments/{paymentId}
              └── claims/{claimId}
```

### New Structure (Flat)
```
farmers/{farmerId}
  - cooperativeId (indexed)
  - NO collectionCentreId

cattle/{cattleId}
  - farmerId (indexed)
  - cooperativeId (indexed)

milkDeliveries/{deliveryId}
  - farmerId (indexed)
  - cooperativeId (indexed)
  - NO collectionCentreId

insurancePolicies/{policyId}
  - farmerId (indexed)
  - cooperativeId (indexed)
  └── premiumPayments/{paymentId} (subcollection)
  └── claims/{claimId} (subcollection)
```

## Migration Script

### Features

- ✅ Batch processing (500 documents per batch)
- ✅ Error logging and tracking
- ✅ Progress reporting
- ✅ Data integrity verification
- ✅ Dry-run mode for testing
- ✅ Selective migration by cooperative
- ✅ Preserves original data (no deletion)

### Usage

#### 1. Dry Run (Test Mode)

Test the migration without making any changes:

```bash
cd functions
node scripts/migrate-to-flat-structure.js --dry-run
```

This will:
- Scan all data
- Report what would be migrated
- Show statistics
- NOT make any changes to Firestore

#### 2. Migrate Specific Cooperative

Migrate a single cooperative for testing:

```bash
node scripts/migrate-to-flat-structure.js --cooperative=coop_test_001
```

#### 3. Full Migration

Migrate all cooperatives:

```bash
node scripts/migrate-to-flat-structure.js
```

**⚠️ WARNING**: This will copy all data to flat collections. Make sure you have:
- Tested with dry-run
- Tested with a single cooperative
- Backed up your database
- Deployed new indexes
- Reviewed the migration plan

### Output

The script provides detailed output:

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

🐄 Migrating cattle...
   ✅ Migrated 420 cattle

🛡️  Migrating insurance policies...
   ✅ Migrated 85 insurance policies

🔍 Verifying migration...

📊 Verification Results:
   Farmers: 150 (expected: 150)
   Milk Deliveries: 3,450 (expected: 3,450)
   Cattle: 420 (expected: 420)
   Insurance Policies: 85 (expected: 85)

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

Milk Deliveries:
  Total: 10,350
  Migrated: 10,350
  Errors: 0

Cattle:
  Total: 1,260
  Migrated: 1,260
  Errors: 0

Insurance Policies:
  Total: 255
  Migrated: 255
  Errors: 0

✅ Verification:
  Farmers: ✅
  Deliveries: ✅
  Cattle: ✅
  Policies: ✅

============================================================
✅ Migration completed successfully!
============================================================
```

## Pre-Migration Checklist

Before running the migration:

- [ ] **Backup Database**
  ```bash
  firebase firestore:export gs://your-bucket/firestore-backup-$(date +%Y%m%d)
  ```

- [ ] **Deploy Indexes**
  ```bash
  firebase deploy --only firestore:indexes
  ```
  Wait for all indexes to build (check Firebase Console)

- [ ] **Test in Staging**
  - Run dry-run in staging
  - Run full migration in staging
  - Test application with migrated data
  - Verify all features work

- [ ] **Review Code Changes**
  - All datasources updated
  - All models updated
  - All use cases updated
  - All screens updated
  - Security rules updated

- [ ] **Communication**
  - Notify team of migration schedule
  - Prepare rollback plan
  - Have team members on standby

## Migration Steps

### Phase 1: Preparation (No Downtime)

1. Deploy updated `firestore.indexes.json`
   ```bash
   firebase deploy --only firestore:indexes
   ```

2. Wait for indexes to build (30-60 minutes for large datasets)
   - Check Firebase Console → Firestore → Indexes
   - All indexes should show "Enabled" status

3. Deploy new security rules (with backward compatibility)
   ```bash
   firebase deploy --only firestore:rules
   ```

4. Test that existing app still works

### Phase 2: Data Migration (Read-Only Mode)

1. Put application in maintenance mode
   - Display banner: "System maintenance in progress"
   - Disable write operations (optional)

2. Run migration script
   ```bash
   cd functions
   node scripts/migrate-to-flat-structure.js
   ```

3. Verify migration completed successfully
   - Check output for errors
   - Verify document counts match
   - Sample check documents in Firebase Console

### Phase 3: Application Update (Brief Downtime)

1. Deploy updated Flutter application
   ```bash
   flutter build apk --release
   # Upload to app stores
   ```

2. Deploy updated Cloud Functions
   ```bash
   cd functions
   npm run build
   firebase deploy --only functions
   ```

3. Remove maintenance mode

4. Monitor application
   - Check error logs
   - Monitor performance metrics
   - Verify user reports

### Phase 4: Cleanup (Post-Migration)

1. Monitor for 48 hours
   - Watch for errors
   - Check performance
   - Collect user feedback

2. After 1 week: Archive old nested data
   ```bash
   firebase firestore:export gs://your-bucket/firestore-archive-nested-$(date +%Y%m%d)
   ```

3. After 2 weeks: Delete old nested collections (if no issues)
   - Use Firebase Console or script
   - Keep backup for 30 days

## Troubleshooting

### Migration Fails with "Index not ready"

**Solution**: Wait for all indexes to build before running migration.

```bash
# Check index status
firebase firestore:indexes
```

### Migration Shows Errors

**Solution**: Check error log in output. Common issues:

- Missing required fields (farmerId, cooperativeId)
- Invalid data types
- Permission issues

Fix data issues and re-run migration for affected documents.

### Document Counts Don't Match

**Solution**: 

1. Check error log for failed documents
2. Manually verify sample documents
3. Re-run migration for specific cooperative:
   ```bash
   node scripts/migrate-to-flat-structure.js --cooperative=<id>
   ```

### Application Not Working After Migration

**Solution**: See [MIGRATION_ROLLBACK.md](./MIGRATION_ROLLBACK.md) for rollback procedure.

## Verification Queries

After migration, verify data integrity:

### Check Farmers

```javascript
// In Firebase Console or script
db.collection('farmers')
  .where('cooperativeId', '==', 'coop_001')
  .get()
  .then(snapshot => {
    console.log(`Farmers in coop_001: ${snapshot.size}`);
    
    // Check sample farmer
    if (!snapshot.empty) {
      const farmer = snapshot.docs[0].data();
      console.log('Sample farmer:', {
        hasCooperativeId: !!farmer.cooperativeId,
        hasCollectionCentreId: !!farmer.collectionCentreId, // Should be false
        name: farmer.name
      });
    }
  });
```

### Check Milk Deliveries

```javascript
db.collection('milkDeliveries')
  .where('cooperativeId', '==', 'coop_001')
  .where('deliveryDate', '>=', new Date('2024-01-01'))
  .get()
  .then(snapshot => {
    console.log(`Deliveries in coop_001: ${snapshot.size}`);
    
    // Check sample delivery
    if (!snapshot.empty) {
      const delivery = snapshot.docs[0].data();
      console.log('Sample delivery:', {
        hasFarmerId: !!delivery.farmerId,
        hasCooperativeId: !!delivery.cooperativeId,
        hasCollectionCentreId: !!delivery.collectionCentreId, // Should be false
        quantityLiters: delivery.quantityLiters
      });
    }
  });
```

## Performance Comparison

Expected performance improvements:

| Operation | Before (Nested) | After (Flat) | Improvement |
|-----------|----------------|--------------|-------------|
| List farmers by cooperative | ~2-5s | ~200-500ms | 4-10x faster |
| Get delivery history | ~1-3s | ~100-300ms | 10x faster |
| Dashboard metrics | ~5-10s | ~500ms-1s | 10-20x faster |
| Analytics queries | ~30-60s | ~3-5s | 10-20x faster |

## Support

For issues or questions:

1. Check [MIGRATION_ROLLBACK.md](./MIGRATION_ROLLBACK.md)
2. Review error logs in script output
3. Contact technical lead
4. Check Firebase Console for data verification

## Related Documentation

- [Requirements Document](../../.kiro/specs/firestore-restructure/requirements.md)
- [Design Document](../../.kiro/specs/firestore-restructure/design.md)
- [Implementation Tasks](../../.kiro/specs/firestore-restructure/tasks.md)
- [Rollback Procedure](./MIGRATION_ROLLBACK.md)
