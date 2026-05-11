import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../services/token_storage_service.dart';

class AuthResult {
  const AuthResult({
    required this.success,
    this.message,
    this.accessToken,
    this.refreshToken,
    this.user,
  });

  final bool success;
  final String? message;
  final String? accessToken;
  final String? refreshToken;
  final Map<String, dynamic>? user;
}

class AuthRepository {
  AuthRepository({TokenStorageService? tokenStorage})
      : _tokenStorage = tokenStorage ?? TokenStorageService();

  final TokenStorageService _tokenStorage;

  Dio get _dio => DioClient.instance.dio;

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      final data = response.data as Map<String, dynamic>;
      final accessToken = data['token'] as String?;
      final refreshToken = data['refresh_token'] as String?;

      if (accessToken != null) {
        await _tokenStorage.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken ?? '',
        );
      }

      return AuthResult(
        success: true,
        message: data['message'] as String?,
        accessToken: accessToken,
        refreshToken: refreshToken,
        user: data['user'] as Map<String, dynamic>?,
      );
    } on DioException catch (e) {
      return AuthResult(success: false, message: _parseError(e));
    } catch (e) {
      return AuthResult(success: false, message: 'Unexpected error: $e');
    }
  }

  Future<AuthResult> signup({
    required String firstName,
    required String middleName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/signup',
        data: {
          'first_name': firstName,
          'middle_name': middleName,
          'email': email,
          'phone': phone,
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final accessToken = data['token'] as String?;
      final refreshToken = data['refresh_token'] as String?;

      if (accessToken != null) {
        await _tokenStorage.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken ?? '',
        );
      }

      return AuthResult(
        success: true,
        message: data['message'] as String?,
        accessToken: accessToken,
        refreshToken: refreshToken,
        user: data['user'] as Map<String, dynamic>?,
      );
    } on DioException catch (e) {
      return AuthResult(success: false, message: _parseError(e));
    } catch (e) {
      return AuthResult(success: false, message: 'Unexpected error: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/logout');
    } catch (_) {
    } finally {
      await _tokenStorage.clearAll();
    }
  }

  Future<bool> isLoggedIn() => _tokenStorage.hasAccessToken();

  String _parseError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ??
          data['error'] as String? ??
          'Server error (${e.response?.statusCode})';
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Check your internet and try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}