import 'package:flutter/material.dart';
import 'package:new_words/services/account_service.dart';
import 'package:new_words/dependency_injection.dart'; // For locator
import 'package:new_words/user_session.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For initAuth token check

class AuthProvider with ChangeNotifier {
  final AccountService _accountService = locator<AccountService>();

  String? _token;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  String? get token => _token;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized; // To track if initAuth has run

  AuthProvider() {
    initAuth();
  }

  Future<void> initAuth() async {
    if (_isInitialized) return; // Prevent multiple initializations

    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final storedToken = prefs.getString('accessToken'); // Matches _tokenKey in AccountService

      if (storedToken != null && storedToken.isNotEmpty) {
        // Validate token and populate UserSession
        // AccountService.isValidToken() also refreshes if needed.
        if (await _accountService.isValidToken()) {
          _token = storedToken;
          // UserSession should be populated by AccountService.setUserSession or similar logic
          // called during isValidToken or by a dedicated method if token is valid.
          // For now, we assume AccountService handles UserSession population on successful token validation/refresh.
          // If not, we might need to explicitly call setUserSession here.
          await _accountService.setUserSession(token: _token); // Ensure session is populated
        } else {
          _token = null; // Token is invalid or expired
          await _accountService.logout(); // Clear any stale session data
        }
      }
    } catch (e) {
      _error = 'Failed to initialize authentication: ${e.toString()}';
      _token = null;
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _accountService.login(email, password);
      // After successful login, AccountService should have populated UserSession
      // and stored the token. We need to get the token for our state.
      _token = await _accountService.getToken();
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _token = null;
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String email, String password, String nativeLanguage, String learningLanguage) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _accountService.register(email, password, nativeLanguage, learningLanguage);
      // After successful registration, AccountService should have populated UserSession
      // and stored the token.
      _token = await _accountService.getToken();
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _token = null;
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    await _accountService.logout();
    _token = null;
    _error = null;
    // UserSession().id = null; // AccountService._clearToken handles this
    // UserSession().email = null;
    // UserSession().nativeLanguage = null;
    // UserSession().currentLearningLanguage = null;
    // UserSession().userSettings = null;
    
    _isLoading = false;
    notifyListeners();
  }
}