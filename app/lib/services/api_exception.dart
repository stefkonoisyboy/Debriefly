class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String? error;

  const ApiException({
    required this.statusCode,
    required this.message,
    this.error,
  });

  factory ApiException.fromJson(Map<String, dynamic> json) {
    return ApiException(
      statusCode: (json['statusCode'] as num).toInt(),
      message: json['message'] as String? ?? 'An error occurred',
      error: json['error'] as String?,
    );
  }

  factory ApiException.unknown(Object cause) {
    return ApiException(statusCode: 0, message: cause.toString());
  }

  @override
  String toString() =>
      'ApiException(statusCode: $statusCode, message: $message)';
}
