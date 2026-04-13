import 'package:dio/dio.dart';
import '../models/models.dart';
import 'api_client.dart';
import 'api_exception.dart';

class DebriefService {
  final ApiClient _apiClient;

  DebriefService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Dio get _dio => _apiClient.dio;

  /// Creates a new debrief. [userId] is sent as the `x-user-id` header.
  Future<Debrief> createDebrief(
    CreateDebriefRequest request, {
    String? userId,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/debriefs',
        data: request.toJson(),
        options: Options(headers: {if (userId != null) 'x-user-id': userId}),
      );
      return Debrief.fromJson(response.data!);
    } on DioException catch (e) {
      throw _unwrap(e);
    }
  }

  /// Returns all debriefs belonging to [userId].
  Future<List<Debrief>> getDebriefs({String? userId}) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/debriefs',
        options: Options(headers: {if (userId != null) 'x-user-id': userId}),
      );
      return (response.data ?? [])
          .map((e) => Debrief.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _unwrap(e);
    }
  }

  /// Returns a single debrief by [id].
  Future<Debrief> getDebrief(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/debriefs/$id');
      return Debrief.fromJson(response.data!);
    } on DioException catch (e) {
      throw _unwrap(e);
    }
  }

  /// Updates the debrief identified by [id].
  Future<Debrief> updateDebrief(String id, UpdateDebriefRequest request) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/debriefs/$id',
        data: request.toJson(),
      );
      return Debrief.fromJson(response.data!);
    } on DioException catch (e) {
      throw _unwrap(e);
    }
  }

  /// Deletes the debrief identified by [id]. Returns `void` (204 No Content).
  Future<void> deleteDebrief(String id) async {
    try {
      await _dio.delete<void>('/debriefs/$id');
    } on DioException catch (e) {
      throw _unwrap(e);
    }
  }

  /// Sends the debrief identified by [id] via email.
  Future<void> emailDebrief(String id, EmailDebriefRequest request) async {
    try {
      await _dio.post<void>('/debriefs/$id/email', data: request.toJson());
    } on DioException catch (e) {
      throw _unwrap(e);
    }
  }

  /// Calls the AI endpoint to extract structured debrief fields from raw [notes].
  Future<AiExtractResult> extractDebriefFields(String notes) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/ai/extract-debrief',
        data: {'notes': notes},
      );
      return AiExtractResult.fromJson(response.data!);
    } on DioException catch (e) {
      throw _unwrap(e);
    }
  }

  /// Extracts an [ApiException] from a [DioException], falling back to a
  /// generic one when the interceptor has not already wrapped it.
  ApiException _unwrap(DioException e) {
    final err = e.error;
    if (err is ApiException) return err;
    return ApiException.unknown(e.message ?? e);
  }
}
