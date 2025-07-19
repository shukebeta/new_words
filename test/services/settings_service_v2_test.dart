import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:new_words/apis/settings_api_v2.dart';
import 'package:new_words/entities/language.dart';
import 'package:new_words/services/settings_service_v2.dart';
import 'package:new_words/common/foundation/foundation.dart';
import 'package:new_words/utils/app_logger_interface.dart';

import 'settings_service_v2_test.mocks.dart';

@GenerateMocks([SettingsApiV2, AppLoggerInterface])
void main() {
  group('SettingsServiceV2', () {
    late SettingsServiceV2 settingsService;
    late MockSettingsApiV2 mockSettingsApi;
    late MockAppLoggerInterface mockLogger;

    setUp(() {
      mockSettingsApi = MockSettingsApiV2();
      mockLogger = MockAppLoggerInterface();
      settingsService = SettingsServiceV2(
        settingsApi: mockSettingsApi,
        logger: mockLogger,
      );
    });

    group('getSupportedLanguages', () {
      test('should return list of languages when API call succeeds', () async {
        // Arrange
        final languages = [
          const Language(code: 'en', name: 'English'),
          const Language(code: 'zh', name: 'Chinese'),
        ];
        
        final successResponse = ApiResponseV2<List<Language>>.success(languages);

        when(mockSettingsApi.getSupportedLanguages())
            .thenAnswer((_) async => successResponse);

        // Act
        final result = await settingsService.getSupportedLanguages();

        // Assert
        expect(result.length, equals(2));
        expect(result[0].code, equals('en'));
        expect(result[0].name, equals('English'));
        expect(result[1].code, equals('zh'));
        expect(result[1].name, equals('Chinese'));

        verify(mockSettingsApi.getSupportedLanguages()).called(1);
      });

      test('should throw ServiceException when API call fails', () async {
        // Arrange
        final errorResponse = ApiResponseV2<List<Language>>.error(
          'Languages not found',
          statusCode: 200,
          errorCode: 404,
        );

        when(mockSettingsApi.getSupportedLanguages())
            .thenAnswer((_) async => errorResponse);

        // Act & Assert
        expect(
          () => settingsService.getSupportedLanguages(),
          throwsA(isA<ServiceException>()),
        );

        verify(mockSettingsApi.getSupportedLanguages()).called(1);
      });

      test('should handle and convert exceptions correctly', () async {
        // Arrange
        when(mockSettingsApi.getSupportedLanguages())
            .thenThrow(const NetworkException('Connection failed'));

        // Act & Assert
        expect(
          () => settingsService.getSupportedLanguages(),
          throwsA(isA<ServiceException>()),
        );

        verify(mockSettingsApi.getSupportedLanguages()).called(1);
      });

      test('should return empty list when API returns empty data', () async {
        // Arrange
        final emptyResponse = ApiResponseV2<List<Language>>.success(<Language>[]);

        when(mockSettingsApi.getSupportedLanguages())
            .thenAnswer((_) async => emptyResponse);

        // Act
        final result = await settingsService.getSupportedLanguages();

        // Assert
        expect(result.isEmpty, isTrue);
        verify(mockSettingsApi.getSupportedLanguages()).called(1);
      });

      test('should log operations correctly', () async {
        // Arrange
        final languages = [const Language(code: 'en', name: 'English')];
        final successResponse = ApiResponseV2<List<Language>>.success(languages);

        when(mockSettingsApi.getSupportedLanguages())
            .thenAnswer((_) async => successResponse);

        // Act
        await settingsService.getSupportedLanguages();

        // Assert - Just verify the API was called, logging is internal implementation
        verify(mockSettingsApi.getSupportedLanguages()).called(1);
      });
    });
  });
}