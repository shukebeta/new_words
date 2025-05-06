import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:new_words/user_session.dart';

import 'app_constants.dart';

class AppConfig {
  AppConfig._();

  static String get apiBaseUrl {
    return dotenv.env['API_BASE_URL'] ?? 'https://staging-newwords-api.dev.shukebeta.com';
  }

  static int get pageSize {
    final pageSizeStr = UserSession().settings(AppConstants.pageSize) ?? dotenv.env['PAGE_SIZE'];
    return pageSizeStr == null ? 20 : int.parse(pageSizeStr);
  }

  static bool get isIOSWeb {
    return kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  }

  // duplicate request error, which shouldn't bother to show anything
  static int quietErrorCode = 105;

  static String get timezone {
    final timezone = UserSession().settings(AppConstants.timezone);
    return timezone ?? 'Pacific/Auckland';
  }

  static String get fontFamily {
    final fontFamily = UserSession().settings(AppConstants.fontFamily);
    return fontFamily ?? 'Noto Sans';
  }

  static String get version {
    return dotenv.env['VERSION'] ?? 'version-place-holder';
  }

  static bool get debugging {
    return dotenv.env['DEBUGGING'] == '1';
  }

  // Map to store property access functions
  static final Map<String, dynamic Function()> _propertyAccessors = {
    AppConstants.apiBaseUrl: () => apiBaseUrl,
    AppConstants.pageSize: () => pageSize,
    AppConstants.quietErrorCode: () => quietErrorCode,
    AppConstants.timezone: () => timezone,
    AppConstants.fontFamily: () => fontFamily,
    AppConstants.isIOSWeb: () => isIOSWeb,
    AppConstants.version: () => version,
    AppConstants.debugging: () => debugging,
  };

  // Method to get property value by name
  static dynamic getProperty(String name) {
    final accessor = _propertyAccessors[name];
    if (accessor != null) {
      return accessor();
    } else {
      throw ArgumentError('No such property: $name');
    }
  }

  static String mastodonRedirectUri(String instanceUrl) {
    return '$apiBaseUrl/mastodonAuth/callback?instanceUrl=${Uri.encodeFull(instanceUrl)}';
  }
}
