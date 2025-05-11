import 'package:dio/dio.dart';
import 'package:new_words/features/new_words_list/models/word_model.dart';
// import 'package:new_words/utils/token_utils.dart'; // Placeholder for token utility
// import 'package:new_words/app_config.dart'; // Placeholder for app config (base URL)
import 'package:flutter_dotenv/flutter_dotenv.dart'; // For accessing .env variables

class VocabularyService {
  late Dio _dio;
  late String _baseUrl;

  VocabularyService() {
    // It's better to get Dio instance from a central place if already configured (e.g., via GetIt)
    // For now, creating a new instance.
    _dio = Dio(); 
    _baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:5016'; // Fallback, should be in .env

    // Add interceptor to include JWT token in headers
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // String? token = await TokenUtils.getToken(); // Placeholder
        String? token; // Replace with actual token retrieval logic
        // Example: SharedPreferences prefs = await SharedPreferences.getInstance();
        // token = prefs.getString('jwt_token');

        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Handle errors globally if needed
        return handler.next(e);
      },
    ));
  }

  Future<PageData<Word>> getWords({required int pageNumber, required int pageSize}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/Vocabulary/List',
        queryParameters: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final apiResult = ApiResult<Map<String,dynamic>>.fromJson(response.data, (dataJson) => dataJson as Map<String,dynamic>);
        if (apiResult.isSuccess && apiResult.data != null) {
             return PageData<Word>.fromJson(apiResult.data!, (wordJson) => Word.fromJson(wordJson as Map<String, dynamic>));
        } else {
          throw Exception(apiResult.errorMessage ?? 'Failed to parse paged words data');
        }
      } else {
        throw Exception('Failed to load words: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Handle Dio specific errors
      throw Exception('Failed to load words (Dio): ${e.message}');
    } catch (e) {
      throw Exception('Failed to load words: ${e.toString()}');
    }
  }

  Future<Word> addWord(Word word) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/Vocabulary/Add',
        data: word.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
         final apiResult = ApiResult<Map<String,dynamic>>.fromJson(response.data, (dataJson) => dataJson as Map<String,dynamic>);
        if (apiResult.isSuccess && apiResult.data != null) {
            return Word.fromJson(apiResult.data!);
        } else {
          // The backend might return a specific error message for language mismatch
          throw Exception(apiResult.errorMessage ?? 'Failed to add word');
        }
      } else {
        throw Exception('Failed to add word: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        // Try to parse error from backend
         final apiResult = ApiResult<dynamic>.fromJson(e.response!.data, (dataJson) => dataJson);
         if (!apiResult.isSuccess && apiResult.errorMessage != null) {
            throw Exception(apiResult.errorMessage);
         }
      }
      throw Exception('Failed to add word (Dio): ${e.message}');
    } catch (e) {
      throw Exception('Failed to add word: ${e.toString()}');
    }
  }
}