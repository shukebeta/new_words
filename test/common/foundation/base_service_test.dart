import 'package:flutter_test/flutter_test.dart';
import 'package:new_words/common/foundation/base_service.dart';
import 'package:new_words/common/foundation/api_response_v2.dart';
import 'package:new_words/common/foundation/service_exceptions.dart';

void main() {
  group('BaseService', () {
    late TestBaseService service;

    setUp(() {
      service = TestBaseService();
    });

    group('processResponse', () {
      test('returns data for successful response', () {
        const testData = 'test data';
        final response = ApiResponseV2.success(testData);

        final result = service.processResponse(response);

        expect(result, equals(testData));
      });

      test('throws ServiceException for error response', () {
        final response = ApiResponseV2<String>.error(
          'API error',
          statusCode: 400,
          errorCode: 1001,
        );

        expect(
          () => service.processResponse(response),
          throwsA(isA<ApiBusinessException>()),
        );
      });

      test('throws ServiceException for successful response with null data', () {
        final response = ApiResponseV2<String?>.success(null);

        expect(
          () => service.processResponse(response),
          throwsA(isA<ServiceException>()),
        );
      });
    });

    group('processVoidResponse', () {
      test('completes successfully for successful void response', () {
        final response = ApiResponseV2<void>.success(null);

        expect(() => service.processVoidResponse(response), returnsNormally);
      });

      test('throws ServiceException for error void response', () {
        final response = ApiResponseV2<void>.error(
          'Operation failed',
          statusCode: 500,
        );

        expect(
          () => service.processVoidResponse(response),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('processResponseWithCustomError', () {
      test('returns data for successful response', () {
        const testData = 42;
        final response = ApiResponseV2.success(testData);

        final result = service.processResponseWithCustomError(
          response,
          (message, errorCode, statusCode) => const DataException('Custom error'),
        );

        expect(result, equals(testData));
      });

      test('uses custom error factory for error response', () {
        final response = ApiResponseV2<int>.error('API error');

        expect(
          () => service.processResponseWithCustomError(
            response,
            (message, errorCode, statusCode) => const DataException('Custom error'),
          ),
          throwsA(
            predicate((e) => e is DataException && e.message == 'Custom error'),
          ),
        );
      });
    });

    group('safeApiCall', () {
      test('returns data for successful API call', () async {
        const expectedData = 'success';
        final response = ApiResponseV2.success(expectedData);

        final result = await service.safeApiCall(Future.value(response));

        expect(result, equals(expectedData));
      });

      test('propagates ServiceException from API call', () async {
        final future = Future<ApiResponseV2<String>>.error(
          const NetworkException('Network error'),
        );

        expect(
          () => service.safeApiCall(future),
          throwsA(isA<NetworkException>()),
        );
      });

      test('wraps non-ServiceException in DataException', () async {
        final future = Future<ApiResponseV2<String>>.error(
          Exception('Generic error'),
        );

        expect(
          () => service.safeApiCall(future),
          throwsA(isA<DataException>()),
        );
      });
    });

    group('safeVoidApiCall', () {
      test('completes successfully for successful void API call', () async {
        final response = ApiResponseV2<void>.success(null);

        expect(
          () => service.safeVoidApiCall(Future.value(response)),
          returnsNormally,
        );
      });

      test('propagates ServiceException from void API call', () async {
        final future = Future<ApiResponseV2<void>>.error(
          const ServerException('Server error', statusCode: 500),
        );

        expect(
          () => service.safeVoidApiCall(future),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('transformData', () {
      test('successfully transforms data', () {
        const input = 'hello';
        final result = service.transformData(
          input,
          (data) => data.toUpperCase(),
        );

        expect(result, equals('HELLO'));
      });

      test('throws DataException on transformation error', () {
        const input = 'test';
        
        expect(
          () => service.transformData(
            input,
            (data) => throw Exception('Transform failed'),
          ),
          throwsA(isA<DataException>()),
        );
      });

      test('includes operation name in error message', () {
        const input = 'test';
        
        expect(
          () => service.transformData(
            input,
            (data) => throw Exception('Transform failed'),
            operationName: 'uppercase conversion',
          ),
          throwsA(
            predicate((e) => 
              e is DataException && 
              e.message.contains('uppercase conversion')
            ),
          ),
        );
      });
    });

    group('validateInput', () {
      test('passes validation for valid inputs', () {
        final validations = {
          'name': 'John Doe',
          'age': 25,
          'items': ['item1', 'item2'],
        };

        expect(
          () => service.validateInput(validations),
          returnsNormally,
        );
      });

      test('throws DataException for null field', () {
        final validations = {
          'name': null,
        };

        expect(
          () => service.validateInput(validations),
          throwsA(
            predicate((e) => 
              e is DataException && 
              e.message.contains('Field is required')
            ),
          ),
        );
      });

      test('throws DataException for empty string', () {
        final validations = {
          'name': '   ',
        };

        expect(
          () => service.validateInput(validations),
          throwsA(
            predicate((e) => 
              e is DataException && 
              e.message.contains('Field cannot be empty')
            ),
          ),
        );
      });

      test('throws DataException for empty list', () {
        final validations = {
          'items': <String>[],
        };

        expect(
          () => service.validateInput(validations),
          throwsA(
            predicate((e) => 
              e is DataException && 
              e.message.contains('List cannot be empty')
            ),
          ),
        );
      });
    });

    group('validateStringField', () {
      test('passes validation for valid string', () {
        expect(
          () => service.validateStringField(
            'valid string',
            'testField',
            minLength: 5,
            maxLength: 20,
          ),
          returnsNormally,
        );
      });

      test('throws DataException for required field that is null', () {
        expect(
          () => service.validateStringField(null, 'testField'),
          throwsA(
            predicate((e) => 
              e is DataException && 
              e.field == 'testField' &&
              e.message.contains('Field is required')
            ),
          ),
        );
      });

      test('allows null for non-required field', () {
        expect(
          () => service.validateStringField(
            null,
            'testField',
            required: false,
          ),
          returnsNormally,
        );
      });

      test('throws DataException for string too short', () {
        expect(
          () => service.validateStringField(
            'abc',
            'testField',
            minLength: 5,
          ),
          throwsA(
            predicate((e) => 
              e is DataException && 
              e.message.contains('Must be at least 5 characters')
            ),
          ),
        );
      });

      test('throws DataException for string too long', () {
        expect(
          () => service.validateStringField(
            'this is a very long string',
            'testField',
            maxLength: 10,
          ),
          throwsA(
            predicate((e) => 
              e is DataException && 
              e.message.contains('Must be no more than 10 characters')
            ),
          ),
        );
      });

      test('throws DataException for pattern mismatch', () {
        expect(
          () => service.validateStringField(
            'invalid-email',
            'email',
            pattern: RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$'),
            patternDescription: 'Must be valid email format',
          ),
          throwsA(
            predicate((e) => 
              e is DataException && 
              e.message.contains('Must be valid email format')
            ),
          ),
        );
      });
    });

    group('validateNumericField', () {
      test('passes validation for valid number', () {
        expect(
          () => service.validateNumericField(
            15,
            'age',
            min: 0,
            max: 100,
          ),
          returnsNormally,
        );
      });

      test('throws DataException for required field that is null', () {
        expect(
          () => service.validateNumericField(null, 'age'),
          throwsA(
            predicate((e) => 
              e is DataException && 
              e.field == 'age' &&
              e.message.contains('Field is required')
            ),
          ),
        );
      });

      test('throws DataException for number below minimum', () {
        expect(
          () => service.validateNumericField(
            -5,
            'age',
            min: 0,
          ),
          throwsA(
            predicate((e) => 
              e is DataException && 
              e.message.contains('Must be at least 0')
            ),
          ),
        );
      });

      test('throws DataException for number above maximum', () {
        expect(
          () => service.validateNumericField(
            150,
            'age',
            max: 100,
          ),
          throwsA(
            predicate((e) => 
              e is DataException && 
              e.message.contains('Must be no more than 100')
            ),
          ),
        );
      });
    });

    group('processPaginationParams', () {
      test('returns valid pagination parameters', () {
        final result = service.processPaginationParams(2, 20);

        expect(result, equals({
          'pageNumber': 2,
          'pageSize': 20,
        }));
      });

      test('throws DataException for invalid page number', () {
        expect(
          () => service.processPaginationParams(0, 20),
          throwsA(
            predicate((e) => 
              e is DataException && 
              e.field == 'pageNumber'
            ),
          ),
        );
      });

      test('throws DataException for page size too small', () {
        expect(
          () => service.processPaginationParams(1, 0),
          throwsA(
            predicate((e) => 
              e is DataException && 
              e.field == 'pageSize'
            ),
          ),
        );
      });

      test('throws DataException for page size too large', () {
        expect(
          () => service.processPaginationParams(1, 150),
          throwsA(
            predicate((e) => 
              e is DataException && 
              e.field == 'pageSize'
            ),
          ),
        );
      });

      test('respects custom size limits', () {
        expect(
          () => service.processPaginationParams(
            1,
            50,
            maxPageSize: 25,
          ),
          throwsA(isA<DataException>()),
        );
      });
    });

    group('createErrorMessage', () {
      test('creates message with details', () {
        final message = service.createErrorMessage(
          'save user',
          'validation failed',
        );

        expect(message, equals('Failed to save user: validation failed'));
      });

      test('creates message without details', () {
        final message = service.createErrorMessage('save user', null);

        expect(message, equals('Failed to save user'));
      });

      test('creates message with empty details', () {
        final message = service.createErrorMessage('save user', '');

        expect(message, equals('Failed to save user'));
      });
    });
  });
}

// Test implementation of BaseService for testing
class TestBaseService extends BaseService {
  // Expose protected methods for testing
  @override
  T processResponse<T>(ApiResponseV2<T> response) => super.processResponse(response);
  
  @override
  void processVoidResponse(ApiResponseV2<void> response) => super.processVoidResponse(response);
  
  @override
  T processResponseWithCustomError<T>(
    ApiResponseV2<T> response,
    ServiceException Function(String? message, int? errorCode, int? statusCode) errorFactory,
  ) => super.processResponseWithCustomError(response, errorFactory);
  
  @override
  Future<T> safeApiCall<T>(Future<ApiResponseV2<T>> apiCall) => super.safeApiCall(apiCall);
  
  @override
  Future<void> safeVoidApiCall(Future<ApiResponseV2<void>> apiCall) => super.safeVoidApiCall(apiCall);
  
  @override
  R transformData<T, R>(
    T data,
    R Function(T data) transformer, {
    String? operationName,
  }) => super.transformData(data, transformer, operationName: operationName);
  
  @override
  void validateInput(Map<String, dynamic> validations) => super.validateInput(validations);
  
  @override
  void validateStringField(
    String? value,
    String fieldName, {
    int? minLength,
    int? maxLength,
    bool required = true,
    Pattern? pattern,
    String? patternDescription,
  }) => super.validateStringField(
    value,
    fieldName,
    minLength: minLength,
    maxLength: maxLength,
    required: required,
    pattern: pattern,
    patternDescription: patternDescription,
  );
  
  @override
  void validateNumericField(
    num? value,
    String fieldName, {
    num? min,
    num? max,
    bool required = true,
  }) => super.validateNumericField(
    value,
    fieldName,
    min: min,
    max: max,
    required: required,
  );
  
  @override
  Map<String, dynamic> processPaginationParams(
    int pageNumber,
    int pageSize, {
    int maxPageSize = 100,
    int minPageSize = 1,
  }) => super.processPaginationParams(
    pageNumber,
    pageSize,
    maxPageSize: maxPageSize,
    minPageSize: minPageSize,
  );
  
  @override
  String createErrorMessage(String operation, String? details) => super.createErrorMessage(operation, details);
}