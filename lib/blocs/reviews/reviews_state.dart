part of 'reviews_bloc.dart';

abstract class ReviewsState extends Equatable {
  const ReviewsState();
  @override
  List<Object?> get props => [];
}

class ReviewsInitial extends ReviewsState {
  const ReviewsInitial();
}

class ReviewsData extends ReviewsState {
  const ReviewsData({
    this.detailServiceId,
    this.detailReviews = const [],
    this.detailLoading = false,
    this.detailError,
    this.isSubmitting = false,
    this.submitError,
    this.submitSuccess = false,
    this.reviewedSubscriptionIds = const {},
    this.myReviews = const [],
    this.pendingLoading = false,
    this.pendingError,
  });

  // Reviews shown inside the service detail sheet.
  final int? detailServiceId;
  final List<ReviewModel> detailReviews;
  final bool detailLoading;
  final String? detailError;

  // Review submission.
  final bool isSubmitting;
  final String? submitError;
  final bool submitSuccess;

  // Set of subscription API IDs that already have a review (built from all
  // fetched review lists).  Used to drive eligibility checks in the UI.
  final Set<int> reviewedSubscriptionIds;

  // Reviews the current user has written (collected during pending-check).
  final List<ReviewModel> myReviews;

  // Whether the pending-reviews check is still running.
  final bool pendingLoading;
  final String? pendingError;

  bool hasReviewForSubscription(int subscriptionId) =>
      reviewedSubscriptionIds.contains(subscriptionId);

  ReviewsData copyWith({
    int? detailServiceId,
    List<ReviewModel>? detailReviews,
    bool? detailLoading,
    String? detailError,
    bool clearDetailError = false,
    bool? isSubmitting,
    String? submitError,
    bool clearSubmitError = false,
    bool? submitSuccess,
    Set<int>? reviewedSubscriptionIds,
    List<ReviewModel>? myReviews,
    bool? pendingLoading,
    String? pendingError,
    bool clearPendingError = false,
  }) =>
      ReviewsData(
        detailServiceId: detailServiceId ?? this.detailServiceId,
        detailReviews: detailReviews ?? this.detailReviews,
        detailLoading: detailLoading ?? this.detailLoading,
        detailError: clearDetailError ? null : detailError ?? this.detailError,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        submitError:
            clearSubmitError ? null : submitError ?? this.submitError,
        submitSuccess: submitSuccess ?? this.submitSuccess,
        reviewedSubscriptionIds:
            reviewedSubscriptionIds ?? this.reviewedSubscriptionIds,
        myReviews: myReviews ?? this.myReviews,
        pendingLoading: pendingLoading ?? this.pendingLoading,
        pendingError:
            clearPendingError ? null : pendingError ?? this.pendingError,
      );

  @override
  List<Object?> get props => [
        detailServiceId,
        detailReviews,
        detailLoading,
        detailError,
        isSubmitting,
        submitError,
        submitSuccess,
        // Convert Set → sorted List so Equatable can compare contents.
        ([...reviewedSubscriptionIds]..sort()),
        myReviews,
        pendingLoading,
        pendingError,
      ];
}
