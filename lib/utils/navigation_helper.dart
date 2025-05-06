class NavigationHelper {
  static String? _normalizeDateString(String input) {
    // Match yyyy-MMM-dd or yyyy-M-d format
    final monthNames = {
      'jan': '01',
      'feb': '02',
      'mar': '03',
      'apr': '04',
      'may': '05',
      'jun': '06',
      'jul': '07',
      'aug': '08',
      'sep': '09',
      'oct': '10',
      'nov': '11',
      'dec': '12'
    };

    // Try yyyy-MMM-dd format
    final monthNamePattern = RegExp(
        r'^(\d{4})-(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)-(\d{2})$',
        caseSensitive: false);
    final monthMatch = monthNamePattern.firstMatch(input);
    if (monthMatch != null) {
      final year = monthMatch.group(1);
      final month = monthNames[monthMatch.group(2)?.toLowerCase()];
      final day = monthMatch.group(3);
      return '$year-$month-$day';
    }

    // Try yyyy-M-d format
    final numericPattern =
        RegExp(r'^(\d{4})-(0?[1-9]|1[0-2])-(0?[1-9]|[12]\d|3[01])$');
    final numericMatch = numericPattern.firstMatch(input);
    if (numericMatch != null) {
      final year = numericMatch.group(1);
      final month = numericMatch.group(2)!.padLeft(2, '0');
      final day = numericMatch.group(3)!.padLeft(2, '0');
      return '$year-$month-$day';
    }

    return null;
  }
}
