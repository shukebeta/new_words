import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:new_words/apis/user_settings_api_v2.dart';
import 'package:new_words/services/user_settings_service_v2.dart';
import 'package:new_words/common/foundation/foundation.dart';
import 'package:new_words/entities/user_settings.dart';
import 'package:new_words/user_session.dart';
import '../mocks/mock_app_logger.dart';

@GenerateMocks([
  UserSettingsApiV2,
])
import 'user_settings_service_v2_test.mocks.dart';

void main() {
  group('UserSettingsServiceV2', () {
    late UserSettingsServiceV2 service;
    late MockUserSettingsApiV2 mockApi;
    late MockAppLogger mockLogger;

    setUpAll(() async {
      // Initialize dotenv for tests with mock values
      dotenv.testLoad(fileInput: '''
API_BASE_URL=https://test.example.com
''');
    });

    setUp(() {
      mockApi = MockUserSettingsApiV2();
      mockLogger = MockAppLogger();
      service = UserSettingsServiceV2(
        userSettingsApi: mockApi,
        logger: mockLogger,
      );
    });

    group('getAll', () {
      test('successfully gets all user settings', () async {
        final settings = [
          UserSettings(
            id: 1,
            userId: 123,
            settingName: 'theme',
            settingValue: 'dark',
          ),
          UserSettings(
            id: 2,
            userId: 123,
            settingName: 'language',
            settingValue: 'en',
          ),
        ];

        final apiResponse = ApiResponseV2<List<UserSettings>>.success(
          settings,
          statusCode: 200,
        );

        when(mockApi.getAll()).thenAnswer((_) async => apiResponse);

        final result = await service.getAll();

        expect(result.length, equals(2));
        expect(result.first.settingName, equals('theme'));
        expect(result.first.settingValue, equals('dark'));
        expect(result[1].settingName, equals('language'));
        expect(result[1].settingValue, equals('en'));
        verify(mockApi.getAll()).called(1);
      });

      test('throws exception for API error', () async {
        final apiResponse = ApiResponseV2<List<UserSettings>>.error(
          'Failed to fetch settings',
          statusCode: 500,
          errorCode: 5001,
        );

        when(mockApi.getAll()).thenAnswer((_) async => apiResponse);

        expect(
          () => service.getAll(),
          throwsA(isA<ServerException>()),
        );
      });

      test('handles API exception gracefully', () async {
        when(mockApi.getAll())
            .thenThrow(Exception('Network error'));

        expect(
          () => service.getAll(),
          throwsA(isA<ServiceException>()),
        );
      });
    });

    group('upsert', () {
      test('successfully upserts setting and updates session', () async {
        // Setup user session with existing settings
        final existingSetting = UserSettings(
          id: 1,
          userId: 123,
          settingName: 'theme',
          settingValue: 'dark',
        );
        UserSession().userSettings = [existingSetting];

        final apiResponse = ApiResponseV2<void>.success(
          null,
          statusCode: 200,
        );

        when(mockApi.upsert('theme', 'light')).thenAnswer((_) async => apiResponse);

        final result = await service.upsert('theme', 'light');

        expect(result, isTrue);
        expect(existingSetting.settingValue, equals('light')); // Session updated
        verify(mockApi.upsert('theme', 'light')).called(1);
        expect(mockLogger.infoLogs, contains('Successfully updated user setting: theme'));
      });

      test('successfully upserts new setting when not in session', () async {
        // Setup user session with no existing settings
        UserSession().userSettings = [];

        final apiResponse = ApiResponseV2<void>.success(
          null,
          statusCode: 200,
        );

        when(mockApi.upsert('newSetting', 'value')).thenAnswer((_) async => apiResponse);

        final result = await service.upsert('newSetting', 'value');

        expect(result, isTrue);
        verify(mockApi.upsert('newSetting', 'value')).called(1);
        expect(mockLogger.infoLogs, contains('Successfully updated user setting: newSetting'));
        expect(mockLogger.debugLogs, contains('Setting newSetting not found in user session'));
      });

      test('handles null user session gracefully', () async {
        // Setup null user session
        UserSession().userSettings = null;

        final apiResponse = ApiResponseV2<void>.success(
          null,
          statusCode: 200,
        );

        when(mockApi.upsert('setting', 'value')).thenAnswer((_) async => apiResponse);

        final result = await service.upsert('setting', 'value');

        expect(result, isTrue);
        verify(mockApi.upsert('setting', 'value')).called(1);
        expect(mockLogger.debugLogs, contains('User session settings not available'));
      });

      test('throws exception for API error', () async {
        final apiResponse = ApiResponseV2<void>.error(
          'Failed to update setting',
          statusCode: 500,
        );

        when(mockApi.upsert('theme', 'light')).thenAnswer((_) async => apiResponse);

        expect(
          () => service.upsert('theme', 'light'),
          throwsA(isA<ServerException>()),
        );
      });

      test('handles API exception gracefully', () async {
        when(mockApi.upsert('theme', 'light'))
            .thenThrow(Exception('Network error'));

        expect(
          () => service.upsert('theme', 'light'),
          throwsA(isA<ServiceException>()),
        );
      });
    });
  });
}