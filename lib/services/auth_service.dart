import '../repositories/auth_repository.dart';

@Deprecated('Use AuthRepository or AuthApiService for authentication calls.')
class AuthService {
  AuthService({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  final AuthRepository _authRepository;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final result = await _authRepository.login(
      email: email,
      password: password,
    );

    return _toMap(result);
  }

  Future<Map<String, dynamic>> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final result = await _authRepository.signup(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      password: password,
    );

    return _toMap(result);
  }

  Map<String, dynamic> _toMap(AuthResult result) {
    return {
      'success': result.success,
      'message': result.message,
      'token': result.accessToken,
      'refresh_token': result.refreshToken,
      'user': result.user,
    };
  }
}
