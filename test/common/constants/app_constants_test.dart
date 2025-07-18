import 'package:flutter_test/flutter_test.dart';
import 'package:new_words/common/constants/app_constants.dart';

void main() {
  group('AppConstants', () {
    group('App Information', () {
      test('app information is properly defined', () {
        expect(AppConstants.appName, equals('New Words'));
        expect(AppConstants.appVersion, equals('1.0.0'));
        expect(AppConstants.appDescription, isNotEmpty);
        expect(AppConstants.packageName, equals('com.shukebeta.newwords'));
      });

      test('app information has no empty values', () {
        expect(AppConstants.appName, isNotEmpty);
        expect(AppConstants.appVersion, isNotEmpty);
        expect(AppConstants.appDescription, isNotEmpty);
        expect(AppConstants.packageName, isNotEmpty);
      });

      test('package name follows convention', () {
        expect(AppConstants.packageName, matches(RegExp(r'^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)*$')));
      });

      test('version follows semantic versioning', () {
        expect(AppConstants.appVersion, matches(RegExp(r'^\d+\.\d+\.\d+$')));
      });
    });

    group('Navigation Routes', () {
      test('all routes are non-empty strings', () {
        final allRoutes = AppConstants.allRoutes;
        
        for (final route in allRoutes) {
          expect(route, isNotEmpty);
          expect(route.trim(), equals(route)); // No leading/trailing whitespace
        }
      });

      test('all routes are unique', () {
        final allRoutes = AppConstants.allRoutes;
        final uniqueRoutes = allRoutes.toSet();
        
        expect(allRoutes.length, equals(uniqueRoutes.length));
      });

      test('all routes start with forward slash', () {
        final allRoutes = AppConstants.allRoutes;
        
        for (final route in allRoutes) {
          expect(route, startsWith('/'));
        }
      });

      test('route validation works correctly', () {
        // Test valid routes
        expect(AppConstants.isValidRoute(AppConstants.routeLogin), isTrue);
        expect(AppConstants.isValidRoute(AppConstants.routeHome), isTrue);
        expect(AppConstants.isValidRoute(AppConstants.routeSettings), isTrue);
        
        // Test invalid routes
        expect(AppConstants.isValidRoute('/invalid-route'), isFalse);
        expect(AppConstants.isValidRoute(''), isFalse);
        expect(AppConstants.isValidRoute('invalid'), isFalse);
      });

      test('route constants are accessible', () {
        expect(AppConstants.routeLogin, equals('/login'));
        expect(AppConstants.routeRegister, equals('/register'));
        expect(AppConstants.routeHome, equals('/home'));
        expect(AppConstants.routeMainMenu, equals('/main-menu'));
        expect(AppConstants.routeSettings, equals('/settings'));
        expect(AppConstants.routeNewWordsList, equals('/new-words-list'));
        expect(AppConstants.routeWordDetail, equals('/word-detail'));
        expect(AppConstants.routeStories, equals('/stories'));
        expect(AppConstants.routeMemories, equals('/memories'));
      });
    });

    group('UI/UX Constants', () {
      test('animation durations are reasonable', () {
        expect(AppConstants.animationDurationFast, equals(150));
        expect(AppConstants.animationDurationNormal, equals(300));
        expect(AppConstants.animationDurationSlow, equals(500));
        
        // Validate relationships
        expect(AppConstants.animationDurationFast, lessThan(AppConstants.animationDurationNormal));
        expect(AppConstants.animationDurationNormal, lessThan(AppConstants.animationDurationSlow));
      });

      test('timing constants are reasonable', () {
        expect(AppConstants.splashScreenDuration, equals(2000));
        expect(AppConstants.snackbarDuration, equals(3000));
        expect(AppConstants.debounceDelay, equals(300));
        expect(AppConstants.autoHideDelay, equals(5000));
        
        // All should be positive values
        expect(AppConstants.splashScreenDuration, greaterThan(0));
        expect(AppConstants.snackbarDuration, greaterThan(0));
        expect(AppConstants.debounceDelay, greaterThan(0));
        expect(AppConstants.autoHideDelay, greaterThan(0));
      });

      test('UI dimensions are reasonable', () {
        expect(AppConstants.borderRadiusSmall, equals(4.0));
        expect(AppConstants.borderRadiusMedium, equals(8.0));
        expect(AppConstants.borderRadiusLarge, equals(12.0));
        
        expect(AppConstants.paddingSmall, equals(8.0));
        expect(AppConstants.paddingMedium, equals(16.0));
        expect(AppConstants.paddingLarge, equals(24.0));
        
        // Validate relationships
        expect(AppConstants.borderRadiusSmall, lessThan(AppConstants.borderRadiusMedium));
        expect(AppConstants.borderRadiusMedium, lessThan(AppConstants.borderRadiusLarge));
        expect(AppConstants.paddingSmall, lessThan(AppConstants.paddingMedium));
        expect(AppConstants.paddingMedium, lessThan(AppConstants.paddingLarge));
      });
    });

    group('Business Logic Limits', () {
      test('word management limits are reasonable', () {
        expect(AppConstants.maxWordLength, equals(100));
        expect(AppConstants.minWordLength, equals(1));
        expect(AppConstants.maxExplanationLength, equals(1000));
        expect(AppConstants.maxWordsPerPage, equals(50));
        expect(AppConstants.defaultWordsPerPage, equals(20));
        
        // Validate relationships
        expect(AppConstants.minWordLength, lessThan(AppConstants.maxWordLength));
        expect(AppConstants.defaultWordsPerPage, lessThanOrEqualTo(AppConstants.maxWordsPerPage));
      });

      test('story management limits are reasonable', () {
        expect(AppConstants.maxStoryLength, equals(10000));
        expect(AppConstants.minStoryLength, equals(100));
        expect(AppConstants.maxStoriesPerPage, equals(20));
        expect(AppConstants.defaultStoriesPerPage, equals(10));
        
        // Validate relationships
        expect(AppConstants.minStoryLength, lessThan(AppConstants.maxStoryLength));
        expect(AppConstants.defaultStoriesPerPage, lessThanOrEqualTo(AppConstants.maxStoriesPerPage));
      });

      test('user input validation limits are reasonable', () {
        expect(AppConstants.minPasswordLength, equals(6));
        expect(AppConstants.maxPasswordLength, equals(128));
        expect(AppConstants.maxEmailLength, equals(254));
        expect(AppConstants.maxNameLength, equals(100));
        
        // Validate relationships
        expect(AppConstants.minPasswordLength, lessThan(AppConstants.maxPasswordLength));
        expect(AppConstants.maxEmailLength, greaterThan(AppConstants.minPasswordLength));
      });
    });

    group('Timing Constants', () {
      test('timing intervals are reasonable', () {
        expect(AppConstants.autoSaveInterval, equals(30000)); // 30 seconds
        expect(AppConstants.syncInterval, equals(300000)); // 5 minutes
        expect(AppConstants.tokenRefreshThreshold, equals(300000)); // 5 minutes
        expect(AppConstants.sessionTimeout, equals(3600000)); // 1 hour
        expect(AppConstants.rememberMeDuration, equals(2592000000)); // 30 days
        expect(AppConstants.addWordReminderInterval, equals(3600000)); // 1 hour
        expect(AppConstants.dailyWordsResetTime, equals(86400000)); // 24 hours
        
        // All should be positive values
        expect(AppConstants.autoSaveInterval, greaterThan(0));
        expect(AppConstants.syncInterval, greaterThan(0));
        expect(AppConstants.tokenRefreshThreshold, greaterThan(0));
        expect(AppConstants.sessionTimeout, greaterThan(0));
        expect(AppConstants.rememberMeDuration, greaterThan(0));
        expect(AppConstants.addWordReminderInterval, greaterThan(0));
        expect(AppConstants.dailyWordsResetTime, greaterThan(0));
      });

      test('timing relationships are logical', () {
        expect(AppConstants.autoSaveInterval, lessThan(AppConstants.syncInterval));
        expect(AppConstants.syncInterval, lessThan(AppConstants.sessionTimeout));
        expect(AppConstants.sessionTimeout, lessThan(AppConstants.rememberMeDuration));
      });
    });

    group('Language Constants', () {
      test('default language settings are valid', () {
        expect(AppConstants.defaultLanguageCode, equals('en'));
        expect(AppConstants.defaultCountryCode, equals('US'));
        expect(AppConstants.defaultLocale, equals('en_US'));
      });

      test('supported languages are valid', () {
        expect(AppConstants.supportedLanguages, contains('en'));
        expect(AppConstants.supportedLanguages, contains('zh'));
        expect(AppConstants.supportedLanguages, hasLength(2));
      });

      test('language validation works correctly', () {
        // Test valid languages
        expect(AppConstants.isSupportedLanguage('en'), isTrue);
        expect(AppConstants.isSupportedLanguage('zh'), isTrue);
        
        // Test invalid languages
        expect(AppConstants.isSupportedLanguage('fr'), isFalse);
        expect(AppConstants.isSupportedLanguage(''), isFalse);
        expect(AppConstants.isSupportedLanguage('invalid'), isFalse);
      });

      test('language display names are provided', () {
        expect(AppConstants.languageNames, containsPair('en', 'English'));
        expect(AppConstants.languageNames, containsPair('zh', '中文'));
      });

      test('getLanguageDisplayName works correctly', () {
        expect(AppConstants.getLanguageDisplayName('en'), equals('English'));
        expect(AppConstants.getLanguageDisplayName('zh'), equals('中文'));
        expect(AppConstants.getLanguageDisplayName('fr'), equals('fr')); // fallback
      });
    });

    group('Theme Constants', () {
      test('theme constants are defined', () {
        expect(AppConstants.themeLight, equals('light'));
        expect(AppConstants.themeDark, equals('dark'));
        expect(AppConstants.themeSystem, equals('system'));
      });

      test('theme validation works correctly', () {
        // Test valid themes
        expect(AppConstants.isValidTheme(AppConstants.themeLight), isTrue);
        expect(AppConstants.isValidTheme(AppConstants.themeDark), isTrue);
        expect(AppConstants.isValidTheme(AppConstants.themeSystem), isTrue);
        
        // Test invalid themes
        expect(AppConstants.isValidTheme('invalid'), isFalse);
        expect(AppConstants.isValidTheme(''), isFalse);
        expect(AppConstants.isValidTheme('auto'), isFalse);
      });

      test('all themes are accessible', () {
        final allThemes = AppConstants.allThemes;
        
        expect(allThemes, contains(AppConstants.themeLight));
        expect(allThemes, contains(AppConstants.themeDark));
        expect(allThemes, contains(AppConstants.themeSystem));
        expect(allThemes, hasLength(3));
      });
    });

    group('Feature Flags', () {
      test('feature flags are boolean values', () {
        expect(AppConstants.enableDebugMode, isA<bool>());
        expect(AppConstants.enableLogging, isA<bool>());
        expect(AppConstants.enableAnalytics, isA<bool>());
        expect(AppConstants.enableCrashReporting, isA<bool>());
        expect(AppConstants.enableOfflineMode, isA<bool>());
        expect(AppConstants.enablePushNotifications, isA<bool>());
      });

      test('feature flags have reasonable defaults', () {
        expect(AppConstants.enableDebugMode, isFalse); // Should be false for production
        expect(AppConstants.enableLogging, isTrue); // Usually enabled
        expect(AppConstants.enableAnalytics, isTrue); // Usually enabled
        expect(AppConstants.enableCrashReporting, isTrue); // Usually enabled
        expect(AppConstants.enableOfflineMode, isTrue); // Feature enabled
        expect(AppConstants.enablePushNotifications, isTrue); // Feature enabled
      });
    });

    group('Regex Patterns', () {
      test('email regex pattern is valid', () {
        final emailRegex = RegExp(AppConstants.emailRegex);
        
        // Valid emails
        expect(emailRegex.hasMatch('test@example.com'), isTrue);
        expect(emailRegex.hasMatch('user.name@domain.co.uk'), isTrue);
        expect(emailRegex.hasMatch('user+tag@example.org'), isTrue);
        
        // Invalid emails
        expect(emailRegex.hasMatch('invalid-email'), isFalse);
        expect(emailRegex.hasMatch('test@'), isFalse);
        expect(emailRegex.hasMatch('@example.com'), isFalse);
        expect(emailRegex.hasMatch(''), isFalse);
      });

      test('word regex pattern is valid', () {
        final wordRegex = RegExp(AppConstants.wordRegex);
        
        // Valid words
        expect(wordRegex.hasMatch('hello'), isTrue);
        expect(wordRegex.hasMatch('Hello World'), isTrue);
        expect(wordRegex.hasMatch('mother-in-law'), isTrue);
        expect(wordRegex.hasMatch("don't"), isTrue);
        
        // Invalid words
        expect(wordRegex.hasMatch('hello123'), isFalse);
        expect(wordRegex.hasMatch('hello@world'), isFalse);
        expect(wordRegex.hasMatch(''), isFalse);
      });

      test('phone regex pattern is valid', () {
        final phoneRegex = RegExp(AppConstants.phoneRegex);
        
        // Valid phones
        expect(phoneRegex.hasMatch('+1234567890'), isTrue);
        expect(phoneRegex.hasMatch('1234567890'), isTrue);
        expect(phoneRegex.hasMatch('+12345678901234'), isTrue);
        
        // Invalid phones
        expect(phoneRegex.hasMatch('0123456789'), isFalse); // starts with 0
        expect(phoneRegex.hasMatch('abc123'), isFalse);
        expect(phoneRegex.hasMatch(''), isFalse);
      });
    });

    group('Error and Success Messages', () {
      test('error messages are non-empty', () {
        expect(AppConstants.errorNetworkUnavailable, isNotEmpty);
        expect(AppConstants.errorServerUnavailable, isNotEmpty);
        expect(AppConstants.errorInvalidCredentials, isNotEmpty);
        expect(AppConstants.errorSessionExpired, isNotEmpty);
        expect(AppConstants.errorGeneric, isNotEmpty);
      });

      test('success messages are non-empty', () {
        expect(AppConstants.successWordAdded, isNotEmpty);
        expect(AppConstants.successWordDeleted, isNotEmpty);
        expect(AppConstants.successAccountCreated, isNotEmpty);
        expect(AppConstants.successPasswordChanged, isNotEmpty);
        expect(AppConstants.successDataSaved, isNotEmpty);
      });

      test('messages are user-friendly', () {
        // Error messages should be helpful
        expect(AppConstants.errorNetworkUnavailable, contains('connection'));
        expect(AppConstants.errorServerUnavailable, contains('try again'));
        expect(AppConstants.errorInvalidCredentials, contains('try again'));
        expect(AppConstants.errorSessionExpired, contains('log in'));
        
        // Success messages should be positive
        expect(AppConstants.successWordAdded, contains('successfully'));
        expect(AppConstants.successWordDeleted, contains('successfully'));
        expect(AppConstants.successAccountCreated, contains('successfully'));
        expect(AppConstants.successPasswordChanged, contains('successfully'));
        expect(AppConstants.successDataSaved, contains('successfully'));
      });
    });
  });
}