import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';

class AdminApiService {
  const AdminApiService({required Dio dio}) : _dio = dio;

  final Dio _dio;

  // ── Statistics ────────────────────────────────────────────────────────────

  Future<Response<dynamic>> getStatistics() =>
      _dio.get(ApiConstants.adminStatistics);

  // ── Users ─────────────────────────────────────────────────────────────────

  Future<Response<dynamic>> getUsers() =>
      _dio.get(ApiConstants.adminUsers);

  Future<Response<dynamic>> createUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String role = 'user',
    String? phone,
  }) =>
      _dio.post(ApiConstants.adminUsers, data: {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'role': role,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      });

  Future<Response<dynamic>> updateUser(
    String id, {
    String? firstName,
    String? lastName,
    String? email,
    String? role,
    String? phone,
  }) {
    final body = <String, dynamic>{};
    if (firstName != null) body['first_name'] = firstName;
    if (lastName != null) body['last_name'] = lastName;
    if (email != null) body['email'] = email;
    if (role != null) body['role'] = role;
    if (phone != null && phone.isNotEmpty) body['phone'] = phone;
    return _dio.put(ApiConstants.adminUserById(id), data: body);
  }

  Future<Response<dynamic>> deleteUser(String id) =>
      _dio.delete(ApiConstants.adminUserById(id));

  Future<Response<dynamic>> toggleUser(String id) =>
      _dio.put(ApiConstants.adminUserToggle(id));

  Future<Response<dynamic>> resetUserPassword(String id, String newPassword) =>
      _dio.put(ApiConstants.adminUserResetPassword(id), data: {
        'password': newPassword,
        'password_confirmation': newPassword,
      });

  Future<Response<dynamic>> getUserSubscriptions(String id) =>
      _dio.get(ApiConstants.adminUserSubscriptions(id));

  Future<Response<dynamic>> getCategories() =>
      _dio.get(ApiConstants.categories);

  // ── Services ──────────────────────────────────────────────────────────────

  Future<Response<dynamic>> getServices() =>
      _dio.get(ApiConstants.adminServices);

  Future<Response<dynamic>> createService({
    required String name,
    required double defaultAmount,
    required String billingCycle,
    String? description,
    int? categoryId,
    String? logoUrl,
  }) {
    final body = <String, dynamic>{
      'name': name,
      'default_amount': defaultAmount,
      'billing_cycle': billingCycle,
    };
    if (description != null && description.isNotEmpty) {
      body['description'] = description;
    }
    if (categoryId != null) body['category_id'] = categoryId;
    if (logoUrl != null && logoUrl.isNotEmpty) body['logo_url'] = logoUrl;
    return _dio.post(ApiConstants.adminServices, data: body);
  }

  Future<Response<dynamic>> updateService(
    int id, {
    String? name,
    double? defaultAmount,
    String? billingCycle,
    String? description,
    int? categoryId,
    String? logoUrl,
  }) {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (defaultAmount != null) body['default_amount'] = defaultAmount;
    if (billingCycle != null) body['billing_cycle'] = billingCycle;
    if (description != null) body['description'] = description;
    if (categoryId != null) body['category_id'] = categoryId;
    if (logoUrl != null) body['logo_url'] = logoUrl;
    return _dio.put(ApiConstants.adminServiceById(id), data: body);
  }

  Future<Response<dynamic>> deleteService(int id) =>
      _dio.delete(ApiConstants.adminServiceById(id));
}
