class AddWordRequest {
  final String wordText;
  final String learningLanguage;
  final String explanationLanguage;

  AddWordRequest({
    required this.wordText,
    required this.learningLanguage,
    required this.explanationLanguage,
  });

  Map<String, dynamic> toJson() {
    return {
      'wordText': wordText,
      'learningLanguage': learningLanguage,
      'explanationLanguage': explanationLanguage,
    };
  }
}