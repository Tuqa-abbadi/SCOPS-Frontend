import 'package:dio/dio.dart';

import '../core/network/dio_client.dart';
import '../services/profile_api_service.dart';

class ProfileResult {
  const ProfileResult({required this.success, required this.message});

  final bool success;
  final String message;
}

class ProfileRepository {
  ProfileRepository({ProfileApiService? service})
      : _service = service ?? ProfileApiService(dio: DioClient.instance.dio);

  final ProfileApiService _service;

  Future<ProfileResult> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final response = await _service.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );
      final data = _asMap(response.data);
      final message = _messageFrom(data) ?? 'Password changed successfully.';
      return ProfileResult(success: true, message: message);
    } on DioException catch (e) {
      return ProfileResult(success: false, message: _parseDioError(e));
    } catch (_) {
      return const ProfileResult(
        success: false,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return const {};
  }

  String? _messageFrom(Map<String, dynamic> data) {
    for (final key in ['message', 'error', 'detail']) {
      final v = data[key];
      if (v is String && v.isNotEmpty) return v;
    }
    // Flatten first validation error if present
    final errors = data['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final first = errors.values.first;
      if (first is List && first.isNotEmpty) return first.first.toString();
      return first.toString();
    }
    return null;
  }

  String _parseDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        if (error.response == null) {
          return 'Network error. Please check your connection.';
        }
        break;
      case DioExceptionType.badCertificate:
        return 'Secure connection failed.';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.badResponse:
        break;
    }

    final statusCode = error.response?.statusCode;
    final data = _asMap(error.response?.data);
    final message = _messageFrom(data);

    if (statusCode == 401 || statusCode == 403) {
      return message ?? 'Session expired. Please log in again.';
    }
    if (statusCode == 422 || statusCode == 400) {
      return message ?? 'Please check your details and try again.';
    }
    if (statusCode != null && statusCode >= 500) {
      return 'Server error. Please try again later.';
    }
    return message ?? 'Something went wrong. Please try again.';
  }
}
