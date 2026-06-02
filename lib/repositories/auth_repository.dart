import 'package:dio/dio.dart';

import '../core/network/dio_client.dart';
import '../models/user_model.dart';
import '../services/auth_api_service.dart';
import '../services/token_storage_service.dart';

class AuthResult {
  const AuthResult({
    required this.success,
    required this.message,
    this.accessToken,
    this.refreshToken,
    this.user,
  });

  final bool success;
  final String message;
  final String? accessToken;
  final String? refreshToken;
  final Map<String, dynamic>? user;
}

class AuthRepository {
  AuthRepository({
    AuthApiService? authApiService,
    TokenStorageService? tokenStorage,
  })  : _tokenStorage = tokenStorage ?? TokenStorageService(),
        _authApiService = authApiService ??
            AuthApiService(dio: DioClient.instance.dio);

  final AuthApiService _authApiService;
  final TokenStorageService _tokenStorage;

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _authApiService.login(
        email: email,
        password: password,
      );

      return _handleAuthResponse(
        response.data,
        defaultMessage: 'Login successful.',
      );
    } on DioException catch (error) {
      return AuthResult(success: false, message: _parseDioError(error));
    } catch (_) {
      return const AuthResult(
        success: false,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  Future<AuthResult> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _authApiService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
      );

      return _handleAuthResponse(
        response.data,
        defaultMessage: 'Account created successfully.',
      );
    } on DioException catch (error) {
      return AuthResult(success: false, message: _parseDioError(error));
    } catch (_) {
      return const AuthResult(
        success: false,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  Future<AuthResult> verifyEmail({
    required String email,
    required String token,
  }) async {
    try {
      final response = await _authApiService.verifyEmail(
        email: email,
        token: token,
      );

      return _handleAuthResponse(
        response.data,
        defaultMessage: 'Email verified successfully.',
      );
    } on DioException catch (error) {
      return AuthResult(success: false, message: _parseDioError(error));
    } catch (_) {
      return const AuthResult(
        success: false,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  Future<AuthResult> verifyResetCode({
    required String email,
    required String token,
  }) async {
    try {
      final response = await _authApiService.verifyResetCode(
        email: email,
        token: token,
      );
      final data = _asMap(response.data);

      if (data['success'] == false) {
        return AuthResult(
          success: false,
          message: _messageFrom(data) ?? 'Invalid or expired code.',
        );
      }

      return AuthResult(
        success: true,
        message: _messageFrom(data) ?? 'Code verified.',
      );
    } on DioException catch (error) {
      return AuthResult(success: false, message: _parseDioError(error));
    } catch (_) {
      return const AuthResult(
        success: false,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  Future<AuthResult> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _authApiService.resetPassword(
        email: email,
        token: token,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      final data = _asMap(response.data);

      if (data['success'] == false) {
        return AuthResult(
          success: false,
          message: _messageFrom(data) ??
              _validationMessageFrom(data) ??
              'Password reset failed. Please try again.',
        );
      }

      return AuthResult(
        success: true,
        message: _messageFrom(data) ?? 'Password reset successfully.',
      );
    } on DioException catch (error) {
      return AuthResult(success: false, message: _parseDioError(error));
    } catch (_) {
      return const AuthResult(
        success: false,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  Future<AuthResult> forgotPassword({required String email}) async {
    try {
      final response = await _authApiService.forgotPassword(email: email);
      final data = _asMap(response.data);

      if (data['success'] == false) {
        return AuthResult(
          success: false,
          message: _messageFrom(data) ??
              _validationMessageFrom(data) ??
              'Please check your email and try again.',
        );
      }

      return AuthResult(
        success: true,
        message: _messageFrom(data) ?? 'Password reset instructions sent.',
      );
    } on DioException catch (error) {
      return AuthResult(success: false, message: _parseDioError(error));
    } catch (_) {
      return const AuthResult(
        success: false,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  Future<void> logout() async {
    try {
      await _authApiService.logout();
    } catch (_) {
      // Logging out locally still matters if the remote call fails.
    } finally {
      await _tokenStorage.clearAll();
    }
  }

  Future<bool> isLoggedIn() => _tokenStorage.hasAccessToken();

  /// Verifies the stored session is still accepted by the backend.
  /// Clears tokens and returns false if the session is expired or invalid.
  /// Returns true on network errors so users aren't kicked out for poor connectivity
  /// unless [allowNetworkFallback] is false.
  Future<bool> validateSession({bool allowNetworkFallback = true}) async {
    final accessToken = await _tokenStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) return false;

    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _tokenStorage.clearAll();
      return false;
    }

    try {
      final response = await _authApiService.refreshSession(refreshToken);
      final data = _asMap(response.data);

      final newAccessToken = _stringValue(data, const ['access_token', 'accessToken', 'token']);
      if (newAccessToken != null && newAccessToken.isNotEmpty) {
        final newRefresh = _stringValue(data, const ['refresh_token', 'refreshToken']);
        await _tokenStorage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefresh ?? refreshToken,
        );
        return true;
      }

      await _tokenStorage.clearAll();
      return false;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401 || status == 403) {
        await _tokenStorage.clearAll();
        return false;
      }
      // Network/server error — don't kick the user out, let the app try normally.
      return allowNetworkFallback;
    } catch (_) {
      return allowNetworkFallback;
    }
  }

  Future<AuthResult> _handleAuthResponse(
    dynamic responseData, {
    required String defaultMessage,
  }) async {
    final data = _asMap(responseData);
    if (data['success'] == false) {
      return AuthResult(
        success: false,
        message: _messageFrom(data) ??
            _validationMessageFrom(data) ??
            'Please check your details and try again.',
      );
    }

    final payload = _payloadFrom(data);
    final accessToken = _stringValue(payload, const [
      'token',
      'access_token',
      'accessToken',
    ]);
    final refreshToken = _stringValue(payload, const [
      'refresh_token',
      'refreshToken',
    ]);

    if (accessToken != null && accessToken.isNotEmpty) {
      await _tokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken ?? '',
      );
    }

    final userMap = _mapValue(payload, 'user') ?? _mapValue(data, 'user');
    if (userMap != null && userMap.isNotEmpty) {
      await _tokenStorage.saveUser(UserModel.fromMap(userMap));
    }

    return AuthResult(
      success: true,
      message: _messageFrom(data) ?? defaultMessage,
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: userMap,
    );
  }

  Future<UserModel?> getUser() => _tokenStorage.getUser();

  String _parseDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        if (error.response == null) {
          return 'Network failure: ${error.message ?? error.type.name}.';
        }
        break;
      case DioExceptionType.badCertificate:
        return 'Secure connection failed. Please try again later.';
      case DioExceptionType.cancel:
        return 'Request cancelled. Please try again.';
      case DioExceptionType.badResponse:
        break;
    }

    final statusCode = error.response?.statusCode;
    final data = _asMap(error.response?.data);
    final message = _messageFrom(data) ?? _validationMessageFrom(data);

    if (statusCode == 401 || statusCode == 403) {
      return message ?? 'Invalid credentials. Please check your email and password.';
    }
    if (statusCode == 422 || statusCode == 400) {
      return message ?? 'Please check your details and try again.';
    }
    if (statusCode != null && statusCode >= 500) {
      return 'Server error. Please try again later.';
    }

    return message ?? 'Something went wrong. Please try again.';
  }

  Map<String, dynamic> _payloadFrom(Map<String, dynamic> data) {
    final nestedData = _mapValue(data, 'data');
    return nestedData ?? data;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return const {};
  }

  Map<String, dynamic>? _mapValue(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  String? _stringValue(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }

  String? _messageFrom(Map<String, dynamic> data) {
    return _stringValue(data, const ['message', 'error', 'detail']);
  }

  String? _validationMessageFrom(Map<String, dynamic> data) {
    final errors = data['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final firstValue = errors.values.first;
      if (firstValue is List && firstValue.isNotEmpty) {
        return firstValue.first.toString();
      }
      return firstValue.toString();
    }
    return null;
  }
}
