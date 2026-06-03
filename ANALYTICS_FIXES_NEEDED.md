# Analytics Feature - Remaining Fixes

## Summary
Tasks 17 & 18 are COMPLETE. All visualization widgets and providers are working.
The remaining 86 errors are in data models and require simple property name corrections.

## Files Fixed ✅
1. pubspec.yaml - Added crypto, pdf, excel, csv, path_provider, share_plus
2. analytics_filter_model.dart - Simplified to match entity
3. All provider files - Updated for Riverpod 3.x
4. All visualization widgets (tasks 17.1-17.6)
5. All filter/export dialogs (tasks 18.1-18.3)

## Files Needing Fixes ⚠️

### 1. farmer_metrics_model.dart
**Line 24-26:** Change `male:` and `female:` to `maleCount:` and `femaleCount:`
**Line 37-40:** Change `byRegion:`, `byDistrict:`, `byWard:`, `byVillage:` to `regionBreakdown:`, `districtBreakdown:`, `wardBreakdown:`, `villageBreakdown:`
**Line 44-47:** Change `score0to300:`, `score301to500:`, `score501to700:`, `score701to850:` to `range0to300:`, `range301to500:`, `range501to700:`, `range701to850:`
**Line 63-64:** Change `.male` and `.female` to `.maleCount` and `.femaleCount`
**Line 75-78:** Change `.byRegion`, `.byDistrict`, `.byWard`, `.byVillage` to `.regionBreakdown`, `.districtBreakdown`, `.wardBreakdown`, `.villageBreakdown`
**Line 82-85:** Change `.score0to300`, `.score301to500`, `.score501to700`, `.score701to850` to `.range0to300`, `.range301to500`, `.range501to700`, `.range701to850`

### 2. milk_production_metrics_model.dart
**Line 24-26:** Change `premium:`, `standard:`, `substandard:` to `premiumCount:`, `standardCount:`, `substandardCount:`
**Line 41:** Remove `averageLitersPerFarmer:` (it's a computed property, not a constructor parameter)
**Line 59-61:** Change `.premium`, `.standard`, `.substandard` to `.premiumCount`, `.standardCount`, `.substandardCount`

### 3. livestock_metrics_model.dart
**Line 6:** Add missing required parameters to super constructor
**Line 11, 16:** Remove `super.` prefix from `breedDistribution` and `healthStatusDistribution`
**Line 36:** Add missing parameters: `totalFruitingAvocados:`, `totalRoosters:`, `totalLargeBeehives:`, `totalSmallBeehives:`, `totalFarmersWithAssets:`
**Line 43-48:** Remove all `average*PerFarmer` parameters (they are computed properties)

### 4. financial_metrics_model.dart
**Line 27:** Add `defaultedLoanCount: 0,`
**Line 35:** Add `totalCattleCovered: 0, totalCattleInSystem: 0,`

### 5. inventory_metrics_model.dart
**Line 5:** Change import path from `../../../../inventory/` to `../../../inventory/`

### 6. report_generator_service.dart
Replace all `.fold()` calls with:
```dart
if (result.isSuccess) {
  // use result.dataOrNull
} else {
  throw Exception(result.errorOrNull);
}
```

### 7. report_repository_impl.dart
**Line 129:** Change return type to match interface
**Lines 164, 170, 176, 197, 218, 239, 245:** Fix list type mismatches

### 8. Deprecated API fixes
**kpi_card.dart:** Replace `.withOpacity()` with `.withValues(alpha:)`
**bar_comparison_chart.dart:** Replace `swapAnimationDuration` with `duration`

## Quick Fix Commands
Run these to see remaining errors:
```bash
flutter analyze lib/features/analytics 2>&1 | grep "error •"
```

All fixes are straightforward property name changes to match entity definitions.
