import 'package:new_words/common/foundation/foundation.dart';
import 'package:new_words/entities/language.dart';

/// Modern settings API implementation using BaseApi foundation
/// 
/// This class replaces the old SettingsApi with standardized validation,
/// error handling, and response wrapping patterns.
class SettingsApiV2 extends BaseApi {
  /// Constructor with optional custom Dio for testing
  SettingsApiV2([super.customDio]);
  /// Get list of supported languages for the application
  Future<ApiResponseV2<List<Language>>> getSupportedLanguages() async {
    return await get<List<Language>>(
      '/settings/languages',
      fromJson: (json) => (json as List<dynamic>)
          .map((item) => Language.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}