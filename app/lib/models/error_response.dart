class ErrorResponse {
  final int statusCode;
  final String message;
  final String? error;
  final String timestamp;
  final String? path;

  const ErrorResponse({
    required this.statusCode,
    required this.message,
    this.error,
    required this.timestamp,
    this.path,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      statusCode: json['statusCode'] as int,
      message: json['message'] as String,
      error: json['error'] as String?,
      timestamp: json['timestamp'] as String,
      path: json['path'] as String?,
    );
  }

  @override
  String toString() =>
      'ErrorResponse(statusCode: $statusCode, message: $message)';
}
