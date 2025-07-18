import 'package:flutter_test/flutter_test.dart';
import 'package:new_words/common/foundation/api_response_v2.dart';

void main() {
  group('ApiResponseV2', () {
    group('Factory constructors', () {
      test('success creates successful response with data', () {
        const testData = 'test data';
        const statusCode = 200;
        
        final response = ApiResponseV2.success(testData, statusCode: statusCode);
        
        expect(response.isSuccess, isTrue);
        expect(response.isError, isFalse);
        expect(response.hasData, isTrue);
        expect(response.data, equals(testData));
        expect(response.statusCode, equals(statusCode));
        expect(response.errorMessage, isNull);
        expect(response.errorCode, isNull);
      });

      test('error creates error response with message', () {
        const errorMessage = 'Something went wrong';
        const statusCode = 400;
        const errorCode = 1001;
        
        final response = ApiResponseV2<String>.error(
          errorMessage,
          statusCode: statusCode,
          errorCode: errorCode,
        );
        
        expect(response.isSuccess, isFalse);
        expect(response.isError, isTrue);
        expect(response.hasData, isFalse);
        expect(response.data, isNull);
        expect(response.errorMessage, equals(errorMessage));
        expect(response.statusCode, equals(statusCode));
        expect(response.errorCode, equals(errorCode));
      });
    });

    group('fromJson factory', () {
      test('creates successful response from valid JSON', () {
        final json = {
          'successful': true,
          'data': {'id': 1, 'name': 'Test'},
          'statusCode': 200,
        };
        
        final response = ApiResponseV2.fromJson(
          json,
          (data) => TestModel.fromJson(data as Map<String, dynamic>),
        );
        
        expect(response.isSuccess, isTrue);
        expect(response.hasData, isTrue);
        expect(response.data!.id, equals(1));
        expect(response.data!.name, equals('Test'));
        expect(response.statusCode, equals(200));
      });

      test('creates error response from failed JSON', () {
        final json = {
          'successful': false,
          'message': 'Validation failed',
          'errorCode': 1001,
          'statusCode': 400,
        };
        
        final response = ApiResponseV2<TestModel>.fromJson(
          json,
          (data) => TestModel.fromJson(data as Map<String, dynamic>),
        );
        
        expect(response.isError, isTrue);
        expect(response.hasData, isFalse);
        expect(response.errorMessage, equals('Validation failed'));
        expect(response.errorCode, equals(1001));
        expect(response.statusCode, equals(400));
      });

      test('handles missing successful field as false', () {
        final json = {
          'message': 'Unknown error',
        };
        
        final response = ApiResponseV2<String>.fromJson(
          json,
          (data) => data as String,
        );
        
        expect(response.isError, isTrue);
        expect(response.errorMessage, equals('Unknown error'));
      });

      test('handles null data in successful response', () {
        final json = {
          'successful': true,
          'data': null,
        };
        
        final response = ApiResponseV2<String?>.fromJson(
          json,
          (data) => data as String?,
        );
        
        expect(response.isSuccess, isTrue);
        expect(response.data, isNull);
        expect(response.hasData, isFalse);
      });

      test('provides default error message when missing', () {
        final json = {
          'successful': false,
        };
        
        final response = ApiResponseV2<String>.fromJson(
          json,
          (data) => data as String,
        );
        
        expect(response.isError, isTrue);
        expect(response.errorMessage, equals('Unknown error occurred'));
      });
    });

    group('fromJsonVoid factory', () {
      test('creates successful void response', () {
        final json = {
          'successful': true,
          'statusCode': 204,
        };
        
        final response = ApiResponseV2<void>.fromJsonVoid(json);
        
        expect(response.isSuccess, isTrue);
        expect(response.statusCode, equals(204));
      });

      test('creates error void response', () {
        final json = {
          'successful': false,
          'message': 'Operation failed',
          'errorCode': 5001,
        };
        
        final response = ApiResponseV2<void>.fromJsonVoid(json);
        
        expect(response.isError, isTrue);
        expect(response.errorMessage, equals('Operation failed'));
        expect(response.errorCode, equals(5001));
      });
    });

    group('Data access methods', () {
      test('dataOrThrow returns data for successful response', () {
        const testData = 'test data';
        final response = ApiResponseV2.success(testData);
        
        expect(response.dataOrThrow, equals(testData));
      });

      test('dataOrThrow throws for error response', () {
        final response = ApiResponseV2<String>.error('Error occurred');
        
        expect(() => response.dataOrThrow, throwsException);
      });

      test('dataOrThrow throws for successful response with null data', () {
        final response = ApiResponseV2<String?>.success(null);
        
        expect(() => response.dataOrThrow, throwsException);
      });

      test('dataOrDefault returns data when available', () {
        const testData = 'test data';
        final response = ApiResponseV2.success(testData);
        
        expect(response.dataOrDefault('default'), equals(testData));
      });

      test('dataOrDefault returns default for error response', () {
        const defaultValue = 'default value';
        final response = ApiResponseV2<String>.error('Error occurred');
        
        expect(response.dataOrDefault(defaultValue), equals(defaultValue));
      });

      test('dataOrDefault returns default for null data', () {
        const defaultValue = 'default value';
        final response = ApiResponseV2<String?>.success(null);
        
        expect(response.dataOrDefault(defaultValue), equals(defaultValue));
      });
    });

    group('Object methods', () {
      test('toString returns correct format for success', () {
        const testData = 'test data';
        const statusCode = 200;
        final response = ApiResponseV2.success(testData, statusCode: statusCode);
        
        final result = response.toString();
        
        expect(result, contains('ApiResponseV2.success'));
        expect(result, contains('test data'));
        expect(result, contains('200'));
      });

      test('toString returns correct format for error', () {
        const errorMessage = 'Error occurred';
        const statusCode = 400;
        const errorCode = 1001;
        final response = ApiResponseV2<String>.error(
          errorMessage,
          statusCode: statusCode,
          errorCode: errorCode,
        );
        
        final result = response.toString();
        
        expect(result, contains('ApiResponseV2.error'));
        expect(result, contains(errorMessage));
        expect(result, contains('400'));
        expect(result, contains('1001'));
      });

      test('equality works correctly', () {
        final response1 = ApiResponseV2.success('data', statusCode: 200);
        final response2 = ApiResponseV2.success('data', statusCode: 200);
        final response3 = ApiResponseV2.success('different', statusCode: 200);
        
        expect(response1, equals(response2));
        expect(response1, isNot(equals(response3)));
      });

      test('hashCode is consistent', () {
        final response1 = ApiResponseV2.success('data', statusCode: 200);
        final response2 = ApiResponseV2.success('data', statusCode: 200);
        
        expect(response1.hashCode, equals(response2.hashCode));
      });
    });
  });
}

// Test model for JSON parsing tests
class TestModel {
  final int id;
  final String name;

  TestModel({required this.id, required this.name});

  factory TestModel.fromJson(Map<String, dynamic> json) {
    return TestModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TestModel && other.id == id && other.name == name;
  }

  @override
  int get hashCode => Object.hash(id, name);
}