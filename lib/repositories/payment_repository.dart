import 'package:dio/dio.dart';

import '../core/network/dio_client.dart';
import '../models/payment_intent_model.dart';
import '../services/payment_api_service.dart';

class PaymentIntentResult {
  const PaymentIntentResult({
    required this.success,
    required this.message,
    this.intent,
  });

  final bool success;
  final String message;
  final PaymentIntentModel? intent;
}

class ConfirmPaymentResult {
  const ConfirmPaymentResult({
    required this.success,
    required this.message,
  });

  final bool success;
  final String message;
}

// ignore: avoid_print
void _log(String msg) => print('[PaymentRepository] $msg');

class PaymentRepository {
  PaymentRepository({PaymentApiService? service})
      : _service = service ?? PaymentApiService(dio: DioClient.instance.dio);

  final PaymentApiService _service;

  Future<PaymentIntentResult> createPaymentIntent(int serviceId) async {
    try {
      final response = await _service.createPaymentIntent(serviceId);
      _log('Raw response: ${response.data}');
      final data = _extractData(response.data);
      _log('Extracted data: $data');
      final intent = PaymentIntentModel.fromJson(data);
      _log('Parsed intent — paymentId=${intent.paymentId}');
      return PaymentIntentResult(
        success: true,
        message: 'Payment intent created.',
        intent: intent,
      );
    } on DioException catch (e) {
      _log('DioException: $e');
      return PaymentIntentResult(success: false, message: _dioError(e));
    } catch (e) {
      _log('Parse error: $e');
      return PaymentIntentResult(
        success: false,
        message: 'Failed to read payment response: $e',
      );
    }
  }

  Future<ConfirmPaymentResult> confirmPayment(
    int paymentId, {
    String clientSecret = '',
  }) async {
    try {
      _log('Confirm request — paymentId=$paymentId clientSecret=$clientSecret');
      await _service.confirmPayment(paymentId, clientSecret: clientSecret);
      return const ConfirmPaymentResult(
        success: true,
        message: 'Payment confirmed successfully.',
      );
    } on DioException catch (e) {
      return ConfirmPaymentResult(success: false, message: _dioError(e));
    } catch (e) {
      return const ConfirmPaymentResult(
        success: false,
        message: 'Failed to confirm payment.',
      );
    }
  }

  Map<String, dynamic> _extractData(dynamic raw) {
    if (raw is Map) {
      final map = raw.map((k, v) => MapEntry(k.toString(), v));

      // Top-level match — backend returned the object directly
      if (_hasPaymentFields(map)) return map;

      // Nested under a wrapper key
      for (final key in const [
        'data', 'payload', 'result', 'payment', 'intent', 'transaction',
      ]) {
        final val = map[key];
        if (val is Map) {
          final nested = val.map((k, v) => MapEntry(k.toString(), v));
          if (_hasPaymentFields(nested)) return nested;
        }
      }

      // Last resort: return the whole map and let fromJson extract what it can
      _log('Warning: no recognised wrapper — passing full map to fromJson');
      return map;
    }
    throw FormatException('Unexpected payment response type: ${raw.runtimeType}');
  }

  bool _hasPaymentFields(Map<String, dynamic> m) =>
      (m.containsKey('client_secret') || m.containsKey('clientSecret')) &&
      (m.containsKey('payment_id') || m.containsKey('id') ||
          m.containsKey('paymentId'));

  String _dioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        if (e.response == null) {
          return 'Network error. Please check your connection.';
        }
        break;
      case DioExceptionType.badCertificate:
        return 'Secure connection failed.';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.badResponse:
        break;
    }
    final status = e.response?.statusCode;
    if (status == 401 || status == 403) {
      return 'Session expired. Please log in again.';
    }
    if (status != null && status >= 500) {
      return 'Server error. Please try again later.';
    }
    final data = e.response?.data;
    if (data is Map) {
      return data['message'] as String? ?? 'Something went wrong.';
    }
    return 'Something went wrong. Please try again.';
  }
}
