import 'package:dio/dio.dart';
import '../dio_client.dart';

class SettingsApi {
  static final Dio _dio = DioClient.getInstance();

  Future<Response> getSupportedLanguages() async {
    return await _dio.get('/settings/languages');
  }
}
