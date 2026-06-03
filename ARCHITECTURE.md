# Agripoa Platform - Flutter App Architecture

## Overview

The Agripoa Flutter mobile application has been initialized with a **Clean Architecture** structure following a **feature-first** approach. This document outlines the architecture decisions and project organization.

## Architecture Principles

### Clean Architecture Layers

1. **Domain Layer** (Business Logic)
   - Pure Dart code with no external dependencies
   - Contains entities, repository interfaces, and use cases
   - Represents the core business rules

2. **Data Layer** (Data Management)
   - Implements repository interfaces from domain layer
   - Handles data sources (Firebase, SQLite, APIs)
   - Manages data models and serialization

3. **Presentation Layer** (UI)
   - Flutter widgets and screens
   - Riverpod providers for state management
   - Consumes use cases from domain layer

### Dependency Rule

```
Presentation → Domain ← Data
```

- Presentation depends on Domain
- Data depends on Domain
- Domain is independent (pure business logic)

## Project Structure

```
lib/
├── core/                           # Shared functionality
│   ├── constants/
│   │   ├── app_constants.dart     # App-wide constants
│   │   └── firebase_constants.dart # Firebase collection names
│   ├── errors/
│   │   ├── failures.dart          # Failure classes for error handling
│   │   └── exceptions.dart        # Exception classes
│   ├── network/
│   │   └── network_info.dart      # Network connectivity checking
│   ├── theme/
│   │   └── app_theme.dart         # FlexColorScheme theme config
│   └── utils/
│       ├── date_formatter.dart    # Date formatting utilities
│       └── validators.dart        # Input validation utilities
│
├── features/                       # Feature modules
│   ├── auth/                      # Authentication
│   ├── farmer_management/         # Farmer CRUD operations
│   ├── milk_collection/           # Milk delivery recording
│   ├── cattle_tracking/           # Cattle registration & biometrics
│   ├── loans/                     # Loan management
│   └── insurance/                 # Insurance & claims
│   
│   Each feature follows this structure:
│   ├── data/
│   │   ├── datasources/           # Firebase, SQLite sources
│   │   ├── models/                # Data models
│   │   └── repositories/          # Repository implementations
│   ├── domain/
│   │   ├── entities/              # Business entities
│   │   ├── repositories/          # Repository interfaces
│   │   └── usecases/              # Business logic
│   └── presentation/
│       ├── providers/             # Riverpod state management
│       ├── screens/               # Full-page widgets
│       └── widgets/               # Reusable components
│
├── l10n/                          # Internationalization
│   └── app_localizations.dart    # English & Swahili translations
│
├── routes/                        # Navigation
│   └── app_router.dart           # go_router configuration
│
└── main.dart                      # App entry point
```

## Technology Stack

### Core Dependencies

- **flutter_riverpod** (^3.0.3): State management without code generation
- **go_router** (^17.0.0): Declarative routing with deep linking
- **flex_color_scheme** (^8.3.1): Theme management with brand colors
- **flutter_screenutil** (^5.9.3): Responsive UI sizing
- **equatable** (^2.0.7): Value equality without code generation

### Firebase Services

- **firebase_core** (^4.2.1): Firebase initialization
- **firebase_auth** (^6.1.2): Authentication
- **cloud_firestore** (^6.1.0): NoSQL database
- **firebase_storage** (^13.0.4): File storage
- **firebase_messaging** (^16.0.4): Push notifications
- **cloud_functions** (^6.0.4): Serverless functions

### Additional Features

- **camera** (^0.11.3): Cattle muzzle capture
- **image_picker** (^1.2.0): Image selection
- **sqflite** (^2.4.2): Local database for offline support
- **local_auth** (^3.0.0): Biometric authentication
- **connectivity_plus** (^7.0.0): Network status monitoring
- **intl** (^0.20.2): Date formatting and localization

## Design Decisions

### 1. No Code Generation

All code is written manually without build_runner or code generators. This provides:
- Simpler development workflow
- Easier debugging
- Better IDE support
- Faster build times

### 2. Feature-First Organization

Features are organized by business capability rather than technical layer:
- Easier to locate related code
- Better encapsulation
- Simpler to add/remove features
- Clearer team ownership

### 3. Offline-First Architecture

- Firestore offline persistence enabled
- Local SQLite for critical data
- Queue system for offline operations
- Automatic sync when online

### 4. Internationalization

- Manual translation files (no code generation)
- Support for English and Swahili
- Locale-based date and number formatting
- Easy to add more languages

### 5. Theme System

- FlexColorScheme for consistent Material Design 3
- Brand colors: Green (primary) and Yellow (accent)
- Light and dark theme support
- Responsive sizing with flutter_screenutil

## Next Steps

### Immediate Tasks (Phase 1)

1. **Task 2.2**: Implement theme configuration with flex_color_scheme ✅ (Completed)
2. **Task 2.3**: Set up internationalization ✅ (Completed)
3. **Task 2.4**: Configure go_router navigation ✅ (Completed)
4. **Task 2.5**: Implement Firebase initialization
5. **Task 3.x**: Build authentication feature
6. **Task 4.x**: Build farmer management feature
7. **Task 5.x**: Build cattle tracking feature
8. **Task 6.x**: Build milk collection feature

### Development Workflow

1. Start with domain layer (entities, repositories, use cases)
2. Implement data layer (models, data sources, repository implementations)
3. Build presentation layer (providers, screens, widgets)
4. Write tests for domain and data layers
5. Integrate with Firebase services

## Testing Strategy

- **Unit Tests**: Domain layer use cases and data layer repositories
- **Widget Tests**: Presentation layer screens and widgets
- **Integration Tests**: End-to-end user flows
- **Target Coverage**: 70% for app, 80% for Cloud Functions

## Code Quality

- **Linting**: flutter_lints package enabled
- **Type Safety**: Strict null safety enabled
- **Error Handling**: Consistent failure/exception pattern
- **Documentation**: Inline comments for complex logic
- **Code Review**: Required before merging

## Resources

- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Riverpod Documentation](https://riverpod.dev/)
- [FlexColorScheme Documentation](https://docs.flexcolorscheme.com/)
- [Firebase Flutter Documentation](https://firebase.flutter.dev/)

---

**Last Updated**: Task 2.1 completed - Clean architecture structure initialized
