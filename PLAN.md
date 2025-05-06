# NewWords App - Phase 1: Registration/Login Plan

This plan outlines the steps to implement the initial registration and login functionality for the NewWords Flutter application.

**Core Requirements:**

*   Combined Registration/Login form.
*   Use `dio` for API requests.
*   API Endpoint: `/login` (POST)
*   API Request: `{ "email": "...", "password": "..." }`
*   API Response (Standard Format):
    ```json
    {
      "data": { ... }, // Contains token on successful login
      "successful": true/false,
      "errorCode": 0, // Or error code
      "message": "Successful" // Or error message
    }
    ```
*   Store authentication token upon successful login/registration.
*   Support English and Chinese languages using `.arb` files and `flutter_localizations`.
*   Use `provider` for state management.
*   Use `shared_preferences` for token persistence.
*   Show a simple "Login Successful" page after authentication.

**Implementation Steps:**

**1. Project Setup & Dependencies:**

*   Add necessary packages to `pubspec.yaml`:
    *   `dio`: For making HTTP requests.
    *   `flutter_localizations`: (Requires `sdk: flutter` dependency) For Flutter's built-in localization support.
    *   `intl`: For internationalization utilities.
    *   `provider`: For state management.
    *   `shared_preferences`: For persisting the authentication token.
*   Configure `flutter_localizations` in `main.dart`.
*   Set up the directory structure for localization files: `lib/l10n/`.
*   Create initial localization files: `lib/l10n/app_en.arb` and `lib/l10n/app_zh.arb`.
*   Organize the code structure: Create folders like `lib/features/auth`, `lib/features/home`, `lib/common/services`, `lib/common/providers`, `lib/common/models`.

**2. Localization Implementation:**

*   Add initial strings to `app_en.arb` and `app_zh.arb` for UI elements and messages.
*   Update `MaterialApp` in `main.dart` to include `localizationsDelegates` and `supportedLocales`.
*   Implement logic to detect and set the initial device locale.

**3. API Service (`dio`):**

*   Create an `ApiService` class (`lib/common/services/api_service.dart`).
*   Configure a `dio` instance (placeholder base URL needed).
*   Define an `ApiResponse` model (`lib/common/models/api_response.dart`).
*   Implement `registerOrLogin(String email, String password)` method:
    *   Make `POST` request to `/login`.
    *   Parse response using `ApiResponse` model.
    *   Extract token on success, handle errors on failure.

**4. Authentication State Management (`provider`):**

*   Create an `AuthProvider` class (`lib/common/providers/auth_provider.dart`) extending `ChangeNotifier`.
*   Manage token (`_token`) and authentication status (`isAuthenticated`).
*   Implement `login(String email, String password)`:
    *   Call `ApiService.registerOrLogin`.
    *   Update state, save token to `shared_preferences`, notify listeners.
*   Implement `logout()`: Clear state, remove token from `shared_preferences`, notify listeners.
*   Implement `initAuth()`: Load token from `shared_preferences` on app start.

**5. UI Implementation:**

*   **Login Screen (`lib/features/auth/presentation/login_screen.dart`):**
    *   Consume `AuthProvider`.
    *   Use `TextFormField`s and `ElevatedButton`.
    *   Use localized strings (`AppLocalizations`).
    *   Call `AuthProvider.login()`.
    *   Show loading/error states.
*   **Home Screen (`lib/features/home/presentation/home_screen.dart`):**
    *   Display localized "Login Successful" message.
    *   Include a logout button calling `AuthProvider.logout()`.
*   **Routing (`main.dart` or dedicated router):**
    *   Listen to `AuthProvider` state changes.
    *   Navigate between `LoginScreen` and `HomeScreen`.
    *   Call `AuthProvider.initAuth()` on startup.

**Architecture Diagram:**

```mermaid
graph LR
    subgraph "User Interaction"
        UI_Login[Login Screen] -- Credentials --> Logic_Auth
        UI_Home[Home Screen] -- Logout --> Logic_Auth
    end

    subgraph "Logic & State (Provider)"
        Logic_Auth[AuthProvider] -- Calls --> Service_API
        Logic_Auth -- Updates --> State_Token[Auth Token]
        Logic_Auth -- Updates --> State_Status[Auth Status]
        Logic_Auth -- Reads/Writes --> Storage[SharedPreferences]
        State_Status -- Controls --> Routing
    end

    subgraph "Services"
        Service_API[ApiService (Dio)] -- HTTP Request --> Backend[/login API]
        Backend -- JSON Response --> Service_API
    end

    subgraph "Data"
        Storage
        State_Token
        State_Status
    end

    subgraph "Localization"
        L10n[ARB Files] --> UI_Login & UI_Home
    end

    Routing{App Router} -- Based on State_Status --> UI_Login
    Routing -- Based on State_Status --> UI_Home

    style Backend fill:#ddd,stroke:#333
    style Storage fill:#ccf,stroke:#333