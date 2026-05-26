import '../config/app_config.dart';

class ApiConstants {
  static const String baseUrl = AppConfig.apiBaseUrl;

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

  // Payments
  static String createPaymentIntent(int serviceId) => 'payments/$serviceId';
  static String confirmPayment(int paymentId) => 'payments/confirm/$paymentId';

  // Cards – Stripe SetupIntent
  static const String cardsSetupIntent = 'cards/setup-intent';

  // Reviews
  static const String reviews = 'reviews';
  static String reviewsForService(int serviceId) => 'reviews/$serviceId';

  // Admin
  static const String adminStatistics = 'admin/statistics';
  static const String adminUsers = 'admin/users';
  static String adminUserById(String id) => 'admin/users/$id';
  static String adminUserToggle(String id) => 'admin/users/$id/toggle';
  static String adminUserResetPassword(String id) => 'admin/users/$id/reset-password';
  static String adminUserSubscriptions(String id) => 'admin/users/$id/subscriptions';
  static const String adminServices = 'admin/services';
  static String adminServiceById(int id) => 'admin/services/$id';
}
