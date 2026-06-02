part of 'subscription_bloc.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();
  @override
  List<Object?> get props => [];
}

// ── Load / refresh ────────────────────────────────────────────────────────────

class SubscriptionLoaded extends SubscriptionEvent {
  const SubscriptionLoaded();
}

class SubscriptionsRefreshRequested extends SubscriptionEvent {
  const SubscriptionsRefreshRequested();
}

// ── Create via API ────────────────────────────────────────────────────────────

/// Dispatched by AddSubscriptionScreen. Contains both display info (name/icon)
/// and API fields (serviceId, planId, cardId) so the bloc can POST to the API
/// and update the service name cache in one step.
class SubscriptionAdded extends SubscriptionEvent {
  const SubscriptionAdded({
    required this.serviceName,
    required this.serviceIcon,
    this.serviceLogoUrl,
    required this.plan,
    required this.billingCycle,
    required this.amount,
    required this.nextRenewal,
    required this.cardId,
    required this.reminderDays,
    this.serviceId,
    this.planId,
    this.cardApiId,
    this.paymentId,
    this.priority = 'medium',
    this.serviceAccountEmail,
  });

  final String serviceName;
  final String serviceIcon;
  final String? serviceLogoUrl;
  final String plan;
  final String billingCycle;
  final double amount;
  final DateTime nextRenewal;
  final String cardId;
  final int reminderDays;
  final int? serviceId;
  final int? planId;
  final int? cardApiId;
  final int? paymentId;
  final String priority;
  final String? serviceAccountEmail;

  @override
  List<Object?> get props =>
      [serviceName, serviceLogoUrl, plan, serviceId, paymentId, serviceAccountEmail];
}

// ── API actions ───────────────────────────────────────────────────────────────

class SubscriptionCancelRequested extends SubscriptionEvent {
  const SubscriptionCancelRequested(this.id);
  final int id;
  @override
  List<Object?> get props => [id];
}

class SubscriptionPauseRequested extends SubscriptionEvent {
  const SubscriptionPauseRequested(this.id);
  final int id;
  @override
  List<Object?> get props => [id];
}

class SubscriptionResumeRequested extends SubscriptionEvent {
  const SubscriptionResumeRequested(this.id);
  final int id;
  @override
  List<Object?> get props => [id];
}

// ── Local edit (edit screen – no PUT endpoint yet) ────────────────────────────

class SubscriptionUpdated extends SubscriptionEvent {
  const SubscriptionUpdated({
    required this.id,
    required this.plan,
    required this.billingCycle,
    required this.amount,
    required this.cardId,
    required this.reminderDays,
    required this.nextRenewal,
  });

  final String id;
  final String plan;
  final String billingCycle;
  final double amount;
  final String cardId;
  final int reminderDays;
  final DateTime nextRenewal;

  @override
  List<Object?> get props => [id];
}

// ── Legacy events kept for backward compatibility ─────────────────────────────

/// Maps to SubscriptionCancelRequested internally (via int.tryParse on id).
class SubscriptionCancelled extends SubscriptionEvent {
  const SubscriptionCancelled(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

/// Removes the subscription from local state only (for UI cleanup after delete).
class SubscriptionDeleted extends SubscriptionEvent {
  const SubscriptionDeleted(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

/// Resets the bloc to its initial state (dispatched on logout so the next
/// login always fetches fresh data for the new user).
class SubscriptionReset extends SubscriptionEvent {
  const SubscriptionReset();
}
