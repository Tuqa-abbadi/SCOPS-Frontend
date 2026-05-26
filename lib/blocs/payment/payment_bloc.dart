import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/payment_repository.dart';

part 'payment_event.dart';
part 'payment_state.dart';

// ignore: avoid_print
void _log(String msg) => print('[PaymentBloc] $msg');

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc({PaymentRepository? repository})
      : _repository = repository ?? PaymentRepository(),
        super(const PaymentInitial()) {
    on<PaymentIntentRequested>(_onIntentRequested);
    on<PaymentConfirmed>(_onConfirmed);
    on<PaymentDeclined>(_onDeclined);
    on<PaymentReset>(_onReset);
  }

  final PaymentRepository _repository;

  // ── Create payment intent ─────────────────────────────────────────────────

  Future<void> _onIntentRequested(
    PaymentIntentRequested event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentIntentLoading());

    final result = await _repository.createPaymentIntent(event.serviceId);

    if (result.success) {
      _log('Intent created: paymentId=${result.intent!.paymentId}');
      emit(PaymentIntentReady(
        clientSecret: result.intent!.clientSecret,
        paymentId: result.intent!.paymentId,
      ));
    } else {
      _log('Intent error: ${result.message}');
      emit(PaymentFailure(message: result.message));
    }
  }

  // ── Confirm payment ───────────────────────────────────────────────────────

  Future<void> _onConfirmed(
    PaymentConfirmed event,
    Emitter<PaymentState> emit,
  ) async {
    // Grab the client_secret before transitioning state away from IntentReady.
    final clientSecret =
        state is PaymentIntentReady
            ? (state as PaymentIntentReady).clientSecret
            : '';

    emit(PaymentConfirming(paymentId: event.paymentId));

    _log('Confirming paymentId=${event.paymentId} clientSecret=$clientSecret');

    final result = await _repository.confirmPayment(
      event.paymentId,
      clientSecret: clientSecret,
    );

    if (result.success) {
      _log('Payment confirmed: paymentId=${event.paymentId}');
      emit(const PaymentSuccess());
    } else {
      _log('Confirm error: ${result.message}');
      emit(PaymentFailure(message: result.message));
    }
  }

  // ── User declined ─────────────────────────────────────────────────────────

  void _onDeclined(PaymentDeclined _, Emitter<PaymentState> emit) {
    _log('Payment declined by user.');
    emit(const PaymentDeclinedState());
  }

  // ── Reset ─────────────────────────────────────────────────────────────────

  void _onReset(PaymentReset _, Emitter<PaymentState> emit) {
    emit(const PaymentInitial());
  }
}
