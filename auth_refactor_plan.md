# Project Refactor Plan: Authentication Overhaul

**Goal:** Redesign the Register/Login flow in the Flutter app (`new_words`) and ensure the C# backend (`NewWords.Api`) accepts data aligned with the `UserSession` model.

**I. Backend (C# - `NewWords.Api`) - Verification & Minor Adjustments (If any)**

*   **Task 1: Verify `RegisterRequest` DTO.**
    *   **File:** `../../RiderProjects/NewWords.Api/src/NewWords.Api/Models/DTOs/Auth/RegisterRequest.cs`
    *   **Current State:** Contains `Email`, `Password`, `NativeLanguage`, `LearningLanguage`. This aligns with the `UserSession` fields needed for registration.
    *   **Action:** No changes seem immediately necessary based on current information. The `LearningLanguage` field correctly corresponds to `CurrentLearningLanguage` in the `UserSession` model.
*   **Task 2: Verify `LoginRequest` DTO.**
    *   **File:** `../../RiderProjects/NewWords.Api/src/NewWords.Api/Models/DTOs/Auth/LoginRequest.cs`
    *   **Current State:** Contains `Email`, `Password`. This is standard.
    *   **Action:** No changes seem immediately necessary.
*   **Task 3: Verify `AuthController` Endpoints.**
    *   **File:** `../../RiderProjects/NewWords.Api/src/NewWords.Api/Controllers/AuthController.cs`
    *   **Current State:**
        *   `Register` endpoint accepts `RegisterRequest` and returns `UserSession`.
        *   `Login` endpoint accepts `LoginRequest` and returns `UserSession`.
    *   **Action:** No changes seem immediately necessary. The backend already returns the full `UserSession` object, which includes `NativeLanguage` and `CurrentLearningLanguage`.

**II. Frontend (Flutter - `new_words`) - Core Refactoring**

*   **Task 1: Update Flutter `UserSession` Model.**
    *   **File:** `lib/user_session.dart`
    *   **Actions:**
        *   Add `String? nativeLanguage;`
        *   Add `String? currentLearningLanguage;`
        *   Modify the logic in `AccountService` (Task II.2) to populate these fields directly from the API response upon login/registration.

*   **Task 2: Refactor `AccountService`.**
    *   **File:** `lib/services/account_service.dart`
    *   **Actions:**
        *   **Modify `login` method:**
            *   Change signature from `login(String username, String password)` to `login(String email, String password)`.
            *   Update `params` map to `{'email': email, 'password': password}`.
            *   Parse the full `UserSession` data from `apiResult['data']` (which should be a map representing the backend `UserSession`).
            *   Populate the Flutter `UserSession` singleton (including the new `nativeLanguage` and `currentLearningLanguage` fields) directly from this parsed data.
            *   Change return type from `Future<dynamic>` to `Future<void>` (or a custom success/failure result type if preferred, but `void` with exceptions for errors is common).
        *   **Modify `register` method:**
            *   Change signature from `register(String username, String email, String password)` to `register(String email, String password, String nativeLanguage, String learningLanguage)`.
            *   Update `params` map to `{'email': email, 'password': password, 'nativeLanguage': nativeLanguage, 'learningLanguage': learningLanguage}`.
            *   Parse the full `UserSession` data from `apiResult['data']`.
            *   Populate the Flutter `UserSession` singleton directly.
            *   Change return type from `Future<dynamic>` to `Future<void>`.
        *   **Refine `setUserSession` method:**
            *   This method is called after storing the token. It currently decodes the token for `UserId` and `Email` and fetches `userSettings`.
            *   **Consideration:** Since `login` and `register` will now populate `UserSession` more fully from the API response, `setUserSession` might only need to handle token decoding for `UserId` and `Email` if that's still desired for some reason, or it could be simplified/removed if all necessary data comes from the initial auth response. The `userSettings` fetch can remain if it loads *additional* settings not present in the auth `UserSession` response. For now, assume it will still be used to populate `UserSession().userSettings`.

*   **Task 3: Create/Refactor `AuthProvider` (State Management).**
    *   **Current File (to be deprecated/removed):** `lib/common/providers/auth_provider.dart`
    *   **New/Refactored File:** e.g., `lib/providers/auth_provider.dart` (or keep in `lib/common/providers/` if that's the intended structure for new providers).
    *   **Actions:**
        *   Create a new `AuthProvider` or refactor the existing one.
        *   Inject/use the `AccountService` (from `GetIt` locator).
        *   Implement a `login(String email, String password)` method:
            *   Calls `accountService.login(email, password)`.
            *   Manages loading state (`isLoading`).
            *   Handles errors and updates an error state (`_error`).
            *   Notifies listeners.
        *   Implement a `register(String email, String password, String nativeLanguage, String learningLanguage)` method:
            *   Calls `accountService.register(email, password, nativeLanguage, learningLanguage)`.
            *   Manages loading state.
            *   Handles errors.
            *   Notifies listeners.
        *   Implement `logout` method (similar to existing, using `accountService.logout()`).
        *   Implement `initAuth` to check for existing tokens (similar to existing).
        *   Ensure `isAuthenticated` getter reflects login state.

*   **Task 4: Create New Login Page UI.**
    *   **File:** e.g., `lib/features/auth/presentation/login_page.dart` (renaming or replacing `lib/features/auth/presentation/login_screen.dart`).
    *   **Actions:**
        *   UI with `Email` and `Password` fields.
        *   "Login" button.
        *   Uses the new `AuthProvider` to call the `login` method.
        *   Displays loading indicators and error messages from `AuthProvider`.
        *   Navigates to home screen on successful login.
        *   Provides a link/button to navigate to the new Register page.

*   **Task 5: Create New Register Page UI.**
    *   **File:** e.g., `lib/features/auth/presentation/register_page.dart`.
    *   **Actions:**
        *   UI with `Email`, `Password`, `NativeLanguage` (dropdown), and `CurrentLearningLanguage` (dropdown) fields.
        *   Populate language dropdowns with a hardcoded list of common languages (e.g., English, Spanish, French, German, Chinese, Japanese). Store language codes (e.g., "en-US", "es-ES") that match backend expectations.
        *   "Register" button.
        *   Uses the new `AuthProvider` to call the `register` method.
        *   Displays loading indicators and error messages.
        *   Navigates to home screen (or login page) on successful registration.
        *   Provides a link/button to navigate to the Login page.

*   **Task 6: Update Navigation.**
    *   Ensure appropriate navigation routes are set up for the new Login and Register pages.
    *   Update any initial routing logic (e.g., in `main.dart`) to show the Login page if not authenticated.

*   **Task 7: Update Dependency Injection.**
    *   **File:** `lib/dependency_injection.dart`
    *   **Actions:**
        *   Ensure the new `AuthProvider` is registered if it's a new class or its dependencies change. (Likely no changes needed here if `AuthProvider` uses `GetIt` internally to locate `AccountService`).

*   **Task 8: Cleanup Old Code.**
    *   Remove/deprecate `lib/common/services/api_service.dart`.
    *   Remove/deprecate the old `lib/common/providers/auth_provider.dart` once the new one is in place.
    *   Remove/deprecate `lib/common/services/account_service.dart` (if it exists and is different from the one in `lib/services/`).

**III. Testing**

*   Thoroughly test the new Login and Register flows on the Flutter app.
*   Verify data is correctly sent to the backend.
*   Verify `UserSession` is correctly populated on the frontend.
*   Test error handling and user feedback.

**Mermaid Diagram of Frontend Auth Flow:**

```mermaid
graph TD
    A[App Start] --> B{Authenticated?};
    B -- Yes --> H[Home Screen];
    B -- No --> LP[Login Page];

    LP -- Enter Credentials & Click Login --> AP1[AuthProvider.login];
    AP1 -- Calls --> AS1[AccountService.login];
    AS1 -- Calls --> AA1[AccountApi.login];
    AA1 -- HTTP POST /account/login --> BE[Backend API];
    BE -- Returns UserSession --> AA1;
    AA1 -- Returns Response --> AS1;
    AS1 -- Populates UserSession Singleton & Stores Token --> AP1;
    AP1 -- Success --> H;
    AP1 -- Error --> LPError[Login Page with Error];

    LP -- Click 'Go to Register' --> RP[Register Page];
    RP -- Enter Details & Click Register --> AP2[AuthProvider.register];
    AP2 -- Calls --> AS2[AccountService.register];
    AS2 -- Calls --> AA2[AccountApi.register];
    AA2 -- HTTP POST /account/register --> BE;
    BE -- Returns UserSession --> AA2;
    AA2 -- Returns Response --> AS2;
    AS2 -- Populates UserSession Singleton & Stores Token --> AP2;
    AP2 -- Success --> H;
    AP2 -- Error --> RPError[Register Page with Error];
    RP -- Click 'Go to Login' --> LP;