import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';

class CardsApiService {
  const CardsApiService({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<Response<dynamic>> getCards() => _dio.get(ApiConstants.cards);

  Future<Response<dynamic>> addCard({
    required String cardHolderName,
    required String cardNumber,
    required int expiryMonth,
    required int expiryYear,
  }) =>
      _dio.post(
        ApiConstants.cards,
        data: {
          'card_holder_name': cardHolderName,
          'card_number': cardNumber,
          'expiry_month': expiryMonth,
          'expiry_year': expiryYear,
        },
      );

  Future<Response<dynamic>> deleteCard(String cardId) =>
      _dio.delete(ApiConstants.cardById(cardId));

  Future<Response<dynamic>> setPrimaryCard(String cardId) =>
      _dio.patch(ApiConstants.cardPrimary(cardId), data: {'is_primary': true});
}
