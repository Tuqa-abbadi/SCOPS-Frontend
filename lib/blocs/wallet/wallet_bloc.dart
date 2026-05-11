import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc() : super(const WalletInitial()) {
    on<WalletLoaded>(_onLoaded);
    on<WalletCardAdded>(_onCardAdded);
    on<WalletCardDeleted>(_onCardDeleted);
    on<WalletPrimaryChanged>(_onPrimaryChanged);
  }

  void _onLoaded(WalletLoaded event, Emitter<WalletState> emit) {
    emit(const WalletData(cards: [], primaryCardId: null));
  }

  void _onCardAdded(WalletCardAdded event, Emitter<WalletState> emit) {
    final current = state as WalletData;
    final newCard = CardModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nickname: event.nickname,
      maskedPan: event.maskedPan,
      expiry: event.expiry,
      type: event.type,
    );
    final updated = [...current.cards, newCard];
    emit(WalletData(
      cards: updated,
      primaryCardId: current.primaryCardId ?? newCard.id,
    ));
  }

  void _onCardDeleted(WalletCardDeleted event, Emitter<WalletState> emit) {
    final current = state as WalletData;
    final updated = current.cards.where((c) => c.id != event.cardId).toList();
    final newPrimary = current.primaryCardId == event.cardId
        ? (updated.isNotEmpty ? updated.first.id : null)
        : current.primaryCardId;
    emit(WalletData(cards: updated, primaryCardId: newPrimary));
  }

  void _onPrimaryChanged(WalletPrimaryChanged event, Emitter<WalletState> emit) {
    final current = state as WalletData;
    emit(WalletData(cards: current.cards, primaryCardId: event.cardId));
  }
}