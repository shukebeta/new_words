/// Standardized API response wrapper for all API calls
/// 
/// This class provides a unified way to handle success and error states
/// from API responses, replacing the inconsistent ApiResult and ApiResponse classes.
class ApiResponseV2<T> {
  /// The response data, null if error occurred
  final T? data;
  
  /// Whether the API call was successful
  final bool isSuccess;
  
  /// Error message if the call failed
  final String? errorMessage;
  
  /// HTTP status code from the response
  final int? statusCode;
  
  /// Backend-specific error code
  final int? errorCode;

  const ApiResponseV2._({
    this.data,
    required this.isSuccess,
    this.errorMessage,
    this.statusCode,
    this.errorCode,
  });

  /// Create a successful response with data
  factory ApiResponseV2.success(T data, {int? statusCode}) {
    return ApiResponseV2._(
      data: data,
      isSuccess: true,
      statusCode: statusCode,
    );
  }

  /// Create an error response
  factory ApiResponseV2.error(
    String errorMessage, {
    int? statusCode,
    int? errorCode,
  }) {
    return ApiResponseV2._(
      isSuccess: false,
      errorMessage: errorMessage,
      statusCode: statusCode,
      errorCode: errorCode,
    );
  }

  /// Create from JSON response (compatible with current backend format)
  factory ApiResponseV2.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT, {
    int? httpStatusCode,
  }) {
    final successful = json['successful'] as bool? ?? false;
    
    if (successful) {
      if (json['data'] != null) {
        return ApiResponseV2.success(
          fromJsonT(json['data']),
          statusCode: httpStatusCode,
        );
      } else {
        return ApiResponseV2._(
          data: null,
          isSuccess: true,
          statusCode: httpStatusCode,
        );
      }
    } else {
      return ApiResponseV2.error(
        json['message'] as String? ?? 'Unknown error occurred',
        statusCode: httpStatusCode,
        errorCode: json['errorCode'] as int?,
      );
    }
  }

  /// Create from JSON response for void operations
  factory ApiResponseV2.fromJsonVoid(
    Map<String, dynamic> json, {
    int? httpStatusCode,
  }) {
    final successful = json['successful'] as bool? ?? false;
    
    if (successful) {
      return ApiResponseV2.success(
        null as T,
        statusCode: httpStatusCode,
      );
    } else {
      return ApiResponseV2.error(
        json['message'] as String? ?? 'Unknown error occurred',
        statusCode: httpStatusCode,
        errorCode: json['errorCode'] as int?,
      );
    }
  }

  /// Whether this is an error response
  bool get isError => !isSuccess;

  /// Whether this response has data
  bool get hasData => isSuccess && data != null;

  /// Get data or throw if error
  T get dataOrThrow {
    if (isError) {
      throw Exception(errorMessage ?? 'API call failed');
    }
    if (data == null) {
      throw Exception('No data available');
    }
    return data!;
  }

  /// Get data or return default value
  T? dataOrDefault(T? defaultValue) {
    return hasData ? data : defaultValue;
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'ApiResponseV2.success(data: $data, statusCode: $statusCode)';
    } else {
      return 'ApiResponseV2.error(message: $errorMessage, statusCode: $statusCode, errorCode: $errorCode)';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ApiResponseV2<T> &&
        other.data == data &&
        other.isSuccess == isSuccess &&
        other.errorMessage == errorMessage &&
        other.statusCode == statusCode &&
        other.errorCode == errorCode;
  }

  @override
  int get hashCode {
    return Object.hash(
      data,
      isSuccess,
      errorMessage,
      statusCode,
      errorCode,
    );
  }
}