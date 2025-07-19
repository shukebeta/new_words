import 'package:new_words/apis/user_settings_api_v2.dart';
import 'package:new_words/common/foundation/foundation.dart';
import 'package:new_words/entities/user_settings.dart';
import 'package:new_words/user_session.dart';
import 'package:new_words/utils/app_logger_interface.dart';
import 'package:new_words/utils/app_logger.dart';

/// Modern user settings service implementation using BaseService foundation
/// 
/// This class replaces the old UserSettingsService with standardized error handling,
/// validation patterns, and proper session management.
class UserSettingsServiceV2 extends BaseService {
  final UserSettingsApiV2 _userSettingsApi;
  final AppLoggerInterface _logger;

  UserSettingsServiceV2({
    required UserSettingsApiV2 userSettingsApi,
    AppLoggerInterface? logger,
  }) : _userSettingsApi = userSettingsApi,
       _logger = logger ?? AppLogger.instance;

  /// Get all user settings for the current user
  Future<List<UserSettings>> getAll() async {
    logOperation('getAll');

    try {
      final response = await _userSettingsApi.getAll();
      return processResponse(response);
    } catch (e) {
      throw ServiceExceptionFactory.fromException(e);
    }
  }

  /// Insert or update a user setting and sync with user session
  Future<bool> upsert(String settingName, String settingValue) async {
    logOperation('upsert', parameters: {
      'settingName': settingName,
      'settingValueLength': settingValue.length,
    });

    try {
      final response = await _userSettingsApi.upsert(settingName, settingValue);
      processVoidResponse(response);

      // Update the user session with the new setting value
      _updateUserSession(settingName, settingValue);
      
      _logger.i('Successfully updated user setting: $settingName');
      return true;
    } catch (e) {
      throw ServiceExceptionFactory.fromException(e);
    }
  }

  /// Update the user session with the new setting value
  void _updateUserSession(String settingName, String settingValue) {
    try {
      final userSettings = UserSession().userSettings;
      if (userSettings != null) {
        for (var setting in userSettings) {
          if (setting.settingName == settingName) {
            setting.settingValue = settingValue;
            _logger.d('Updated user session setting: $settingName = $settingValue');
            return;
          }
        }
        // If setting doesn't exist in session, log this but don't fail
        _logger.d('Setting $settingName not found in user session');
      } else {
        _logger.d('User session settings not available');
      }
    } catch (e) {
      // Don't throw - session update is not critical for the operation
      _logger.e('Failed to update user session setting $settingName: $e');
    }
  }
}