# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Build and Run
- `flutter run` - Run the app in debug mode
- `flutter run --release` - Run the app in release mode  
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app (requires macOS and Xcode)

### Code Quality
- `flutter analyze` - Run static analysis on Dart code
- `flutter test` - Run unit and widget tests
- `dart format .` - Format all Dart files
- `flutter pub get` - Install dependencies from pubspec.yaml

### Debugging and Development
- `flutter clean` - Clean build cache when experiencing build issues
- `flutter pub deps` - Show dependency tree
- `flutter doctor` - Check Flutter environment and dependencies

## Architecture Overview

This is a Flutter vocabulary learning app with the following architecture:

### Core Architecture
- **State Management**: Provider pattern for global state
- **Dependency Injection**: GetIt service locator pattern
- **Navigation**: Named routes with MaterialApp routing
- **HTTP Client**: Dio for API communication with custom interceptors
- **Persistence**: SharedPreferences for local data storage
- **Internationalization**: Flutter's built-in l10n with .arb files (English/Chinese)

### Project Structure
```
lib/
├── apis/              # API layer (HTTP requests)
├── common/            # Shared models, widgets, services
├── entities/          # Data models and DTOs
├── features/          # Feature-based organization
│   ├── auth/          # Authentication (login/register)
│   ├── main_menu/     # Main navigation scaffold
│   ├── new_words_list/# Word list management
│   ├── memories/      # Memory features
│   ├── stories/       # Story features
│   ├── settings/      # App settings
│   └── word_detail/   # Word detail views
├── providers/         # Provider state management
├── services/          # Business logic layer
└── utils/             # Utility functions and helpers
```

### Key Components

#### State Management
- `AuthProvider` - Handles authentication state and token management
- `VocabularyProvider` - Manages word lists and vocabulary data
- Uses Provider package for reactive state management

#### Navigation
- `MainMenuScreen` - Main scaffold with bottom/rail navigation
- Responsive design (bottom nav on mobile, rail nav on desktop)
- Uses `LazyLoadIndexedStack` for efficient page management
- Auto-shows add word dialog periodically

#### API Layer
- `VocabularyApi`, `AccountApi`, `UserSettingsApi`, `SettingsApi` - API endpoints
- Dio HTTP client with authentication interceptor
- Standardized API response format with `ApiResponse<T>`

#### Services Layer
- `VocabularyService` - Business logic for word management
- `AccountService` - User account operations
- `UserSettingsService` - User preference management
- All services use repository pattern (follows clean architecture)

### Configuration
- Environment configuration via `.env` file
- `AppConfig` class for centralized config access
- API base URL configurable per environment
- Supports staging and production environments

### Key Features
- Multilingual support (English/Chinese) with .arb localization files
- Responsive design for mobile and desktop
- Token-based authentication with auto-refresh
- Vocabulary word management with explanations
- User settings and preferences
- Material Design 3 theming

### Development Notes
- Package identifier: `com.shukebeta.newwords`
- Minimum SDK: As defined in Flutter configuration
- Uses Material Design 3 with deep purple color scheme
- Supports Android, iOS, Linux, macOS, Windows, and Web platforms
- Environment variables loaded from `.env` file at app startup