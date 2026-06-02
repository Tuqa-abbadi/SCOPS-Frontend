part of 'payment_bloc.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

/// Initiate a payment intent for the given service.
class PaymentIntentRequested extends PaymentEvent {
  const PaymentIntentRequested(
    this.serviceId, {
    this.planId,
    this.serviceAccountEmail,
  });

  final int serviceId;
  final int? planId;
  final String? serviceAccountEmail;

  @override
  List<Object?> get props => [serviceId, planId, serviceAccountEmail];
}

/// User confirmed — call POST /payments/confirm/{paymentId}.
class PaymentConfirmed extends PaymentEvent {
  const PaymentConfirmed(this.paymentId);

  final int paymentId;

  @override
  List<Object?> get props => [paymentId];
}

/// User declined the confirmation dialog.
class PaymentDeclined extends PaymentEvent {
  const PaymentDeclined();
}

/// Reset bloc back to initial (e.g. on sheet close or after success/error).
class PaymentReset extends PaymentEvent {
  const PaymentReset();
}
