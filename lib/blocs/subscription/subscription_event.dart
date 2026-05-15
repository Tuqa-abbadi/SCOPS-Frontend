part of 'subscription_bloc.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();
  @override
  List<Object> get props => [];
}

class SubscriptionLoaded extends SubscriptionEvent {
  const SubscriptionLoaded();
}

class SubscriptionAdded extends SubscriptionEvent {
  final String serviceName;
  final String serviceIcon;
  final String plan;
  final String billingCycle;
  final double amount;
  final DateTime nextRenewal;
  final String cardId;
  final int reminderDays;

  const SubscriptionAdded({
    required this.serviceName,
    required this.serviceIcon,
    required this.plan,
    required this.billingCycle,
    required this.amount,
    required this.nextRenewal,
    required this.cardId,
    required this.reminderDays,
  });

  @override
  List<Object> get props => [serviceName, plan];
}

class SubscriptionUpdated extends SubscriptionEvent {
  final String id;
  final String plan;
  final String billingCycle;
  final double amount;
  final String cardId;
  final int reminderDays;
  final DateTime nextRenewal;

  const SubscriptionUpdated({
    required this.id,
    required this.plan,
    required this.billingCycle,
    required this.amount,
    required this.cardId,
    required this.reminderDays,
    required this.nextRenewal,
  });

  @override
  List<Object> get props => [id];
}

class SubscriptionCancelled extends SubscriptionEvent {
  final String id;
  const SubscriptionCancelled(this.id);
  @override
  List<Object> get props => [id];
}

class SubscriptionDeleted extends SubscriptionEvent {
  final String id;
  const SubscriptionDeleted(this.id);
  @override
  List<Object> get props => [id];
}