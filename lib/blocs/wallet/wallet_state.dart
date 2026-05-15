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

class WalletData extends WalletState {
  const WalletData({required this.cards, required this.primaryCardId});

  final List<CardModel> cards;
  final String? primaryCardId;

  @override
  List<Object?> get props => [cards, primaryCardId];
}

// Carries the last known card list so the UI stays visible during brief error states.
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
