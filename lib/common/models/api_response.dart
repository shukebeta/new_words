class ApiResponse<T> {
  final T data;
  final bool successful;
  final int errorCode;
  final String message;

  ApiResponse({
    required this.data,
    required this.successful,
    required this.errorCode,
    required this.message,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) dataFromJson,
  ) {
    return ApiResponse<T>(
      data: dataFromJson(json['data']),
      successful: json['successful'],
      errorCode: json['errorCode'],
      message: json['message'],
    );
  }
}
