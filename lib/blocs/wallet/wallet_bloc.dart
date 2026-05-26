import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../models/card_model.dart';
import '../../repositories/cards_repository.dart';

export '../../models/card_model.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

// ignore: avoid_print
void _log(String msg) => print('[WalletBloc] $msg');

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc({CardsRepository? cardsRepository})
      : _repository = cardsRepository ?? CardsRepository(),
        super(const WalletInitial()) {
    on<WalletLoaded>(_onLoaded);
    on<WalletSetupIntentRequested>(_onSetupIntentRequested);
    on<WalletStripeCardSaved>(_onStripeCardSaved);
    on<WalletCardDeleted>(_onCardDeleted);
    on<WalletPrimaryChanged>(_onPrimaryChanged);
  }

  final CardsRepository _repository;

  // ── Load cards ────────────────────────────────────────────────────────────

  Future<void> _onLoaded(WalletLoaded event, Emitter<WalletState> emit) async {
    emit(const WalletLoading());
    final result = await _repository.fetchCards();
    if (result.success) {
      emit(_buildData(result.cards!));
    } else {
      emit(WalletError(message: result.message ?? 'Failed to load cards.'));
    }
  }

  // ── Step 1: request SetupIntent from backend ──────────────────────────────

  Future<void> _onSetupIntentRequested(
    WalletSetupIntentRequested event,
    Emitter<WalletState> emit,
  ) async {
    final current = _currentCards;
    _log('SetupIntent requested');
    emit(WalletAddingCard(
      cards: current.cards,
      primaryCardId: current.primaryCardId,
    ));

    final result = await _repository.createCardSetupIntent();

    if (result.success) {
      _log('SetupIntent ready');
      emit(WalletSetupIntentReady(
        clientSecret: result.clientSecret!,
        customerId: result.customerId,
        customerEphemeralKeySecret: result.customerEphemeralKeySecret,
        cards: current.cards,
        primaryCardId: current.primaryCardId,
      ));
    } else {
      _log('SetupIntent error: ${result.message}');
      emit(_errorWithCurrent(result.message));
    }
  }

  // ── Step 2: Stripe confirmed — save payment method to backend ─────────────

  Future<void> _onStripeCardSaved(
    WalletStripeCardSaved event,
    Emitter<WalletState> emit,
  ) async {
    final current = _currentCards;
    emit(WalletAddingCard(
      cards: current.cards,
      primaryCardId: current.primaryCardId,
    ));

    _log('Saving stripe card pm=${event.paymentMethodId}');

    final result = await _repository.saveStripeCard(
      paymentMethodId: event.paymentMethodId,
      cardHolderName: event.cardHolderName,
    );

    if (result.success) {
      _log('Card saved — ${result.cards?.length} cards total');
      emit(_buildData(result.cards ?? [], cardJustAdded: true));
    } else {
      _log('Card save error: ${result.message}');
      emit(_errorWithCurrent(result.message ?? 'Failed to save card.'));
    }
  }

  // ── Delete card ───────────────────────────────────────────────────────────

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

  // ── Set primary ───────────────────────────────────────────────────────────

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

  // ── Helpers ───────────────────────────────────────────────────────────────

  ({List<CardModel> cards, String? primaryCardId}) get _currentCards {
    final s = state;
    if (s is WalletData) return (cards: s.cards, primaryCardId: s.primaryCardId);
    if (s is WalletError) return (cards: s.cards, primaryCardId: s.primaryCardId);
    if (s is WalletAddingCard) return (cards: s.cards, primaryCardId: s.primaryCardId);
    if (s is WalletSetupIntentReady) return (cards: s.cards, primaryCardId: s.primaryCardId);
    return (cards: const [], primaryCardId: null);
  }

  WalletData _buildData(List<CardModel> cards, {bool cardJustAdded = false}) {
    final primaryId = cards
        .where((c) => c.isPrimary)
        .map((c) => c.id)
        .cast<String?>()
        .firstOrNull;
    return WalletData(
      cards: cards,
      primaryCardId: primaryId ?? (cards.isNotEmpty ? cards.first.id : null),
      cardJustAdded: cardJustAdded,
    );
  }

  WalletError _errorWithCurrent(String? message) {
    final c = _currentCards;
    return WalletError(
      message: message ?? 'Something went wrong.',
      cards: c.cards,
      primaryCardId: c.primaryCardId,
    );
  }
}
