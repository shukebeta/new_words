import 'package:flutter_test/flutter_test.dart';
import 'package:new_words/common/constants/storage_keys.dart';

void main() {
  group('StorageKeys', () {
    test('all keys are non-empty strings', () {
      final allKeys = StorageKeys.allKeys;
      
      for (final key in allKeys) {
        expect(key, isNotEmpty);
        expect(key.trim(), equals(key)); // No leading/trailing whitespace
      }
    });

    test('all keys are unique', () {
      final allKeys = StorageKeys.allKeys;
      final uniqueKeys = allKeys.toSet();
      
      expect(allKeys.length, equals(uniqueKeys.length));
    });

    test('key validation works correctly', () {
      // Test valid keys
      expect(StorageKeys.isValidKey(StorageKeys.accessToken), isTrue);
      expect(StorageKeys.isValidKey(StorageKeys.userEmail), isTrue);
      expect(StorageKeys.isValidKey(StorageKeys.selectedLocale), isTrue);
      
      // Test invalid keys
      expect(StorageKeys.isValidKey('invalid_key'), isFalse);
      expect(StorageKeys.isValidKey(''), isFalse);
      expect(StorageKeys.isValidKey('random_string'), isFalse);
    });

    test('keysByCategory contains all keys', () {
      final categorizedKeys = StorageKeys.keysByCategory;
      final allCategorizedKeys = <String>{};
      
      for (final categoryKeys in categorizedKeys.values) {
        allCategorizedKeys.addAll(categoryKeys);
      }
      
      expect(allCategorizedKeys, equals(StorageKeys.allKeys));
    });

    test('keysByCategory has valid structure', () {
      final categorizedKeys = StorageKeys.keysByCategory;
      
      // Should have expected categories
      expect(categorizedKeys.containsKey('authentication'), isTrue);
      expect(categorizedKeys.containsKey('user_preferences'), isTrue);
      expect(categorizedKeys.containsKey('app_state'), isTrue);
      expect(categorizedKeys.containsKey('settings'), isTrue);
      expect(categorizedKeys.containsKey('cache'), isTrue);
      
      // Each category should have at least one key
      for (final entry in categorizedKeys.entries) {
        expect(entry.value, isNotEmpty, reason: 'Category ${entry.key} should not be empty');
      }
    });

    test('authentication keys are properly categorized', () {
      final authKeys = StorageKeys.keysByCategory['authentication']!;
      
      expect(authKeys.contains(StorageKeys.accessToken), isTrue);
      expect(authKeys.contains(StorageKeys.baseUrl), isTrue);
      expect(authKeys.contains(StorageKeys.userEmail), isTrue);
    });

    test('user preferences keys are properly categorized', () {
      final prefKeys = StorageKeys.keysByCategory['user_preferences']!;
      
      expect(prefKeys.contains(StorageKeys.userNativeLanguage), isTrue);
      expect(prefKeys.contains(StorageKeys.userLearningLanguage), isTrue);
      expect(prefKeys.contains(StorageKeys.selectedLocale), isTrue);
      expect(prefKeys.contains(StorageKeys.themeMode), isTrue);
    });

    test('app state keys are properly categorized', () {
      final stateKeys = StorageKeys.keysByCategory['app_state']!;
      
      expect(stateKeys.contains(StorageKeys.isFirstLaunch), isTrue);
      expect(stateKeys.contains(StorageKeys.lastAddWordShownTime), isTrue);
      expect(stateKeys.contains(StorageKeys.lastSyncTimestamp), isTrue);
    });

    test('settings keys are properly categorized', () {
      final settingsKeys = StorageKeys.keysByCategory['settings']!;
      
      expect(settingsKeys.contains(StorageKeys.notificationsEnabled), isTrue);
      expect(settingsKeys.contains(StorageKeys.autoBackupEnabled), isTrue);
      expect(settingsKeys.contains(StorageKeys.offlineMode), isTrue);
    });

    test('cache keys are properly categorized', () {
      final cacheKeys = StorageKeys.keysByCategory['cache']!;
      
      expect(cacheKeys.contains(StorageKeys.cachedUserData), isTrue);
    });

    test('all constants are accessible', () {
      // Test that all constants can be accessed without error
      expect(StorageKeys.accessToken, isNotNull);
      expect(StorageKeys.baseUrl, isNotNull);
      expect(StorageKeys.userEmail, isNotNull);
      expect(StorageKeys.userNativeLanguage, isNotNull);
      expect(StorageKeys.userLearningLanguage, isNotNull);
      expect(StorageKeys.lastAddWordShownTime, isNotNull);
      expect(StorageKeys.selectedLocale, isNotNull);
      expect(StorageKeys.themeMode, isNotNull);
      expect(StorageKeys.isFirstLaunch, isNotNull);
      expect(StorageKeys.notificationsEnabled, isNotNull);
      expect(StorageKeys.autoBackupEnabled, isNotNull);
      expect(StorageKeys.offlineMode, isNotNull);
      expect(StorageKeys.lastSyncTimestamp, isNotNull);
      expect(StorageKeys.cachedUserData, isNotNull);
    });

    test('key naming follows convention', () {
      final allKeys = StorageKeys.allKeys;
      
      for (final key in allKeys) {
        // Keys should use camelCase or snake_case
        expect(key, matches(RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$')));
        
        // Keys should not have consecutive underscores
        expect(key, isNot(contains('__')));
        
        // Keys should not start or end with underscore
        expect(key, isNot(startsWith('_')));
        expect(key, isNot(endsWith('_')));
      }
    });
  });
}