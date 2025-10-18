import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:new_words/apis/user_settings_api_v2.dart';
import 'package:new_words/common/foundation/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

@GenerateMocks([Dio])
import 'user_settings_api_v2_test.mocks.dart';

class TestUserSettingsApiV2 extends UserSettingsApiV2 {
  TestUserSettingsApiV2([super.dio]);
}

void main() {
  group('UserSettingsApiV2', () {
    late UserSettingsApiV2 api;
    late MockDio mockDio;

    setUpAll(() async {
      // Initialize dotenv for tests with mock values
      dotenv.testLoad(fileInput: '''
API_BASE_URL=https://test.example.com
''');
    });

    setUp(() {
      mockDio = MockDio();
      api = TestUserSettingsApiV2(mockDio);
    });

    group('getAll', () {
      test('successfully gets all user settings', () async {
        final responseData = {
          'successful': true,
          'data': [
            {
              'id': 1,
              'userId': 123,
              'settingName': 'theme',
              'settingValue': 'dark',
            },
            {
              'id': 2,
              'userId': 123,
              'settingName': 'language',
              'settingValue': 'en',
            }
          ]
        };

        when(mockDio.get(
          '/settings/getAll',
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => Response<Map<String, dynamic>>(
              data: responseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: '/settings/getAll'),
            ));

        final result = await api.getAll();

        expect(result.isSuccess, isTrue);
        expect(result.data, isNotNull);
        expect(result.data!.length, equals(2));
        expect(result.data!.first.settingName, equals('theme'));
        expect(result.data!.first.settingValue, equals('dark'));
        expect(result.data![1].settingName, equals('language'));
        expect(result.data![1].settingValue, equals('en'));
        
        verify(mockDio.get(
          '/settings/getAll',
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).called(1);
      });

      test('handles empty settings list', () async {
        final responseData = {
          'successful': true,
          'data': []
        };

        when(mockDio.get(
          '/settings/getAll',
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => Response<Map<String, dynamic>>(
              data: responseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: '/settings/getAll'),
            ));

        final result = await api.getAll();

        expect(result.isSuccess, isTrue);
        expect(result.data, isNotNull);
        expect(result.data!.length, equals(0));
      });
    });

    group('upsert', () {
      test('successfully upserts a setting', () async {
        final responseData = {
          'successful': true,
          'message': 'Setting updated successfully'
        };

        when(mockDio.post(
          any,
          data: anyNamed('data'),
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => Response<Map<String, dynamic>>(
              data: responseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: '/settings/upsert'),
            ));

        final result = await api.upsert('theme', 'light');

        expect(result.isSuccess, isTrue);
        
        verify(mockDio.post(
          '/settings/upsert',
          data: {
            'settingName': 'theme',
            'settingValue': 'light',
          },
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).called(1);
      });

      test('throws DataException for empty setting name', () async {
        expect(
          () => api.upsert('', 'value'),
          throwsA(isA<DataException>()),
        );
      });

      test('throws DataException for setting name too long', () async {
        final longName = 'a' * 101; // 101 characters, max is 100
        expect(
          () => api.upsert(longName, 'value'),
          throwsA(isA<DataException>()),
        );
      });

      test('throws DataException for setting value too long', () async {
        final longValue = 'a' * 1001; // 1001 characters, max is 1000
        expect(
          () => api.upsert('name', longValue),
          throwsA(isA<DataException>()),
        );
      });

      test('allows empty setting value', () async {
        final responseData = {
          'successful': true,
          'message': 'Setting updated successfully'
        };

        when(mockDio.post(
          any,
          data: anyNamed('data'),
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => Response<Map<String, dynamic>>(
              data: responseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: '/settings/upsert'),
            ));

        final result = await api.upsert('setting', '');

        expect(result.isSuccess, isTrue);
        
        verify(mockDio.post(
          '/settings/upsert',
          data: {
            'settingName': 'setting',
            'settingValue': '',
          },
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).called(1);
      });
    });
  });
}