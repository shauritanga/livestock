# Migration Rollback Procedure

This document describes how to rollback the Firestore restructuring migration if issues are discovered.

## Overview

The migration script (`migrate-to-flat-structure.js`) copies data from the nested structure to the flat structure **without deleting the original data**. This means rollback is straightforward - simply revert the application code to use the old nested structure.

## Rollback Steps

### 1. Immediate Rollback (Application Level)

If issues are discovered immediately after deployment:

1. **Revert Flutter Application**
   ```bash
   # Checkout previous version
   git checkout <previous-commit-hash>
   
   # Or revert specific commits
   git revert <commit-hash>
   
   # Rebuild and redeploy
   flutter build apk
   # Deploy to app stores
   ```

2. **Revert Cloud Functions**
   ```bash
   # Checkout previous version
   git checkout <previous-commit-hash> functions/
   
   # Redeploy functions
   cd functions
   npm run build
   firebase deploy --only functions
   ```

3. **Revert Security Rules**
   ```bash
   # Checkout previous rules
   git checkout <previous-commit-hash> firestore.rules
   
   # Deploy old rules
   firebase deploy --only firestore:rules
   ```

### 2. Data Cleanup (Optional)

If you want to remove the migrated flat collections:

```javascript
// Run this script to delete flat collections
// WARNING: This is destructive!

const admin = require('firebase-admin');
const serviceAccount = require('../serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function cleanupFlatCollections() {
  console.log('⚠️  WARNING: This will delete all flat collection data!');
  console.log('Press Ctrl+C to cancel...');
  
  await new Promise(resolve => setTimeout(resolve, 5000));
  
  const collections = ['farmers', 'milkDeliveries', 'cattle', 'insurancePolicies'];
  
  for (const collectionName of collections) {
    console.log(`Deleting ${collectionName}...`);
    const snapshot = await db.collection(collectionName).get();
    
    const batches = [];
    let batch = db.batch();
    let count = 0;
    
    for (const doc of snapshot.docs) {
      batch.delete(doc.ref);
      count++;
      
      if (count >= 500) {
        batches.push(batch.commit());
        batch = db.batch();
        count = 0;
      }
    }
    
    if (count > 0) {
      batches.push(batch.commit());
    }
    
    await Promise.all(batches);
    console.log(`✅ Deleted ${snapshot.size} documents from ${collectionName}`);
  }
  
  console.log('✅ Cleanup complete');
  process.exit(0);
}

cleanupFlatCollections();
```

### 3. Verification After Rollback

After rolling back, verify the application works correctly:

1. **Test Farmer Registration**
   - Register a new farmer
   - Verify data is saved to nested structure
   - Check that farmer appears in lists

2. **Test Milk Delivery Recording**
   - Record a milk delivery
   - Verify delivery is saved to nested structure
   - Check that delivery appears in history

3. **Test Dashboard**
   - View dashboard metrics
   - Verify data is loaded from nested structure
   - Check that analytics work correctly

4. **Test Analytics**
   - Generate reports
   - Verify Cloud Functions query nested structure
   - Check that calculations are correct

## Prevention of Data Loss

The migration script is designed to be safe:

1. **No Deletion**: Original nested data is never deleted
2. **Dry Run Mode**: Test migration without making changes
3. **Batch Processing**: Handles large datasets efficiently
4. **Error Logging**: Tracks all errors for investigation
5. **Verification**: Compares document counts after migration

## Timeline for Cleanup

Recommended timeline for removing old nested data:

- **Day 0**: Run migration, deploy new code
- **Day 1-2**: Monitor for issues, verify functionality
- **Day 3-7**: Continue monitoring, collect user feedback
- **Week 2**: If no issues, archive nested data (don't delete)
- **Week 4**: If still no issues, can safely delete nested data

## Archiving Old Data

Before deleting nested data, export it for archival:

```bash
# Export nested data to JSON
gcloud firestore export gs://your-bucket/firestore-backup-nested-$(date +%Y%m%d)

# Or use Firebase CLI
firebase firestore:export gs://your-bucket/firestore-backup-nested-$(date +%Y%m%d)
```

## Emergency Contacts

If issues arise during migration:

1. **Technical Lead**: [Contact Info]
2. **Database Admin**: [Contact Info]
3. **DevOps Team**: [Contact Info]

## Rollback Decision Criteria

Consider rollback if:

- ✅ Data integrity issues detected
- ✅ Performance degradation > 50%
- ✅ Critical features not working
- ✅ Security rules not enforcing isolation
- ✅ User reports of missing data

Do NOT rollback for:

- ❌ Minor UI issues (can be fixed with hotfix)
- ❌ Non-critical feature bugs
- ❌ Cosmetic problems
- ❌ Individual user issues (investigate first)

## Post-Rollback Actions

After rollback:

1. **Document Issues**: Record what went wrong
2. **Analyze Root Cause**: Understand why rollback was needed
3. **Fix Issues**: Address problems in code
4. **Test Thoroughly**: Test fixes in staging
5. **Plan Re-migration**: Schedule new migration attempt

## Testing Rollback Procedure

Test the rollback procedure in a staging environment:

1. Run migration in staging
2. Deploy new code to staging
3. Verify functionality
4. Practice rollback procedure
5. Verify old code works after rollback
6. Document any issues or improvements

## Notes

- Keep this document updated with actual contact information
- Review rollback procedure before each migration
- Practice rollback in staging environment
- Have team members on standby during migration
- Monitor logs and metrics closely after migration
