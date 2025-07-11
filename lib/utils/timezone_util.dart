import 'dart:io';

class TimezoneUtil {
  /// Get the user's current timezone identifier
  static String getUserTimezone() {
    // Get the system timezone name
    final timeZoneName = DateTime.now().timeZoneName;
    
    // Convert common timezone abbreviations to IANA identifiers
    switch (timeZoneName) {
      case 'EST':
      case 'EDT':
        return 'America/New_York';
      case 'PST':
      case 'PDT':
        return 'America/Los_Angeles';
      case 'CST':
      case 'CDT':
        return 'America/Chicago';
      case 'MST':
      case 'MDT':
        return 'America/Denver';
      case 'GMT':
      case 'UTC':
        return 'UTC';
      case 'CET':
      case 'CEST':
        return 'Europe/Paris';
      case 'JST':
        return 'Asia/Tokyo';
      default:
        // Try to get timezone from system environment
        if (Platform.isAndroid || Platform.isIOS) {
          // For mobile platforms, we can get more accurate timezone info
          return _getMobileTimezone();
        }
        // Fallback to UTC if we can't determine timezone
        return 'UTC';
    }
  }

  /// Get timezone for mobile platforms (simplified implementation)
  static String _getMobileTimezone() {
    // This is a simplified version. In a real app, you might want to use
    // a package like timezone or device_info_plus to get more accurate timezone info
    final offset = DateTime.now().timeZoneOffset;
    
    // Map common offsets to timezones
    switch (offset.inHours) {
      case -8:
        return 'America/Los_Angeles';
      case -7:
        return 'America/Denver';
      case -6:
        return 'America/Chicago';
      case -5:
        return 'America/New_York';
      case 0:
        return 'UTC';
      case 1:
        return 'Europe/London';
      case 2:
        return 'Europe/Paris';
      case 8:
        return 'Asia/Shanghai';
      case 9:
        return 'Asia/Tokyo';
      default:
        return 'UTC';
    }
  }

  /// Format date for API (YYYYMMDD format)
  static String formatDateForApi(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}'
        '${date.month.toString().padLeft(2, '0')}'
        '${date.day.toString().padLeft(2, '0')}';
  }

  /// Get user-friendly text for how long ago a word was learned
  static String getDaysAgoText(DateTime learnedDate) {
    final now = DateTime.now();
    final difference = now.difference(learnedDate).inDays;

    if (difference == 0) return "Today";
    if (difference == 1) return "Yesterday";
    if (difference < 7) return "$difference days ago";
    if (difference < 30) return "${(difference / 7).round()} weeks ago";
    if (difference < 365) return "${(difference / 30).round()} months ago";
    return "${(difference / 365).round()} years ago";
  }

  /// Get user-friendly text for spaced repetition intervals
  static String getSpacedRepetitionText(DateTime learnedDate) {
    final now = DateTime.now();
    final difference = now.difference(learnedDate).inDays;

    // Map to spaced repetition intervals
    if (difference <= 3) return "Review today";
    if (difference <= 7) return "3-day review";
    if (difference <= 14) return "1-week review";
    if (difference <= 30) return "2-week review";
    if (difference <= 60) return "1-month review";
    if (difference <= 90) return "2-month review";
    if (difference <= 180) return "3-month review";
    if (difference <= 365) return "6-month review";
    return "1-year review";
  }
}