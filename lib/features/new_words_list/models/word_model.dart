class Word {
  final int wordId;
  final String wordText;
  final String wordLanguage;
  final String explanationLanguage;
  final String markdownExplanation;
  final String? pronunciation;
  final String? definitions; // Could be JSON string
  final String? examples;    // Could be JSON string
  final int createdAt; // Unix timestamp
  final String? providerModelName;

  Word({
    required this.wordId,
    required this.wordText,
    required this.wordLanguage,
    required this.explanationLanguage,
    required this.markdownExplanation,
    this.pronunciation,
    this.definitions,
    this.examples,
    required this.createdAt,
    this.providerModelName,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      wordId: json['wordId'] as int? ?? 0, // Default to 0 if null, though ID should always be present
      wordText: json['wordText'] as String? ?? '',
      wordLanguage: json['wordLanguage'] as String? ?? '',
      explanationLanguage: json['explanationLanguage'] as String? ?? '',
      markdownExplanation: json['markdownExplanation'] as String? ?? '',
      pronunciation: json['pronunciation'] as String?,
      definitions: json['definitions'] as String?,
      examples: json['examples'] as String?,
      createdAt: json['createdAt'] as int? ?? 0,
      providerModelName: json['providerModelName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wordId': wordId,
      'wordText': wordText,
      'wordLanguage': wordLanguage,
      'explanationLanguage': explanationLanguage,
      'markdownExplanation': markdownExplanation,
      'pronunciation': pronunciation,
      'definitions': definitions,
      'examples': examples,
      'createdAt': createdAt,
      'providerModelName': providerModelName,
    };
  }
}

// Helper class for paged data from API, mirroring Api.Framework.Models.PageData
class PageData<T> {
  final List<T> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;

  PageData({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
  });

  factory PageData.fromJson(Map<String, dynamic> json, T Function(dynamic json) fromJsonT) {
    return PageData<T>(
      items: (json['items'] as List<dynamic>?)?.map((itemJson) => fromJsonT(itemJson)).toList() ?? [],
      totalCount: json['totalCount'] as int? ?? 0,
      pageNumber: json['pageNumber'] as int? ?? 0,
      pageSize: json['pageSize'] as int? ?? 0,
    );
  }
}

// Helper class for the ApiResult structure, mirroring Api.Framework.Result.ApiResult
class ApiResult<T> {
  final T? data;
  final bool isSuccess;
  final String? errorMessage;
  final List<String>? errors; // Assuming errors can be a list of strings

  ApiResult({
    this.data,
    required this.isSuccess,
    this.errorMessage,
    this.errors,
  });

  factory ApiResult.fromJson(Map<String, dynamic> json, T Function(dynamic json) fromJsonT) {
    return ApiResult<T>(
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      isSuccess: json['isSuccess'] as bool? ?? false,
      errorMessage: json['errorMessage'] as String?,
      errors: (json['errors'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
    );
  }
}