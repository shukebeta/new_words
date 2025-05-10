import 'package:new_words/apis/settings_api.dart'; // Changed import
import 'package:new_words/entities/language.dart';
import 'package:new_words/exceptions/api_exception.dart';

class SettingsService {
  final SettingsApi _settingsApi; // Changed type

  SettingsService({SettingsApi? settingsApi}) // Changed type
      : _settingsApi = settingsApi ?? SettingsApi(); // Changed type

  Future<List<Language>> getSupportedLanguages() async {
    try {
      // Changed to use _settingsApi
      final apiResult = (await _settingsApi.getSupportedLanguages()).data;
      if (apiResult['successful'] == true && apiResult['data'] != null) {
        List<dynamic> data = apiResult['data'];
        return data.map((item) => Language.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        throw ApiException(apiResult);
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException({
        'successful': false,
        'errorCode': -1,
        'message': 'Failed to load languages: $e',
      });
    }
  }
}