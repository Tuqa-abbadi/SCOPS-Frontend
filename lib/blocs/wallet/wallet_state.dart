part of 'wallet_bloc.dart';

class CardModel extends Equatable {
  final String id;
  final String nickname;
  final String maskedPan;
  final String expiry;
  final String type;

  const CardModel({
    required this.id,
    required this.nickname,
    required this.maskedPan,
    required this.expiry,
    required this.type,
  });

  @override
  List<Object> get props => [id];
}

abstract class WalletState extends Equatable {
  const WalletState();
  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {
  const WalletInitial();
}

class WalletData extends WalletState {
  final List<CardModel> cards;
  final String? primaryCardId;
  const WalletData({required this.cards, required this.primaryCardId});
  @override
  List<Object?> get props => [cards, primaryCardId];
}