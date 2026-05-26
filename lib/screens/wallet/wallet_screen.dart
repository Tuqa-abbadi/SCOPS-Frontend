import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:intl/intl.dart';

import '../../blocs/wallet/wallet_bloc.dart';
import '../../blocs/subscription/subscription_bloc.dart';
import '../../core/app_design.dart';
import '../../core/config/app_config.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  void _confirmDelete(BuildContext context, String cardId, String nickname) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: D.cardBg,
        shape: RoundedRectangleBorder(borderRadius: D.r24),
        title: const Text('Delete Card',
            style: TextStyle(color: D.white, fontWeight: FontWeight.w900)),
        content: Text('Remove "$nickname" from your wallet?',
            style: const TextStyle(color: D.textSub)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: D.textSub))),
          TextButton(
            onPressed: () {
              context.read<WalletBloc>().add(WalletCardDeleted(cardId));
              Navigator.pop(context);
            },
            child: const Text('Delete',
                style: TextStyle(
                    color: D.orange, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _showAddCard(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<WalletBloc>(),
        child: const _AddCardSheet(),
      ),
    );
  }

  void _showCardSubs(
      BuildContext context, CardModel card, List<SubscriptionModel> subs) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CardSubsSheet(card: card, subscriptions: subs),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, subState) {
        final allSubs = subState is SubscriptionData
            ? subState.subscriptions
            : <SubscriptionModel>[];
        final subsUnavailable = subState is SubscriptionError;
        final subsLoading = subState is SubscriptionsLoading ||
            subState is SubscriptionInitial;

        return BlocConsumer<WalletBloc, WalletState>(
          listener: (context, state) {
            if (state is WalletError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: D.orange,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is WalletLoading) {
              return const Center(
                child: CircularProgressIndicator(color: D.cyan),
              );
            }

            final cards = state is WalletData
                ? state.cards
                : state is WalletError
                    ? state.cards
                    : <CardModel>[];
            final primaryId = state is WalletData
                ? state.primaryCardId
                : state is WalletError
                    ? state.primaryCardId
                    : null;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Card Wallet',
                                style: TextStyle(
                                    color: D.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900)),
                            SizedBox(height: 4),
                            Text('Manage your payment cards', style: D.tsLabel),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showAddCard(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                          decoration: BoxDecoration(
                            color: D.orange,
                            borderRadius: D.r16,
                            boxShadow: [
                              BoxShadow(
                                  color: D.orange.withValues(alpha: 0.35),
                                  blurRadius: 14)
                            ],
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.add, color: D.white, size: 18),
                              SizedBox(width: 6),
                              Text('Add Card',
                                  style: TextStyle(
                                      color: D.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  if (cards.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      decoration: BoxDecoration(
                        color: D.cardBg,
                        borderRadius: D.r24,
                        border: Border.all(
                            color: D.cyan.withValues(alpha: 0.25), width: 1.1),
                        boxShadow: [
                          BoxShadow(
                              color: D.cyan.withValues(alpha: 0.08), blurRadius: 20)
                        ],
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.credit_card_off_rounded,
                              color: D.textSub, size: 48),
                          SizedBox(height: 16),
                          Text('No cards yet',
                              style: TextStyle(
                                  color: D.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16)),
                          SizedBox(height: 8),
                          Text('Add a card to link it\nto your subscriptions',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: D.textSub, fontSize: 13, height: 1.5)),
                        ],
                      ),
                    )
                  else
                    ...cards.map((card) {
                      final isPrimary = card.id == primaryId;
                      final cardSubs =
                          allSubs.where((s) => s.cardId == card.id).toList();
                      final activeCount =
                          cardSubs.where((s) => s.isActive).length;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: isPrimary
                            ? D.glowCard(
                                accent: D.cyan, bg: D.cardBg, radius: D.r24)
                            : BoxDecoration(
                                color: D.cardBg,
                                borderRadius: D.r24,
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.07))),
                        child: Column(
                          children: [
                            // ── Card visual ──────────────────────────────────
                            Container(
                              width: double.infinity,
                              height: 170,
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(24)),
                                gradient: LinearGradient(
                                  colors: isPrimary
                                      ? [
                                          const Color(0xFF0D3A40),
                                          const Color(0xFF1A2A35)
                                        ]
                                      : [
                                          const Color(0xFF1A2030),
                                          D.cardBg
                                        ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.memory_rounded,
                                          color: D.orange, size: 22),
                                      const Spacer(),
                                      if (isPrimary)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: D.cyan.withValues(alpha: 0.15),
                                            borderRadius: D.r12,
                                          ),
                                          child: const Text('PRIMARY',
                                              style: TextStyle(
                                                  color: D.cyan,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 1)),
                                        )
                                      else
                                        Text(card.type.toUpperCase(),
                                            style: const TextStyle(
                                                color: D.textSub,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                  const Spacer(),
                                  Text(
                                    '••••  ••••  ••••  ${card.maskedPan.length >= 4 ? card.maskedPan.substring(card.maskedPan.length - 4) : card.maskedPan}',
                                    style: const TextStyle(
                                        color: D.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 2),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: Text(card.nickname,
                                              style: const TextStyle(
                                                  color: D.white,
                                                  fontWeight: FontWeight.w700))),
                                      Text('EXP ${card.expiry}',
                                          style: const TextStyle(
                                              color: D.textSub, fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // ── Subscription count + View ─────────────────────
                            Container(
                              decoration: BoxDecoration(
                                border: Border(
                                    top: BorderSide(
                                        color:
                                            Colors.white.withValues(alpha: 0.06))),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.receipt_long_rounded,
                                    color:
                                        subsUnavailable ? D.textSub : D.cyan,
                                    size: 15,
                                  ),
                                  const SizedBox(width: 8),
                                  if (subsLoading)
                                    const SizedBox(
                                      width: 11,
                                      height: 11,
                                      child: CircularProgressIndicator(
                                          color: D.cyan, strokeWidth: 1.5),
                                    )
                                  else if (subsUnavailable)
                                    const Text('Subscriptions unavailable',
                                        style: TextStyle(
                                            color: D.textSub, fontSize: 12))
                                  else
                                    Text(
                                      '$activeCount active ${activeCount == 1 ? 'subscription' : 'subscriptions'}',
                                      style: TextStyle(
                                        color: activeCount > 0
                                            ? D.cyan
                                            : D.textSub,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  const Spacer(),
                                  if (!subsUnavailable && !subsLoading)
                                    GestureDetector(
                                      onTap: () => _showCardSubs(
                                          context, card, cardSubs),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: D.cyan.withValues(alpha: 0.10),
                                          borderRadius: D.r12,
                                          border: Border.all(
                                              color: D.cyan.withValues(alpha: 0.25),
                                              width: 1),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text('View',
                                                style: TextStyle(
                                                    color: D.cyan,
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.w700)),
                                            SizedBox(width: 3),
                                            Icon(
                                                Icons.arrow_forward_ios_rounded,
                                                color: D.cyan,
                                                size: 10),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // ── Card actions ─────────────────────────────────
                            Container(
                              decoration: BoxDecoration(
                                border: Border(
                                    top: BorderSide(
                                        color:
                                            Colors.white.withValues(alpha: 0.06))),
                              ),
                              child: Row(
                                children: [
                                  if (!isPrimary)
                                    Expanded(
                                      child: TextButton.icon(
                                        onPressed: () => context
                                            .read<WalletBloc>()
                                            .add(WalletPrimaryChanged(card.id)),
                                        icon: const Icon(Icons.star_rounded,
                                            color: D.cyan, size: 18),
                                        label: const Text('Set Primary',
                                            style: TextStyle(
                                                color: D.cyan, fontSize: 13)),
                                      ),
                                    )
                                  else
                                    const Expanded(
                                      child: Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 12),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.star_rounded,
                                                color: D.cyan, size: 18),
                                            SizedBox(width: 6),
                                            Text('Primary Card',
                                                style: TextStyle(
                                                    color: D.cyan,
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w700)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  Container(
                                      width: 1,
                                      height: 36,
                                      color: Colors.white.withValues(alpha: 0.06)),
                                  Expanded(
                                    child: TextButton.icon(
                                      onPressed: () => _confirmDelete(
                                          context, card.id, card.nickname),
                                      icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: D.orange,
                                          size: 18),
                                      label: const Text('Delete',
                                          style: TextStyle(
                                              color: D.orange, fontSize: 13)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── Card subscriptions sheet ───────────────────────────────────────────────────

class _CardSubsSheet extends StatelessWidget {
  const _CardSubsSheet({
    required this.card,
    required this.subscriptions,
  });

  final CardModel card;
  final List<SubscriptionModel> subscriptions;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM dd, yyyy');
    final last4 = card.maskedPan.length >= 4
        ? card.maskedPan.substring(card.maskedPan.length - 4)
        : card.maskedPan;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: D.cardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(card.nickname,
                      style: const TextStyle(
                          color: D.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 3),
                  Text(
                    '••••  $last4  ·  ${subscriptions.length} linked subscription${subscriptions.length == 1 ? '' : 's'}',
                    style: const TextStyle(color: D.textSub, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
            if (subscriptions.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.receipt_long_rounded,
                          color: D.textSub, size: 48),
                      SizedBox(height: 14),
                      Text('No subscriptions linked',
                          style: TextStyle(
                              color: D.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15)),
                      SizedBox(height: 6),
                      Text('This card has no subscriptions yet.',
                          style: TextStyle(color: D.textSub, fontSize: 13)),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
                  itemCount: subscriptions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final sub = subscriptions[i];
                    final statusColor = sub.isActive
                        ? D.cyan
                        : sub.isPaused
                            ? Colors.amber
                            : D.orange;
                    final statusLabel = sub.isActive
                        ? 'Active'
                        : sub.isPaused
                            ? 'Paused'
                            : 'Cancelled';

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: D.fieldBg,
                        borderRadius: D.r16,
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.06)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.30),
                              borderRadius: D.r12,
                            ),
                            child: Center(
                              child: Text(sub.serviceIcon,
                                  style: const TextStyle(fontSize: 22)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(sub.serviceName,
                                    style: const TextStyle(
                                        color: D.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14)),
                                const SizedBox(height: 3),
                                Text(
                                  '${sub.billingCycle}  ·  Renews ${fmt.format(sub.nextRenewal)}',
                                  style: const TextStyle(
                                      color: D.textSub, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${sub.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    color: D.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.12),
                                  borderRadius: D.r12,
                                  border: Border.all(
                                      color: statusColor.withValues(alpha: 0.30),
                                      width: 1),
                                ),
                                child: Text(statusLabel,
                                    style: TextStyle(
                                        color: statusColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Add Card bottom sheet ──────────────────────────────────────────────────────

class _AddCardSheet extends StatefulWidget {
  const _AddCardSheet();

  @override
  State<_AddCardSheet> createState() => _AddCardSheetState();
}

class _AddCardSheetState extends State<_AddCardSheet> {
  final _holderCtrl = TextEditingController();
  String? _holderError;
  bool _cardComplete = false;
  String? _activeClientSecret;
  bool _stripeInProgress = false;

  bool _isCreatingPaymentMethod = false;
  String? _saveStatus;

  @override
  void dispose() {
    _holderCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    final holderError =
        _holderCtrl.text.trim().isEmpty ? 'Card holder name is required' : null;
    setState(() => _holderError = holderError);
    return holderError == null;
  }

  /// Runs the full Stripe SetupIntent → PaymentSheet → save flow.
  Future<void> _runStripeFlow(
      BuildContext context, WalletSetupIntentReady state) async {
    if (_stripeInProgress || _activeClientSecret == state.clientSecret) return;
    _activeClientSecret = state.clientSecret;
    setState(() => _stripeInProgress = true);
    // ignore: avoid_print
    print('[AddCardSheet] Opening Stripe PaymentSheet');
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          setupIntentClientSecret: state.clientSecret,
          merchantDisplayName: 'SCOPS',
          customerId: state.customerEphemeralKeySecret == null
              ? null
              : state.customerId,
          customerEphemeralKeySecret: state.customerEphemeralKeySecret,
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      // ignore: avoid_print
      print('[AddCardSheet] Stripe PaymentSheet completed');

      // Retrieve the confirmed SetupIntent to get the payment method ID.
      final intent =
          await Stripe.instance.retrieveSetupIntent(state.clientSecret);
      final pmId = intent.paymentMethodId;

      if (pmId.isEmpty) {
        throw Exception('Stripe did not return a payment method ID.');
      }

      if (!context.mounted) return;
      context.read<WalletBloc>().add(WalletStripeCardSaved(
            paymentMethodId: pmId,
            cardHolderName: _holderCtrl.text.trim(),
          ));
    } on StripeException catch (e) {
      // ignore: avoid_print
      print('[AddCardSheet] Stripe error: ${e.error.localizedMessage}');
      if (!context.mounted) return;
      if (e.error.code == FailureCode.Canceled) {
        // User dismissed the sheet — reset bloc back to WalletData.
        context.read<WalletBloc>().add(const WalletLoaded());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.error.localizedMessage ?? 'Card setup failed.'),
          backgroundColor: D.orange,
          behavior: SnackBarBehavior.floating,
        ));
        context.read<WalletBloc>().add(const WalletLoaded());
      }
    } catch (e) {
      // ignore: avoid_print
      print('[AddCardSheet] Unexpected error: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: D.orange,
        behavior: SnackBarBehavior.floating,
      ));
      context.read<WalletBloc>().add(const WalletLoaded());
    } finally {
      _activeClientSecret = null;
      if (mounted) setState(() => _stripeInProgress = false);
    }
  }

  Future<void> _createAndSavePaymentMethod(BuildContext context) async {
    // ignore: avoid_print
    print('[AddCardSheet] Save Card tapped');

    if (!_validate()) return;

    if (AppConfig.stripePublishableKey.contains('YOUR_KEY_HERE')) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: D.cardBg,
          shape: RoundedRectangleBorder(borderRadius: D.r24),
          title: const Text(
            'Stripe Key Missing',
            style: TextStyle(color: D.white, fontWeight: FontWeight.w900),
          ),
          content: const Text(
            'Set your real Stripe publishable key in app_config.dart before saving cards.',
            style: TextStyle(color: D.textSub),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK', style: TextStyle(color: D.cyan)),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _isCreatingPaymentMethod = true;
      _saveStatus = 'Creating card token...';
    });
    try {
      final holderName = _holderCtrl.text.trim();
      // ignore: avoid_print
      print('[AddCardSheet] Creating Stripe payment method');
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(name: holderName),
          ),
        ),
      ).timeout(const Duration(seconds: 15));

      if (paymentMethod.id.isEmpty) {
        throw Exception('Stripe did not return a payment method ID.');
      }

      if (!context.mounted) return;
      setState(() => _saveStatus = 'Saving to server...');
      // ignore: avoid_print
      print('[AddCardSheet] Saving payment method ${paymentMethod.id}');
      context.read<WalletBloc>().add(WalletStripeCardSaved(
            paymentMethodId: paymentMethod.id,
            cardHolderName: holderName,
          ));
    } on StripeException catch (e) {
      if (mounted) setState(() => _saveStatus = null);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.error.localizedMessage ?? 'Card setup failed.'),
        backgroundColor: D.orange,
        behavior: SnackBarBehavior.floating,
      ));
    } on TimeoutException {
      if (mounted) setState(() => _saveStatus = null);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Stripe took too long. Please try again.'),
        backgroundColor: D.orange,
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      if (mounted) setState(() => _saveStatus = null);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: D.orange,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _isCreatingPaymentMethod = false);
    }
  }

  InputDecoration _fieldDec(String hint, {Widget? prefix}) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: D.textSub, fontSize: 13),
        filled: true,
        fillColor: D.fieldBg,
        border:
            OutlineInputBorder(borderRadius: D.r16, borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: D.r16,
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.07), width: 1),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: D.r16,
          borderSide: BorderSide(color: D.cyan, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: D.r16,
          borderSide: BorderSide(color: D.orange, width: 1.2),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: D.r16,
          borderSide: BorderSide(color: D.orange, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        prefixIcon: prefix,
        errorStyle: const TextStyle(color: D.orange, fontSize: 11),
      );

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WalletBloc, WalletState>(
      listenWhen: (_, s) =>
          s is WalletAddingCard ||
          (s is WalletData && s.cardJustAdded) ||
          s is WalletError,
      listener: (context, state) {
        if (state is WalletData && state.cardJustAdded) {
          if (mounted) {
            setState(() {
              _saveStatus = null;
            });
          }
          final messenger = ScaffoldMessenger.of(context);
          Navigator.of(context).pop();
          messenger.showSnackBar(const SnackBar(
            content: Text('Card added successfully!'),
            backgroundColor: D.cyan,
            behavior: SnackBarBehavior.floating,
          ));
        } else if (state is WalletError) {
          if (mounted) {
            setState(() {
              _saveStatus = null;
            });
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: D.orange,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      builder: (context, state) {
        final isBusy = state is WalletAddingCard || _isCreatingPaymentMethod;
        final statusText =
            state is WalletAddingCard ? 'Saving to server...' : _saveStatus;

        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: D.cardBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Add New Card',
                    style: TextStyle(
                        color: D.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                const Text(
                  'Enter your name and card details securely through Stripe.',
                  style: TextStyle(color: D.textSub, fontSize: 12),
                ),
                const SizedBox(height: 24),

                const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text('Card Details',
                      style: TextStyle(
                          color: D.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: D.fieldBg,
                    borderRadius: D.r16,
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.07)),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: CardField(
                    disabled: isBusy,
                    enablePostalCode: false,
                    cursorColor: D.cyan,
                    style: const TextStyle(color: D.white, fontSize: 14),
                    decoration: const InputDecoration(border: InputBorder.none),
                    onCardChanged: (details) {
                      setState(() => _cardComplete = details?.complete ?? false);
                    },
                  ),
                ),
                const SizedBox(height: 18),

                // Card holder name — the only field Flutter collects
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: const Text('Card Holder Name',
                      style: TextStyle(
                          color: D.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                ),
                TextField(
                  controller: _holderCtrl,
                  textCapitalization: TextCapitalization.words,
                  enabled: !isBusy,
                  style: const TextStyle(
                      color: D.white, fontWeight: FontWeight.w600),
                  decoration: _fieldDec(
                    'e.g. John Doe',
                    prefix: const Icon(Icons.person_outline_rounded,
                        color: D.textSub, size: 20),
                  ).copyWith(errorText: _holderError),
                ),
                const SizedBox(height: 12),

                // Stripe badge — reassures user card details stay with Stripe
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: D.cyan.withValues(alpha: 0.06),
                    borderRadius: D.r12,
                    border:
                        Border.all(color: D.cyan.withValues(alpha: 0.20)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lock_outline_rounded,
                          color: D.cyan, size: 15),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Card details are entered directly in Stripe\'s secure sheet — never stored in this app.',
                          style: TextStyle(
                              color: D.textSub, fontSize: 11, height: 1.45),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isBusy
                        ? null
                        : () => _createAndSavePaymentMethod(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: D.orange,
                      foregroundColor: D.white,
                      disabledBackgroundColor:
                          D.orange.withValues(alpha: 0.45),
                      shape: RoundedRectangleBorder(borderRadius: D.r16),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    child: isBusy
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.3),
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(statusText ?? 'Saving...',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 14)),
                              ),
                            ],
                          )
                        : const Text('Save Card',
                            style: TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
