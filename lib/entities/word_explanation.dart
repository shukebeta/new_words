class WordExplanation {
  final int id;
  final int wordCollectionId;
  final String wordText;
  final String wordLanguage;
  final String explanationLanguage;
  final String markdownExplanation;
  final String? pronunciation;
  final String? definitions;
  final String? examples;
  final int createdAt; // Unix timestamp
  final String? providerModelName;

  WordExplanation({
    required this.id,
    required this.wordCollectionId,
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

  factory WordExplanation.fromJson(Map<String, dynamic> json) {
    return WordExplanation(
      id: json['id'] as int? ?? 0,
      wordCollectionId: json['wordCollectionId'] as int? ?? 0,
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
}
