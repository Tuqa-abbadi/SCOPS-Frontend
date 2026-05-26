import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';

class PaymentApiService {
  const PaymentApiService({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<Response<dynamic>> createPaymentIntent(int serviceId) =>
      _dio.post(ApiConstants.createPaymentIntent(serviceId));

  Future<Response<dynamic>> confirmPayment(
    int paymentId, {
    String? clientSecret,
  }) =>
      _dio.post(
        ApiConstants.confirmPayment(paymentId),
        data: (clientSecret != null && clientSecret.isNotEmpty)
            ? {'client_secret': clientSecret}
            : null,
      );
}
