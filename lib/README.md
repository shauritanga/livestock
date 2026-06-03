# Agripoa Flutter App - Project Structure

This Flutter application follows **Clean Architecture** principles with a **feature-first** folder structure for better maintainability and scalability.

## Folder Structure

```
lib/
├── core/                    # Core functionality shared across features
│   ├── constants/          # Application constants
│   ├── errors/             # Error handling (failures & exceptions)
│   ├── network/            # Network connectivity utilities
│   ├── theme/              # App theme configuration (FlexColorScheme)
│   └── utils/              # Utility functions (validators, formatters)
│
├── features/               # Feature modules (feature-first approach)
│   ├── auth/              # Authentication feature
│   │   ├── data/          # Data layer
│   │   │   ├── datasources/    # Remote & local data sources
│   │   │   ├── models/         # Data models (Firestore serialization)
│   │   │   └── repositories/   # Repository implementations
│   │   ├── domain/        # Domain layer (business logic)
│   │   │   ├── entities/       # Business entities
│   │   │   ├── repositories/   # Repository interfaces
│   │   │   └── usecases/       # Use cases
│   │   └── presentation/  # Presentation layer (UI)
│   │       ├── providers/      # Riverpod state management
│   │       ├── screens/        # Screen widgets
│   │       └── widgets/        # Reusable widgets
│   │
│   ├── farmer_management/ # Farmer registration & management
│   ├── milk_collection/   # Daily milk collection recording
│   ├── cattle_tracking/   # Cattle registration & biometrics
│   ├── loans/             # Loan application & management
│   └── insurance/         # Insurance enrollment & claims
│
├── l10n/                   # Localization (English & Swahili)
│   └── app_localizations.dart
│
├── routes/                 # Navigation configuration (go_router)
│   └── app_router.dart
│
└── main.dart              # Application entry point
```

## Clean Architecture Layers

### 1. Domain Layer (Business Logic)
- **Entities**: Pure Dart classes representing business objects (using Equatable)
- **Repository Interfaces**: Abstract contracts for data operations
- **Use Cases**: Single-responsibility business logic operations
- **No dependencies** on Flutter or external packages

### 2. Data Layer (Data Sources)
- **Models**: Data transfer objects with Firestore serialization
- **Data Sources**: Firebase, local SQLite, API clients
- **Repository Implementations**: Concrete implementations of domain repositories
- **Mappers**: Convert between models and entities

### 3. Presentation Layer (UI)
- **Screens**: Full-page UI components
- **Widgets**: Reusable UI components
- **Providers**: Riverpod state management
- **Consumes use cases** from the domain layer

## Dependency Rule

Dependencies flow inward:
- **Presentation** → Domain
- **Data** → Domain
- **Domain** → Nothing (pure business logic)

This ensures:
- Testability (easy to mock repositories)
- Maintainability (clear separation of concerns)
- Scalability (add features without affecting others)
- Flexibility (swap data sources without changing business logic)

## Key Technologies

- **State Management**: flutter_riverpod (no code generation)
- **Navigation**: go_router (declarative routing)
- **Theme**: flex_color_scheme (green & yellow brand colors)
- **Responsive UI**: flutter_screenutil
- **Localization**: Manual i18n (English & Swahili)
- **Backend**: Firebase (Auth, Firestore, Storage, Functions, Messaging)
- **Offline Support**: Firestore offline persistence + SQLite
- **Value Equality**: equatable (no code generation)

## Development Guidelines

1. **No Code Generators**: All code is written manually for simplicity
2. **Feature-First**: Group code by feature, not by layer
3. **Single Responsibility**: Each class/function has one clear purpose
4. **Dependency Injection**: Use Riverpod providers for DI
5. **Error Handling**: Use Either type or Result pattern for operations
6. **Testing**: Write tests for domain layer (use cases) and data layer (repositories)

## Next Steps

1. Implement authentication feature (Task 3.x)
2. Implement farmer management feature (Task 4.x)
3. Implement cattle tracking feature (Task 5.x)
4. Implement milk collection feature (Task 6.x)
5. Continue with remaining features as per tasks.md
