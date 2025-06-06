import 'package:dio/dio.dart';
import 'package:new_words/dio_client.dart';
import 'package:new_words/entities/add_word_request.dart';

class VocabularyApi {
  final Dio _dio = DioClient.getInstance();

  Future<Response> addWord(AddWordRequest request) async {
    return await _dio.post(
      '/vocabulary/add',
      data: request.toJson(),
    );
  }

  Future<Response> listWords(int pageNumber, int pageSize) async {
    return await _dio.get(
      '/vocabulary/list',
      queryParameters: {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      },
    );
  }

  Future<Response> deleteWord(int wordId) async {
    return await _dio.delete(
      '/vocabulary/delete/$wordId',
    );
  }
}