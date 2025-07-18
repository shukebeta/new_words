import 'package:new_words/apis/user_settings_api.dart';
import 'package:new_words/entities/user_settings.dart';
import 'package:new_words/exceptions/api_exception.dart';
import 'package:new_words/user_session.dart';

class UserSettingsService {
  final UserSettingsApi _userSettingsApi;
  UserSettingsService({required UserSettingsApi userSettingsApi})
    : _userSettingsApi = userSettingsApi;

  Future<List<UserSettings>> getAll() async {
    List<dynamic> apiResult = (await _userSettingsApi.getAll()).data['data'];
    return apiResult.map((json) => UserSettings.fromJson(json)).toList();
  }

  Future<bool> upsert(String settingName, String settingValue) async {
    final apiResult =
        (await _userSettingsApi.upsert(settingName, settingValue)).data;
    if (!apiResult['successful']) throw ApiException(apiResult);
    for (var el in UserSession().userSettings!) {
      if (el.settingName == settingName) {
        el.settingValue = settingValue;
      }
    }
    return true;
  }
}
