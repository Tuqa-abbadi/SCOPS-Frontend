import 'package:dio/dio.dart';

import '../core/network/dio_client.dart';
import '../models/card_model.dart';
import '../services/cards_api_service.dart';

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

class CardsRepository {
  CardsRepository({CardsApiService? service})
      : _service = service ?? CardsApiService(dio: DioClient.instance.dio);

  final CardsApiService _service;

  Future<CardsResult> fetchCards() async {
    try {
      final response = await _service.getCards();
      return CardsResult(success: true, cards: _parseList(response.data));
    } on DioException catch (e) {
      return CardsResult(success: false, message: _parseDioError(e));
    } catch (_) {
      return const CardsResult(
          success: false, message: 'Something went wrong. Please try again.');
    }
  }

  Future<CardsResult> addCard({
    required String cardHolderName,
    required String cardNumber,
    required int expiryMonth,
    required int expiryYear,
  }) async {
    try {
      await _service.addCard(
        cardHolderName: cardHolderName,
        cardNumber: cardNumber,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
      );
      return fetchCards();
    } on DioException catch (e) {
      return CardsResult(success: false, message: _parseDioError(e));
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
      return CardsResult(success: false, message: _parseDioError(e));
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
      return CardsResult(success: false, message: _parseDioError(e));
    } catch (_) {
      return const CardsResult(
          success: false, message: 'Something went wrong. Please try again.');
    }
  }

  List<CardModel> _parseList(dynamic data) {
    List<dynamic> raw = [];
    if (data is List) {
      raw = data;
    } else if (data is Map) {
      final d = data['data'];
      final c = data['cards'];
      if (d is List) { raw = d; }
      else if (c is List) { raw = c; }
    }
    return raw.whereType<Map<String, dynamic>>().map(CardModel.fromJson).toList();
  }

  String _parseDioError(DioException error) {
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
    if (data is Map) return data['message'] as String? ?? 'Something went wrong.';
    return 'Something went wrong.';
  }
}
