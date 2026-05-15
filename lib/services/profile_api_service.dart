import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';

class ProfileApiService {
  const ProfileApiService({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<Response<dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) =>
      _dio.post(
        ApiConstants.changePassword,
        data: {
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': newPasswordConfirmation,
        },
      );
}
