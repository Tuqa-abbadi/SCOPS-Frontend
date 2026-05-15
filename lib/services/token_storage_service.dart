import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user_model.dart';

class _Keys {
  static const accessToken = 'access_token';
  static const refreshToken = 'refresh_token';
  static const userData = 'user_data';
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

  Future<void> saveUser(UserModel user) =>
      _storage.write(key: _Keys.userData, value: jsonEncode(user.toMap()));

  Future<UserModel?> getUser() async {
    final raw = await _storage.read(key: _Keys.userData);
    if (raw == null) return null;
    try {
      return UserModel.fromMap(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteUser() => _storage.delete(key: _Keys.userData);

  Future<void> clearAll() async {
    await Future.wait([
      deleteAccessToken(),
      deleteRefreshToken(),
      deleteUser(),
    ]);
  }

  Future<bool> hasAccessToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}