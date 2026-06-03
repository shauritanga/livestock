# Firebase Setup Guide

## Overview

The Agripoa platform uses Firebase as its backend infrastructure, providing authentication, database, storage, cloud functions, and messaging services.

## Firebase Services Used

1. **Firebase Authentication** - User authentication and authorization
2. **Cloud Firestore** - NoSQL database for storing app data
3. **Firebase Storage** - File storage for images and documents
4. **Cloud Functions** - Serverless backend logic
5. **Firebase Cloud Messaging** - Push notifications

## Current Configuration

### Project Details
- **Project ID**: `livestock-agripoa`
- **Storage Bucket**: `livestock-agripoa.firebasestorage.app`

### Platforms Configured
- ✅ Android
- ✅ iOS

### Configuration Files
- `lib/firebase_options.dart` - Auto-generated Firebase configuration
- `android/app/google-services.json` - Android configuration (if exists)
- `ios/Runner/GoogleService-Info.plist` - iOS configuration (if exists)

## Firebase Initialization

Firebase is initialized in `lib/main.dart`:

```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

## Firebase Services Architecture

### 1. Firebase Service Providers

Located in `lib/core/services/firebase_service.dart`:

```dart
// Firebase Auth instance
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

// Firestore instance with offline persistence
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  final firestore = FirebaseFirestore.instance;
  firestore.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  return firestore;
});

// Firebase Storage instance
final firebaseStorageProvider = Provider<FirebaseStorage>((ref) => FirebaseStorage.instance);

// Firebase Messaging instance
final firebaseMessagingProvider = Provider<FirebaseMessaging>((ref) => FirebaseMessaging.instance);

// Auth state changes stream
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
});

// Current user
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});
```

### 2. Error Handling

Firebase errors are handled in `lib/core/services/firebase_error_handler.dart`:

- Converts `FirebaseAuthException` to `AuthenticationFailure`
- Converts `FirebaseException` to appropriate `Failure` types
- Provides user-friendly error messages

### 3. App Initialization

The `AppInitializationService` handles startup tasks:

- Configures Firestore offline persistence
- Requests notification permissions
- Gets FCM token for push notifications

## Firestore Configuration

### Offline Persistence

Firestore is configured with offline persistence enabled:

```dart
Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
)
```

This allows the app to:
- Work offline
- Cache data locally
- Automatically sync when online
- Queue writes for later execution

### Collections Structure

See `lib/core/constants/firebase_constants.dart` for collection names:

```dart
- cooperatives
  - collectionCentres
    - farmers
      - cattle
      - milkDeliveries
      - loans
        - repayments
      - insurancePolicies
        - claims
- offtakers
  - sales
- products
  - productionBatches
  - productSales
- users
- transactions
```

## Security Rules

Firestore security rules should be configured in the Firebase Console to:

1. Enforce role-based access control
2. Implement cooperative-level data isolation
3. Validate data before writes
4. Prevent unauthorized access

Example rule structure:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function hasRole(role) {
      return isAuthenticated() && request.auth.token.role == role;
    }
    
    // Cooperative data
    match /cooperatives/{cooperativeId} {
      allow read: if isAuthenticated();
      allow write: if hasRole('system_admin');
      
      // Nested collections...
    }
  }
}
```

## Firebase Cloud Messaging (FCM)

### Notification Permissions

The app requests notification permissions on startup:

```dart
final settings = await messaging.requestPermission(
  alert: true,
  badge: true,
  sound: true,
);
```

### FCM Token

The device FCM token is retrieved and should be stored in Firestore:

```dart
final token = await messaging.getToken();
// Store in Firestore user document
```

### Handling Notifications

Implement notification handlers in the app:

1. **Foreground messages**: Display in-app notifications
2. **Background messages**: Handle via background handler
3. **Notification taps**: Navigate to relevant screen

## Environment Configuration

For multiple environments (dev, staging, production):

1. Create separate Firebase projects for each environment
2. Run FlutterFire CLI for each environment:
   ```bash
   flutterfire configure --project=agripoa-dev
   flutterfire configure --project=agripoa-staging
   flutterfire configure --project=agripoa-prod
   ```
3. Use build flavors to switch between configurations

## Testing with Firebase Emulator

For local development, use Firebase Emulator Suite:

```bash
firebase emulators:start
```

Configure the app to use emulators in debug mode:

```dart
if (kDebugMode) {
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  await FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
}
```

## Troubleshooting

### Common Issues

1. **Firebase not initialized**
   - Ensure `Firebase.initializeApp()` is called before `runApp()`
   - Check that `firebase_options.dart` exists

2. **Platform not configured**
   - Run `flutterfire configure` to add missing platforms
   - Ensure google-services.json (Android) or GoogleService-Info.plist (iOS) exists

3. **Offline persistence not working**
   - Check Firestore settings are configured
   - Verify app has storage permissions

4. **Notifications not working**
   - Check notification permissions are granted
   - Verify FCM token is being generated
   - Ensure Firebase Cloud Messaging is enabled in Firebase Console

## Next Steps

1. ✅ Firebase initialization implemented
2. ✅ Service providers created
3. ✅ Error handling configured
4. ✅ Offline persistence enabled
5. ⏳ Implement Firestore security rules (Task 1.3)
6. ⏳ Set up Firebase Emulator Suite (Task 1.4)
7. ⏳ Implement authentication feature (Task 3.x)

## Resources

- [Firebase Flutter Documentation](https://firebase.flutter.dev/)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/)
- [Firestore Offline Persistence](https://firebase.google.com/docs/firestore/manage-data/enable-offline)
- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- [Firebase Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
