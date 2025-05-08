class User {
  String email;
  String gravatar;
  int createdAt;

  User({
    required this.email,
    required this.gravatar,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      gravatar: json['gravatar'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['gravatar'] = gravatar;
    data['createdAt'] = createdAt;
    return data;
  }
}
