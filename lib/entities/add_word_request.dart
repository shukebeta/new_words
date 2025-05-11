class AddWordRequest {
  final String wordText;
  final String wordLanguage;
  final String explanationLanguage;

  AddWordRequest({
    required this.wordText,
    required this.wordLanguage,
    required this.explanationLanguage,
  });

  Map<String, dynamic> toJson() {
    return {
      'wordText': wordText,
      'wordLanguage': wordLanguage,
      'explanationLanguage': explanationLanguage,
    };
  }
}