part of 'wallet_bloc.dart';

abstract class WalletState extends Equatable {
  const WalletState();
  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {
  const WalletInitial();
}

class WalletLoading extends WalletState {
  const WalletLoading();
}

/// Emitted while a backend call is in progress (setup intent or card save).
/// Carries the current card list so the wallet screen stays populated.
class WalletAddingCard extends WalletState {
  const WalletAddingCard({this.cards = const [], this.primaryCardId});

  final List<CardModel> cards;
  final String? primaryCardId;

  @override
  List<Object?> get props => [cards, primaryCardId];
}

/// Backend returned a SetupIntent — widget should launch Stripe PaymentSheet.
class WalletSetupIntentReady extends WalletState {
  const WalletSetupIntentReady({
    required this.clientSecret,
    this.customerId,
    this.customerEphemeralKeySecret,
    this.cards = const [],
    this.primaryCardId,
  });

  final String clientSecret;
  final String? customerId;
  final String? customerEphemeralKeySecret;
  final List<CardModel> cards;
  final String? primaryCardId;

  @override
  List<Object?> get props => [clientSecret, customerId, customerEphemeralKeySecret];
}

class WalletData extends WalletState {
  const WalletData({
    required this.cards,
    required this.primaryCardId,
    this.cardJustAdded = false,
  });

  final List<CardModel> cards;
  final String? primaryCardId;

  /// True only immediately after a card is successfully saved via Stripe.
  /// The UI uses this to close the add-card sheet and show a success snackbar.
  final bool cardJustAdded;

  @override
  List<Object?> get props => [cards, primaryCardId, cardJustAdded];
}

/// Carries the last-known card list so the UI never goes blank during errors.
class WalletError extends WalletState {
  const WalletError({
    required this.message,
    this.cards = const [],
    this.primaryCardId,
  });

  final String message;
  final List<CardModel> cards;
  final String? primaryCardId;

  @override
  List<Object?> get props => [message, cards, primaryCardId];
}
