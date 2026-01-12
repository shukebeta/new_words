/// Represents a GitHub Release for app updates
class GitHubRelease {
  final String tagName;
  final String name;
  final String? body;
  final String htmlUrl;
  final String? apkDownloadUrl;
  final int publishedAt;

  GitHubRelease({
    required this.tagName,
    required this.name,
    this.body,
    required this.htmlUrl,
    this.apkDownloadUrl,
    required this.publishedAt,
  });

  /// Create from GitHub API JSON response
  factory GitHubRelease.fromJson(Map<String, dynamic> json) {
    // Find APK file in assets
    String? apkUrl;
    if (json['assets'] != null && json['assets'] is List) {
      final assets = json['assets'] as List;
      for (final asset in assets) {
        if (asset is Map<String, dynamic>) {
          final name = asset['name'] as String?;
          if (name != null && name.endsWith('.apk')) {
            apkUrl = asset['browser_download_url'] as String?;
            break;
          }
        }
      }
    }

    return GitHubRelease(
      tagName: json['tag_name'] as String? ?? '',
      name: json['name'] as String? ?? json['tag_name'] ?? '',
      body: json['body'] as String?,
      htmlUrl: json['html_url'] as String? ?? '',
      apkDownloadUrl: apkUrl,
      publishedAt: _parseTimestamp(json['published_at']),
    );
  }

  /// Parse timestamp to milliseconds since epoch
  static int _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return DateTime.now().millisecondsSinceEpoch;
    if (timestamp is int) return timestamp;
    if (timestamp is String) {
      return DateTime.parse(timestamp).millisecondsSinceEpoch;
    }
    return DateTime.now().millisecondsSinceEpoch;
  }

  /// Get version number without 'v' prefix
  String get version {
    return tagName.startsWith('v') ? tagName.substring(1) : tagName;
  }

  /// Check if this release has an APK asset
  bool get hasApk => apkDownloadUrl != null && apkDownloadUrl!.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'tag_name': tagName,
      'name': name,
      'body': body,
      'html_url': htmlUrl,
      'apk_download_url': apkDownloadUrl,
      'published_at': publishedAt,
    };
  }
}
