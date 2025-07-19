import 'package:new_words/apis/stories_api_v2.dart';
import 'package:new_words/common/foundation/foundation.dart';
import 'package:new_words/entities/generate_story_request.dart';
import 'package:new_words/entities/page_data.dart';
import 'package:new_words/entities/story.dart';
import 'package:new_words/utils/app_logger_interface.dart';
import 'package:new_words/utils/app_logger.dart';

/// Modern stories service implementation using BaseService foundation
/// 
/// This class replaces the old StoriesService with standardized error handling,
/// validation patterns, and centralized constants usage.
class StoriesServiceV2 extends BaseService {
  final StoriesApiV2 _storiesApi;
  final AppLoggerInterface _logger;

  StoriesServiceV2({
    required StoriesApiV2 storiesApi,
    AppLoggerInterface? logger,
  }) : _storiesApi = storiesApi,
       _logger = logger ?? AppLogger.instance;

  /// Get current user's generated stories with pagination
  Future<PageData<Story>> getMyStories(int pageNumber, int pageSize) async {
    logOperation('getMyStories', parameters: {
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    });

    try {
      final response = await _storiesApi.getMyStories(pageNumber, pageSize);
      return processResponse(response);
    } catch (e) {
      throw ServiceExceptionFactory.fromException(e);
    }
  }

  /// Browse popular stories from other users for discovery
  Future<PageData<Story>> getStorySquare(int pageNumber, int pageSize) async {
    logOperation('getStorySquare', parameters: {
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    });

    try {
      final response = await _storiesApi.getStorySquare(pageNumber, pageSize);
      return processResponse(response);
    } catch (e) {
      throw ServiceExceptionFactory.fromException(e);
    }
  }

  /// Get stories the current user has favorited
  Future<PageData<Story>> getMyFavoriteStories(int pageNumber, int pageSize) async {
    logOperation('getMyFavoriteStories', parameters: {
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    });

    try {
      final response = await _storiesApi.getMyFavoriteStories(pageNumber, pageSize);
      return processResponse(response);
    } catch (e) {
      throw ServiceExceptionFactory.fromException(e);
    }
  }

  /// Generate one or more stories for the current user
  Future<List<Story>> generateStories({List<String>? customWords}) async {
    logOperation('generateStories', parameters: {
      'customWordsCount': customWords?.length ?? 0,
      'hasCustomWords': customWords != null && customWords.isNotEmpty,
    });

    try {
      final request = customWords != null && customWords.isNotEmpty
          ? GenerateStoryRequest(words: customWords)
          : null; // null request means use recent vocabulary

      final response = await _storiesApi.generateStories(request);
      return processResponse(response);
    } catch (e) {
      throw ServiceExceptionFactory.fromException(e);
    }
  }

  /// Smart mark as read - only calls API if story hasn't been read yet
  Future<void> markAsReadIfNeeded(Story story) async {
    logOperation('markAsReadIfNeeded', parameters: {
      'storyId': story.id,
      'alreadyRead': story.firstReadAt != null,
    });

    // Only mark as read if not already read
    if (story.firstReadAt == null) {
      try {
        final response = await _storiesApi.markStoryAsRead(story.id);
        processVoidResponse(response);
        _logger.i('Successfully marked story ${story.id} as read');
      } catch (e) {
        // Don't rethrow for mark as read failures - it's not critical for user experience
        _logger.e('Failed to mark story ${story.id} as read: $e');
        // Log but don't throw to avoid disrupting user experience
      }
    }
  }

  /// Toggle favorite status for a story
  Future<void> toggleFavorite(int storyId) async {
    logOperation('toggleFavorite', parameters: {
      'storyId': storyId,
    });

    try {
      final response = await _storiesApi.toggleFavorite(storyId);
      processVoidResponse(response);
    } catch (e) {
      throw ServiceExceptionFactory.fromException(e);
    }
  }
}