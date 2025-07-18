class Language {
  final String code;
  final String name;

  const Language({
    required this.code,
    required this.name,
  }); // Made constructor const

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(code: json['code'] as String, name: json['name'] as String);
  }

  // Optional: Add a toJson method if you ever need to send this model to the backend
  // Map<String, dynamic> toJson() {
  //   return {
  //     'code': code,
  //     'name': name,
  //   };
  // }

  // Optional: For easier debugging or logging
  @override
  String toString() {
    return 'Language{code: $code, name: $name}';
  }
}
