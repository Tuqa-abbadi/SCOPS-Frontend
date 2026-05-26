part of 'subscription_bloc.dart';

enum SubscriptionStatus { active, cancelled, paused }

class SubscriptionModel extends Equatable {
  const SubscriptionModel({
    required this.id,
    required this.apiId,
    required this.serviceId,
    this.planId,
    this.cardApiId,
    required this.serviceName,
    required this.serviceIcon,
    required this.plan,
    required this.billingCycle,
    required this.amount,
    required this.nextRenewal,
    required this.cardId,
    required this.reminderDays,
    this.status = SubscriptionStatus.active,
    this.priority = 'medium',
    this.startDate,
  });

  final String id;          // String of apiId, used by existing UI
  final int apiId;          // original int from API
  final int serviceId;
  final int? planId;
  final int? cardApiId;
  final String serviceName;
  final String serviceIcon;
  final String plan;        // plan display name
  final String billingCycle; // Monthly | Weekly | Yearly
  final double amount;
  final DateTime nextRenewal;
  final String cardId;      // String for existing UI (= cardApiId?.toString() ?? '')
  final int reminderDays;
  final SubscriptionStatus status;
  final String priority;
  final DateTime? startDate; // null only for locally-created subscriptions

  bool get isActive    => status == SubscriptionStatus.active;
  bool get isPaused    => status == SubscriptionStatus.paused;
  bool get isCancelled => status == SubscriptionStatus.cancelled;

  SubscriptionModel copyWith({
    String? plan,
    String? billingCycle,
    double? amount,
    String? cardId,
    int? cardApiId,
    int? reminderDays,
    DateTime? nextRenewal,
    SubscriptionStatus? status,
    String? priority,
    DateTime? startDate,
  }) =>
      SubscriptionModel(
        id: id,
        apiId: apiId,
        serviceId: serviceId,
        planId: planId,
        cardApiId: cardApiId ?? this.cardApiId,
        serviceName: serviceName,
        serviceIcon: serviceIcon,
        plan: plan ?? this.plan,
        billingCycle: billingCycle ?? this.billingCycle,
        amount: amount ?? this.amount,
        nextRenewal: nextRenewal ?? this.nextRenewal,
        cardId: cardId ?? this.cardId,
        reminderDays: reminderDays ?? this.reminderDays,
        status: status ?? this.status,
        priority: priority ?? this.priority,
        startDate: startDate ?? this.startDate,
      );

  @override
  List<Object?> get props =>
      [id, plan, billingCycle, amount, status, priority, startDate];
}

// ── States ────────────────────────────────────────────────────────────────────

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();
  @override
  List<Object?> get props => [];
}

class SubscriptionInitial extends SubscriptionState {
  const SubscriptionInitial();
}

/// Full-page loading (first load only).
class SubscriptionsLoading extends SubscriptionState {
  const SubscriptionsLoading();
}

/// Loaded state. [isLoading] is true during background refresh / action calls.
/// [actionError] carries a non-fatal error message after a failed action.
class SubscriptionData extends SubscriptionState {
  const SubscriptionData({
    required this.subscriptions,
    this.isLoading = false,
    this.actionError,
  });

  final List<SubscriptionModel> subscriptions;
  final bool isLoading;
  final String? actionError;

  List<SubscriptionModel> get active =>
      subscriptions.where((s) => s.isActive).toList();

  List<SubscriptionModel> get paused =>
      subscriptions.where((s) => s.isPaused).toList();

  SubscriptionData copyWith({
    List<SubscriptionModel>? subscriptions,
    bool? isLoading,
    String? actionError,
    bool clearError = false,
  }) =>
      SubscriptionData(
        subscriptions: subscriptions ?? this.subscriptions,
        isLoading: isLoading ?? this.isLoading,
        actionError: clearError ? null : actionError ?? this.actionError,
      );

  @override
  List<Object?> get props => [subscriptions, isLoading, actionError];
}

/// Emitted on full-page load failure when there is no prior data to show.
class SubscriptionError extends SubscriptionState {
  const SubscriptionError({required this.message, this.previous = const []});
  final String message;
  final List<SubscriptionModel> previous;

  @override
  List<Object?> get props => [message];
}
