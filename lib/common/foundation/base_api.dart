import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:new_words/dio_client.dart';
import 'api_response_v2.dart';
import 'service_exceptions.dart';

/// Base class for all API implementations
/// 
/// Provides common HTTP operations with standardized error handling
/// and response parsing. All new API classes should extend this base class.
abstract class BaseApi {
  /// Dio instance for HTTP requests
  late final Dio _dio;

  /// Initialize with DioClient instance or custom Dio for testing
  BaseApi([Dio? customDio]) {
    _dio = customDio ?? DioClient.getInstance();
  }

  /// Perform GET request with standardized response handling
  Future<ApiResponseV2<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      
      return parseResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw ServiceExceptionFactory.fromDioException(e);
    } catch (e) {
      throw ServiceExceptionFactory.fromException(e);
    }
  }

  /// Perform POST request with standardized response handling
  Future<ApiResponseV2<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      
      return parseResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw ServiceExceptionFactory.fromDioException(e);
    } catch (e) {
      throw ServiceExceptionFactory.fromException(e);
    }
  }

  /// Perform PUT request with standardized response handling
  Future<ApiResponseV2<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      
      return parseResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw ServiceExceptionFactory.fromDioException(e);
    } catch (e) {
      throw ServiceExceptionFactory.fromException(e);
    }
  }

  /// Perform DELETE request with standardized response handling
  Future<ApiResponseV2<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      
      return parseResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw ServiceExceptionFactory.fromDioException(e);
    } catch (e) {
      throw ServiceExceptionFactory.fromException(e);
    }
  }

  /// Perform request for void operations (no response data expected)
  Future<ApiResponseV2<void>> requestVoid(
    String method,
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      Response response;
      
      switch (method.toUpperCase()) {
        case 'GET':
          response = await _dio.get(path, queryParameters: queryParameters, options: options);
          break;
        case 'POST':
          response = await _dio.post(path, data: data, queryParameters: queryParameters, options: options);
          break;
        case 'PUT':
          response = await _dio.put(path, data: data, queryParameters: queryParameters, options: options);
          break;
        case 'DELETE':
          response = await _dio.delete(path, data: data, queryParameters: queryParameters, options: options);
          break;
        default:
          throw ArgumentError('Unsupported HTTP method: $method');
      }
      
      return parseVoidResponse(response);
    } on DioException catch (e) {
      throw ServiceExceptionFactory.fromDioException(e);
    } catch (e) {
      throw ServiceExceptionFactory.fromException(e);
    }
  }

  /// Parse response data with error handling
  @protected
  ApiResponseV2<T> parseResponse<T>(
    Response response,
    T Function(dynamic json)? fromJson,
  ) {
    try {
      final data = response.data;
      
      if (data is! Map<String, dynamic>) {
        throw DataException.parsing('Expected JSON object but got ${data.runtimeType}');
      }

      if (fromJson != null) {
        return ApiResponseV2<T>.fromJson(
          data, 
          fromJson,
          httpStatusCode: response.statusCode,
        );
      } else {
        // For primitive types or when no parser is provided
        return ApiResponseV2<T>.fromJson(
          data, 
          (json) => json as T,
          httpStatusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServiceException) {
        rethrow;
      }
      throw DataException.parsing('Failed to parse response: ${e.toString()}', cause: e);
    }
  }

  /// Parse void response (operations that don't return data)
  @protected
  ApiResponseV2<void> parseVoidResponse(Response response) {
    try {
      final data = response.data;
      
      if (data is! Map<String, dynamic>) {
        throw DataException.parsing('Expected JSON object but got ${data.runtimeType}');
      }

      return ApiResponseV2<void>.fromJsonVoid(
        data,
        httpStatusCode: response.statusCode,
      );
    } catch (e) {
      if (e is ServiceException) {
        rethrow;
      }
      throw DataException.parsing('Failed to parse response: ${e.toString()}', cause: e);
    }
  }

  /// Create options with custom timeout
  Options createOptions({
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Map<String, dynamic>? headers,
    String? contentType,
  }) {
    return Options(
      headers: headers,
      contentType: contentType,
      sendTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
    );
  }

  /// Create options for anonymous requests (bypass auth)
  Options createAnonymousOptions({
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Map<String, dynamic>? headers,
    String? contentType,
  }) {
    final finalHeaders = <String, dynamic>{
      'AllowAnonymous': 'true',
      ...?headers,
    };

    return Options(
      headers: finalHeaders,
      contentType: contentType,
      sendTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
    );
  }

  /// Create options for long-running operations
  Options createLongRunningOptions({
    Duration? connectTimeout = const Duration(minutes: 2),
    Duration? receiveTimeout = const Duration(minutes: 5),
    Map<String, dynamic>? headers,
    String? contentType,
  }) {
    return createOptions(
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      headers: headers,
      contentType: contentType,
    );
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
}