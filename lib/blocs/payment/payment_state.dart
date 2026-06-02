part of 'payment_bloc.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

/// POST /payments/{serviceId} is in flight.
class PaymentIntentLoading extends PaymentState {
  const PaymentIntentLoading();
}

/// Intent created — UI should show the confirmation dialog.
class PaymentIntentReady extends PaymentState {
  const PaymentIntentReady({
    required this.clientSecret,
    required this.paymentId,
  });

  final String clientSecret;
  final int paymentId;

  @override
  List<Object?> get props => [clientSecret, paymentId];
}

/// POST /payments/confirm/{paymentId} is in flight.
class PaymentConfirming extends PaymentState {
  const PaymentConfirming({required this.paymentId});

  final int paymentId;

  @override
  List<Object?> get props => [paymentId];
}

/// Payment confirmed successfully.
class PaymentSuccess extends PaymentState {
  const PaymentSuccess({
    required this.paymentId,
    this.receipt,
  });

  final int paymentId;
  final Map<String, dynamic>? receipt;

  @override
  List<Object?> get props => [paymentId, receipt];
}

/// User pressed "No" in the confirmation dialog.
class PaymentDeclinedState extends PaymentState {
  const PaymentDeclinedState();
}

/// An error occurred during intent creation or confirmation.
class PaymentFailure extends PaymentState {
  const PaymentFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
