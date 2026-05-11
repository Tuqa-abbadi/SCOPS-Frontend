import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'subscription_event.dart';
part 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  SubscriptionBloc() : super(const SubscriptionInitial()) {
    on<SubscriptionLoaded>(_onLoaded);
    on<SubscriptionAdded>(_onAdded);
    on<SubscriptionDeleted>(_onDeleted);
  }

  void _onLoaded(SubscriptionLoaded event, Emitter<SubscriptionState> emit) {
    emit(const SubscriptionData(subscriptions: []));
  }

  void _onAdded(SubscriptionAdded event, Emitter<SubscriptionState> emit) {
    final current = state as SubscriptionData;
    final sub = SubscriptionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      serviceName: event.serviceName,
      serviceIcon: event.serviceIcon,
      plan: event.plan,
      billingCycle: event.billingCycle,
      amount: event.amount,
      nextRenewal: event.nextRenewal,
      cardId: event.cardId,
      reminderDays: event.reminderDays,
    );
    emit(SubscriptionData(subscriptions: [...current.subscriptions, sub]));
  }

  void _onDeleted(SubscriptionDeleted event, Emitter<SubscriptionState> emit) {
    final current = state as SubscriptionData;
    emit(SubscriptionData(
      subscriptions: current.subscriptions.where((s) => s.id != event.id).toList(),
    ));
  }
}