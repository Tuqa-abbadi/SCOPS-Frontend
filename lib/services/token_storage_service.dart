import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class _Keys {
  static const accessToken = 'access_token';
  static const refreshToken = 'refresh_token';
}

class TokenStorageService {
  TokenStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  final FlutterSecureStorage _storage;

  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _Keys.accessToken, value: token);

  Future<String?> getAccessToken() =>
      _storage.read(key: _Keys.accessToken);

  Future<void> deleteAccessToken() =>
      _storage.delete(key: _Keys.accessToken);

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _Keys.refreshToken, value: token);

  Future<String?> getRefreshToken() =>
      _storage.read(key: _Keys.refreshToken);

  Future<void> deleteRefreshToken() =>
      _storage.delete(key: _Keys.refreshToken);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      saveAccessToken(accessToken),
      saveRefreshToken(refreshToken),
    ]);
  }

  Future<void> clearAll() async {
    await Future.wait([
      deleteAccessToken(),
      deleteRefreshToken(),
    ]);
  }

  Future<bool> hasAccessToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}