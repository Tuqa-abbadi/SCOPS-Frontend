import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../models/card_model.dart';
import '../../repositories/cards_repository.dart';

export '../../models/card_model.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc({CardsRepository? cardsRepository})
      : _repository = cardsRepository ?? CardsRepository(),
        super(const WalletInitial()) {
    on<WalletLoaded>(_onLoaded);
    on<WalletCardAdded>(_onCardAdded);
    on<WalletCardDeleted>(_onCardDeleted);
    on<WalletPrimaryChanged>(_onPrimaryChanged);
  }

  final CardsRepository _repository;

  Future<void> _onLoaded(WalletLoaded event, Emitter<WalletState> emit) async {
    emit(const WalletLoading());
    final result = await _repository.fetchCards();
    if (result.success) {
      emit(_buildData(result.cards!));
    } else {
      emit(WalletError(message: result.message ?? 'Failed to load cards.'));
    }
  }

  Future<void> _onCardAdded(
      WalletCardAdded event, Emitter<WalletState> emit) async {
    try {
      final result = await _repository.addCard(
        cardHolderName: event.cardHolderName,
        cardNumber: event.cardNumber,
        expiryMonth: event.expiryMonth,
        expiryYear: event.expiryYear,
      );
      if (result.success) {
        emit(_buildData(result.cards ?? []));
      } else {
        emit(_errorWithCurrent(result.message ?? 'Failed to add card.'));
      }
    } catch (_) {
      emit(_errorWithCurrent('Something went wrong. Please try again.'));
    }
  }

  Future<void> _onCardDeleted(
      WalletCardDeleted event, Emitter<WalletState> emit) async {
    try {
      final result = await _repository.deleteCard(event.cardId);
      if (result.success) {
        emit(_buildData(result.cards ?? []));
      } else {
        emit(_errorWithCurrent(result.message ?? 'Failed to delete card.'));
      }
    } catch (_) {
      emit(_errorWithCurrent('Something went wrong. Please try again.'));
    }
  }

  Future<void> _onPrimaryChanged(
      WalletPrimaryChanged event, Emitter<WalletState> emit) async {
    try {
      final result = await _repository.setPrimaryCard(event.cardId);
      if (result.success) {
        emit(_buildData(result.cards ?? []));
      } else {
        emit(_errorWithCurrent(result.message ?? 'Failed to update primary card.'));
      }
    } catch (_) {
      emit(_errorWithCurrent('Something went wrong. Please try again.'));
    }
  }

  WalletData _buildData(List<CardModel> cards) {
    final primaryId = cards
        .where((c) => c.isPrimary)
        .map((c) => c.id)
        .cast<String?>()
        .firstOrNull;
    return WalletData(
      cards: cards,
      primaryCardId: primaryId ?? (cards.isNotEmpty ? cards.first.id : null),
    );
  }

  // Preserves the current card list inside the error so the UI never shows blank.
  WalletError _errorWithCurrent(String message) {
    final current = state;
    if (current is WalletData) {
      return WalletError(
        message: message,
        cards: current.cards,
        primaryCardId: current.primaryCardId,
      );
    }
    return WalletError(message: message);
  }
}
