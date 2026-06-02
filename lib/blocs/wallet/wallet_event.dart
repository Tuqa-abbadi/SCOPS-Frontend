part of 'wallet_bloc.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();
  @override
  List<Object> get props => [];
}

class WalletLoaded extends WalletEvent {
  const WalletLoaded();
}

/// Step 1 — request a SetupIntent from the backend.
class WalletSetupIntentRequested extends WalletEvent {
  const WalletSetupIntentRequested();
}

/// Step 2 — Stripe PaymentSheet confirmed; send payment method to backend.
class WalletStripeCardSaved extends WalletEvent {
  const WalletStripeCardSaved({
    required this.paymentMethodId,
    required this.cardHolderName,
  });

  final String paymentMethodId;
  final String cardHolderName;

  @override
  List<Object> get props => [paymentMethodId, cardHolderName];
}

class WalletCardDeleted extends WalletEvent {
  final String cardId;
  const WalletCardDeleted(this.cardId);
  @override
  List<Object> get props => [cardId];
}

class WalletPrimaryChanged extends WalletEvent {
  final String cardId;
  const WalletPrimaryChanged(this.cardId);
  @override
  List<Object> get props => [cardId];
}

/// Resets the bloc to its initial state (dispatched on logout so the next
/// login always fetches fresh data for the new user).
class WalletReset extends WalletEvent {
  const WalletReset();
}
