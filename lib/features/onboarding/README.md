# Onboarding Feature

## Overview

The onboarding feature provides a first-time user experience that introduces new users to the Agripoa platform's key features and benefits.

## Structure

```
onboarding/
├── data/
│   └── datasources/
│       └── onboarding_local_datasource.dart  # SharedPreferences management
├── domain/
│   └── entities/
│       └── onboarding_page.dart              # Onboarding page entity
└── presentation/
    ├── providers/
    │   └── onboarding_provider.dart          # State management
    ├── screens/
    │   ├── splash_screen.dart                # Initial splash screen
    │   └── onboarding_screen.dart            # Onboarding carousel
    └── widgets/
        └── onboarding_page_widget.dart       # Single page widget
```

## Features

### 1. Splash Screen
- Displays app logo during initialization
- Checks if user has seen onboarding
- Routes to appropriate screen:
  - First-time users → Onboarding
  - Returning users (not authenticated) → Login
  - Authenticated users → Dashboard

### 2. Onboarding Carousel
- 5 informative pages introducing key features:
  1. **Welcome** - Platform overview
  2. **Track Cattle** - Biometric identification
  3. **Record Milk** - Daily milk collection
  4. **Financial Services** - Loans and insurance
  5. **Offline Mode** - Work without internet

### 3. Navigation
- Swipe or tap to navigate between pages
- Skip button to bypass onboarding
- Back button (except on first page)
- "Get Started" button on last page

### 4. Page Indicators
- Animated dots showing current page
- Visual feedback for navigation

### 5. Persistent State
- Uses SharedPreferences to remember if user has seen onboarding
- Only shown once per installation
- Can be reset for testing

## Onboarding Pages

### Page 1: Welcome to Agripoa
- **Icon**: Agriculture
- **Message**: Transform your dairy farming with digital milk collection, cattle tracking, and financial services

### Page 2: Track Your Cattle
- **Icon**: Pets
- **Message**: Register cattle with biometric identification using muzzle patterns

### Page 3: Record Milk Deliveries
- **Icon**: Water Drop
- **Message**: Quickly record daily milk deliveries with instant payment calculations

### Page 4: Access Financial Services
- **Icon**: Account Balance
- **Message**: Apply for input loans and livestock insurance with automatic repayment

### Page 5: Work Offline
- **Icon**: Cloud Off
- **Message**: Record data without internet, syncs automatically when online

## Usage

### Checking Onboarding Status

```dart
// In a widget
final hasSeenOnboarding = await ref.read(hasSeenOnboardingProvider.future);

if (!hasSeenOnboarding) {
  // Show onboarding
  context.go('/onboarding');
}
```

### Marking Onboarding as Complete

```dart
final dataSource = ref.read(onboardingLocalDataSourceProvider);
await dataSource.setOnboardingSeen();
```

### Resetting Onboarding (for testing)

```dart
final dataSource = ref.read(onboardingLocalDataSourceProvider);
await dataSource.resetOnboarding();
```

## Customization

### Adding New Pages

Edit `onboardingPagesProvider` in `onboarding_provider.dart`:

```dart
final onboardingPagesProvider = Provider<List<OnboardingPage>>((ref) {
  return [
    const OnboardingPage(
      title: 'Your Title',
      description: 'Your description',
      imagePath: 'assets/images/your_image.png',
      iconData: 'your_icon', // Optional
    ),
    // ... more pages
  ];
});
```

### Changing Icons

Update the icon mapping in `onboarding_page_widget.dart`:

```dart
switch (page.iconData) {
  case 'your_icon':
    icon = Icons.your_icon;
    break;
  // ... more cases
}
```

### Using Custom Images

1. Add images to `assets/images/` directory
2. Update `pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       - assets/images/
   ```
3. Set `imagePath` in OnboardingPage
4. Update `_buildIcon()` in `onboarding_page_widget.dart` to load images

## State Management

### Providers

- **sharedPreferencesProvider**: SharedPreferences instance
- **onboardingLocalDataSourceProvider**: Data source for onboarding state
- **hasSeenOnboardingProvider**: FutureProvider checking onboarding status
- **onboardingPagesProvider**: List of onboarding pages
- **onboardingPageIndexProvider**: Current page index

### State Flow

```
App Start
    ↓
Splash Screen
    ↓
Check hasSeenOnboarding
    ↓
┌───────────────┬──────────────┐
│ First Time    │ Returning    │
│ (false)       │ (true)       │
↓               ↓              │
Onboarding → Check Auth        │
    ↓           ↓              │
Complete    ┌────────┬─────────┘
    ↓       │        │
Mark Seen   │ Auth   │ No Auth
    ↓       ↓        ↓
    └→ Dashboard  Login
```

## Styling

The onboarding screens use the app's theme:
- Primary color for icons and active indicators
- Primary container for icon backgrounds
- Responsive sizing with flutter_screenutil
- Material Design 3 components

## Accessibility

- Large, readable text
- High contrast icons
- Clear navigation buttons
- Descriptive content

## Testing

### Manual Testing

1. **First Launch**:
   - Uninstall and reinstall app
   - Should show onboarding

2. **Skip Functionality**:
   - Tap "Skip" button
   - Should navigate to login

3. **Navigation**:
   - Swipe between pages
   - Use Back/Next buttons
   - Check page indicators update

4. **Completion**:
   - Reach last page
   - Tap "Get Started"
   - Should navigate to login
   - Relaunch app - should skip onboarding

### Resetting for Testing

```dart
// In debug mode or settings screen
final dataSource = ref.read(onboardingLocalDataSourceProvider);
await dataSource.resetOnboarding();
// Restart app to see onboarding again
```

## Future Enhancements

- [ ] Add animations between pages
- [ ] Include video demonstrations
- [ ] Add interactive tutorials
- [ ] Support for more languages
- [ ] A/B testing different onboarding flows
- [ ] Analytics tracking for onboarding completion
- [ ] Role-specific onboarding (farmer vs agent)

## Dependencies

- **flutter_riverpod**: State management
- **go_router**: Navigation
- **shared_preferences**: Persistent storage
- **flutter_screenutil**: Responsive sizing
- **equatable**: Value equality

## Related Files

- `lib/routes/app_router.dart` - Route definitions
- `lib/main.dart` - SharedPreferences initialization
- `lib/core/widgets/loading_screen.dart` - Splash loading UI
- `lib/core/widgets/error_screen.dart` - Error handling
