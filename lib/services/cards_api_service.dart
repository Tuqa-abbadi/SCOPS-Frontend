import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';

class CardsApiService {
  const CardsApiService({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<Response<dynamic>> getCards() => _dio.get(ApiConstants.cards);

  /// POST /api/cards/setup-intent — returns {client_secret, customer_id}
  Future<Response<dynamic>> createSetupIntent() =>
      _dio.post(ApiConstants.cardsSetupIntent);

  /// POST /api/cards — saves the Stripe payment method to the backend
  Future<Response<dynamic>> saveStripeCard({
    required String paymentMethodId,
    required String cardHolderName,
  }) {
    final normalizedPaymentMethodId = paymentMethodId.trim();
    final normalizedCardHolderName = cardHolderName.trim();

    final data = {
      'stripe_payment_method_id': normalizedPaymentMethodId,
      'card_holder_name': normalizedCardHolderName,
    };

    // ignore: avoid_print
    print('[CardsApiService] POST ${ApiConstants.cards} data=$data');

    return _dio.post(
      ApiConstants.cards,
      data: data,
      options: Options(contentType: Headers.jsonContentType),
    );
  }

  Future<Response<dynamic>> deleteCard(String cardId) =>
      _dio.delete(ApiConstants.cardById(cardId));

  Future<Response<dynamic>> setPrimaryCard(String cardId) =>
      _dio.patch(ApiConstants.cardPrimary(cardId), data: {'is_primary': true});
}
