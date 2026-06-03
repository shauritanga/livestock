# Firestore Restructuring - Deployment Checklist

Quick reference checklist for deployment day.

## Pre-Deployment (1 day before)

- [ ] Review [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
- [ ] Review [MIGRATION_ROLLBACK.md](functions/scripts/MIGRATION_ROLLBACK.md)
- [ ] Notify team of deployment schedule
- [ ] Backup database
  ```bash
  firebase firestore:export gs://your-bucket/firestore-backup-$(date +%Y%m%d)
  ```
- [ ] Test in staging environment
- [ ] Prepare monitoring dashboards
- [ ] Assign team roles (deployer, monitor, support)

---

## Phase 1: Deploy Indexes (30-60 min)

- [ ] Deploy indexes
  ```bash
  firebase deploy --only firestore:indexes
  ```
- [ ] Monitor Firebase Console → Firestore → Indexes
- [ ] Wait for all indexes to show "Enabled"
- [ ] Verify indexes
  ```bash
  cd functions && node scripts/verify-indexes.js
  ```

**✅ Checkpoint:** All indexes enabled and verified

---

## Phase 2: Deploy Security Rules (10 min)

- [ ] Review security rules
  ```bash
  cat firestore.rules
  ```
- [ ] Deploy security rules
  ```bash
  firebase deploy --only firestore:rules
  ```
- [ ] Test security rules
  ```bash
  cd functions && node scripts/test-security-rules.js
  ```

**✅ Checkpoint:** Security rules deployed and tested

---

## Phase 3: Run Migration (30-90 min)

- [ ] **ENABLE MAINTENANCE MODE**
- [ ] Run dry-run
  ```bash
  cd functions
  node scripts/migrate-to-flat-structure.js --dry-run
  ```
- [ ] Review dry-run output
- [ ] Run full migration
  ```bash
  node scripts/migrate-to-flat-structure.js
  ```
- [ ] Verify migration completed successfully
- [ ] Check document counts match
- [ ] Run verification scripts
  ```bash
  node scripts/verify-indexes.js
  node scripts/test-security-rules.js
  ```

**✅ Checkpoint:** Data migrated and verified

---

## Phase 4: Deploy Cloud Functions (15-30 min)

- [ ] Build functions
  ```bash
  cd functions
  npm run build
  ```
- [ ] Deploy functions
  ```bash
  firebase deploy --only functions
  ```
- [ ] Monitor function logs
  ```bash
  firebase functions:log
  ```
- [ ] Test analytics functions

**✅ Checkpoint:** Functions deployed and working

---

## Phase 5: Deploy Application (30-60 min)

- [ ] Test locally
  ```bash
  flutter run
  ```
- [ ] Run tests
  ```bash
  flutter test
  ```
- [ ] Build release
  ```bash
  flutter build apk --release
  ```
- [ ] Deploy to staging
- [ ] Test in staging
- [ ] Deploy to production
- [ ] **DISABLE MAINTENANCE MODE**

**✅ Checkpoint:** Application deployed

---

## Phase 6: Monitor (First Hour)

- [ ] Check error rates (Firebase Console)
- [ ] Monitor function execution times
- [ ] Verify query performance
- [ ] Check user reports
- [ ] Monitor app crash rates

**✅ Checkpoint:** No critical issues

---

## Post-Deployment (First 24 Hours)

- [ ] Review all error logs
- [ ] Check data consistency
- [ ] Verify analytics accuracy
- [ ] Monitor performance metrics
- [ ] Collect user feedback
- [ ] Document any issues

---

## Rollback (If Needed)

If critical issues discovered:

- [ ] Revert application code
- [ ] Revert Cloud Functions
- [ ] Revert security rules
- [ ] Test old application works
- [ ] Notify team
- [ ] Document issues
- [ ] Plan fix and re-deployment

See [MIGRATION_ROLLBACK.md](functions/scripts/MIGRATION_ROLLBACK.md) for details.

---

## Success Criteria

✅ All indexes enabled  
✅ Security rules deployed  
✅ Data migration completed (0 errors)  
✅ Functions deployed and working  
✅ Application deployed  
✅ No critical errors in first hour  
✅ Performance improved as expected  
✅ User feedback positive  

---

## Emergency Contacts

- Technical Lead: [Contact]
- Database Admin: [Contact]
- DevOps: [Contact]
- On-Call: [Contact]

---

**Deployment Date:** _______________  
**Deployed By:** _______________  
**Start Time:** _______________  
**End Time:** _______________  
**Status:** _______________
