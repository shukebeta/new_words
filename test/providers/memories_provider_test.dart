import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:new_words/entities/word_explanation.dart';
import 'package:new_words/providers/memories_provider.dart';
import 'package:new_words/services/memories_service_v2.dart';
import 'package:new_words/common/foundation/service_exceptions.dart';

import 'memories_provider_test.mocks.dart';

@GenerateMocks([MemoriesServiceV2])
void main() {
  group('MemoriesProvider', () {
    late MemoriesProvider provider;
    late MockMemoriesServiceV2 mockService;

    setUp(() {
      mockService = MockMemoriesServiceV2();
      provider = MemoriesProvider(mockService);
    });

    group('loadSpacedRepetitionWords', () {
      test('should load words successfully', () async {
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

        when(mockService.getSpacedRepetitionWords())
            .thenAnswer((_) async => words);

        // Act
        await provider.loadSpacedRepetitionWords();

        // Assert
        expect(provider.memoryWords, equals(words));
        expect(provider.isLoadingMemories, isFalse);
        expect(provider.memoriesError, isNull);
        verify(mockService.getSpacedRepetitionWords()).called(1);
      });

      test('should handle ServiceException correctly', () async {
        // Arrange
        const error = ApiBusinessException(
          'Failed to load memories',
          backendErrorCode: 404,
        );
        when(mockService.getSpacedRepetitionWords()).thenThrow(error);

        // Act
        await provider.loadSpacedRepetitionWords();

        // Assert
        expect(provider.memoryWords, isEmpty);
        expect(provider.isLoadingMemories, isFalse);
        expect(provider.memoriesError, equals('Failed to load memories'));
        verify(mockService.getSpacedRepetitionWords()).called(1);
      });

      test('should handle generic exceptions correctly', () async {
        // Arrange
        const error = 'Network error';
        when(mockService.getSpacedRepetitionWords()).thenThrow(error);

        // Act
        await provider.loadSpacedRepetitionWords();

        // Assert
        expect(provider.memoryWords, isEmpty);
        expect(provider.isLoadingMemories, isFalse);
        expect(provider.memoriesError, equals('Failed to load memories: Network error'));
        verify(mockService.getSpacedRepetitionWords()).called(1);
      });

      test('should not load if already loading', () async {
        // Arrange
        when(mockService.getSpacedRepetitionWords())
            .thenAnswer((_) async => <WordExplanation>[]);

        // Set loading state manually
        provider.loadSpacedRepetitionWords(); // First call

        // Act - Second call while first is still running
        await provider.loadSpacedRepetitionWords();

        // Assert - Service should only be called once from the first call
        verify(mockService.getSpacedRepetitionWords()).called(1);
      });
    });

    group('loadWordsForDate', () {
      test('should load words for date successfully', () async {
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

        when(mockService.getWordsFromDate(any))
            .thenAnswer((_) async => words);

        // Act
        await provider.loadWordsForDate(testDate);

        // Assert
        expect(provider.dateWords, equals(words));
        expect(provider.selectedDate, equals(testDate));
        expect(provider.isLoadingDate, isFalse);
        expect(provider.dateError, isNull);
        verify(mockService.getWordsFromDate(testDate)).called(1);
      });

      test('should handle ServiceException correctly', () async {
        // Arrange
        final testDate = DateTime(2023, 12, 25);
        const error = ApiBusinessException(
          'No words found for date',
          backendErrorCode: 404,
        );
        when(mockService.getWordsFromDate(any)).thenThrow(error);

        // Act
        await provider.loadWordsForDate(testDate);

        // Assert
        expect(provider.dateWords, isEmpty);
        expect(provider.selectedDate, equals(testDate));
        expect(provider.isLoadingDate, isFalse);
        expect(provider.dateError, equals('No words found for date'));
        verify(mockService.getWordsFromDate(testDate)).called(1);
      });

      test('should handle generic exceptions correctly', () async {
        // Arrange
        final testDate = DateTime(2023, 12, 25);
        const error = 'Database error';
        when(mockService.getWordsFromDate(any)).thenThrow(error);

        // Act
        await provider.loadWordsForDate(testDate);

        // Assert
        expect(provider.dateWords, isEmpty);
        expect(provider.selectedDate, equals(testDate));
        expect(provider.isLoadingDate, isFalse);
        expect(provider.dateError, equals('Failed to load words for date: Database error'));
        verify(mockService.getWordsFromDate(testDate)).called(1);
      });
    });

    group('clearAllData', () {
      test('should clear all data and reset state', () {
        // Arrange - Set some data first
        provider.loadSpacedRepetitionWords();

        // Act
        provider.clearAllData();

        // Assert
        expect(provider.memoryWords, isEmpty);
        expect(provider.dateWords, isEmpty);
        expect(provider.selectedDate, isNull);
        expect(provider.isLoadingMemories, isFalse);
        expect(provider.isLoadingDate, isFalse);
        expect(provider.memoriesError, isNull);
        expect(provider.dateError, isNull);
      });
    });

    group('AuthAwareProvider integration', () {
      test('should load data on login', () async {
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

        when(mockService.getSpacedRepetitionWords())
            .thenAnswer((_) async => words);

        // Act
        await provider.onLogin();
        await provider.loadSpacedRepetitionWords();

        // Assert
        expect(provider.memoryWords, equals(words));
        verify(mockService.getSpacedRepetitionWords()).called(1);
      });

      test('should clear data on logout', () async {
        // Arrange - Set some data first
        when(mockService.getSpacedRepetitionWords())
            .thenAnswer((_) async => <WordExplanation>[
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
            ]);
        await provider.loadSpacedRepetitionWords();

        // Act
        await provider.onLogout();

        // Assert
        expect(provider.memoryWords, isEmpty);
        expect(provider.dateWords, isEmpty);
      });
    });
  });
}