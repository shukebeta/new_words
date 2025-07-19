import 'package:new_words/apis/settings_api_v2.dart';
import 'package:new_words/common/foundation/foundation.dart';
import 'package:new_words/entities/language.dart';
import 'package:new_words/utils/app_logger.dart';
import 'package:new_words/utils/app_logger_interface.dart';

/// Modern settings service implementation using BaseService foundation
/// 
/// This class replaces the old SettingsService with standardized error handling,
/// logging patterns, and centralized exception management.
class SettingsServiceV2 extends BaseService {
  final SettingsApiV2 _settingsApi;
  final AppLoggerInterface _logger;

  SettingsServiceV2({
    required SettingsApiV2 settingsApi,
    AppLoggerInterface? logger,
  })  : _settingsApi = settingsApi,
        _logger = logger ?? AppLogger.instance;

  /// Get list of supported languages for the application
  Future<List<Language>> getSupportedLanguages() async {
    logOperation('getSupportedLanguages');

    try {
      final response = await _settingsApi.getSupportedLanguages();
      return processResponse(response);
    } catch (e) {
      throw ServiceExceptionFactory.fromException(e);
    }
  }
}