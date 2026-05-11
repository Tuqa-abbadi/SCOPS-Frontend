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
  final String nickname;
  final String maskedPan;
  final String expiry;
  final String type;
  const WalletCardAdded({
    required this.nickname,
    required this.maskedPan,
    required this.expiry,
    required this.type,
  });
  @override
  List<Object> get props => [maskedPan];
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