import 'package:new_words/common/foundation/foundation.dart';
import 'package:new_words/entities/user_settings.dart';

/// Modern user settings API implementation using BaseApi foundation
/// 
/// This class replaces the old UserSettingsApi with standardized error handling,
/// validation patterns, and centralized constants usage.
class UserSettingsApiV2 extends BaseApi {
  UserSettingsApiV2([super.customDio]);

  /// Get all user settings for the current user
  Future<ApiResponseV2<List<UserSettings>>> getAll() async {
    return await get<List<UserSettings>>(
      '/settings/getAll',
      fromJson: (json) => (json as List<dynamic>)
          .map((settingJson) => UserSettings.fromJson(settingJson as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Insert or update a user setting
  Future<ApiResponseV2<void>> upsert(String settingName, String settingValue) async {
    validateStringField(settingName, 'settingName', minLength: 1, maxLength: 100);
    validateStringField(settingValue, 'settingValue', required: false, maxLength: 1000);

    return await requestVoid(
      'POST',
      '/settings/upsert',
      data: {
        'settingName': settingName,
        'settingValue': settingValue,
      },
    );
  }
}