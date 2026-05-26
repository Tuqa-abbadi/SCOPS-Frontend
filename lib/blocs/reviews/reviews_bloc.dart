import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/dio_client.dart';
import '../../models/review_model.dart';
import '../../services/reviews_api_service.dart';
import '../subscription/subscription_bloc.dart';

part 'reviews_event.dart';
part 'reviews_state.dart';

// ignore: avoid_print
void _log(String msg) => print('[ReviewsBloc] $msg');

class ReviewsBloc extends Bloc<ReviewsEvent, ReviewsState> {
  ReviewsBloc({ReviewsApiService? reviewsService})
      : _reviewsService = reviewsService ??
            ReviewsApiService(dio: DioClient.instance.dio),
        super(const ReviewsInitial()) {
    on<ReviewsForServiceRequested>(_onForServiceRequested);
    on<PendingReviewsRequested>(_onPendingRequested);
    on<ReviewSubmitRequested>(_onSubmitRequested);
    on<ReviewSubmitReset>(_onSubmitReset);
  }

  final ReviewsApiService _reviewsService;

  // ── Load reviews for the service detail sheet ─────────────────────────────

  Future<void> _onForServiceRequested(
    ReviewsForServiceRequested event,
    Emitter<ReviewsState> emit,
  ) async {
    final current = _data ?? const ReviewsData();
    emit(current.copyWith(
      detailServiceId: event.serviceId,
      detailLoading: true,
      clearDetailError: true,
      detailReviews: const [],
    ));

    try {
      final response =
          await _reviewsService.getReviewsForService(event.serviceId);
      final reviews = _parseReviews(response.data);
      _log('Loaded ${reviews.length} reviews for service ${event.serviceId}');

      final reviewed = Set<int>.from(current.reviewedSubscriptionIds)
        ..addAll(reviews.map((r) => r.subscriptionId));

      emit(current.copyWith(
        detailServiceId: event.serviceId,
        detailReviews: reviews,
        detailLoading: false,
        clearDetailError: true,
        reviewedSubscriptionIds: reviewed,
      ));
    } on DioException catch (e) {
      _log('Load reviews error: $e');
      emit(current.copyWith(
        detailServiceId: event.serviceId,
        detailLoading: false,
        detailError: _dioError(e),
      ));
    } catch (e) {
      _log('Unexpected load reviews error: $e');
      emit(current.copyWith(
        detailServiceId: event.serviceId,
        detailLoading: false,
        detailError: 'Failed to load reviews.',
      ));
    }
  }

  // ── Check which subscriptions are pending review (Profile page) ───────────

  Future<void> _onPendingRequested(
    PendingReviewsRequested event,
    Emitter<ReviewsState> emit,
  ) async {
    final current = _data ?? const ReviewsData();
    emit(current.copyWith(pendingLoading: true, clearPendingError: true));

    // Only check active subscriptions that started ≥7 days ago (or renewed).
    final eligible =
        event.subscriptions.where(_isEligibleForReview).toList();
    final uniqueServiceIds = eligible.map((s) => s.serviceId).toSet();

    final reviewed = Set<int>.from(current.reviewedSubscriptionIds);
    final myReviews = <ReviewModel>[...current.myReviews];

    for (final serviceId in uniqueServiceIds) {
      try {
        final response =
            await _reviewsService.getReviewsForService(serviceId);
        final reviews = _parseReviews(response.data);
        reviewed.addAll(reviews.map((r) => r.subscriptionId));

        // Collect the user's own reviews (subscription IDs that belong to them).
        final userSubIds = eligible
            .where((s) => s.serviceId == serviceId)
            .map((s) => s.apiId)
            .toSet();
        myReviews.addAll(
            reviews.where((r) => userSubIds.contains(r.subscriptionId)));
      } catch (e) {
        _log('Pending check fetch error for service $serviceId: $e');
      }
    }

    // Deduplicate by review id.
    final seen = <int>{};
    final dedupedMyReviews =
        myReviews.where((r) => seen.add(r.id)).toList();

    emit((_data ?? current).copyWith(
      pendingLoading: false,
      reviewedSubscriptionIds: reviewed,
      myReviews: dedupedMyReviews,
    ));
  }

  // ── Submit a review ───────────────────────────────────────────────────────

  Future<void> _onSubmitRequested(
    ReviewSubmitRequested event,
    Emitter<ReviewsState> emit,
  ) async {
    final current = _data ?? const ReviewsData();
    if (current.isSubmitting) return;

    emit(current.copyWith(
      isSubmitting: true,
      clearSubmitError: true,
      submitSuccess: false,
    ));

    try {
      await _reviewsService.createReview(
        subscriptionId: event.subscriptionId,
        rating: event.rating,
        comment: event.comment,
      );
      _log('Review submitted for service ${event.serviceId}');

      final reviewed = Set<int>.from((_data ?? current).reviewedSubscriptionIds)
        ..add(event.subscriptionId);

      // Re-fetch to get the freshly created review object.
      List<ReviewModel> updatedReviews =
          (_data ?? current).detailReviews;
      try {
        final response =
            await _reviewsService.getReviewsForService(event.serviceId);
        updatedReviews = _parseReviews(response.data);
        reviewed.addAll(updatedReviews.map((r) => r.subscriptionId));
      } catch (e) {
        _log('Re-fetch after submit failed (non-fatal): $e');
      }

      emit((_data ?? current).copyWith(
        isSubmitting: false,
        submitSuccess: true,
        reviewedSubscriptionIds: reviewed,
        detailReviews: updatedReviews,
      ));
    } on DioException catch (e) {
      _log('Submit review error: $e');
      emit((_data ?? current).copyWith(
        isSubmitting: false,
        submitError: _dioError(e),
        submitSuccess: false,
      ));
    } catch (e) {
      _log('Submit review unexpected error: $e');
      emit((_data ?? current).copyWith(
        isSubmitting: false,
        submitError: 'Failed to submit review. Please try again.',
        submitSuccess: false,
      ));
    }
  }

  // ── Reset submit flags ────────────────────────────────────────────────────

  void _onSubmitReset(ReviewSubmitReset _, Emitter<ReviewsState> emit) {
    final current = _data;
    if (current == null) return;
    emit(current.copyWith(
      submitSuccess: false,
      clearSubmitError: true,
    ));
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  ReviewsData? get _data =>
      state is ReviewsData ? state as ReviewsData : null;

  bool _isEligibleForReview(SubscriptionModel sub) {
    if (!sub.isActive) return false;
    final startDate = sub.startDate;
    if (startDate == null) return false;
    final daysSinceStart = DateTime.now().difference(startDate).inDays;
    if (daysSinceStart >= 7) return true;
    // Also eligible if the subscription has completed at least one renewal.
    if (sub.nextRenewal.isBefore(DateTime.now())) return true;
    return false;
  }

  List<ReviewModel> _parseReviews(dynamic data) {
    final list = _extractList(data);
    final result = <ReviewModel>[];
    for (final item in list) {
      if (item is! Map) continue;
      try {
        result.add(ReviewModel.fromJson(
            item.map((k, v) => MapEntry(k.toString(), v))));
      } catch (e) {
        _log('Review parse error: $e');
      }
    }
    return result;
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      for (final key in const [
        'data', 'reviews', 'payload', 'results', 'items'
      ]) {
        final val = data[key];
        if (val is List) return val;
        if (val is Map) {
          for (final inner in const ['data', 'items', 'results']) {
            if (val[inner] is List) return val[inner] as List;
          }
        }
      }
    }
    return [];
  }

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
