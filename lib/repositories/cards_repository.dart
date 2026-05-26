import 'dart:async';

import 'package:dio/dio.dart';

import '../core/network/dio_client.dart';
import '../models/card_model.dart';
import '../services/cards_api_service.dart';

// ignore: avoid_print
void _log(String msg) => print('[CardsRepository] $msg');

class CardsResult {
  const CardsResult({
    required this.success,
    this.cards,
    this.message,
  });

  final bool success;
  final List<CardModel>? cards;
  final String? message;
}

class SetupIntentResult {
  const SetupIntentResult({
    required this.success,
    required this.message,
    this.clientSecret,
    this.customerId,
    this.customerEphemeralKeySecret,
  });

  final bool success;
  final String message;
  final String? clientSecret;
  final String? customerId;
  final String? customerEphemeralKeySecret;
}

class CardsRepository {
  CardsRepository({CardsApiService? service})
      : _service = service ?? CardsApiService(dio: DioClient.instance.dio);

  final CardsApiService _service;

  // ── Setup Intent ─────────────────────────────────────────────────────────

  Future<SetupIntentResult> createCardSetupIntent() async {
    try {
      final response = await _service
          .createSetupIntent()
          .timeout(const Duration(seconds: 30));
      _log('Setup intent raw: ${response.data}');
      final map = _toMap(response.data);
      final secret = _stringValue(map, const [
            'client_secret',
            'clientSecret',
            'setup_intent_client_secret',
            'setupIntentClientSecret',
          ]) ??
          '';
      final customerId = map['customer_id'] as String? ??
          map['customerId'] as String? ??
          '';
      final ephemeralKey = _stringValue(map, const [
            'ephemeral_key',
            'ephemeralKey',
            'ephemeral_key_secret',
            'ephemeralKeySecret',
            'customer_ephemeral_key_secret',
            'customerEphemeralKeySecret',
          ]) ??
          '';
      if (secret.isEmpty) {
        return const SetupIntentResult(
          success: false,
          message: 'No client_secret in setup intent response.',
        );
      }
      return SetupIntentResult(
        success: true,
        message: 'Setup intent created.',
        clientSecret: secret,
        customerId: customerId.isEmpty ? null : customerId,
        customerEphemeralKeySecret: ephemeralKey.isEmpty ? null : ephemeralKey,
      );
    } on DioException catch (e) {
      return SetupIntentResult(success: false, message: _dioError(e));
    } on TimeoutException {
      return const SetupIntentResult(
        success: false,
        message: 'Card setup request timed out. Please try again.',
      );
    } catch (e) {
      _log('Setup intent parse error: $e');
      return SetupIntentResult(
        success: false,
        message: 'Failed to create setup intent: $e',
      );
    }
  }

  // ── Save Stripe Card ──────────────────────────────────────────────────────

  Future<CardsResult> saveStripeCard({
    required String paymentMethodId,
    required String cardHolderName,
  }) async {
    try {
      _log('Saving card — pm=$paymentMethodId holder=$cardHolderName');
      await _service
          .saveStripeCard(
            paymentMethodId: paymentMethodId,
            cardHolderName: cardHolderName,
          )
          .timeout(const Duration(seconds: 15));

      return fetchCards().timeout(const Duration(seconds: 15));
    } on DioException catch (e) {
      return CardsResult(success: false, message: _dioError(e));
    } on TimeoutException {
      return const CardsResult(
        success: false,
        message: 'Saving card timed out. Please try again.',
      );
    } catch (_) {
      return const CardsResult(
          success: false, message: 'Something went wrong. Please try again.');
    }
  }

  // ── Fetch / Delete / Primary ──────────────────────────────────────────────

  Future<CardsResult> fetchCards() async {
    try {
      final response = await _service.getCards();
      return CardsResult(success: true, cards: _parseList(response.data));
    } on DioException catch (e) {
      return CardsResult(success: false, message: _dioError(e));
    } catch (_) {
      return const CardsResult(
          success: false, message: 'Something went wrong. Please try again.');
    }
  }

  Future<CardsResult> deleteCard(String cardId) async {
    try {
      await _service.deleteCard(cardId);
      return fetchCards();
    } on DioException catch (e) {
      return CardsResult(success: false, message: _dioError(e));
    } catch (_) {
      return const CardsResult(
          success: false, message: 'Something went wrong. Please try again.');
    }
  }

  Future<CardsResult> setPrimaryCard(String cardId) async {
    try {
      await _service.setPrimaryCard(cardId);
      return fetchCards();
    } on DioException catch (e) {
      return CardsResult(success: false, message: _dioError(e));
    } catch (_) {
      return const CardsResult(
          success: false, message: 'Something went wrong. Please try again.');
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Map<String, dynamic> _toMap(dynamic raw) {
    if (raw is Map) {
      final top = raw.map((k, v) => MapEntry(k.toString(), v));
      // Unwrap common wrapper keys
      for (final key in const ['data', 'payload', 'result']) {
        final val = top[key];
        if (val is Map) return val.map((k, v) => MapEntry(k.toString(), v));
      }
      return top;
    }
    return {};
  }

  String? _stringValue(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }

  List<CardModel> _parseList(dynamic data) {
    List<dynamic> raw = [];
    if (data is List) {
      raw = data;
    } else if (data is Map) {
      final d = data['data'];
      final c = data['cards'];
      if (d is List) {
        raw = d;
      } else if (c is List) {
        raw = c;
      }
    }
    return raw.whereType<Map<String, dynamic>>().map(CardModel.fromJson).toList();
  }

  CardModel? _parseCard(dynamic data) {
    if (data is Map) {
      final map = data.map((k, v) => MapEntry(k.toString(), v));
      final nested = map['data'];
      if (nested is Map) {
        return CardModel.fromJson(
          nested.map((k, v) => MapEntry(k.toString(), v)),
        );
      }
      if (map.containsKey('card_id') || map.containsKey('id')) {
        return CardModel.fromJson(map);
      }
    }
    return null;
  }

  String _dioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        if (error.response == null) {
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
    final statusCode = error.response?.statusCode;
    if (statusCode == 401 || statusCode == 403) {
      return 'Session expired. Please log in again.';
    }
    if (statusCode != null && statusCode >= 500) {
      return 'Server error. Please try again later.';
    }
    final data = error.response?.data;
    if (data is Map) {
      final message = data['message'] as String?;
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
        return first.toString();
      }
      return message ?? 'Something went wrong.';
    }
    return 'Something went wrong.';
  }
}
