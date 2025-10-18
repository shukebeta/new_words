import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:new_words/apis/vocabulary_api_v2.dart';
import 'package:new_words/entities/word_explanation.dart';
import 'package:new_words/services/memories_service_v2.dart';
import 'package:new_words/common/foundation/foundation.dart';
import 'package:new_words/utils/app_logger_interface.dart';

import 'memories_service_v2_test.mocks.dart';

@GenerateMocks([VocabularyApiV2, AppLoggerInterface])
void main() {
  group('MemoriesServiceV2', () {
    late MemoriesServiceV2 memoriesService;
    late MockVocabularyApiV2 mockVocabularyApi;
    late MockAppLoggerInterface mockLogger;

    setUp(() {
      mockVocabularyApi = MockVocabularyApiV2();
      mockLogger = MockAppLoggerInterface();
      memoriesService = MemoriesServiceV2(
        vocabularyApi: mockVocabularyApi,
        logger: mockLogger,
      );
    });

    group('getSpacedRepetitionWords', () {
      test('should return list of words when API call succeeds', () async {
        // Arrange
        final words = <WordExplanation>[
          WordExplanation(
            id: 1,
            wordCollectionId: 100,
            wordText: 'test',
            learningLanguage: 'en',
            explanationLanguage: 'zh',
            markdownExplanation: 'Test explanation',
            createdAt: 1234567890,
            updatedAt: 1234567890,
            providerModelName: 'test-model',
          ),
        ];
        
        final successResponse = ApiResponseV2<List<WordExplanation>>.success(words);

        when(mockVocabularyApi.getMemories(any))
            .thenAnswer((_) async => successResponse);

        // Act
        final result = await memoriesService.getSpacedRepetitionWords();

        // Assert
        expect(result.length, equals(1));
        expect(result[0].wordText, equals('test'));
        verify(mockVocabularyApi.getMemories(any)).called(1);
      });

      test('should throw ServiceException when API call fails', () async {
        // Arrange
        final errorResponse = ApiResponseV2<List<WordExplanation>>.error(
          'Memory words not found',
          statusCode: 200,
          errorCode: 404,
        );

        when(mockVocabularyApi.getMemories(any))
            .thenAnswer((_) async => errorResponse);

        // Act & Assert
        expect(
          () => memoriesService.getSpacedRepetitionWords(),
          throwsA(isA<ServiceException>()),
        );

        verify(mockVocabularyApi.getMemories(any)).called(1);
      });

      test('should handle and convert exceptions correctly', () async {
        // Arrange
        when(mockVocabularyApi.getMemories(any))
            .thenThrow(const NetworkException('Connection failed'));

        // Act & Assert
        expect(
          () => memoriesService.getSpacedRepetitionWords(),
          throwsA(isA<ServiceException>()),
        );

        verify(mockVocabularyApi.getMemories(any)).called(1);
      });

      test('should return empty list when API returns empty data', () async {
        // Arrange
        final emptyResponse = ApiResponseV2<List<WordExplanation>>.success(<WordExplanation>[]);

        when(mockVocabularyApi.getMemories(any))
            .thenAnswer((_) async => emptyResponse);

        // Act
        final result = await memoriesService.getSpacedRepetitionWords();

        // Assert
        expect(result.isEmpty, isTrue);
        verify(mockVocabularyApi.getMemories(any)).called(1);
      });
    });

    group('getWordsFromDate', () {
      test('should return list of words for specific date when API call succeeds', () async {
        // Arrange
        final testDate = DateTime(2023, 12, 25);
        final words = <WordExplanation>[
          WordExplanation(
            id: 2,
            wordCollectionId: 200,
            wordText: 'christmas',
            learningLanguage: 'en',
            explanationLanguage: 'zh',
            markdownExplanation: 'Christmas explanation',
            createdAt: 1234567890,
            updatedAt: 1234567890,
            providerModelName: 'test-model',
          ),
        ];
        
        final successResponse = ApiResponseV2<List<WordExplanation>>.success(words);

        when(mockVocabularyApi.getMemoriesOnDate(any, any))
            .thenAnswer((_) async => successResponse);

        // Act
        final result = await memoriesService.getWordsFromDate(testDate);

        // Assert
        expect(result.length, equals(1));
        expect(result[0].wordText, equals('christmas'));
        verify(mockVocabularyApi.getMemoriesOnDate(any, any)).called(1);
      });

      test('should throw ServiceException when API call fails', () async {
        // Arrange
        final testDate = DateTime(2023, 12, 25);
        final errorResponse = ApiResponseV2<List<WordExplanation>>.error(
          'Words for date not found',
          statusCode: 200,
          errorCode: 404,
        );

        when(mockVocabularyApi.getMemoriesOnDate(any, any))
            .thenAnswer((_) async => errorResponse);

        // Act & Assert
        expect(
          () => memoriesService.getWordsFromDate(testDate),
          throwsA(isA<ServiceException>()),
        );

        verify(mockVocabularyApi.getMemoriesOnDate(any, any)).called(1);
      });

      test('should handle and convert exceptions correctly', () async {
        // Arrange
        final testDate = DateTime(2023, 12, 25);
        when(mockVocabularyApi.getMemoriesOnDate(any, any))
            .thenThrow(const NetworkException('Connection failed'));

        // Act & Assert
        expect(
          () => memoriesService.getWordsFromDate(testDate),
          throwsA(isA<ServiceException>()),
        );

        verify(mockVocabularyApi.getMemoriesOnDate(any, any)).called(1);
      });

      test('should return empty list when API returns empty data for date', () async {
        // Arrange
        final testDate = DateTime(2023, 12, 25);
        final emptyResponse = ApiResponseV2<List<WordExplanation>>.success(<WordExplanation>[]);

        when(mockVocabularyApi.getMemoriesOnDate(any, any))
            .thenAnswer((_) async => emptyResponse);

        // Act
        final result = await memoriesService.getWordsFromDate(testDate);

        // Assert
        expect(result.isEmpty, isTrue);
        verify(mockVocabularyApi.getMemoriesOnDate(any, any)).called(1);
      });
    });
  });
}