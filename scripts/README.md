# Data Seeding Scripts

This directory contains scripts to seed Tanzania geographical data to Firestore.

## Overview

The scripts upload data from `data.json` to:
- **Collection**: `locations`
- **Document**: `tz_geo_2025`

## Data Structure

The seeded data includes:
- **31 Regions** of Tanzania
- **185+ Districts**
- **82 Wards** (with detailed data for major dairy farming areas)
- **111 Villages** (real villages in key regions)
- **Hierarchical relationships** (Region → District → Ward → Village)

## Option 1: Using Dart Script (Recommended for Flutter projects)

### Prerequisites
- Flutter/Dart SDK installed
- Firebase configured in your project

### Steps

1. Make sure you're in the project root directory
2. Run the script:
   ```bash
   dart run scripts/seed_locations.dart
   ```

## Option 2: Using Node.js Script

### Prerequisites
- Node.js installed
- Firebase Admin SDK

### Steps

1. Install Firebase Admin SDK:
   ```bash
   npm install firebase-admin
   ```

2. Download your Firebase service account key:
   - Go to Firebase Console → Project Settings → Service Accounts
   - Click "Generate New Private Key"
   - Save the JSON file securely

3. Set environment variable:
   ```bash
   export GOOGLE_APPLICATION_CREDENTIALS="path/to/serviceAccountKey.json"
   ```

4. Run the script:
   ```bash
   node scripts/seed_locations.js
   ```

## Option 3: Manual Upload via Firebase Console

1. Open Firebase Console
2. Go to Firestore Database
3. Create collection `locations`
4. Create document `tz_geo_2025`
5. Copy the entire content of `data.json`
6. Paste into the document editor
7. Save

## Verification

After seeding, verify the data:

1. Open Firebase Console → Firestore
2. Navigate to `locations` → `tz_geo_2025`
3. Check that the document contains:
   - `regions` (31 items)
   - `districts` (185+ items)
   - `wards` (82 items)
   - `villages` (111 items)
   - `hierarchy` (relationships)
   - `updatedAt` (timestamp)

## Key Regions with Detailed Data

The following regions have comprehensive ward and village data:

### Kilimanjaro Region (Major Dairy Area)
- **Hai District** (901): 9 wards, 15 villages
  - Famous dairy areas: Kibosho, Lyamungo, Machame
- **Moshi Municipal** (902): 10 wards, 10 villages
- **Moshi District** (903): 16 wards, 18 villages
  - Includes: Kilema, Marangu, Old Moshi, Mwika

### Arusha Region
- **Arusha City** (101): 6 wards, 6 villages
- **Arusha District** (102): 8 wards, 9 villages
  - Includes: Ngaramtoni (dairy farming area)

### Dar es Salaam Region
- **Ilala Municipal** (201): 13 wards, 13 villages
- **Kinondoni Municipal** (203): 11 wards, 11 villages

### Mbeya Region (Southern Highlands)
- **Mbeya City** (1305): 9 wards, 10 villages
  - Includes: Mbalizi, Itende (dairy areas)

### Iringa Region
- **Iringa Municipal** (501): 10 wards, 10 villages

## Troubleshooting

### "Permission denied" error
- Ensure your Firebase user has write permissions to Firestore
- Check Firestore security rules

### "File not found" error
- Ensure `data.json` exists in the project root
- Check the file path in the script

### "Firebase not initialized" error
- For Dart: Ensure `firebase_options.dart` exists
- For Node.js: Set `GOOGLE_APPLICATION_CREDENTIALS` correctly

## Data Updates

To update the geographical data:

1. Edit `data.json` with new regions/districts/wards/villages
2. Update the `updatedAt` field to current date
3. Re-run the seeding script

## Notes

- All data is based on official Tanzania administrative divisions
- Urban/rural classification is included for each village
- The hierarchy structure allows easy querying of relationships
- Data is optimized for dairy farming cooperative management

## Support

For issues or questions about the seeding process, check:
- Firebase Console for error logs
- Firestore security rules
- Network connectivity
