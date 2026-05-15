part of 'wallet_bloc.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();
  @override
  List<Object> get props => [];
}

class WalletLoaded extends WalletEvent {
  const WalletLoaded();
}

class WalletCardAdded extends WalletEvent {
  final String cardHolderName;
  final String cardNumber;
  final int expiryMonth;
  final int expiryYear;
  const WalletCardAdded({
    required this.cardHolderName,
    required this.cardNumber,
    required this.expiryMonth,
    required this.expiryYear,
  });
  @override
  List<Object> get props => [cardNumber];
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