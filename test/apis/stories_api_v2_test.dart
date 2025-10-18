import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:new_words/apis/stories_api_v2.dart';
import 'package:new_words/common/foundation/foundation.dart';
import 'package:new_words/entities/generate_story_request.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

@GenerateMocks([Dio])
import 'stories_api_v2_test.mocks.dart';

class TestStoriesApiV2 extends StoriesApiV2 {
  TestStoriesApiV2([super.dio]);
}

void main() {
  group('StoriesApiV2', () {
    late StoriesApiV2 api;
    late MockDio mockDio;

    setUpAll(() async {
      // Initialize dotenv for tests with mock values
      dotenv.testLoad(fileInput: '''
API_BASE_URL=https://test.example.com
''');
    });

    setUp(() {
      mockDio = MockDio();
      api = TestStoriesApiV2(mockDio);
    });

    group('getMyStories', () {
      test('successfully gets my stories', () async {
        final responseData = {
          'successful': true,
          'data': {
            'dataList': [
              {
                'id': 1,
                'userId': 1,
                'content': 'Once upon a time...',
                'storyWords': 'apple,tree,sunshine',
                'learningLanguage': 'en',
                'firstReadAt': null,
                'favoriteCount': 5,
                'providerModelName': 'test-model',
                'createdAt': 1704067200,
                'isFavorited': false,
              }
            ],
            'totalCount': 1,
            'pageIndex': 1,
            'pageSize': 10,
          }
        };

        when(mockDio.get(
          '/stories/MyStories',
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => Response<Map<String, dynamic>>(
              data: responseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: '/stories/MyStories'),
            ));

        final result = await api.getMyStories(1, 10);

        expect(result.isSuccess, isTrue);
        expect(result.data, isNotNull);
        expect(result.data!.dataList.length, equals(1));
        expect(result.data!.dataList.first.content, contains('Once upon a time'));
        verify(mockDio.get(
          '/stories/MyStories',
          queryParameters: {'pageNumber': 1, 'pageSize': 10},
          options: anyNamed('options'),
        )).called(1);
      });

      test('throws DataException for invalid page number', () async {
        expect(
          () => api.getMyStories(0, 10),
          throwsA(isA<DataException>()),
        );
      });

      test('throws DataException for negative page number', () async {
        expect(
          () => api.getMyStories(-1, 10),
          throwsA(isA<DataException>()),
        );
      });

      test('throws DataException for page size too small', () async {
        expect(
          () => api.getMyStories(1, 0),
          throwsA(isA<DataException>()),
        );
      });

      test('throws DataException for page size too large', () async {
        expect(
          () => api.getMyStories(1, 101), // Default max is 100
          throwsA(isA<DataException>()),
        );
      });
    });

    group('getStorySquare', () {
      test('successfully gets story square', () async {
        final responseData = {
          'successful': true,
          'data': {
            'dataList': [
              {
                'id': 2,
                'userId': 2,
                'content': 'A story for everyone...',
                'storyWords': 'public,story,share',
                'learningLanguage': 'en',
                'firstReadAt': 1704067200,
                'favoriteCount': 15,
                'providerModelName': 'test-model',
                'createdAt': 1704067200,
                'isFavorited': true,
              }
            ],
            'totalCount': 1,
            'pageIndex': 1,
            'pageSize': 10,
          }
        };

        when(mockDio.get(
          '/stories/StorySquare',
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => Response<Map<String, dynamic>>(
              data: responseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: '/stories/StorySquare'),
            ));

        final result = await api.getStorySquare(1, 10);

        expect(result.isSuccess, isTrue);
        expect(result.data, isNotNull);
        expect(result.data!.dataList.length, equals(1));
        expect(result.data!.dataList.first.content, contains('A story for everyone'));
        expect(result.data!.dataList.first.isFavorited, isTrue);
      });

      test('throws DataException for invalid pagination', () async {
        expect(
          () => api.getStorySquare(0, 10),
          throwsA(isA<DataException>()),
        );
      });
    });

    group('getMyFavoriteStories', () {
      test('successfully gets favorite stories', () async {
        final responseData = {
          'successful': true,
          'data': {
            'dataList': [
              {
                'id': 3,
                'userId': 1,
                'content': 'A beloved story...',
                'storyWords': 'favorite,beloved,story',
                'learningLanguage': 'en',
                'firstReadAt': 1704067200,
                'favoriteCount': 25,
                'providerModelName': 'test-model',
                'createdAt': 1704067200,
                'isFavorited': true,
              }
            ],
            'totalCount': 1,
            'pageIndex': 1,
            'pageSize': 10,
          }
        };

        when(mockDio.get(
          '/stories/MyFavorite',
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => Response<Map<String, dynamic>>(
              data: responseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: '/stories/MyFavorite'),
            ));

        final result = await api.getMyFavoriteStories(1, 10);

        expect(result.isSuccess, isTrue);
        expect(result.data, isNotNull);
        expect(result.data!.dataList.length, equals(1));
        expect(result.data!.dataList.first.content, contains('A beloved story'));
        expect(result.data!.dataList.first.isFavorited, isTrue);
      });
    });

    group('generateStories', () {
      test('successfully generates stories with custom words', () async {
        final responseData = {
          'successful': true,
          'data': [
            {
              'id': 4,
              'userId': 1,
              'content': 'A story using custom words...',
              'storyWords': 'apple,tree,sunshine',
              'learningLanguage': 'en',
              'firstReadAt': null,
              'favoriteCount': 0,
              'providerModelName': 'test-model',
              'createdAt': 1704067200,
              'isFavorited': false,
            }
          ]
        };

        when(mockDio.post(
          any,
          data: anyNamed('data'),
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => Response<Map<String, dynamic>>(
              data: responseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: '/stories/Generate'),
            ));

        final request = GenerateStoryRequest(words: ['apple', 'tree', 'sunshine']);
        final result = await api.generateStories(request);

        expect(result.isSuccess, isTrue);
        expect(result.data, isNotNull);
        expect(result.data!.length, equals(1));
        expect(result.data!.first.content, contains('A story using custom words'));
        
        verify(mockDio.post(
          '/stories/Generate',
          data: request.toJson(),
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).called(1);
      });

      test('successfully generates stories with null request', () async {
        final responseData = {
          'successful': true,
          'data': [
            {
              'id': 5,
              'userId': 1,
              'content': 'A story from recent vocabulary...',
              'storyWords': 'vocabulary,recent,story',
              'learningLanguage': 'en',
              'firstReadAt': null,
              'favoriteCount': 0,
              'providerModelName': 'test-model',
              'createdAt': 1704067200,
              'isFavorited': false,
            }
          ]
        };

        when(mockDio.post(
          any,
          data: anyNamed('data'),
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => Response<Map<String, dynamic>>(
              data: responseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: '/stories/Generate'),
            ));

        final result = await api.generateStories(null);

        expect(result.isSuccess, isTrue);
        expect(result.data, isNotNull);
        expect(result.data!.length, equals(1));
        
        verify(mockDio.post(
          '/stories/Generate',
          data: {},
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).called(1);
      });
    });

    group('markStoryAsRead', () {
      test('successfully marks story as read', () async {
        final responseData = {
          'successful': true,
          'message': 'Story marked as read'
        };

        when(mockDio.post(
          any,
          data: anyNamed('data'),
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => Response<Map<String, dynamic>>(
              data: responseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: '/stories/MarkRead/1'),
            ));

        final result = await api.markStoryAsRead(1);

        expect(result.isSuccess, isTrue);
        verify(mockDio.post(
          '/stories/MarkRead/1',
          data: anyNamed('data'),
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).called(1);
      });

      test('throws DataException for invalid story ID', () async {
        expect(
          () => api.markStoryAsRead(0),
          throwsA(isA<DataException>()),
        );
      });

      test('throws DataException for negative story ID', () async {
        expect(
          () => api.markStoryAsRead(-1),
          throwsA(isA<DataException>()),
        );
      });
    });

    group('toggleFavorite', () {
      test('successfully toggles favorite', () async {
        final responseData = {
          'successful': true,
          'message': 'Favorite status toggled'
        };

        when(mockDio.post(
          any,
          data: anyNamed('data'),
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => Response<Map<String, dynamic>>(
              data: responseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: '/stories/ToggleFavorite/1'),
            ));

        final result = await api.toggleFavorite(1);

        expect(result.isSuccess, isTrue);
        verify(mockDio.post(
          '/stories/ToggleFavorite/1',
          data: anyNamed('data'),
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).called(1);
      });

      test('throws DataException for invalid story ID', () async {
        expect(
          () => api.toggleFavorite(0),
          throwsA(isA<DataException>()),
        );
      });
    });
  });
}