class User {
  String email;
  String gravatar;
  int createdAt;
  String? nativeLanguage; // Added
  String? currentLearningLanguage; // Added

  User({
    required this.email,
    required this.gravatar,
    required this.createdAt,
    this.nativeLanguage, // Added
    this.currentLearningLanguage, // Added
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      gravatar: json['gravatar'],
      createdAt: json['createdAt'],
      nativeLanguage: json['nativeLanguage'], // Added
      currentLearningLanguage: json['currentLearningLanguage'], // Added
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['gravatar'] = gravatar;
    data['createdAt'] = createdAt;
    data['nativeLanguage'] = nativeLanguage; // Added
    data['currentLearningLanguage'] = currentLearningLanguage; // Added
    return data;
  }
}
