import 'package:dio/dio.dart';
import 'package:new_words/app_config.dart'; // For AppConfig.pageSize if needed, or general constants
import 'package:new_words/dio_client.dart';
import 'package:new_words/entities/add_word_request.dart';
import 'package:new_words/entities/api_result.dart';
import 'package:new_words/entities/page_data.dart';
import 'package:new_words/entities/word_explanation.dart';

class VocabularyApi {
  final Dio _dio = DioClient.getInstance();

  Future<ApiResult<WordExplanation>> addWord(AddWordRequest request) async {
    try {
      final response = await _dio.post(
        '/vocabulary/add', // Endpoint path
        data: request.toJson(),
      );

      // Assuming the backend directly returns ApiResult<WordExplanation> structure
      return ApiResult<WordExplanation>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => WordExplanation.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      // Handle Dio specific errors (e.g., network, timeouts, status codes)
      // You might want to parse e.response?.data if the backend sends structured errors
      return ApiResult<WordExplanation>(
        isSuccess: false,
        errorMessage: e.response?.data?['errorMessage'] as String? ?? e.message,
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      // Handle other unexpected errors
      return ApiResult<WordExplanation>(
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<ApiResult<PageData<WordExplanation>>> listWords(int pageNumber, int pageSize) async {
    try {
      final response = await _dio.get(
        '/vocabulary/list', // Endpoint path
        queryParameters: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
      );

      // Assuming the backend directly returns ApiResult<PageData<WordExplanation>> structure
      return ApiResult<PageData<WordExplanation>>.fromJson(
        response.data as Map<String, dynamic>,
        (jsonData) => PageData<WordExplanation>.fromJson(
          jsonData as Map<String, dynamic>,
          (wordJson) => WordExplanation.fromJson(wordJson as Map<String, dynamic>),
        ),
      );
    } on DioException catch (e) {
      return ApiResult<PageData<WordExplanation>>(
        isSuccess: false,
        errorMessage: e.response?.data?['errorMessage'] as String? ?? e.message,
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResult<PageData<WordExplanation>>(
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }
}