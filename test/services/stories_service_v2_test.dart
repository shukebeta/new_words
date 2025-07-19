import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:new_words/apis/stories_api_v2.dart';
import 'package:new_words/services/stories_service_v2.dart';
import 'package:new_words/common/foundation/foundation.dart';
import 'package:new_words/entities/generate_story_request.dart';
import 'package:new_words/entities/story.dart';
import 'package:new_words/entities/page_data.dart';
import '../mocks/mock_app_logger.dart';

@GenerateMocks([
  StoriesApiV2,
])
import 'stories_service_v2_test.mocks.dart';

void main() {
  group('StoriesServiceV2', () {
    late StoriesServiceV2 service;
    late MockStoriesApiV2 mockApi;
    late MockAppLogger mockLogger;

    setUpAll(() async {
      // Initialize dotenv for tests with mock values
      dotenv.testLoad(fileInput: '''
API_BASE_URL=https://test.example.com
''');
    });

    setUp(() {
      mockApi = MockStoriesApiV2();
      mockLogger = MockAppLogger();
      service = StoriesServiceV2(
        storiesApi: mockApi,
        logger: mockLogger,
      );
    });

    group('getMyStories', () {
      test('successfully gets my stories', () async {
        final stories = [
          Story(
            id: 1,
            userId: 1,
            content: 'Once upon a time...',
            storyWords: 'test,story,words',
            learningLanguage: 'en',
            favoriteCount: 5,
            firstReadAt: null,
            createdAt: 1704067200,
          )
        ];

        final pageData = PageData<Story>(
          dataList: stories,
          totalCount: 1,
          pageIndex: 1,
          pageSize: 10,
        );

        final apiResponse = ApiResponseV2<PageData<Story>>.success(
          pageData,
          statusCode: 200,
        );

        when(mockApi.getMyStories(1, 10)).thenAnswer((_) async => apiResponse);

        final result = await service.getMyStories(1, 10);

        expect(result.dataList.length, equals(1));
        expect(result.dataList.first.content, contains('Once upon a time'));
        expect(result.totalCount, equals(1));
        verify(mockApi.getMyStories(1, 10)).called(1);
      });

      test('throws exception for API error', () async {
        final apiResponse = ApiResponseV2<PageData<Story>>.error(
          'Failed to fetch stories',
          statusCode: 500,
          errorCode: 5001,
        );

        when(mockApi.getMyStories(1, 10)).thenAnswer((_) async => apiResponse);

        expect(
          () => service.getMyStories(1, 10),
          throwsA(isA<ServerException>()),
        );
      });

      test('handles API exception gracefully', () async {
        when(mockApi.getMyStories(1, 10))
            .thenThrow(Exception('Network error'));

        expect(
          () => service.getMyStories(1, 10),
          throwsA(isA<ServiceException>()),
        );
      });
    });

    group('getStorySquare', () {
      test('successfully gets story square', () async {
        final stories = [
          Story(
            id: 2,
            userId: 2,
            content: 'A story for everyone...',
            storyWords: 'public,story,share',
            learningLanguage: 'en',
            favoriteCount: 15,
            isFavorited: true,
            firstReadAt: 1704067200,
            createdAt: 1704067200,
          )
        ];

        final pageData = PageData<Story>(
          dataList: stories,
          totalCount: 1,
          pageIndex: 1,
          pageSize: 10,
        );

        final apiResponse = ApiResponseV2<PageData<Story>>.success(
          pageData,
          statusCode: 200,
        );

        when(mockApi.getStorySquare(1, 10)).thenAnswer((_) async => apiResponse);

        final result = await service.getStorySquare(1, 10);

        expect(result.dataList.length, equals(1));
        expect(result.dataList.first.content, contains('A story for everyone'));
        expect(result.dataList.first.isFavorited, isTrue);
        verify(mockApi.getStorySquare(1, 10)).called(1);
      });

      test('throws exception for API error', () async {
        final apiResponse = ApiResponseV2<PageData<Story>>.error(
          'Failed to fetch story square',
          statusCode: 500,
        );

        when(mockApi.getStorySquare(1, 10)).thenAnswer((_) async => apiResponse);

        expect(
          () => service.getStorySquare(1, 10),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('getMyFavoriteStories', () {
      test('successfully gets favorite stories', () async {
        final stories = [
          Story(
            id: 3,
            userId: 1,
            content: 'A beloved story...',
            storyWords: 'favorite,beloved,story',
            learningLanguage: 'en',
            favoriteCount: 25,
            isFavorited: true,
            firstReadAt: 1704067200,
            createdAt: 1704067200,
          )
        ];

        final pageData = PageData<Story>(
          dataList: stories,
          totalCount: 1,
          pageIndex: 1,
          pageSize: 10,
        );

        final apiResponse = ApiResponseV2<PageData<Story>>.success(
          pageData,
          statusCode: 200,
        );

        when(mockApi.getMyFavoriteStories(1, 10))
            .thenAnswer((_) async => apiResponse);

        final result = await service.getMyFavoriteStories(1, 10);

        expect(result.dataList.length, equals(1));
        expect(result.dataList.first.content, contains('A beloved story'));
        expect(result.dataList.first.isFavorited, isTrue);
        verify(mockApi.getMyFavoriteStories(1, 10)).called(1);
      });

      test('throws exception for API error', () async {
        final apiResponse = ApiResponseV2<PageData<Story>>.error(
          'Failed to fetch favorite stories',
          statusCode: 500,
        );

        when(mockApi.getMyFavoriteStories(1, 10))
            .thenAnswer((_) async => apiResponse);

        expect(
          () => service.getMyFavoriteStories(1, 10),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('generateStories', () {
      test('successfully generates stories with custom words', () async {
        final stories = [
          Story(
            id: 4,
            userId: 1,
            content: 'A story using custom words...',
            storyWords: 'apple,tree,sunshine',
            learningLanguage: 'en',
            favoriteCount: 0,
            isFavorited: false,
            firstReadAt: null,
            createdAt: 1704067200,
          )
        ];

        final apiResponse = ApiResponseV2<List<Story>>.success(
          stories,
          statusCode: 200,
        );

        when(mockApi.generateStories(any)).thenAnswer((_) async => apiResponse);

        final result = await service.generateStories(
          customWords: ['apple', 'tree', 'sunshine'],
        );

        expect(result.length, equals(1));
        expect(result.first.content, contains('A story using custom words'));

        final captured = verify(mockApi.generateStories(captureAny)).captured;
        final request = captured.first as GenerateStoryRequest;
        expect(request.words, equals(['apple', 'tree', 'sunshine']));
      });

      test('successfully generates stories without custom words', () async {
        final stories = [
          Story(
            id: 5,
            userId: 1,
            content: 'A story from recent vocabulary...',
            storyWords: 'vocabulary,recent,story',
            learningLanguage: 'en',
            favoriteCount: 0,
            isFavorited: false,
            firstReadAt: null,
            createdAt: 1704067200,
          )
        ];

        final apiResponse = ApiResponseV2<List<Story>>.success(
          stories,
          statusCode: 200,
        );

        when(mockApi.generateStories(any)).thenAnswer((_) async => apiResponse);

        final result = await service.generateStories();

        expect(result.length, equals(1));
        expect(result.first.content, contains('A story from recent vocabulary'));

        final captured = verify(mockApi.generateStories(captureAny)).captured;
        expect(captured.first, isNull);
      });

      test('generates stories with empty custom words list', () async {
        final stories = [
          Story(
            id: 6,
            userId: 1,
            content: 'A story when list is empty...',
            storyWords: 'empty,list,story',
            learningLanguage: 'en',
            favoriteCount: 0,
            isFavorited: false,
            firstReadAt: null,
            createdAt: 1704067200,
          )
        ];

        final apiResponse = ApiResponseV2<List<Story>>.success(
          stories,
          statusCode: 200,
        );

        when(mockApi.generateStories(any)).thenAnswer((_) async => apiResponse);

        final result = await service.generateStories(customWords: []);

        expect(result.length, equals(1));

        final captured = verify(mockApi.generateStories(captureAny)).captured;
        expect(captured.first, isNull);
      });

      test('throws exception for API error', () async {
        final apiResponse = ApiResponseV2<List<Story>>.error(
          'Story generation failed',
          statusCode: 500,
        );

        when(mockApi.generateStories(any)).thenAnswer((_) async => apiResponse);

        expect(
          () => service.generateStories(customWords: ['test']),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('markAsReadIfNeeded', () {
      test('marks unread story as read successfully', () async {
        final story = Story(
          id: 1,
          userId: 1,
          content: 'A story that hasnt been read...',
          storyWords: 'unread,story,content',
          learningLanguage: 'en',
          favoriteCount: 0,
          isFavorited: false,
          firstReadAt: null, // Not read yet
          createdAt: 1704067200,
        );

        final apiResponse = ApiResponseV2<void>.success(
          null,
          statusCode: 200,
        );

        when(mockApi.markStoryAsRead(1)).thenAnswer((_) async => apiResponse);

        await service.markAsReadIfNeeded(story);

        verify(mockApi.markStoryAsRead(1)).called(1);
        expect(mockLogger.infoLogs, contains('Successfully marked story 1 as read'));
      });

      test('does not mark already read story', () async {
        final story = Story(
          id: 1,
          userId: 1,
          content: 'A story that has been read...',
          storyWords: 'read,story,content',
          learningLanguage: 'en',
          favoriteCount: 5,
          isFavorited: false,
          firstReadAt: 1704067200, // Already read
          createdAt: 1704067200,
        );

        await service.markAsReadIfNeeded(story);

        verifyNever(mockApi.markStoryAsRead(any));
      });

      test('handles API error gracefully without throwing', () async {
        final story = Story(
          id: 1,
          userId: 1,
          content: 'A story that hasnt been read...',
          storyWords: 'unread,story,content',
          learningLanguage: 'en',
          favoriteCount: 0,
          isFavorited: false,
          firstReadAt: null,
          createdAt: 1704067200,
        );

        when(mockApi.markStoryAsRead(1))
            .thenThrow(Exception('Network error'));

        // Should not throw - should handle gracefully
        await service.markAsReadIfNeeded(story);

        verify(mockApi.markStoryAsRead(1)).called(1);
        expect(mockLogger.errorLogs, isNotEmpty);
        expect(mockLogger.errorLogs.first,
            contains('Failed to mark story 1 as read'));
      });
    });

    group('toggleFavorite', () {
      test('successfully toggles favorite', () async {
        final apiResponse = ApiResponseV2<void>.success(
          null,
          statusCode: 200,
        );

        when(mockApi.toggleFavorite(1)).thenAnswer((_) async => apiResponse);

        await service.toggleFavorite(1);

        verify(mockApi.toggleFavorite(1)).called(1);
      });

      test('throws exception for API error', () async {
        final apiResponse = ApiResponseV2<void>.error(
          'Failed to toggle favorite',
          statusCode: 500,
        );

        when(mockApi.toggleFavorite(1)).thenAnswer((_) async => apiResponse);

        expect(
          () => service.toggleFavorite(1),
          throwsA(isA<ServerException>()),
        );
      });

      test('handles API exception gracefully', () async {
        when(mockApi.toggleFavorite(1))
            .thenThrow(Exception('Network error'));

        expect(
          () => service.toggleFavorite(1),
          throwsA(isA<ServiceException>()),
        );
      });
    });

  });
}