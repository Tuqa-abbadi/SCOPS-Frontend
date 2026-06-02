import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';

class AuthApiService {
  const AuthApiService({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<Response<dynamic>> login({
    required String email,
    required String password,
  }) {
    return _dio.post(
      ApiConstants.login,
      data: {
        'email': email,
        'password': password,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
  }

  Future<Response<dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) {
    return _dio.post(
      ApiConstants.register,
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'password': password,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
  }

  Future<Response<dynamic>> verifyEmail({
    required String email,
    required String token,
  }) {
    return _dio.post(
      ApiConstants.verifyEmail,
      data: {
        'email': email,
        'token': token,
        'code': token,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
  }

  Future<Response<dynamic>> forgotPassword({required String email}) {
    return _dio.post(
      ApiConstants.forgotPassword,
      data: {'email': email},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
  }

  Future<Response<dynamic>> verifyResetCode({
    required String email,
    required String token,
  }) {
    return _dio.post(
      ApiConstants.verifyResetCode,
      data: {'email': email, 'token': token},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
  }

  Future<Response<dynamic>> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) {
    return _dio.post(
      ApiConstants.resetPassword,
      data: {
        'email': email,
        'token': token,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
  }

  Future<Response<dynamic>> logout() {
    return _dio.post(ApiConstants.logout);
  }

  Future<Response<dynamic>> refreshSession(String refreshToken) {
    final freshDio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ));
    return freshDio.post(
      ApiConstants.refreshToken,
      data: {'refresh_token': refreshToken},
    );
  }

}
