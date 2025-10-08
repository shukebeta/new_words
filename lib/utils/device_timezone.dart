class DeviceTimezone {
  /// Get the device's timezone in IANA format for API calls
  static String getTimezoneForApi() {
    final timeZoneName = DateTime.now().timeZoneName;
    final offset = DateTime.now().timeZoneOffset;

    // First try to map common timezone names to IANA identifiers
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
      case 'KST':
        return 'Asia/Seoul';
      case 'IST':
        return 'Asia/Kolkata';
      default:
        // If we can't map the name, use offset to determine timezone
        return _getTimezoneFromOffset(offset);
    }
  }

  /// Map timezone offset to IANA timezone identifier
  static String _getTimezoneFromOffset(Duration offset) {
    final hours = offset.inHours;

    switch (hours) {
      case -11:
        return 'Pacific/Midway';
      case -10:
        return 'Pacific/Honolulu';
      case -9:
        return 'America/Anchorage';
      case -8:
        return 'America/Los_Angeles';
      case -7:
        return 'America/Denver';
      case -6:
        return 'America/Chicago';
      case -5:
        return 'America/New_York';
      case -4:
        return 'America/Santiago';
      case -3:
        return 'America/Argentina/Buenos_Aires';
      case -2:
        return 'Atlantic/South_Georgia';
      case -1:
        return 'Atlantic/Azores';
      case 0:
        return 'UTC';
      case 1:
        return 'Europe/London';
      case 2:
        return 'Europe/Paris';
      case 3:
        return 'Europe/Moscow';
      case 4:
        return 'Asia/Dubai';
      case 5:
        return 'Asia/Karachi';
      case 6:
        return 'Asia/Dhaka';
      case 7:
        return 'Asia/Bangkok';
      case 8:
        return 'Asia/Shanghai';
      case 9:
        return 'Asia/Tokyo';
      case 10:
        return 'Australia/Sydney';
      case 11:
        return 'Pacific/Noumea';
      case 12:
        return 'Pacific/Auckland';
      default:
        // Fallback to UTC if we can't determine
        return 'UTC';
    }
  }

  /// Format date for API (yyyyMMdd format, no dashes)
  /// This uses the same date that would be shown in the UI
  static String formatDateForApi(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}'
        '${date.month.toString().padLeft(2, '0')}'
        '${date.day.toString().padLeft(2, '0')}';
  }

  /// Get user-friendly text for spaced repetition intervals
  static String getSpacedRepetitionText(DateTime learnedDate) {
    final now = DateTime.now();
    final difference = now.difference(learnedDate).inDays;

    if (difference == 0) return "Today";
    if (difference == 1) return "Yesterday";
    if (difference == 2) return "2 days ago";
    if (difference == 3) return "3 days ago";
    if (difference < 7) return "$difference days ago";
    if (difference < 14) return "1 week ago";
    if (difference < 21) return "2 weeks ago";
    if (difference < 30) return "3 weeks ago";
    if (difference < 60) return "1 month ago";
    if (difference < 90) return "2 months ago";
    if (difference < 180) return "3 months ago";
    if (difference < 365) return "6 months ago";
    return "1 year ago";
  }
}
