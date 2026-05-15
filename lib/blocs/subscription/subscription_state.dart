part of 'subscription_bloc.dart';

enum SubscriptionStatus { active, cancelled }

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
  final SubscriptionStatus status;

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
    this.status = SubscriptionStatus.active,
  });

  SubscriptionModel copyWith({
    String? plan,
    String? billingCycle,
    double? amount,
    String? cardId,
    int? reminderDays,
    DateTime? nextRenewal,
    SubscriptionStatus? status,
  }) =>
      SubscriptionModel(
        id: id,
        serviceName: serviceName,
        serviceIcon: serviceIcon,
        plan: plan ?? this.plan,
        billingCycle: billingCycle ?? this.billingCycle,
        amount: amount ?? this.amount,
        nextRenewal: nextRenewal ?? this.nextRenewal,
        cardId: cardId ?? this.cardId,
        reminderDays: reminderDays ?? this.reminderDays,
        status: status ?? this.status,
      );

  bool get isActive => status == SubscriptionStatus.active;

  @override
  List<Object> get props => [id, plan, billingCycle, amount, status];
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

  List<SubscriptionModel> get active =>
      subscriptions.where((s) => s.isActive).toList();

  @override
  List<Object> get props => [subscriptions];
}