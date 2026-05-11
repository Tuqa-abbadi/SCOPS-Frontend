part of 'subscription_bloc.dart';

class SubscriptionModel extends Equatable {
  final String id;
  final String serviceName;
  final String serviceIcon;
  final String plan;
  final String billingCycle;
  final double amount;
  final DateTime nextRenewal;
  final String cardId;
  final int reminderDays;

  const SubscriptionModel({
    required this.id,
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
  List<Object> get props => [id];
}

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();
  @override
  List<Object> get props => [];
}

class SubscriptionInitial extends SubscriptionState {
  const SubscriptionInitial();
}

class SubscriptionData extends SubscriptionState {
  final List<SubscriptionModel> subscriptions;
  const SubscriptionData({required this.subscriptions});
  @override
  List<Object> get props => [subscriptions];
}