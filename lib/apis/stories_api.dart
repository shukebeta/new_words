import 'package:dio/dio.dart';
import 'package:new_words/dio_client.dart';
import 'package:new_words/entities/generate_story_request.dart';

class StoriesApi {
  final Dio _dio = DioClient.getInstance();

  // Get current user's generated stories with pagination
  Future<Response> getMyStories(int pageNumber, int pageSize) async {
    return await _dio.get(
      '/stories/MyStories',
      queryParameters: {'pageNumber': pageNumber, 'pageSize': pageSize},
    );
  }

  // Browse popular stories from other users for discovery
  Future<Response> getStorySquare(int pageNumber, int pageSize) async {
    return await _dio.get(
      '/stories/StorySquare',
      queryParameters: {'pageNumber': pageNumber, 'pageSize': pageSize},
    );
  }

  // Get stories the current user has favorited
  Future<Response> getMyFavoriteStories(int pageNumber, int pageSize) async {
    return await _dio.get(
      '/stories/MyFavorite',
      queryParameters: {'pageNumber': pageNumber, 'pageSize': pageSize},
    );
  }

  // Generate one or more stories for the current user
  Future<Response> generateStories(GenerateStoryRequest? request) async {
    return await _dio.post(
      '/stories/Generate',
      data: request?.toJson() ?? {},
      options: Options(
        receiveTimeout: const Duration(
          minutes: 5,
        ), // 5 minutes timeout for story generation
        sendTimeout: const Duration(
          minutes: 1,
        ), // 1 minute timeout for sending request
      ),
    );
  }

  // Mark a story as read by the current user
  Future<Response> markStoryAsRead(int storyId) async {
    return await _dio.post('/stories/MarkRead/$storyId');
  }

  // Add or remove a story from the current user's favorites
  Future<Response> toggleFavorite(int storyId) async {
    return await _dio.post('/stories/ToggleFavorite/$storyId');
  }
}
