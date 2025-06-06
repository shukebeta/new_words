import 'package:dio/dio.dart';
import 'package:new_words/apis/vocabulary_api.dart';
import 'package:new_words/entities/add_word_request.dart';
import 'package:new_words/entities/api_result.dart';
import 'package:new_words/entities/page_data.dart';
import 'package:new_words/entities/word_explanation.dart';
import 'package:new_words/exceptions/api_exception.dart';

class VocabularyService {
  final VocabularyApi _vocabularyApi;

  VocabularyService(this._vocabularyApi);

  Future<WordExplanation> addWord(AddWordRequest request) async {
    final response = await _vocabularyApi.addWord(request);
    final result = ApiResult<WordExplanation>.fromJson(
      response.data as Map<String, dynamic>,
      (json) => WordExplanation.fromJson(json as Map<String, dynamic>),
    );
    
    if (result.isSuccess && result.data != null) {
      return result.data!;
    } else {
      throw ApiException(result.errorMessage ?? 'Failed to add word');
    }
  }

  Future<PageData<WordExplanation>> listWords(int pageNumber, int pageSize) async {
    final response = await _vocabularyApi.listWords(pageNumber, pageSize);
    final result = ApiResult<PageData<WordExplanation>>.fromJson(
      response.data as Map<String, dynamic>,
      (jsonData) => PageData<WordExplanation>.fromJson(
        jsonData as Map<String, dynamic>,
        (wordJson) => WordExplanation.fromJson(wordJson as Map<String, dynamic>),
      ),
    );
    
    if (result.isSuccess && result.data != null) {
      return result.data!;
    } else {
      throw ApiException(result.errorMessage ?? 'Failed to list words');
    }
  }

  Future<void> deleteWord(int wordId) async {
    final response = await _vocabularyApi.deleteWord(wordId);
    final result = ApiResult<void>.fromJson(
      response.data as Map<String, dynamic>,
      (json) => null,
    );
    
    if (!result.isSuccess) {
      throw ApiException(result.errorMessage ?? 'Failed to delete word');
    }
  }
}