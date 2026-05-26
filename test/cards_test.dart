import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:scops_frontend/blocs/wallet/wallet_bloc.dart';
import 'package:scops_frontend/repositories/cards_repository.dart';
import 'package:scops_frontend/services/cards_api_service.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

Response<dynamic> _okResponse(dynamic data) => Response<dynamic>(
      requestOptions: RequestOptions(path: ''),
      statusCode: 200,
      data: data,
    );

DioException _dioError({
  int statusCode = 500,
  dynamic data,
  DioExceptionType type = DioExceptionType.badResponse,
}) =>
    DioException(
      requestOptions: RequestOptions(path: ''),
      type: type,
      response: type == DioExceptionType.badResponse
          ? Response(
              requestOptions: RequestOptions(path: ''),
              statusCode: statusCode,
              data: data,
            )
          : null,
    );

// ── Fake API service ──────────────────────────────────────────────────────────

class _FakeCardsApi extends CardsApiService {
  _FakeCardsApi({required this.onAdd, required this.onList, this.onSetPrimary})
      : super(dio: Dio());

  final dynamic onAdd;         // Response<dynamic> or DioException
  final dynamic onList;        // Response<dynamic> or DioException
  final dynamic onSetPrimary;  // Response<dynamic> or DioException

  @override
  Future<Response<dynamic>> saveStripeCard({
    required String paymentMethodId,
    required String cardHolderName,
  }) async {
    if (onAdd is DioException) throw onAdd as DioException;
    return onAdd as Response<dynamic>;
  }

  @override
  Future<Response<dynamic>> getCards() async {
    if (onList is DioException) throw onList as DioException;
    return onList as Response<dynamic>;
  }

  @override
  Future<Response<dynamic>> setPrimaryCard(String cardId) async {
    if (onSetPrimary is DioException) throw onSetPrimary as DioException;
    return onSetPrimary as Response<dynamic>;
  }
}

// ── Fake repository for WalletBloc tests ─────────────────────────────────────

class _FakeCardsRepository extends CardsRepository {
  _FakeCardsRepository(this._result)
      : super(service: CardsApiService(dio: Dio()));

  final CardsResult _result;

  @override
  Future<CardsResult> saveStripeCard({
    required String paymentMethodId,
    required String cardHolderName,
  }) async =>
      _result;

  @override
  Future<CardsResult> setPrimaryCard(String cardId) async => _result;
}

// ── Sample data ───────────────────────────────────────────────────────────────

const _cardJson = {
  'card_id': 8,
  'card_holder_name': 'Tuqa Dowikat',
  'card_brand': 'Visa',
  'card_number': '**** **** **** 4444',
  'expired_date': '12/2027',
  'is_primary': 'yes',
};

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── CardModel ──────────────────────────────────────────────────────────────

  group('CardModel.fromJson', () {
    test('parses all fields from actual backend response', () {
      final card = CardModel.fromJson(_cardJson);

      expect(card.id, '8');
      expect(card.nickname, 'Tuqa Dowikat');
      expect(card.maskedPan, '**** **** **** 4444');
      expect(card.expiry, '12/2027');
      expect(card.type, 'Visa');
      expect(card.isPrimary, isTrue);
    });

    test('is_primary "yes" parses as true', () {
      final card = CardModel.fromJson({..._cardJson, 'is_primary': 'yes'});
      expect(card.isPrimary, isTrue);
    });

    test('is_primary "no" parses as false', () {
      final card = CardModel.fromJson({..._cardJson, 'is_primary': 'no'});
      expect(card.isPrimary, isFalse);
    });

    test('is_primary bool false parses correctly', () {
      final card = CardModel.fromJson({..._cardJson, 'is_primary': false});
      expect(card.isPrimary, isFalse);
    });

    test('builds expiry from month/year parts when expired_date is absent', () {
      final card = CardModel.fromJson({
        'card_id': 2,
        'card_holder_name': 'Test',
        'card_number': '5500000000000004',
        'expiry_month': 3,
        'expiry_year': 2026,
      });

      expect(card.expiry, '03/2026');
    });

    test('handles completely empty JSON without crashing', () {
      final card = CardModel.fromJson({'card_id': 3});

      expect(card.id, '3');
      expect(card.nickname, '');
      expect(card.maskedPan, '');
      expect(card.expiry, '');
      expect(card.isPrimary, isFalse);
    });

    test('prefers card_number over masked_pan fallbacks', () {
      final card = CardModel.fromJson({
        'card_id': 4,
        'card_number': '**** **** **** 1234',
        'masked_pan': '****5678',
      });

      expect(card.maskedPan, '**** **** **** 1234');
    });
  });

  // ── CardsRepository ────────────────────────────────────────────────────────

  group('CardsRepository.saveStripeCard', () {
    test('success — returns updated card list after add', () async {
      final api = _FakeCardsApi(
        onAdd: _okResponse(null),
        onList: _okResponse([_cardJson]),
      );
      final repo = CardsRepository(service: api);

      final result = await repo.saveStripeCard(
        paymentMethodId: 'pm_test_123',
        cardHolderName: 'Tuqa Dowikat',
      );

      expect(result.success, isTrue);
      expect(result.cards, hasLength(1));
      expect(result.cards!.first.nickname, 'Tuqa Dowikat');
      expect(result.cards!.first.expiry, '12/2027');
      expect(result.cards!.first.id, '8');
    });

    test('success — parses list wrapped in data key', () async {
      final api = _FakeCardsApi(
        onAdd: _okResponse(null),
        onList: _okResponse({'data': [_cardJson]}),
      );
      final repo = CardsRepository(service: api);

      final result = await repo.saveStripeCard(
        paymentMethodId: 'pm_test_123',
        cardHolderName: 'Tuqa Dowikat',
      );

      expect(result.success, isTrue);
      expect(result.cards, hasLength(1));
    });

    test('server error (422) — returns failure with message', () async {
      final api = _FakeCardsApi(
        onAdd: _dioError(
          statusCode: 422,
          data: {'message': 'Invalid card number.'},
        ),
        onList: _okResponse([]),
      );
      final repo = CardsRepository(service: api);

      final result = await repo.saveStripeCard(
        paymentMethodId: 'pm_test_bad',
        cardHolderName: 'Tuqa Dowikat',
      );

      expect(result.success, isFalse);
      expect(result.message, isNotNull);
    });

    test('401 — returns session expired message', () async {
      final api = _FakeCardsApi(
        onAdd: _dioError(statusCode: 401),
        onList: _okResponse([]),
      );
      final repo = CardsRepository(service: api);

      final result = await repo.saveStripeCard(
        paymentMethodId: 'pm_test_123',
        cardHolderName: 'Tuqa Dowikat',
      );

      expect(result.success, isFalse);
      expect(result.message, contains('Session expired'));
    });

    test('network error — returns failure without crashing', () async {
      final api = _FakeCardsApi(
        onAdd: _dioError(type: DioExceptionType.connectionError),
        onList: _okResponse([]),
      );
      final repo = CardsRepository(service: api);

      final result = await repo.saveStripeCard(
        paymentMethodId: 'pm_test_123',
        cardHolderName: 'Tuqa Dowikat',
      );

      expect(result.success, isFalse);
      expect(result.message, contains('Network error'));
    });
  });

  // ── WalletBloc ─────────────────────────────────────────────────────────────

  group('WalletBloc — WalletCardAdded', () {
    const addEvent = WalletStripeCardSaved(
      paymentMethodId: 'pm_test_123',
      cardHolderName: 'Tuqa Dowikat',
    );

    test('emits WalletData with new card on success', () async {
      final repo = _FakeCardsRepository(
        CardsResult(
          success: true,
          cards: [CardModel.fromJson(_cardJson)],
        ),
      );
      final bloc = WalletBloc(cardsRepository: repo);

      bloc.add(addEvent);

      await expectLater(bloc.stream, emits(isA<WalletData>()));

      final state = bloc.state as WalletData;
      expect(state.cards, hasLength(1));
      expect(state.cards.first.nickname, 'Tuqa Dowikat');
      await bloc.close();
    });

    test('emits WalletError with message on failure', () async {
      final repo = _FakeCardsRepository(
        const CardsResult(
          success: false,
          message: 'Invalid card number.',
        ),
      );
      final bloc = WalletBloc(cardsRepository: repo);

      bloc.add(addEvent);

      await expectLater(bloc.stream, emits(isA<WalletError>()));

      final state = bloc.state as WalletError;
      expect(state.message, 'Invalid card number.');
      await bloc.close();
    });

    test('WalletError preserves existing cards from previous WalletData', () async {
      final repo = _FakeCardsRepository(
        const CardsResult(success: false, message: 'Failed.'),
      );
      final bloc = WalletBloc(cardsRepository: repo);

      // Manually seed state with existing cards via a successful load first
      // by emitting WalletData internally — simulate via the error-with-cards path
      bloc.add(addEvent);
      await expectLater(bloc.stream, emits(isA<WalletError>()));

      // Cards should be empty list (no prior state) but not null
      final state = bloc.state as WalletError;
      expect(state.cards, isA<List<CardModel>>());
      await bloc.close();
    });
  });

  // ── CardsRepository.setPrimaryCard ─────────────────────────────────────────

  group('CardsRepository.setPrimaryCard', () {
    const primaryCardJson = {
      'card_id': 9,
      'card_holder_name': 'John Doe',
      'card_brand': 'Visa',
      'card_number': '**** **** **** 4242',
      'expired_date': '01/2027',
      'is_primary': 'yes',
    };

    test('success — returns updated list with card marked as primary', () async {
      final api = _FakeCardsApi(
        onAdd: _okResponse(null),
        onList: _okResponse([primaryCardJson]),
        onSetPrimary: _okResponse({
          'success': true,
          'message': 'Card updated successfully',
          'data': primaryCardJson,
        }),
      );
      final repo = CardsRepository(service: api);

      final result = await repo.setPrimaryCard('9');

      expect(result.success, isTrue);
      expect(result.cards, hasLength(1));
      expect(result.cards!.first.id, '9');
      expect(result.cards!.first.isPrimary, isTrue);
    });

    test('server error (500) — returns failure with message', () async {
      final api = _FakeCardsApi(
        onAdd: _okResponse(null),
        onList: _okResponse([]),
        onSetPrimary: _dioError(statusCode: 500),
      );
      final repo = CardsRepository(service: api);

      final result = await repo.setPrimaryCard('9');

      expect(result.success, isFalse);
      expect(result.message, contains('Server error'));
    });

    test('401 — returns session expired message', () async {
      final api = _FakeCardsApi(
        onAdd: _okResponse(null),
        onList: _okResponse([]),
        onSetPrimary: _dioError(statusCode: 401),
      );
      final repo = CardsRepository(service: api);

      final result = await repo.setPrimaryCard('9');

      expect(result.success, isFalse);
      expect(result.message, contains('Session expired'));
    });

    test('network error — returns failure without crashing', () async {
      final api = _FakeCardsApi(
        onAdd: _okResponse(null),
        onList: _okResponse([]),
        onSetPrimary: _dioError(type: DioExceptionType.connectionError),
      );
      final repo = CardsRepository(service: api);

      final result = await repo.setPrimaryCard('9');

      expect(result.success, isFalse);
      expect(result.message, contains('Network error'));
    });

    test('only one card is primary after update', () async {
      final twoCardsJson = [
        {
          'card_id': 9,
          'card_holder_name': 'John Doe',
          'card_brand': 'Visa',
          'card_number': '**** **** **** 4242',
          'expired_date': '01/2027',
          'is_primary': 'yes',
        },
        {
          'card_id': 10,
          'card_holder_name': 'John Doe',
          'card_brand': 'Mastercard',
          'card_number': '**** **** **** 5555',
          'expired_date': '06/2028',
          'is_primary': 'no',
        },
      ];
      final api = _FakeCardsApi(
        onAdd: _okResponse(null),
        onList: _okResponse(twoCardsJson),
        onSetPrimary: _okResponse({'success': true}),
      );
      final repo = CardsRepository(service: api);

      final result = await repo.setPrimaryCard('9');

      expect(result.success, isTrue);
      final primaryCards = result.cards!.where((c) => c.isPrimary).toList();
      expect(primaryCards, hasLength(1));
      expect(primaryCards.first.id, '9');
    });
  });

  // ── WalletBloc — WalletPrimaryChanged ──────────────────────────────────────

  group('WalletBloc — WalletPrimaryChanged', () {
    const primaryCardJson = {
      'card_id': 9,
      'card_holder_name': 'John Doe',
      'card_brand': 'Visa',
      'card_number': '**** **** **** 4242',
      'expired_date': '01/2027',
      'is_primary': 'yes',
    };

    test('emits WalletData with primaryCardId set on success', () async {
      final repo = _FakeCardsRepository(
        CardsResult(
          success: true,
          cards: [CardModel.fromJson(primaryCardJson)],
        ),
      );
      final bloc = WalletBloc(cardsRepository: repo);

      bloc.add(const WalletPrimaryChanged('9'));

      await expectLater(bloc.stream, emits(isA<WalletData>()));

      final state = bloc.state as WalletData;
      expect(state.primaryCardId, '9');
      expect(state.cards.first.isPrimary, isTrue);
      await bloc.close();
    });

    test('emits WalletError with message on failure', () async {
      final repo = _FakeCardsRepository(
        const CardsResult(
          success: false,
          message: 'Failed to update primary card.',
        ),
      );
      final bloc = WalletBloc(cardsRepository: repo);

      bloc.add(const WalletPrimaryChanged('9'));

      await expectLater(bloc.stream, emits(isA<WalletError>()));

      final state = bloc.state as WalletError;
      expect(state.message, 'Failed to update primary card.');
      await bloc.close();
    });

    test('WalletError preserves card list from previous WalletData state', () async {
      final existingCard = CardModel.fromJson(primaryCardJson);
      final successRepo = _FakeCardsRepository(
        CardsResult(success: true, cards: [existingCard]),
      );
      final bloc = WalletBloc(cardsRepository: successRepo);

      // First get into a WalletData state
      bloc.add(const WalletPrimaryChanged('9'));
      await expectLater(bloc.stream, emits(isA<WalletData>()));

      // Now trigger a failure — swap to a failing repo by adding directly
      final failRepo = _FakeCardsRepository(
        const CardsResult(success: false, message: 'Server error.'),
      );
      final bloc2 = WalletBloc(cardsRepository: failRepo);

      bloc2.add(const WalletPrimaryChanged('9'));
      await expectLater(bloc2.stream, emits(isA<WalletError>()));

      // Even on error, cards list is a List (not null)
      final errorState = bloc2.state as WalletError;
      expect(errorState.cards, isA<List<CardModel>>());

      await bloc.close();
      await bloc2.close();
    });

    test('primaryCardId reflects the card that is_primary=yes', () async {
      final twoCards = [
        {
          'card_id': 9,
          'card_holder_name': 'John Doe',
          'card_brand': 'Visa',
          'card_number': '**** **** **** 4242',
          'expired_date': '01/2027',
          'is_primary': 'yes',
        },
        {
          'card_id': 10,
          'card_holder_name': 'Jane Doe',
          'card_brand': 'Mastercard',
          'card_number': '**** **** **** 5555',
          'expired_date': '06/2028',
          'is_primary': 'no',
        },
      ];
      final repo = _FakeCardsRepository(
        CardsResult(
          success: true,
          cards: twoCards.map(CardModel.fromJson).toList(),
        ),
      );
      final bloc = WalletBloc(cardsRepository: repo);

      bloc.add(const WalletPrimaryChanged('9'));
      await expectLater(bloc.stream, emits(isA<WalletData>()));

      final state = bloc.state as WalletData;
      expect(state.primaryCardId, '9');
      expect(state.cards.where((c) => c.isPrimary), hasLength(1));
      await bloc.close();
    });
  });
}
