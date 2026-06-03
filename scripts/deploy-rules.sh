#!/bin/bash

# Script to deploy Firestore security rules

echo "🔐 Deploying Firestore Security Rules..."
echo ""

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI is not installed"
    echo ""
    echo "Install it with:"
    echo "  npm install -g firebase-tools"
    echo ""
    exit 1
fi

# Check if user is logged in
if ! firebase projects:list &> /dev/null; then
    echo "❌ Not logged in to Firebase"
    echo ""
    echo "Login with:"
    echo "  firebase login"
    echo ""
    exit 1
fi

# Deploy rules
echo "Deploying rules..."
firebase deploy --only firestore:rules

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Firestore rules deployed successfully!"
    echo ""
    echo "You can now:"
    echo "  • View farmers in the app"
    echo "  • Register new farmers"
    echo "  • Record milk deliveries"
    echo ""
else
    echo ""
    echo "❌ Failed to deploy rules"
    echo ""
    echo "Make sure you have:"
    echo "  1. Initialized Firebase in this project (firebase init)"
    echo "  2. Selected the correct project"
    echo ""
fi
