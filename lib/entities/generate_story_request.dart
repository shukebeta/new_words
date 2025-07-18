class GenerateStoryRequest {
  final List<String>?
  words; // Optional: custom words, null = use recent vocabulary

  GenerateStoryRequest({this.words});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};

    // Only include words if they are provided
    if (words != null && words!.isNotEmpty) {
      json['words'] = words;
    }

    // Note: learningLanguage will be set by the backend using current user's setting
    // We don't include it in the request as per the updated requirements

    return json;
  }

  @override
  String toString() {
    return 'GenerateStoryRequest{words: $words}';
  }
}
