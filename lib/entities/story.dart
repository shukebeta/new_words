class Story {
  final int id;
  final int userId;
  final String content;
  final String storyWords;
  final String learningLanguage;
  final int? firstReadAt; // Unix timestamp, null = unread
  final int favoriteCount;
  final String? providerModelName;
  final int createdAt; // Unix timestamp
  final bool isFavorited; // Client-side tracking

  Story({
    required this.id,
    required this.userId,
    required this.content,
    required this.storyWords,
    required this.learningLanguage,
    this.firstReadAt,
    required this.favoriteCount,
    this.providerModelName,
    required this.createdAt,
    this.isFavorited = false,
  });

  // Computed property to check if story has been read
  bool get isRead => firstReadAt != null;

  // Get list of vocabulary words from comma-separated string
  List<String> get vocabularyWords {
    return storyWords
        .split(',')
        .map((word) => word.trim())
        .where((word) => word.isNotEmpty)
        .toList();
  }

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      content: json['content'] as String? ?? '',
      storyWords: json['storyWords'] as String? ?? '',
      learningLanguage: json['learningLanguage'] as String? ?? '',
      firstReadAt: json['firstReadAt'] as int?,
      favoriteCount: json['favoriteCount'] as int? ?? 0,
      providerModelName: json['providerModelName'] as String?,
      createdAt: json['createdAt'] as int? ?? 0,
      isFavorited: json['isFavorited'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'storyWords': storyWords,
      'learningLanguage': learningLanguage,
      'firstReadAt': firstReadAt,
      'favoriteCount': favoriteCount,
      'providerModelName': providerModelName,
      'createdAt': createdAt,
      'isFavorited': isFavorited,
    };
  }

  // Create a copy with updated fields
  Story copyWith({
    int? id,
    int? userId,
    String? content,
    String? storyWords,
    String? learningLanguage,
    int? firstReadAt,
    int? favoriteCount,
    String? providerModelName,
    int? createdAt,
    bool? isFavorited,
  }) {
    return Story(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      storyWords: storyWords ?? this.storyWords,
      learningLanguage: learningLanguage ?? this.learningLanguage,
      firstReadAt: firstReadAt ?? this.firstReadAt,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      providerModelName: providerModelName ?? this.providerModelName,
      createdAt: createdAt ?? this.createdAt,
      isFavorited: isFavorited ?? this.isFavorited,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Story && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Story{id: $id, userId: $userId, content: ${content.substring(0, content.length > 50 ? 50 : content.length)}..., isRead: $isRead, isFavorited: $isFavorited}';
  }
}
