import 'package:dio/dio.dart';
import 'api_exception.dart';

class ApiClient {
  static const String _defaultBaseUrl = 'http://192.168.1.102:3000';

  final Dio _dio;

  ApiClient({String? baseUrl})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl ?? _defaultBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    _dio.interceptors.add(_ErrorInterceptor());
  }

  Dio get dio => _dio;
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    if (response != null) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            response: err.response,
            error: ApiException.fromJson(data),
            type: err.type,
          ),
        );
        return;
      }
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          error: ApiException(
            statusCode: response.statusCode ?? 0,
            message: response.statusMessage ?? 'An error occurred',
          ),
          type: err.type,
        ),
      );
      return;
    }
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: ApiException.unknown(err.message ?? err),
        type: err.type,
      ),
    );
  }
}
