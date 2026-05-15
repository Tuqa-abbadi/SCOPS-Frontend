import '../config/app_config.dart';

class ApiConstants {
  static String get baseUrl => AppConfig.apiBaseUrl;

  static const String login = 'logIn';
  static const String register = 'register';
  static const String forgotPassword = 'forgot-password';
  static const String logout = 'logout';
  static const String refreshToken = 'auth/refresh';

  static const String changePassword = 'profile/change-password';

  static const String cards = 'cards';
  static String cardById(String id) => 'cards/$id';
  static String cardPrimary(String id) => 'cards/$id/primary';
}
