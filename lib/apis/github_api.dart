import 'package:dio/dio.dart';
import 'package:new_words/entities/github_release.dart';

/// GitHub API for fetching release information
class GitHubApi {
  final Dio _dio;
  final String repoOwner;
  final String repoName;

  GitHubApi({
    Dio? dio,
    required this.repoOwner,
    required this.repoName,
  }) : _dio = dio ?? Dio(BaseOptions(
          baseUrl: 'https://api.github.com',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Accept': 'application/vnd.github.v3+json',
          },
        ));

  /// Get the latest release from GitHub
  /// Returns null if no releases exist or on error
  Future<GitHubRelease?> getLatestRelease() async {
    try {
      final response = await _dio.get(
        '/repos/$repoOwner/$repoName/releases/latest',
      );

      if (response.statusCode == 200 && response.data != null) {
        return GitHubRelease.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      // Log error but don't throw - updates are non-critical
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw UpdateException('GitHub API timeout: ${e.message}');
      }
      if (e.response?.statusCode == 404) {
        // No releases found
        return null;
      }
      throw UpdateException('GitHub API error: ${e.message}');
    } catch (e) {
      throw UpdateException('Failed to fetch release info: ${e.toString()}');
    }
  }

  /// Download APK from the given URL to a local file
  /// [url] - The APK download URL
  /// [savePath] - Where to save the APK file
  /// [onProgress] - Optional callback for download progress (0.0 to 1.0)
  Future<void> downloadApk(
    String url,
    String savePath, {
    void Function(double progress)? onProgress,
  }) async {
    try {
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            onProgress(received / total);
          }
        },
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw UpdateException('Download timeout');
      }
      throw UpdateException('Download failed: ${e.message}');
    } catch (e) {
      throw UpdateException('Download error: ${e.toString()}');
    }
  }
}

/// Exception thrown during update operations
class UpdateException implements Exception {
  final String message;

  UpdateException(this.message);

  @override
  String toString() => message;
}
