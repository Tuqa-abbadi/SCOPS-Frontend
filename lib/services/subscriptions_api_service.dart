import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';

class SubscriptionsApiService {
  const SubscriptionsApiService({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<Response<dynamic>> getSubscriptions({
    String? status,
    String? search,
    String? billingCycle,
    String? sortBy,
    String? sortOrder,
  }) {
    final params = <String, dynamic>{};
    if (status != null && status.isNotEmpty) params['status'] = status;
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (billingCycle != null && billingCycle.isNotEmpty) {
      params['billing_cycle'] = billingCycle;
    }
    if (sortBy != null && sortBy.isNotEmpty) params['sort_by'] = sortBy;
    if (sortOrder != null && sortOrder.isNotEmpty) {
      params['sort_order'] = sortOrder;
    }
    return _dio.get(
      ApiConstants.subscriptions,
      queryParameters: params.isEmpty ? null : params,
    );
  }

  Future<Response<dynamic>> createSubscription({
    required int serviceId,
    int? planId,
    int? cardId,
    int? paymentId,
    required double amount,
    required String billingCycle,
    required String startDate,
    required String renewalDate,
    required int reminderDays,
    String priority = 'medium',
    String? serviceAccountEmail,
  }) {
    final body = <String, dynamic>{
      'service_id': serviceId,
      'amount': amount,
      'billing_cycle': billingCycle,
      'start_date': startDate,
      'renewal_date': renewalDate,
      'reminder_days': reminderDays,
      'priority': priority,
    };
    if (planId != null) body['plan_id'] = planId;
    if (cardId != null) body['card_id'] = cardId;
    if (paymentId != null) body['payment_id'] = paymentId;
    if (serviceAccountEmail != null && serviceAccountEmail.isNotEmpty) {
      body['service_account_email'] = serviceAccountEmail;
    }
    return _dio.post(ApiConstants.subscriptions, data: body);
  }

  Future<Response<dynamic>> cancelSubscription(int id) =>
      _dio.put(ApiConstants.subscriptionCancel(id));

  Future<Response<dynamic>> pauseSubscription(int id) =>
      _dio.put(ApiConstants.subscriptionPause(id));

  Future<Response<dynamic>> resumeSubscription(int id) =>
      _dio.put(ApiConstants.subscriptionResume(id));

  Future<Response<dynamic>> getSubscriptionRenewal(int id) =>
      _dio.get(ApiConstants.subscriptionRenewal(id));
}
