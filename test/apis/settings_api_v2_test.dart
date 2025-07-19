import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:new_words/apis/settings_api_v2.dart';
import 'package:new_words/entities/language.dart';
import 'package:new_words/common/foundation/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:new_words/services/account_service_v2.dart';

@GenerateMocks([Dio])
import 'settings_api_v2_test.mocks.dart';

// Mock AccountServiceV2 for testing
class MockAccountService extends Mock implements AccountServiceV2 {
  @override
  Future<String?> getToken() async => 'mock-token';
  
  @override
  String? getValidToken() => 'mock-token';
  
  @override
  bool hasValidToken() => true;
}

Response<dynamic> createMockResponse(Map<String, dynamic> data) {
  return Response<dynamic>(
    data: data,
    statusCode: 200,
    requestOptions: RequestOptions(path: ''),
  );
}

void main() {
  group('SettingsApiV2', () {
    late SettingsApiV2 settingsApi;
    late MockDio mockDio;

    setUpAll(() async {
      // Initialize dotenv for tests with mock values
      dotenv.testLoad(fileInput: '''
API_BASE_URL=https://test.example.com
''');
      
      // Setup GetIt for tests to avoid dependency issues
      final getIt = GetIt.instance;
      
      // Reset GetIt for clean test environment
      if (getIt.isRegistered<AccountServiceV2>()) {
        await getIt.reset();
      }
      
      // Register minimal mocks for dependencies
      getIt.registerLazySingleton<AccountServiceV2>(() => MockAccountService());
    });

    setUp(() {
      mockDio = MockDio();
      settingsApi = SettingsApiV2(mockDio);
    });

    group('getSupportedLanguages', () {
      test('should return list of languages when API call succeeds', () async {
        // Arrange
        final mockResponse = {
          'successful': true,
          'data': [
            {'code': 'en', 'name': 'English'},
            {'code': 'zh', 'name': 'Chinese'},
          ],
        };

        when(mockDio.get(
          '/settings/languages',
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer(
          (_) async => createMockResponse(mockResponse),
        );

        // Act
        final result = await settingsApi.getSupportedLanguages();

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data, isNotNull);
        expect(result.data!.length, equals(2));
        expect(result.data![0].code, equals('en'));
        expect(result.data![0].name, equals('English'));
        expect(result.data![1].code, equals('zh'));
        expect(result.data![1].name, equals('Chinese'));
      });

      test('should return error response when API returns error', () async {
        // Arrange
        final mockResponse = {
          'successful': false,
          'errorCode': 404,
          'message': 'Languages not found',
        };

        when(mockDio.get(
          '/settings/languages',
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer(
          (_) async => createMockResponse(mockResponse),
        );

        // Act
        final result = await settingsApi.getSupportedLanguages();

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.errorMessage, equals('Languages not found'));
        expect(result.errorCode, equals(404));
      });

      test('should handle network errors correctly', () async {
        // Arrange
        when(mockDio.get(
          '/settings/languages',
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/settings/languages'),
          type: DioExceptionType.connectionTimeout,
          message: 'Connection timeout',
        ));

        // Act & Assert
        expect(
          () => settingsApi.getSupportedLanguages(),
          throwsA(isA<NetworkException>()),
        );
      });

      test('should handle empty language list', () async {
        // Arrange
        final mockResponse = {
          'successful': true,
          'data': <Map<String, dynamic>>[],
        };

        when(mockDio.get(
          '/settings/languages',
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer(
          (_) async => createMockResponse(mockResponse),
        );

        // Act
        final result = await settingsApi.getSupportedLanguages();

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data, isNotNull);
        expect(result.data!.isEmpty, isTrue);
      });
    });
  });
}