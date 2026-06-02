import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';

class PaymentApiService {
  const PaymentApiService({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<Response<dynamic>> createPaymentIntent(
    int serviceId, {
    int? planId,
    String? serviceAccountEmail,
  }) {
    final body = <String, dynamic>{};
    if (planId != null) body['plan_id'] = planId;
    if (serviceAccountEmail != null && serviceAccountEmail.isNotEmpty) {
      body['email'] = serviceAccountEmail;
    }
    return _dio.post(
      ApiConstants.createPaymentIntent(serviceId),
      data: body.isEmpty ? null : body,
    );
  }

  Future<Response<dynamic>> confirmPayment(
    int paymentId, {
    String? clientSecret,
  }) =>
      _dio.post(ApiConstants.confirmPayment(paymentId));
}
