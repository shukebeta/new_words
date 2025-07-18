import 'package:flutter_test/flutter_test.dart';
import 'package:new_words/common/constants/api_constants.dart';

void main() {
  group('ApiConstants', () {
    group('Endpoints', () {
      test('all endpoints are non-empty strings', () {
        final allEndpoints = ApiConstants.allEndpoints;
        
        for (final endpoint in allEndpoints) {
          expect(endpoint, isNotEmpty);
          expect(endpoint.trim(), equals(endpoint)); // No leading/trailing whitespace
        }
      });

      test('all endpoints are unique', () {
        final allEndpoints = ApiConstants.allEndpoints;
        final uniqueEndpoints = allEndpoints.toSet();
        
        expect(allEndpoints.length, equals(uniqueEndpoints.length));
      });

      test('all endpoints start with forward slash', () {
        final allEndpoints = ApiConstants.allEndpoints;
        
        for (final endpoint in allEndpoints) {
          expect(endpoint, startsWith('/'));
        }
      });

      test('endpoint validation works correctly', () {
        // Test valid endpoints
        expect(ApiConstants.isValidEndpoint(ApiConstants.authLogin), isTrue);
        expect(ApiConstants.isValidEndpoint(ApiConstants.vocabularyAdd), isTrue);
        expect(ApiConstants.isValidEndpoint(ApiConstants.storiesGenerate), isTrue);
        
        // Test invalid endpoints
        expect(ApiConstants.isValidEndpoint('/invalid/endpoint'), isFalse);
        expect(ApiConstants.isValidEndpoint(''), isFalse);
        expect(ApiConstants.isValidEndpoint('invalid'), isFalse);
      });

      test('endpointsByCategory contains all endpoints', () {
        final categorizedEndpoints = ApiConstants.endpointsByCategory;
        final allCategorizedEndpoints = <String>{};
        
        for (final categoryEndpoints in categorizedEndpoints.values) {
          allCategorizedEndpoints.addAll(categoryEndpoints);
        }
        
        expect(allCategorizedEndpoints, equals(ApiConstants.allEndpoints));
      });

      test('authentication endpoints are properly categorized', () {
        final authEndpoints = ApiConstants.endpointsByCategory['authentication']!;
        
        expect(authEndpoints.contains(ApiConstants.authLogin), isTrue);
        expect(authEndpoints.contains(ApiConstants.authRegister), isTrue);
        expect(authEndpoints.contains(ApiConstants.accountRefreshToken), isTrue);
        expect(authEndpoints.contains(ApiConstants.accountMyInformation), isTrue);
      });

      test('vocabulary endpoints are properly categorized', () {
        final vocabEndpoints = ApiConstants.endpointsByCategory['vocabulary']!;
        
        expect(vocabEndpoints.contains(ApiConstants.vocabularyAdd), isTrue);
        expect(vocabEndpoints.contains(ApiConstants.vocabularyList), isTrue);
        expect(vocabEndpoints.contains(ApiConstants.vocabularyDelete), isTrue);
        expect(vocabEndpoints.contains(ApiConstants.vocabularyMemories), isTrue);
      });

      test('stories endpoints are properly categorized', () {
        final storiesEndpoints = ApiConstants.endpointsByCategory['stories']!;
        
        expect(storiesEndpoints.contains(ApiConstants.storiesMyStories), isTrue);
        expect(storiesEndpoints.contains(ApiConstants.storiesGenerate), isTrue);
        expect(storiesEndpoints.contains(ApiConstants.storiesMyFavorite), isTrue);
      });

      test('settings endpoints are properly categorized', () {
        final settingsEndpoints = ApiConstants.endpointsByCategory['settings']!;
        
        expect(settingsEndpoints.contains(ApiConstants.settingsLanguages), isTrue);
        expect(settingsEndpoints.contains(ApiConstants.settingsGetAll), isTrue);
        expect(settingsEndpoints.contains(ApiConstants.settingsUpsert), isTrue);
      });
    });

    group('Headers', () {
      test('all headers are non-empty strings', () {
        final allHeaders = ApiConstants.allHeaders;
        
        for (final header in allHeaders) {
          expect(header, isNotEmpty);
          expect(header.trim(), equals(header)); // No leading/trailing whitespace
        }
      });

      test('all headers are unique', () {
        final allHeaders = ApiConstants.allHeaders;
        final uniqueHeaders = allHeaders.toSet();
        
        expect(allHeaders.length, equals(uniqueHeaders.length));
      });

      test('header constants are accessible', () {
        expect(ApiConstants.headerContentType, equals('Content-Type'));
        expect(ApiConstants.headerAuthorization, equals('Authorization'));
        expect(ApiConstants.headerAllowAnonymous, equals('AllowAnonymous'));
        expect(ApiConstants.headerAccept, equals('Accept'));
        expect(ApiConstants.headerUserAgent, equals('User-Agent'));
      });

      test('header values are correct', () {
        expect(ApiConstants.contentTypeJson, equals('application/json'));
        expect(ApiConstants.contentTypeFormData, equals('application/x-www-form-urlencoded'));
        expect(ApiConstants.bearerPrefix, equals('Bearer '));
        expect(ApiConstants.allowAnonymousValue, equals('true'));
      });
    });

    group('Response Fields', () {
      test('all response fields are non-empty strings', () {
        final allFields = ApiConstants.allResponseFields;
        
        for (final field in allFields) {
          expect(field, isNotEmpty);
          expect(field.trim(), equals(field)); // No leading/trailing whitespace
        }
      });

      test('all response fields are unique', () {
        final allFields = ApiConstants.allResponseFields;
        final uniqueFields = allFields.toSet();
        
        expect(allFields.length, equals(uniqueFields.length));
      });

      test('standard response fields are correct', () {
        expect(ApiConstants.responseFieldSuccessful, equals('successful'));
        expect(ApiConstants.responseFieldData, equals('data'));
        expect(ApiConstants.responseFieldMessage, equals('message'));
        expect(ApiConstants.responseFieldErrorCode, equals('errorCode'));
      });

      test('authentication response fields are correct', () {
        expect(ApiConstants.responseFieldToken, equals('token'));
        expect(ApiConstants.responseFieldUserId, equals('userId'));
        expect(ApiConstants.responseFieldEmail, equals('email'));
        expect(ApiConstants.responseFieldNativeLanguage, equals('nativeLanguage'));
        expect(ApiConstants.responseFieldCurrentLearningLanguage, equals('currentLearningLanguage'));
      });
    });

    group('Default Values', () {
      test('pagination defaults are reasonable', () {
        expect(ApiConstants.defaultPageSize, equals(20));
        expect(ApiConstants.maxPageSize, equals(100));
        expect(ApiConstants.minPageSize, equals(1));
        
        // Validate relationships
        expect(ApiConstants.minPageSize, lessThan(ApiConstants.defaultPageSize));
        expect(ApiConstants.defaultPageSize, lessThan(ApiConstants.maxPageSize));
      });

      test('timeout values are reasonable', () {
        expect(ApiConstants.defaultTimeout, equals(30000)); // 30 seconds
        expect(ApiConstants.longRunningTimeout, equals(300000)); // 5 minutes
        
        // Long running should be longer than default
        expect(ApiConstants.defaultTimeout, lessThan(ApiConstants.longRunningTimeout));
      });
    });

    group('Parameter Names', () {
      test('parameter names are consistent', () {
        expect(ApiConstants.paramEmail, equals('email'));
        expect(ApiConstants.paramPassword, equals('password'));
        expect(ApiConstants.paramPageNumber, equals('pageNumber'));
        expect(ApiConstants.paramPageSize, equals('pageSize'));
        expect(ApiConstants.paramLocalTimezone, equals('localTimezone'));
      });

      test('parameter names match request fields', () {
        expect(ApiConstants.paramPageNumber, equals(ApiConstants.requestFieldPageNumber));
        expect(ApiConstants.paramPageSize, equals(ApiConstants.requestFieldPageSize));
        expect(ApiConstants.paramLocalTimezone, equals(ApiConstants.requestFieldLocalTimezone));
      });
    });

    group('Endpoint Naming Convention', () {
      test('endpoints follow REST conventions', () {
        final allEndpoints = ApiConstants.allEndpoints;
        
        for (final endpoint in allEndpoints) {
          // Should start with /
          expect(endpoint, startsWith('/'));
          
          // Should not end with /
          expect(endpoint, isNot(endsWith('/')));
          
          // Should not have consecutive slashes
          expect(endpoint, isNot(contains('//')));
          
          // Should only contain valid URL characters
          expect(endpoint, matches(RegExp(r'^/[a-zA-Z0-9/_-]+$')));
        }
      });

      test('authentication endpoints follow pattern', () {
        expect(ApiConstants.authLogin, startsWith('/auth/'));
        expect(ApiConstants.authRegister, startsWith('/auth/'));
        expect(ApiConstants.accountRefreshToken, startsWith('/account/'));
        expect(ApiConstants.accountMyInformation, startsWith('/account/'));
      });

      test('vocabulary endpoints follow pattern', () {
        expect(ApiConstants.vocabularyAdd, startsWith('/vocabulary/'));
        expect(ApiConstants.vocabularyList, startsWith('/vocabulary/'));
        expect(ApiConstants.vocabularyDelete, startsWith('/vocabulary/'));
      });

      test('stories endpoints follow pattern', () {
        expect(ApiConstants.storiesMyStories, startsWith('/stories/'));
        expect(ApiConstants.storiesGenerate, startsWith('/stories/'));
        expect(ApiConstants.storiesMyFavorite, startsWith('/stories/'));
      });

      test('settings endpoints follow pattern', () {
        expect(ApiConstants.settingsLanguages, startsWith('/settings/'));
        expect(ApiConstants.settingsGetAll, startsWith('/settings/'));
        expect(ApiConstants.settingsUpsert, startsWith('/settings/'));
      });
    });
  });
}