import '../config/app_config.dart';

class ApiConstants {
  static String get baseUrl => AppConfig.apiBaseUrl;

  static const String login = 'logIn';
  static const String register = 'register';
  static const String forgotPassword = 'forgot-password';
  static const String logout = 'logout';
  static const String refreshToken = 'auth/refresh';

  static const String changePassword = 'profile/change-password';

  static const String categories = 'categories';
  static const String services = 'services';

  static const String cards = 'cards';
  static String cardById(String id) => 'cards/$id';
  static String cardPrimary(String id) => 'cards/$id/primary';

  static String serviceById(int id) => 'services/$id';

  // Fallback ①: sub-resource  GET /api/services/{id}/plans
  static String servicePlans(int id) => 'services/$id/plans';

  // Fallback ②: standalone resource  GET /api/service-plans?service_id={id}
  static const String servicePlansList = 'service-plans';

  // Subscriptions
  static const String subscriptions = 'subscriptions';
  static String subscriptionById(int id) => 'subscriptions/$id';
  static String subscriptionCancel(int id) => 'subscriptions/$id/cancel';
  static String subscriptionPause(int id) => 'subscriptions/$id/pause';
  static String subscriptionResume(int id) => 'subscriptions/$id/resume';
  static String subscriptionRenewal(int id) => 'subscriptions/$id/renewal';
}
