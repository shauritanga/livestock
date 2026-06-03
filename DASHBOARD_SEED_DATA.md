# Dashboard Sample Data Setup

This guide explains how to populate your dashboard with sample milk collection data for the past 30 days.

## Prerequisites

1. Firebase project configured
2. Service account key file in `functions/serviceAccountKey.json`
3. Test data already seeded (run `node functions/scripts/seed-data.js` first)

## Quick Start

### Option 1: Using Node.js Script (Recommended)

```bash
# Navigate to functions directory
cd functions

# Run the seed script
node scripts/seed-milk-deliveries.js
```

This will:
- Create milk deliveries for the past 30 days
- Generate realistic delivery patterns (1-2 deliveries per farmer per day)
- Vary quantities (5-25 liters per delivery)
- Distribute quality grades (70% standard, 20% premium, 10% substandard)
- Calculate payments based on quality

### Option 2: Using Firebase Functions

```bash
# Deploy the function
firebase deploy --only functions:seedMilkDeliveries

# Call the function
firebase functions:call seedMilkDeliveries
```

## What Gets Created

The script generates:

- **~60-90 deliveries** over 30 days (varies due to randomness)
- **Morning deliveries** (6:00 AM): 10-20 liters typically
- **Evening deliveries** (6:00 PM): 3-13 liters typically
- **Quality distribution**:
  - 70% Standard quality
  - 20% Premium quality (+10% price)
  - 10% Substandard quality (-10% price)

## Sample Data Patterns

The script creates realistic patterns:

1. **Daily Variation**: Not all farmers deliver every day (80% probability)
2. **Time of Day**: Morning deliveries are larger than evening
3. **Quality Variation**: Random quality grades affecting payment
4. **Quantity Variation**: Natural fluctuation in milk volumes

## Viewing the Data

After running the script:

1. **Login to the app** with test credentials:
   - Email: `agent@test.com`
   - Password: `Test123456`

2. **Dashboard will show**:
   - Today's summary (if you run deliveries for today)
   - Collection trends chart (past 7 days or 30 days)
   - Recent deliveries list

3. **Toggle between views**:
   - Week view: Last 7 days
   - Month view: Last 30 days

## Cleanup

To remove all milk deliveries:

```bash
# Using Node.js
node functions/scripts/cleanup-milk-deliveries.js

# Or using Firebase Functions
firebase functions:call cleanupMilkDeliveries
```

## Troubleshooting

### "No farmers found" Error

Run the base seed data first:
```bash
node functions/scripts/seed-data.js
```

### Permission Errors

Ensure your service account key has the necessary permissions:
- Firestore read/write
- Authentication admin

### No Data Showing on Dashboard

1. Check that deliveries were created in Firestore Console
2. Verify the cooperative and collection centre IDs match
3. Ensure you're logged in as the test agent
4. Pull down to refresh the dashboard

## Sample Output

```
🥛 Starting milk delivery data seeding...

📊 Found 3 farmers

[3%] Day 1/30: Created 4 deliveries for Mon Dec 09 2024
[7%] Day 2/30: Created 5 deliveries for Tue Dec 10 2024
[10%] Day 3/30: Created 3 deliveries for Wed Dec 11 2024
...
[100%] Day 30/30: Created 4 deliveries for Sat Jan 07 2025

🎉 Milk delivery seeding completed successfully!

📊 Statistics:
   Total Deliveries: 87
   Average per Day: 2.9
   Date Range: Mon Dec 09 2024 to Sat Jan 07 2025

✨ You can now see the collection trends on the dashboard!
```

## Next Steps

After seeding data:

1. Open the mobile app
2. Login with test credentials
3. View the dashboard with real data
4. Test the week/month toggle
5. Pull to refresh to see updates
6. Check recent deliveries section

Enjoy exploring your dashboard with realistic data! 📊🥛
