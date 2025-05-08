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
  })
      :
        _accountApi = accountApi,
        _userSettingsService = userSettingsService,
        _tokenUtils = tokenUtils;

  Future<void> login(String email, String password) async {
    var params = {'email': email, 'password': password};
    final responseData = (await _accountApi.login(params)).data;
    if (responseData['successful']) {
      final sessionData = responseData['data'] as Map<String, dynamic>;
      await _populateUserSessionFromApiResponse(sessionData);
      await _storeTokenString(sessionData['token'] as String);
    } else {
      throw ApiException(responseData);
    }
  }

  Future<void> logout() async {
    await _clearToken();
  }

  Future<void> register(String email, String password, String nativeLanguage, String learningLanguage) async {
    var params = {
      'email': email,
      'password': password,
      'nativeLanguage': nativeLanguage,
      'learningLanguage': learningLanguage
    };
    final responseData = (await _accountApi.register(params)).data;
    if (responseData['successful']) {
      final sessionData = responseData['data'] as Map<String, dynamic>;
      await _populateUserSessionFromApiResponse(sessionData);
      await _storeTokenString(sessionData['token'] as String);
    } else {
      throw ApiException(responseData);
    }
  }

  Future<void> _refreshToken() async {
    var responseData = (await _accountApi.refreshToken()).data;
    if (responseData['successful']) {
      final sessionData = responseData['data'] as Map<String, dynamic>;
      // Assuming refreshToken also returns the full session data or at least the token
      // If it only returns a new token, _populateUserSessionFromApiResponse might not be suitable here
      // or would need an updated UserSession object from another call.
      // For now, let's assume it returns a token that needs storing.
      // If the session details (like languages) could change and are returned, then populate.
      await _storeTokenString(sessionData['token'] as String);
      // Potentially re-fetch or update user session details if refreshToken provides them
      // await _populateUserSessionFromApiResponse(sessionData); // If applicable
    }
  }

  Future<void> _populateUserSessionFromApiResponse(Map<String, dynamic> sessionData) async {
    UserSession().id = sessionData['userId'] as int?; // Backend UserSession.UserId is long
    UserSession().email = sessionData['email'] as String?;
    UserSession().nativeLanguage = sessionData['nativeLanguage'] as String?;
    UserSession().currentLearningLanguage = sessionData['currentLearningLanguage'] as String?;
    UserSession().userSettings = await _userSettingsService.getAll();
  }

  final _tokenKey = 'accessToken';
  final _baseUrlKey = 'baseUrl';
  final String _payloadUserIdKey = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier';
  final String _payloadEmailKey = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress';

  Future<void> _storeTokenString(String token) async {
    final prefs = await SharedPreferences.getInstance();
    // setUserSession is called by _populateUserSessionFromApiResponse or by initAuth
    // Storing the token itself is the main job here.
    // If _populateUserSessionFromApiResponse hasn't been called (e.g. in _refreshToken if it only returns token)
    // then setUserSession might be needed here.
    // For login/register flow, _populateUserSessionFromApiResponse handles UserSession population.
    await prefs.setString(_baseUrlKey, AppConfig.apiBaseUrl);
    await prefs.setString(_tokenKey, token);
  }

  Future<void> setUserSession({String? token}) async {
    token ??= await getToken();
    if (token == null || token.isEmpty) {
      // No token, cannot set user session
      await _clearToken(); // Ensure session is cleared
      return;
    }

    try {
      var payload = await _tokenUtils.decodeToken(token);
      UserSession().id = int.parse(payload[_payloadUserIdKey]);
      UserSession().email = payload[_payloadEmailKey];

      // Fetch full user information to get language preferences
      final userInfo = await AccountApi.getMyInformation();
      UserSession().nativeLanguage = userInfo.nativeLanguage;
      UserSession().currentLearningLanguage = userInfo.currentLearningLanguage;

      UserSession().userSettings = await _userSettingsService.getAll();
    } catch (e) {
      AppLogger.e("Failed to set user session: $e");
      await _clearToken(); // Clear session on error
    }
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_baseUrlKey);
    UserSession().id = null;
    UserSession().email = null;
    UserSession().nativeLanguage = null;
    UserSession().currentLearningLanguage = null;
    UserSession().userSettings = null;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token != null && token != '') {
      var remainingTime = await _tokenUtils.getTokenRemainingTime(token);
      if (remainingTime.inDays <= 30) {
        try {
          //we deliberately don't use await here to avoid blocking the getToken operation
          _refreshToken();
        } catch (e) {
          // eat the exception
        }
      }
    }
    return token;
  }

  Future<bool> isValidToken() async {
    if (await _isSameEnv()) {
      final token = await getToken();
      if (token != null && token != '') {
        try {
          return (await _tokenUtils.getTokenRemainingTime(token)).inSeconds >= 1;
        } catch (e) {
          AppLogger.e(e.toString());
          return false;
        }
      }
    }
    return false;
  }

  // if env changes, even the token is valid, we still need to ask user to log in
  Future<bool> _isSameEnv() async {
    final prefs = await SharedPreferences.getInstance();
    final previousBaseUrl = prefs.getString(_baseUrlKey);
    return previousBaseUrl == AppConfig.apiBaseUrl;
  }
}
