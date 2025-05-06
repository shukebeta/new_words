import 'package:dio/dio.dart';
import 'package:new_words/common/models/api_response.dart';

class ApiService {
  final Dio _dio = Dio();

  // TODO: Move this to a config file or environment variable
  static const String _baseUrl = 'https://api.example.com'; // Placeholder base URL

  Future<ApiResponse<String>> registerOrLogin(String email, String password) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final apiResponse = ApiResponse<String>.fromJson(response.data, (json) => json['token']);
      return apiResponse;
    } catch (e) {
      // Handle network errors and other exceptions
      return ApiResponse<String>(
        data: '',
        successful: false,
        errorCode: -1,
        message: 'Network error',
      );
    }
  }
}