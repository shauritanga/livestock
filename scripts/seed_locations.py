#!/usr/bin/env python3
"""
Script to seed Tanzania geographical data to Firestore

This script reads data.json and uploads it to:
Collection: locations
Document: tz_geo_2025

Prerequisites:
1. Install Firebase Admin SDK: pip install firebase-admin
2. Download your Firebase service account key JSON file
3. Set GOOGLE_APPLICATION_CREDENTIALS environment variable

Usage:
export GOOGLE_APPLICATION_CREDENTIALS="path/to/serviceAccountKey.json"
python3 scripts/seed_locations.py
"""

import json
import os
import sys
from pathlib import Path

try:
    import firebase_admin
    from firebase_admin import credentials, firestore
except ImportError:
    print("❌ Error: firebase-admin not installed")
    print("   Install it with: pip install firebase-admin")
    sys.exit(1)


def main():
    print("🌍 Tanzania Geographical Data Seeding Script")
    print("=" * 50)
    
    try:
        # Initialize Firebase Admin
        print("\n📱 Initializing Firebase Admin...")
        
        # Check if service account key is set
        if not os.getenv('GOOGLE_APPLICATION_CREDENTIALS'):
            print("⚠️  GOOGLE_APPLICATION_CREDENTIALS not set")
            print("   Attempting to use default credentials...")
        
        # Initialize Firebase
        if not firebase_admin._apps:
            cred = credentials.ApplicationDefault()
            firebase_admin.initialize_app(cred)
        
        print("✅ Firebase Admin initialized successfully")
        
        # Read data.json file
        print("\n📖 Reading data.json file...")
        data_path = Path(__file__).parent.parent / 'data.json'
        
        if not data_path.exists():
            print(f"❌ Error: data.json file not found at: {data_path}")
            sys.exit(1)
        
        with open(data_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        print("✅ Data loaded successfully")
        
        # Display data statistics
        print("\n📊 Data Statistics:")
        print(f"   - Regions: {len(data['regions'])}")
        print(f"   - Districts: {len(data['districts'])}")
        print(f"   - Wards: {len(data['wards'])}")
        print(f"   - Villages: {len(data['villages'])}")
        
        # Get Firestore instance
        db = firestore.client()
        
        # Upload to Firestore
        print("\n🔄 Uploading to Firestore...")
        print("   Collection: locations")
        print("   Document: tz_geo_2025")
        
        doc_ref = db.collection('locations').document('tz_geo_2025')
        doc_ref.set(data)
        
        print("✅ Data uploaded successfully!")
        
        # Verify the upload
        print("\n🔍 Verifying upload...")
        doc = doc_ref.get()
        
        if doc.exists:
            uploaded_data = doc.to_dict()
            print("✅ Verification successful!")
            print(f"   - Document exists: {doc.exists}")
            print(f"   - Regions in Firestore: {len(uploaded_data['regions'])}")
            print(f"   - Districts in Firestore: {len(uploaded_data['districts'])}")
            print(f"   - Wards in Firestore: {len(uploaded_data['wards'])}")
            print(f"   - Villages in Firestore: {len(uploaded_data['villages'])}")
            print(f"   - Last updated: {uploaded_data['updatedAt']}")
        else:
            print("⚠️  Warning: Document not found after upload")
        
        print("\n" + "=" * 50)
        print("🎉 Seeding completed successfully!")
        print("=" * 50)
        
    except Exception as e:
        print("\n❌ Error occurred during seeding:")
        print(f"   {str(e)}")
        import traceback
        print("\n📋 Stack trace:")
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
