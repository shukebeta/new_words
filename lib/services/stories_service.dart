import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:new_words/apis/stories_api.dart';
import 'package:new_words/entities/api_result.dart';
import 'package:new_words/entities/generate_story_request.dart';
import 'package:new_words/entities/page_data.dart';
import 'package:new_words/entities/story.dart';
import 'package:new_words/exceptions/api_exception.dart';

class StoriesService {
  final StoriesApi _storiesApi;

  StoriesService(this._storiesApi);

  // Get current user's generated stories with pagination
  Future<PageData<Story>> getMyStories(int pageNumber, int pageSize) async {
    final response = await _storiesApi.getMyStories(pageNumber, pageSize);
    final result = ApiResult<PageData<Story>>.fromJson(
      response.data as Map<String, dynamic>,
      (json) => PageData<Story>.fromJson(
        json as Map<String, dynamic>,
        (storyJson) => Story.fromJson(storyJson as Map<String, dynamic>),
      ),
    );

    if (result.isSuccess && result.data != null) {
      return result.data!;
    } else {
      throw ApiException(result.errorMessage ?? 'Failed to fetch my stories');
    }
  }

  // Browse popular stories from other users for discovery
  Future<PageData<Story>> getStorySquare(int pageNumber, int pageSize) async {
    final response = await _storiesApi.getStorySquare(pageNumber, pageSize);
    final result = ApiResult<PageData<Story>>.fromJson(
      response.data as Map<String, dynamic>,
      (json) => PageData<Story>.fromJson(
        json as Map<String, dynamic>,
        (storyJson) => Story.fromJson(storyJson as Map<String, dynamic>),
      ),
    );

    if (result.isSuccess && result.data != null) {
      return result.data!;
    } else {
      throw ApiException(result.errorMessage ?? 'Failed to fetch story square');
    }
  }

  // Get stories the current user has favorited
  Future<PageData<Story>> getMyFavoriteStories(
    int pageNumber,
    int pageSize,
  ) async {
    final response = await _storiesApi.getMyFavoriteStories(
      pageNumber,
      pageSize,
    );
    final result = ApiResult<PageData<Story>>.fromJson(
      response.data as Map<String, dynamic>,
      (json) => PageData<Story>.fromJson(
        json as Map<String, dynamic>,
        (storyJson) => Story.fromJson(storyJson as Map<String, dynamic>),
      ),
    );

    if (result.isSuccess && result.data != null) {
      return result.data!;
    } else {
      throw ApiException(
        result.errorMessage ?? 'Failed to fetch favorite stories',
      );
    }
  }

  // Generate one or more stories for the current user
  Future<List<Story>> generateStories({List<String>? customWords}) async {
    final request =
        customWords != null && customWords.isNotEmpty
            ? GenerateStoryRequest(words: customWords)
            : GenerateStoryRequest(); // Empty request = use recent vocabulary

    final response = await _storiesApi.generateStories(request);
    final result = ApiResult<List<Story>>.fromJson(
      response.data as Map<String, dynamic>,
      (json) =>
          (json as List<dynamic>)
              .map(
                (storyJson) =>
                    Story.fromJson(storyJson as Map<String, dynamic>),
              )
              .toList(),
    );

    if (result.isSuccess && result.data != null) {
      return result.data!;
    } else {
      throw ApiException(result.errorMessage ?? 'Failed to generate stories');
    }
  }

  // Smart mark as read - only calls API if story hasn't been read yet
  Future<void> markAsReadIfNeeded(Story story) async {
    if (story.firstReadAt == null) {
      try {
        await _storiesApi.markStoryAsRead(story.id);
      } on DioException catch (e) {
        // Don't throw for mark as read failures - it's not critical
        debugPrint('Failed to mark story as read: ${e.message}');
      }
    }
  }

  // Toggle favorite status for a story
  Future<void> toggleFavorite(int storyId) async {
    final response = await _storiesApi.toggleFavorite(storyId);

    // Check if the response indicates success
    final responseData = response.data as Map<String, dynamic>?;
    final isSuccess = responseData?['successful'] as bool? ?? false;

    if (!isSuccess) {
      final errorMessage =
          responseData?['message'] as String? ?? 'Failed to toggle favorite';
      throw ApiException(errorMessage);
    }
  }
}
