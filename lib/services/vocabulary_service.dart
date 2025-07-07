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

  Future<RefreshExplanationResult> refreshExplanation(WordExplanation explanation) async {
    try {
      final response = await _vocabularyApi.refreshExplanation(explanation.id);
      
      final result = ApiResult<WordExplanation>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => WordExplanation.fromJson(json as Map<String, dynamic>),
      );
      
      if (result.isSuccess && result.data != null) {
        return RefreshExplanationResult.updated(result.data!);
      } else {
        // If there's a non-zero error code, it means no refresh was needed
        if (!result.isSuccess && result.statusCode != null && result.statusCode! > 0) {
          return RefreshExplanationResult.noUpdate(result.errorMessage ?? 'No update needed');
        }
        throw ApiException(result.errorMessage ?? 'Failed to refresh explanation');
      }
    } on DioException catch (e) {
      throw ApiException('Failed to refresh explanation: ${e.message}');
    }
  }
}

// Result class for refresh explanation operations
class RefreshExplanationResult {
  final WordExplanation? explanation;
  final String? message;
  final bool wasUpdated;

  RefreshExplanationResult._(this.explanation, this.message, this.wasUpdated);

  factory RefreshExplanationResult.updated(WordExplanation explanation) {
    return RefreshExplanationResult._(explanation, null, true);
  }

  factory RefreshExplanationResult.noUpdate(String message) {
    return RefreshExplanationResult._(null, message, false);
  }
}