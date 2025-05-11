class ApiResult<T> {
  final T? data;
  final bool isSuccess;
  final String? errorMessage;
  final int? statusCode; // Or specific error code from backend

  ApiResult({this.data, required this.isSuccess, this.errorMessage, this.statusCode});

  factory ApiResult.fromJson(Map<String, dynamic> json, T Function(dynamic json) fromJsonT) {
    return ApiResult(
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      isSuccess: json['successful'] as bool? ?? false, // Changed 'isSuccess' to 'successful'
      errorMessage: json['message'] as String?, // Backend uses 'message' for success/error messages
      statusCode: json['errorCode'] as int?, // Backend uses 'errorCode'
    );
  }
}