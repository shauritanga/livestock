#!/bin/bash

# Firestore Restructuring Deployment Script
# This script helps you deploy the changes step by step

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_step() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Function to ask for confirmation
confirm() {
    read -p "$(echo -e ${YELLOW}$1${NC}) [y/N]: " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Check prerequisites
print_step "Checking prerequisites..."

if ! command -v firebase &> /dev/null; then
    print_error "Firebase CLI not installed"
    exit 1
fi

if ! command -v flutter &> /dev/null; then
    print_error "Flutter not installed"
    exit 1
fi

print_success "Prerequisites check passed"

# Phase 1: Deploy Indexes
echo ""
echo "=========================================="
echo "PHASE 1: Deploy Firestore Indexes"
echo "=========================================="
echo ""

if confirm "Deploy Firestore indexes?"; then
    print_step "Deploying indexes..."
    firebase deploy --only firestore:indexes
    
    print_warning "Indexes are now building. This may take 30-60 minutes."
    print_warning "Check Firebase Console → Firestore → Indexes"
    print_warning "Wait for all indexes to show 'Enabled' status before continuing."
    
    if confirm "Have all indexes finished building?"; then
        print_step "Verifying indexes..."
        cd functions
        node scripts/verify-indexes.js
        cd ..
        print_success "Index verification complete"
    else
        print_warning "Please wait for indexes to build before continuing"
        exit 0
    fi
else
    print_warning "Skipping index deployment"
fi

# Phase 2: Deploy Security Rules
echo ""
echo "=========================================="
echo "PHASE 2: Deploy Security Rules"
echo "=========================================="
echo ""

if confirm "Deploy Firestore security rules?"; then
    print_step "Deploying security rules..."
    firebase deploy --only firestore:rules
    
    print_step "Testing security rules..."
    cd functions
    node scripts/test-security-rules.js
    cd ..
    
    print_success "Security rules deployed and tested"
else
    print_warning "Skipping security rules deployment"
fi

# Phase 3: Data Migration
echo ""
echo "=========================================="
echo "PHASE 3: Data Migration"
echo "=========================================="
echo ""

print_warning "IMPORTANT: This will migrate data from nested to flat structure"
print_warning "Make sure you have:"
print_warning "  1. Backed up your database"
print_warning "  2. All indexes are built and enabled"
print_warning "  3. Security rules are deployed"

if confirm "Run data migration?"; then
    if confirm "Run dry-run first (recommended)?"; then
        print_step "Running migration dry-run..."
        cd functions
        node scripts/migrate-to-flat-structure.js --dry-run
        cd ..
        
        if ! confirm "Dry-run looks good. Proceed with actual migration?"; then
            print_warning "Migration cancelled"
            exit 0
        fi
    fi
    
    print_step "Running full migration..."
    print_warning "This may take 30-90 minutes depending on data size"
    
    cd functions
    node scripts/migrate-to-flat-structure.js
    cd ..
    
    print_success "Migration complete"
    
    print_step "Verifying migration..."
    cd functions
    node scripts/verify-indexes.js
    node scripts/test-security-rules.js
    cd ..
    
    print_success "Migration verification complete"
else
    print_warning "Skipping data migration"
fi

# Phase 4: Deploy Cloud Functions
echo ""
echo "=========================================="
echo "PHASE 4: Deploy Cloud Functions"
echo "=========================================="
echo ""

if confirm "Deploy Cloud Functions?"; then
    print_step "Building functions..."
    cd functions
    npm run build
    
    print_step "Deploying functions..."
    cd ..
    firebase deploy --only functions
    
    print_success "Cloud Functions deployed"
    
    print_warning "Monitor function logs:"
    print_warning "  firebase functions:log"
else
    print_warning "Skipping Cloud Functions deployment"
fi

# Phase 5: Flutter Application
echo ""
echo "=========================================="
echo "PHASE 5: Flutter Application"
echo "=========================================="
echo ""

if confirm "Build Flutter application?"; then
    print_step "Running tests..."
    flutter test || print_warning "Some tests failed"
    
    print_step "Analyzing code..."
    flutter analyze lib
    
    if confirm "Build Android APK?"; then
        print_step "Building Android release..."
        flutter build apk --release
        print_success "Android APK built: build/app/outputs/flutter-apk/app-release.apk"
    fi
    
    if confirm "Build iOS?"; then
        print_step "Building iOS release..."
        flutter build ios --release
        print_success "iOS build complete"
    fi
    
    print_success "Flutter application built"
else
    print_warning "Skipping Flutter build"
fi

# Summary
echo ""
echo "=========================================="
echo "DEPLOYMENT SUMMARY"
echo "=========================================="
echo ""

print_success "Deployment process complete!"
echo ""
echo "Next steps:"
echo "  1. Test the application thoroughly"
echo "  2. Monitor Firebase Console for errors"
echo "  3. Check function logs: firebase functions:log"
echo "  4. Deploy to app stores if needed"
echo ""
echo "For rollback instructions, see:"
echo "  functions/scripts/MIGRATION_ROLLBACK.md"
echo ""

print_success "All done! 🎉"
