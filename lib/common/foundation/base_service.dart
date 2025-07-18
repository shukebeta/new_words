import 'api_response_v2.dart';
import 'service_exceptions.dart';

/// Base class for all service implementations
/// 
/// Provides common patterns for handling API responses, error processing,
/// and data transformation. All new service classes should extend this base class.
abstract class BaseService {
  /// Process API response and extract data or throw service exception
  T processResponse<T>(ApiResponseV2<T> response) {
    if (response.isSuccess && response.data != null) {
      return response.data!;
    } else {
      throw ServiceExceptionFactory.fromApiResponse(
        response.errorMessage,
        response.errorCode,
        response.statusCode,
      );
    }
  }

  /// Process API response for void operations
  void processVoidResponse(ApiResponseV2<void> response) {
    if (!response.isSuccess) {
      throw ServiceExceptionFactory.fromApiResponse(
        response.errorMessage,
        response.errorCode,
        response.statusCode,
      );
    }
  }

  /// Process API response with custom error handling
  T processResponseWithCustomError<T>(
    ApiResponseV2<T> response,
    ServiceException Function(String? message, int? errorCode, int? statusCode) errorFactory,
  ) {
    if (response.isSuccess && response.data != null) {
      return response.data!;
    } else {
      throw errorFactory(response.errorMessage, response.errorCode, response.statusCode);
    }
  }

  /// Safe wrapper for API calls with automatic error conversion
  Future<T> safeApiCall<T>(Future<ApiResponseV2<T>> apiCall) async {
    try {
      final response = await apiCall;
      return processResponse(response);
    } on ServiceException {
      rethrow; // Already a service exception, don't wrap again
    } catch (e) {
      throw ServiceExceptionFactory.fromException(e);
    }
  }

  /// Safe wrapper for void API calls
  Future<void> safeVoidApiCall(Future<ApiResponseV2<void>> apiCall) async {
    try {
      final response = await apiCall;
      processVoidResponse(response);
    } on ServiceException {
      rethrow; // Already a service exception, don't wrap again
    } catch (e) {
      throw ServiceExceptionFactory.fromException(e);
    }
  }

  /// Transform data with error handling
  R transformData<T, R>(
    T data,
    R Function(T data) transformer, {
    String? operationName,
  }) {
    try {
      return transformer(data);
    } catch (e) {
      final operation = operationName ?? 'data transformation';
      throw DataException('Failed to perform $operation: ${e.toString()}', cause: e);
    }
  }

  /// Validate input data before API calls
  void validateInput(Map<String, dynamic> validations) {
    for (final entry in validations.entries) {
      final field = entry.key;
      final value = entry.value;

      if (value == null) {
        throw DataException.validation(field, 'Field is required');
      }

      if (value is String && value.trim().isEmpty) {
        throw DataException.validation(field, 'Field cannot be empty');
      }

      if (value is List && value.isEmpty) {
        throw DataException.validation(field, 'List cannot be empty');
      }
    }
  }

  /// Validate string field with custom rules
  void validateStringField(
    String? value,
    String fieldName, {
    int? minLength,
    int? maxLength,
    bool required = true,
    Pattern? pattern,
    String? patternDescription,
  }) {
    if (required && (value == null || value.trim().isEmpty)) {
      throw DataException.validation(fieldName, 'Field is required');
    }

    if (value != null && value.isNotEmpty) {
      if (minLength != null && value.length < minLength) {
        throw DataException.validation(fieldName, 'Must be at least $minLength characters');
      }

      if (maxLength != null && value.length > maxLength) {
        throw DataException.validation(fieldName, 'Must be no more than $maxLength characters');
      }

      if (pattern != null) {
        bool matches = false;
        if (pattern is RegExp) {
          matches = pattern.hasMatch(value);
        } else {
          matches = pattern.allMatches(value).isNotEmpty;
        }
        
        if (!matches) {
          final description = patternDescription ?? 'Invalid format';
          throw DataException.validation(fieldName, description);
        }
      }
    }
  }

  /// Validate numeric field with range checks
  void validateNumericField(
    num? value,
    String fieldName, {
    num? min,
    num? max,
    bool required = true,
  }) {
    if (required && value == null) {
      throw DataException.validation(fieldName, 'Field is required');
    }

    if (value != null) {
      if (min != null && value < min) {
        throw DataException.validation(fieldName, 'Must be at least $min');
      }

      if (max != null && value > max) {
        throw DataException.validation(fieldName, 'Must be no more than $max');
      }
    }
  }

  /// Handle pagination parameters with validation
  Map<String, dynamic> processPaginationParams(
    int pageNumber,
    int pageSize, {
    int maxPageSize = 100,
    int minPageSize = 1,
  }) {
    validateNumericField(pageNumber, 'pageNumber', min: 1);
    validateNumericField(pageSize, 'pageSize', min: minPageSize, max: maxPageSize);

    return {
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    };
  }

  /// Create standardized error message with context
  String createErrorMessage(String operation, String? details) {
    if (details != null && details.isNotEmpty) {
      return 'Failed to $operation: $details';
    }
    return 'Failed to $operation';
  }

  /// Log service operation (can be overridden by subclasses)
  void logOperation(String operation, {Map<String, dynamic>? parameters}) {
    // Base implementation - can be enhanced with actual logging
    // print('Service operation: $operation ${parameters ?? ''}');
  }

  /// Log service error (can be overridden by subclasses)
  void logError(String operation, ServiceException error) {
    // Base implementation - can be enhanced with actual logging
    // print('Service error in $operation: $error');
  }
}