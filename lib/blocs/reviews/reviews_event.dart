part of 'reviews_bloc.dart';

abstract class ReviewsEvent extends Equatable {
  const ReviewsEvent();
  @override
  List<Object?> get props => [];
}

/// Fetch reviews shown in the service detail bottom sheet.
class ReviewsForServiceRequested extends ReviewsEvent {
  const ReviewsForServiceRequested(this.serviceId);
  final int serviceId;
  @override
  List<Object?> get props => [serviceId];
}

/// Check which of the given subscriptions are eligible and unreviewed.
/// Dispatched from the Profile page when subscription data is ready.
class PendingReviewsRequested extends ReviewsEvent {
  const PendingReviewsRequested(this.subscriptions);
  final List<SubscriptionModel> subscriptions;
  @override
  List<Object?> get props => [subscriptions];
}

/// Submit a new review via POST /api/reviews.
/// [serviceId] is kept for re-fetching after success, not sent in POST body.
class ReviewSubmitRequested extends ReviewsEvent {
  const ReviewSubmitRequested({
    required this.serviceId,
    required this.subscriptionId,
    required this.rating,
    this.comment,
  });
  final int serviceId;
  final int subscriptionId;
  final int rating;
  final String? comment;
  @override
  List<Object?> get props => [serviceId, subscriptionId, rating, comment];
}

/// Clear submit success / error flags after the UI has consumed them.
class ReviewSubmitReset extends ReviewsEvent {
  const ReviewSubmitReset();
}
