import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';

class ReviewsApiService {
  const ReviewsApiService({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<Response<dynamic>> getReviewsForService(int serviceId) =>
      _dio.get(ApiConstants.reviewsForService(serviceId));

  Future<Response<dynamic>> createReview({
    required int subscriptionId,
    required int rating,
    String? comment,
  }) =>
      _dio.post(ApiConstants.reviews, data: {
        'subscription_id': subscriptionId,
        'rating': rating,
        if (comment != null) 'comment': comment,
      });
}
