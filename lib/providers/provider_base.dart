import 'package:flutter/foundation.dart';

/// Base class for providers that need to respond to authentication state changes
abstract class AuthAwareProvider with ChangeNotifier {
  bool _isAuthStateInitialized = false;
  bool get isAuthStateInitialized => _isAuthStateInitialized;

  /// Called when the user logs in successfully
  /// Override this to load initial data after login
  @protected
  Future<void> onLogin() async {
    // Default implementation does nothing
    // Subclasses can override to load data
  }

  /// Called when the user logs out
  /// Override this to perform custom cleanup in addition to clearAllData
  @protected
  Future<void> onLogout() async {
    // Default implementation just clears data
    clearAllData();
  }

  /// Called when auth state changes
  /// This is called by AppStateProvider
  Future<void> onAuthStateChanged(bool isAuthenticated) async {
    if (isAuthenticated) {
      // Always initialize on login, regardless of previous state
      // This ensures clean state for each user session
      _isAuthStateInitialized = true;

      // Note: clearAllData() is already called by AppStateProvider
      // We don't call it again here to avoid double clearing

      // Add a small delay to ensure UI updates with cleared state
      // before loading new data
      await Future.delayed(const Duration(milliseconds: 100));

      await onLogin();
    } else {
      if (_isAuthStateInitialized) {
        _isAuthStateInitialized = false;
        await onLogout();
      }
    }
  }

  /// Clear all cached data
  /// All auth-aware providers must implement this method
  void clearAllData();

  /// Reset the auth state initialization flag
  /// Used for testing purposes
  @protected
  void resetAuthState() {
    _isAuthStateInitialized = false;
  }
}
