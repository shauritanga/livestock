#!/bin/bash

# Script to seed milk delivery data for dashboard testing
# This creates sample deliveries for the past 30 days

echo "🥛 Seeding Milk Delivery Data..."
echo ""
echo "This will create sample milk deliveries for the past 30 days"
echo "to visualize on the dashboard."
echo ""

# Deploy the functions first
echo "📦 Deploying Cloud Functions..."
cd functions
npm run build
firebase deploy --only functions:seedMilkDeliveries
cd ..

echo ""
echo "✅ Functions deployed!"
echo ""
echo "🔧 Now calling the seed function..."
echo ""

# Call the function using Firebase CLI
firebase functions:call seedMilkDeliveries

echo ""
echo "✨ Done! Check your dashboard to see the collection trends."
echo ""
