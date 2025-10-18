import 'word_explanation.dart';

class ExplanationsResponse {
  final List<WordExplanation> explanations;
  int? userDefaultExplanationId;

  ExplanationsResponse({
    required this.explanations,
    this.userDefaultExplanationId,
  });

  factory ExplanationsResponse.fromJson(Map<String, dynamic> json) {
    return ExplanationsResponse(
      explanations: (json['explanations'] as List<dynamic>)
          .map((e) => WordExplanation.fromJson(e as Map<String, dynamic>))
          .toList(),
      userDefaultExplanationId: json['userDefaultExplanationId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'explanations': explanations.map((e) => e.toJson()).toList(),
      'userDefaultExplanationId': userDefaultExplanationId,
    };
  }
}
