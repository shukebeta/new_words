import 'package:flutter/foundation.dart';
import 'package:new_words/providers/auth_provider.dart';
import 'package:new_words/providers/vocabulary_provider.dart';
import 'package:new_words/providers/stories_provider.dart';
import 'package:new_words/providers/memories_provider.dart';
import 'package:new_words/providers/locale_provider.dart';
import 'package:new_words/providers/provider_base.dart';

/// Main application state provider that manages all other providers
/// and handles authentication state changes
class AppStateProvider with ChangeNotifier {
  final AuthProvider _authProvider;
  final VocabularyProvider _vocabularyProvider;
  final StoriesProvider _storiesProvider;
  final MemoriesProvider _memoriesProvider;
  final LocaleProvider _localeProvider;

  // List of all auth-aware providers for easy management
  late final List<AuthAwareProvider> _authAwareProviders;

  AppStateProvider({
    required AuthProvider authProvider,
    required VocabularyProvider vocabularyProvider,
    required StoriesProvider storiesProvider,
    required MemoriesProvider memoriesProvider,
    required LocaleProvider localeProvider,
  }) : _authProvider = authProvider,
       _vocabularyProvider = vocabularyProvider,
       _storiesProvider = storiesProvider,
       _memoriesProvider = memoriesProvider,
       _localeProvider = localeProvider {
    debugPrint('AppStateProvider: Constructor called - setting up listeners');

    // Initialize list of auth-aware providers
    _authAwareProviders = [
      _vocabularyProvider,
      _storiesProvider,
      _memoriesProvider,
    ];

    // Listen to auth state changes
    _authProvider.addListener(_onAuthStateChanged);

    // Initialize auth state for all providers
    _initializeAuthState();
  }

  // Getters for accessing individual providers
  AuthProvider get auth => _authProvider;
  VocabularyProvider get vocabulary => _vocabularyProvider;
  StoriesProvider get stories => _storiesProvider;
  MemoriesProvider get memories => _memoriesProvider;
  LocaleProvider get locale => _localeProvider;

  /// Initialize auth state for all providers based on current auth status
  void _initializeAuthState() {
    final isAuthenticated = _authProvider.isAuthenticated;
    debugPrint(
      'AppStateProvider: Initializing auth state - isAuthenticated: $isAuthenticated',
    );

    // Notify all auth-aware providers of current auth state
    for (final provider in _authAwareProviders) {
      provider.onAuthStateChanged(isAuthenticated);
    }
  }

  /// Handle authentication state changes
  void _onAuthStateChanged() {
    final isAuthenticated = _authProvider.isAuthenticated;
    debugPrint(
      'AppStateProvider: Auth state changed - isAuthenticated: $isAuthenticated',
    );

    // Always clear data first to prevent stale data
    for (final provider in _authAwareProviders) {
      provider.clearAllData();
    }

    // Notify listeners immediately after clearing to update UI
    notifyListeners();

    // Then handle the auth state change
    for (final provider in _authAwareProviders) {
      provider.onAuthStateChanged(isAuthenticated);
    }

    // Final notification
    notifyListeners();
  }

  /// Clear all provider data manually (for testing purposes)
  void clearAllProviderData() {
    debugPrint('AppStateProvider: Manually clearing all provider data');

    for (final provider in _authAwareProviders) {
      provider.clearAllData();
    }
  }

  /// Get the count of auth-aware providers
  int get authAwareProviderCount => _authAwareProviders.length;

  /// Check if all auth-aware providers are initialized
  bool get allProvidersInitialized => _authAwareProviders.every(
    (provider) =>
        provider.isAuthStateInitialized || !_authProvider.isAuthenticated,
  );

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthStateChanged);
    super.dispose();
  }
}
