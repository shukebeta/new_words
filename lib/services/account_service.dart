import 'package:new_words/apis/account_api.dart';
import 'package:new_words/app_config.dart';
import 'package:new_words/services/user_settings_service.dart';
import 'package:new_words/user_session.dart';
import 'package:new_words/utils/app_logger.dart';
import 'package:new_words/utils/token_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../exceptions/api_exception.dart';

class AccountService {
  final AccountApi _accountApi;
  final UserSettingsService _userSettingsService;
  final TokenUtils _tokenUtils;

  AccountService({
    required AccountApi accountApi,
    required UserSettingsService userSettingsService,
    required TokenUtils tokenUtils,
  }) : _accountApi = accountApi,
       _userSettingsService = userSettingsService,
       _tokenUtils = tokenUtils;

  // SharedPreferences Keys
  static const String _kTokenKey = 'accessToken';
  static const String _kBaseUrlKey = 'baseUrl';
  static const String _kUserEmailKey = 'user_email';
  static const String _kUserNativeLangKey = 'user_native_language';
  static const String _kUserLearningLangKey = 'user_learning_language';
  static const String kLastAddWordShownTime = 'last_add_word_shown_time';
  // Note: userId is typically derived from the token or API response directly, not stored separately in prefs unless API doesn't return it consistently.
  // For now, we'll get userId from token in initAuth, and from API response in login/register.

  // Token Payload Keys (already present, kept for reference)
  final String _payloadUserIdKey =
      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier';
  final String _payloadEmailKey =
      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress';

  Future<void> login(String email, String password) async {
    var params = {'email': email, 'password': password};
    final responseData = (await _accountApi.login(params)).data;
    if (responseData['successful']) {
      await _processLoginOrRegisterSuccess(responseData);
    } else {
      throw ApiException(responseData);
    }
  }

  Future<void> logout() async {
    await _clearUserSessionAndStorage();
  }

  Future<void> register(
    String email,
    String password,
    String nativeLanguage,
    String learningLanguage,
  ) async {
    var params = {
      'email': email,
      'password': password,
      'nativeLanguage': nativeLanguage,
      'learningLanguage': learningLanguage,
    };
    final responseData = (await _accountApi.register(params)).data;
    if (responseData['successful']) {
      await _processLoginOrRegisterSuccess(responseData);
    } else {
      throw ApiException(responseData);
    }
  }

  Future<void> _processLoginOrRegisterSuccess(
    Map<String, dynamic> apiResponseData,
  ) async {
    final sessionData = apiResponseData['data'] as Map<String, dynamic>;
    final token = sessionData['token'] as String?;
    final userId =
        sessionData['userId'] as int?; // Assuming API provides userId
    final email = sessionData['email'] as String?;
    final nativeLanguage = sessionData['nativeLanguage'] as String?;
    final currentLearningLanguage =
        sessionData['currentLearningLanguage'] as String?;

    if (token == null || token.isEmpty) {
      throw Exception('Token not found in API response');
    }

    // Store token and other details in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTokenKey, token);
    await prefs.setString(
      _kBaseUrlKey,
      AppConfig.apiBaseUrl,
    ); // Store current base URL for env check

    if (email != null) await prefs.setString(_kUserEmailKey, email);
    if (nativeLanguage != null)
      await prefs.setString(_kUserNativeLangKey, nativeLanguage);
    if (currentLearningLanguage != null)
      await prefs.setString(_kUserLearningLangKey, currentLearningLanguage);

    // Populate UserSession singleton
    UserSession().id = userId;
    UserSession().email = email;
    UserSession().nativeLanguage = nativeLanguage;
    UserSession().currentLearningLanguage = currentLearningLanguage;
    try {
      UserSession().userSettings = await _userSettingsService.getAll();
    } catch (e) {
      AppLogger.e("Failed to load user settings during login/register: $e");
      UserSession().userSettings = null; // Or some default
    }
  }

  // Called by AuthProvider.initAuth()
  Future<void> setUserSession({String? tokenFromInit}) async {
    final tokenToUse =
        tokenFromInit ??
        await getToken(); // getToken also handles refresh logic

    if (tokenToUse == null || tokenToUse.isEmpty) {
      await _clearUserSessionAndStorage(); // Ensure session is cleared if no token
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    try {
      // Decode token for essential info like userId
      var payload = await _tokenUtils.decodeToken(tokenToUse);
      UserSession().id = int.tryParse(payload[_payloadUserIdKey] ?? '');

      // Load other details from SharedPreferences
      UserSession().email =
          prefs.getString(_kUserEmailKey) ??
          payload[_payloadEmailKey]; // Fallback to token email
      UserSession().nativeLanguage = prefs.getString(_kUserNativeLangKey);
      UserSession().currentLearningLanguage = prefs.getString(
        _kUserLearningLangKey,
      );

      // If critical info like languages are missing from prefs (e.g., old session),
      // UserSession will have nulls. App should handle this gracefully.
      // The user opted against an API call here like getMyInformation.

      UserSession().userSettings = await _userSettingsService.getAll();
    } catch (e) {
      AppLogger.e("Failed to set user session during init: $e");
      await _clearUserSessionAndStorage(); // Clear session on error
    }
  }

  Future<void> _clearUserSessionAndStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTokenKey);
    await prefs.remove(_kBaseUrlKey);
    await prefs.remove(_kUserEmailKey);
    await prefs.remove(_kUserNativeLangKey);
    await prefs.remove(_kUserLearningLangKey);

    UserSession().id = null;
    UserSession().email = null;
    UserSession().nativeLanguage = null;
    UserSession().currentLearningLanguage = null;
    UserSession().userSettings = null;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_kTokenKey);
    if (token != null && token.isNotEmpty) {
      // Check if token is about to expire and refresh if needed
      var remainingTime = await _tokenUtils.getTokenRemainingTime(token);
      if (remainingTime.inMinutes < 5 && remainingTime.inSeconds > 0) {
        // Refresh if less than 5 mins left but not expired
        try {
          AppLogger.i("Attempting to refresh token...");
          await _refreshTokenAndResave(); // Don't await fully to avoid blocking UI, but log outcome
          return prefs.getString(_kTokenKey); // Return potentially new token
        } catch (e) {
          AppLogger.e("Token refresh failed: $e");
          // Don't clear token here, let isValidToken handle expiry
        }
      }
    }
    return token;
  }

  Future<void> _refreshTokenAndResave() async {
    var responseData =
        (await _accountApi.refreshToken())
            .data; // Assuming this API exists and is parameterless
    if (responseData['successful']) {
      final sessionData = responseData['data'] as Map<String, dynamic>;
      final newToken = sessionData['token'] as String?;
      if (newToken != null && newToken.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_kTokenKey, newToken);
        AppLogger.i("Token refreshed and resaved successfully.");
        // Optionally, if refresh token response contains updated user details, update them in prefs & UserSession
        // For now, just updating the token.
      } else {
        AppLogger.i(
          "Refresh token API success but no new token in response.",
        ); // Changed w to i
        throw Exception("No new token in refresh response");
      }
    } else {
      AppLogger.i(
        "Refresh token API call failed: ${responseData['message']}",
      ); // Changed w to i
      throw ApiException(responseData);
    }
  }

  Future<bool> isValidToken() async {
    if (await _isSameEnv()) {
      // Use a locally stored token first, without triggering refresh if not needed
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_kTokenKey);
      if (token != null && token.isNotEmpty) {
        try {
          return (await _tokenUtils.getTokenRemainingTime(token)).inSeconds >
              0; // Check if strictly positive
        } catch (e) {
          AppLogger.e(
            "isValidToken: Error decoding token or token expired: $e",
          );
          return false;
        }
      }
    }
    return false;
  }

  Future<bool> _isSameEnv() async {
    final prefs = await SharedPreferences.getInstance();
    final previousBaseUrl = prefs.getString(_kBaseUrlKey);
    return previousBaseUrl == null ||
        previousBaseUrl ==
            AppConfig.apiBaseUrl; // Allow if no previous URL (first run)
  }

  Future<void> updateUserLanguages(
    String nativeLanguage,
    String learningLanguage,
  ) async {
    final responseData =
        (await AccountApi.updateLanguages(
          nativeLanguage,
          learningLanguage,
        )).data;
    if (responseData['successful']) {
      // Update SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kUserNativeLangKey, nativeLanguage);
      await prefs.setString(_kUserLearningLangKey, learningLanguage);

      // Update UserSession
      UserSession().nativeLanguage = nativeLanguage;
      UserSession().currentLearningLanguage = learningLanguage;
    } else {
      throw ApiException(responseData);
    }
  }

  // _storeTokenString is now part of _processLoginOrRegisterSuccess
  // _populateUserSessionFromApiResponse is now part of _processLoginOrRegisterSuccess
}
