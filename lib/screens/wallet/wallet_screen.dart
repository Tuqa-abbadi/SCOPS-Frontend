import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:intl/intl.dart';

import '../../blocs/wallet/wallet_bloc.dart';
import '../../blocs/subscription/subscription_bloc.dart';
import '../../core/app_design.dart';
import '../../core/config/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/service_logo.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  void _confirmDelete(BuildContext context, String cardId, String nickname) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: D.cardBg,
        shape: RoundedRectangleBorder(borderRadius: D.r24),
        title: Text(
          'Delete Card',
          style: TextStyle(color: D.white, fontWeight: FontWeight.w900),
        ),
        content: Text(
          'Remove "$nickname" from your wallet?',
          style: TextStyle(color: D.textSub),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: D.textSub)),
          ),
          TextButton(
            onPressed: () {
              context.read<WalletBloc>().add(WalletCardDeleted(cardId));
              Navigator.pop(context);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: D.orange, fontWeight: FontWeight.w800),
            ),
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
        child: AddCardSheet(),
      ),
    );
  }

  void _showCardSubs(
    BuildContext context,
    CardModel card,
    List<SubscriptionModel> subs,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CardSubsSheet(card: card, subscriptions: subs),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, subState) {
        final allSubs = subState is SubscriptionData
            ? subState.subscriptions
            : <SubscriptionModel>[];
        final subsUnavailable = subState is SubscriptionError;
        final subsLoading =
            subState is SubscriptionsLoading || subState is SubscriptionInitial;

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
              return Center(child: CircularProgressIndicator(color: D.cyan));
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
              padding: EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Card Wallet',
                              style: TextStyle(
                                color: D.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text('Manage your payment cards', style: D.tsLabel),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showAddCard(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: D.orange,
                            borderRadius: D.r16,
                            boxShadow: [
                              BoxShadow(
                                color: D.orange.withValues(alpha: 0.35),
                                blurRadius: 14,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.add, color: D.white, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Add Card',
                                style: TextStyle(
                                  color: D.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 28),

                  if (cards.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 48),
                      decoration: BoxDecoration(
                        color: D.cardBg,
                        borderRadius: D.r24,
                        border: Border.all(
                          color: D.cyan.withValues(alpha: 0.25),
                          width: 1.1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: D.cyan.withValues(alpha: 0.08),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.credit_card_off_rounded,
                            color: D.textSub,
                            size: 48,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No cards yet',
                            style: TextStyle(
                              color: D.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add a card to link it\nto your subscriptions',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: D.textSub,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...cards.map((card) {
                      final isPrimary = card.id == primaryId;
                      final cardSubs = allSubs
                          .where((s) => s.cardId == card.id)
                          .toList();
                      final activeCount = cardSubs
                          .where((s) => s.isActive)
                          .length;

                      return Container(
                        margin: EdgeInsets.only(bottom: 18),
                        decoration: isPrimary
                            ? isDark
                                  ? D.glowCard(
                                      accent: D.cyan,
                                      bg: D.cardBg,
                                      radius: D.r24,
                                    )
                                  : BoxDecoration(
                                      color: D.cardBg,
                                      borderRadius: D.r24,
                                      border: Border.all(
                                        color: D.cyan.withValues(alpha: 0.22),
                                      ),
                                    )
                            : BoxDecoration(
                                color: D.cardBg,
                                borderRadius: D.r24,
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.07)
                                      : AppColors.lightBorder,
                                ),
                              ),
                        child: Column(
                          children: [
                            // ── Card visual ──────────────────────────────────
                            Container(
                              width: double.infinity,
                              height: 170,
                              padding: EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                                gradient: LinearGradient(
                                  colors: isPrimary
                                      ? isDark
                                            ? [
                                                Color(0xFF0D3A40),
                                                Color(0xFF1A2A35),
                                              ]
                                            : [
                                                Color(0xFFF5FFFF),
                                                Color(0xFFDDF3F4),
                                              ]
                                      : isDark
                                      ? [Color(0xFF1A2030), D.cardBg]
                                      : [Color(0xFFFAFBFD), Color(0xFFE9EEF5)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.memory_rounded,
                                        color: D.orange,
                                        size: 22,
                                      ),
                                      Spacer(),
                                      if (isPrimary)
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: D.cyan.withValues(
                                              alpha: 0.15,
                                            ),
                                            borderRadius: D.r12,
                                          ),
                                          child: Text(
                                            'PRIMARY',
                                            style: TextStyle(
                                              color: D.cyan,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        )
                                      else
                                        Text(
                                          card.type.toUpperCase(),
                                          style: TextStyle(
                                            color: D.textSub,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                    ],
                                  ),
                                  Spacer(),
                                  Text(
                                    '••••  ••••  ••••  ${card.maskedPan.length >= 4 ? card.maskedPan.substring(card.maskedPan.length - 4) : card.maskedPan}',
                                    style: TextStyle(
                                      color: D.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 6),
                                    child: Text(
                                      '\$${(card.balance ?? 0.0).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: D.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          card.nickname,
                                          style: TextStyle(
                                            color: D.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'EXP ${card.expiry}',
                                        style: TextStyle(
                                          color: D.textSub,
                                          fontSize: 12,
                                        ),
                                      ),
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
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.06)
                                        : AppColors.lightBorder,
                                  ),
                                ),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.receipt_long_rounded,
                                    color: subsUnavailable ? D.textSub : D.cyan,
                                    size: 15,
                                  ),
                                  SizedBox(width: 8),
                                  if (subsLoading)
                                    SizedBox(
                                      width: 11,
                                      height: 11,
                                      child: CircularProgressIndicator(
                                        color: D.cyan,
                                        strokeWidth: 1.5,
                                      ),
                                    )
                                  else if (subsUnavailable)
                                    Text(
                                      'Subscriptions unavailable',
                                      style: TextStyle(
                                        color: D.textSub,
                                        fontSize: 12,
                                      ),
                                    )
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
                                  Spacer(),
                                  if (!subsUnavailable && !subsLoading)
                                    GestureDetector(
                                      onTap: () => _showCardSubs(
                                        context,
                                        card,
                                        cardSubs,
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: D.cyan.withValues(alpha: 0.10),
                                          borderRadius: D.r12,
                                          border: Border.all(
                                            color: D.cyan.withValues(
                                              alpha: 0.25,
                                            ),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'View',
                                              style: TextStyle(
                                                color: D.cyan,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            SizedBox(width: 3),
                                            Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              color: D.cyan,
                                              size: 10,
                                            ),
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
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.06)
                                        : AppColors.lightBorder,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  if (!isPrimary)
                                    Expanded(
                                      child: TextButton.icon(
                                        onPressed: () => context
                                            .read<WalletBloc>()
                                            .add(WalletPrimaryChanged(card.id)),
                                        icon: Icon(
                                          Icons.star_rounded,
                                          color: D.cyan,
                                          size: 18,
                                        ),
                                        label: Text(
                                          'Set Primary',
                                          style: TextStyle(
                                            color: D.cyan,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.star_rounded,
                                              color: D.cyan,
                                              size: 18,
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              'Primary Card',
                                              style: TextStyle(
                                                color: D.cyan,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  Container(
                                    width: 1,
                                    height: 36,
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.06)
                                        : AppColors.lightBorder,
                                  ),
                                  Expanded(
                                    child: TextButton.icon(
                                      onPressed: () => _confirmDelete(
                                        context,
                                        card.id,
                                        card.nickname,
                                      ),
                                      icon: Icon(
                                        Icons.delete_outline_rounded,
                                        color: D.orange,
                                        size: 18,
                                      ),
                                      label: Text(
                                        'Delete',
                                        style: TextStyle(
                                          color: D.orange,
                                          fontSize: 13,
                                        ),
                                      ),
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

class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limitedDigits = digits.length > 16 ? digits.substring(0, 16) : digits;
    final buffer = StringBuffer();
    for (var i = 0; i < limitedDigits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(limitedDigits[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class _ExpiryInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return TextEditingValue();
    }

    final normalizedDigits = digits.length == 1 && int.parse(digits) > 1
        ? '0$digits'
        : digits;
    if (normalizedDigits.length >= 2) {
      final month = int.tryParse(normalizedDigits.substring(0, 2));
      if (month == null || month < 1 || month > 12) return oldValue;
    }

    final limitedDigits = normalizedDigits.length > 4
        ? normalizedDigits.substring(0, 4)
        : normalizedDigits;
    final text = limitedDigits.length <= 2
        ? limitedDigits
        : '${limitedDigits.substring(0, 2)}/${limitedDigits.substring(2)}';
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

// ── Card subscriptions sheet ───────────────────────────────────────────────────

class _CardSubsSheet extends StatelessWidget {
  const _CardSubsSheet({required this.card, required this.subscriptions});

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
        decoration: BoxDecoration(
          color: D.cardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: 18),
                  Text(
                    card.nickname,
                    style: TextStyle(
                      color: D.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    '••••  $last4  ·  ${subscriptions.length} linked subscription${subscriptions.length == 1 ? '' : 's'}',
                    style: TextStyle(color: D.textSub, fontSize: 12),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
            Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
            if (subscriptions.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.receipt_long_rounded,
                        color: D.textSub,
                        size: 48,
                      ),
                      SizedBox(height: 14),
                      Text(
                        'No subscriptions linked',
                        style: TextStyle(
                          color: D.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'This card has no subscriptions yet.',
                        style: TextStyle(color: D.textSub, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  controller: scrollCtrl,
                  padding: EdgeInsets.fromLTRB(16, 14, 16, 32),
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
                      padding: EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: D.fieldBg,
                        borderRadius: D.r16,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
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
                            clipBehavior: Clip.antiAlias,
                            child: ServiceLogo(
                              serviceName: sub.serviceName,
                              logoUrl: sub.serviceLogoUrl,
                              fallbackIcon: sub.serviceIcon,
                              fallbackFontSize: 22,
                              padding: EdgeInsets.all(5),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sub.serviceName,
                                  style: TextStyle(
                                    color: D.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  '${sub.billingCycle}  ·  Renews ${fmt.format(sub.nextRenewal)}',
                                  style: TextStyle(
                                    color: D.textSub,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${sub.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: D.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 5),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.12),
                                  borderRadius: D.r12,
                                  border: Border.all(
                                    color: statusColor.withValues(alpha: 0.30),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  statusLabel,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
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

class AddCardSheet extends StatefulWidget {
  const AddCardSheet({
    super.key,
    this.title = 'Add New Card',
    this.subtitle = 'Enter your name and card details securely through Stripe.',
    this.successMessage = 'Card added successfully!',
    this.showSkip = false,
    this.skipLabel = 'Skip for now',
    this.onCardAdded,
    this.onSkip,
  });

  final String title;
  final String subtitle;
  final String successMessage;
  final bool showSkip;
  final String skipLabel;
  final VoidCallback? onCardAdded;
  final VoidCallback? onSkip;

  @override
  State<AddCardSheet> createState() => _AddCardSheetState();
}

class _AddCardSheetState extends State<AddCardSheet> {
  final _holderCtrl = TextEditingController();
  final _cardNumberCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvcCtrl = TextEditingController();
  String? _holderError;
  String? _cardNumberError;
  String? _expiryError;
  String? _cvcError;
  bool _cardComplete = false;
  String? _activeClientSecret;
  bool _stripeInProgress = false;

  bool _isCreatingPaymentMethod = false;
  String? _saveStatus;

  @override
  void initState() {
    super.initState();
    _cardNumberCtrl.addListener(_updateManualCardComplete);
    _expiryCtrl.addListener(_updateManualCardComplete);
    _cvcCtrl.addListener(_updateManualCardComplete);
  }

  @override
  void dispose() {
    _holderCtrl.dispose();
    _cardNumberCtrl.dispose();
    _expiryCtrl.dispose();
    _cvcCtrl.dispose();
    super.dispose();
  }

  String _digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');

  ({int? month, int? year}) _parseExpiry() {
    final parts = _expiryCtrl.text.split('/');
    if (parts.length != 2) return (month: null, year: null);
    final month = int.tryParse(parts[0]);
    final shortYear = int.tryParse(parts[1]);
    return (month: month, year: shortYear == null ? null : 2000 + shortYear);
  }

  bool _isCardDetailsComplete() {
    final number = _digitsOnly(_cardNumberCtrl.text);
    final expiry = _parseExpiry();
    final cvc = _digitsOnly(_cvcCtrl.text);
    return number.length == 16 &&
        _isValidExpiry(expiry.month, expiry.year) &&
        cvc.length >= 3;
  }

  bool _isValidExpiry(int? month, int? year) {
    if (month == null || month < 1 || month > 12 || year == null) {
      return false;
    }
    final now = DateTime.now();
    final lastDayOfExpiryMonth = DateTime(year, month + 1, 0, 23, 59, 59);
    return !lastDayOfExpiryMonth.isBefore(now);
  }

  void _updateManualCardComplete() {
    final complete = _isCardDetailsComplete();
    if (complete != _cardComplete && mounted) {
      setState(() => _cardComplete = complete);
    }
  }

  bool _validate() {
    final holderError = _holderCtrl.text.trim().isEmpty
        ? 'Card holder name is required'
        : null;

    setState(() {
      _holderError = holderError;
      _cardNumberError = null;
      _expiryError = null;
      _cvcError = null;
    });
    return holderError == null;
  }

  /// Runs the full Stripe SetupIntent → PaymentSheet → save flow.
  Future<void> _runStripeFlow(
    BuildContext context,
    WalletSetupIntentReady state,
  ) async {
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
      final intent = await Stripe.instance.retrieveSetupIntent(
        state.clientSecret,
      );
      final pmId = intent.paymentMethodId;

      if (pmId.isEmpty) {
        throw Exception('Stripe did not return a payment method ID.');
      }

      if (!context.mounted) return;
      // ignore: avoid_print
      print('[AddCardSheet] Stripe payment method id: $pmId');
      context.read<WalletBloc>().add(
        WalletStripeCardSaved(
          paymentMethodId: pmId,
          cardHolderName: _holderCtrl.text.trim(),
        ),
      );
    } on StripeException catch (e) {
      // ignore: avoid_print
      print('[AddCardSheet] Stripe error: ${e.error.localizedMessage}');
      if (!context.mounted) return;
      if (e.error.code == FailureCode.Canceled) {
        // User dismissed the sheet — reset bloc back to WalletData.
        context.read<WalletBloc>().add(WalletLoaded());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.error.localizedMessage ?? 'Card setup failed.'),
            backgroundColor: D.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.read<WalletBloc>().add(WalletLoaded());
      }
    } catch (e) {
      // ignore: avoid_print
      print('[AddCardSheet] Unexpected error: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: D.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.read<WalletBloc>().add(WalletLoaded());
    } finally {
      _activeClientSecret = null;
      if (mounted) setState(() => _stripeInProgress = false);
    }
  }

  void _requestStripeCardSetup(BuildContext context) {
    // ignore: avoid_print
    print('[AddCardSheet] Continue to Stripe tapped');

    if (!_validate()) return;

    if (AppConfig.stripePublishableKey.contains('YOUR_KEY_HERE')) {
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: D.cardBg,
          shape: RoundedRectangleBorder(borderRadius: D.r24),
          title: Text(
            'Stripe Key Missing',
            style: TextStyle(color: D.white, fontWeight: FontWeight.w900),
          ),
          content: Text(
            'Set your real Stripe publishable key in app_config.dart before saving cards.',
            style: TextStyle(color: D.textSub),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('OK', style: TextStyle(color: D.cyan)),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => _saveStatus = 'Opening Stripe...');
    context.read<WalletBloc>().add(WalletSetupIntentRequested());
  }

  BoxDecoration _cardBoxDecoration({Color? borderColor, bool glow = false}) =>
      BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? D.cardBg.withValues(alpha: 0.96)
            : AppColors.lightSurface,
        borderRadius: D.r20,
        border: Border.all(
          color:
              borderColor ??
              (Theme.of(context).brightness == Brightness.dark
                  ? const Color(0x2633F4FF)
                  : AppColors.lightBorder),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.38)
                : AppColors.lightTextPrimary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: Offset(0, 10),
          ),
          if (glow)
            BoxShadow(color: D.cyan.withValues(alpha: 0.12), blurRadius: 22),
        ],
      );

  Widget _inputShell({
    required IconData icon,
    required String label,
    required Widget child,
    bool dense = false,
    String? errorText,
  }) {
    return Container(
      height: errorText == null ? (dense ? 70 : 76) : (dense ? 86 : 92),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: _cardBoxDecoration(),
      child: Row(
        children: [
          Icon(icon, color: D.cyan, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: D.textSub.withValues(alpha: 0.95),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 5),
                child,
                if (errorText != null) ...[
                  SizedBox(height: 4),
                  Text(
                    errorText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: D.orange, fontSize: 10),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _flatFieldDecoration(String hint) => InputDecoration(
    isDense: true,
    hintText: hint,
    hintStyle: TextStyle(
      color: D.textSub.withValues(alpha: 0.80),
      fontSize: 16,
    ),
    filled: false,
    fillColor: Colors.transparent,
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    disabledBorder: InputBorder.none,
    errorBorder: InputBorder.none,
    focusedErrorBorder: InputBorder.none,
    contentPadding: EdgeInsets.zero,
  );

  Widget _manualCardField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    required String hint,
    required bool isBusy,
    required List<TextInputFormatter> inputFormatters,
    TextInputType keyboardType = TextInputType.number,
    String? errorText,
    bool dense = false,
  }) {
    return _inputShell(
      icon: icon,
      label: label,
      dense: dense,
      errorText: errorText,
      child: TextField(
        controller: controller,
        enabled: !isBusy,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: TextStyle(
          color: D.white,
          fontWeight: FontWeight.w700,
          fontSize: 16,
          letterSpacing: 0,
        ),
        cursorColor: D.cyan,
        decoration: _flatFieldDecoration(hint),
      ),
    );
  }

  Widget _securityNotice() {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: _cardBoxDecoration(
        borderColor: D.cyan.withValues(alpha: 0.70),
        glow: true,
      ),
      child: Row(
        children: [
          Icon(Icons.shield_outlined, color: D.cyan, size: 28),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Card details are securely handled by Stripe. We never store your card details.',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.78)
                    : AppColors.lightTextSecondary,
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _saveButton({
    required bool isBusy,
    required String? statusText,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: D.r20,
        gradient: LinearGradient(
          colors: [Color(0xFFFF8A00), D.orange, Color(0xFFFF2F17)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: D.orange.withValues(alpha: 0.34),
            blurRadius: 30,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: D.white,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: D.r20),
          elevation: 0,
        ),
        child: isBusy
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.3,
                    ),
                  ),
                  SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      statusText ?? 'Saving...',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Save Card',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  SizedBox(width: 12),
                  Icon(Icons.arrow_forward_rounded, size: 25),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WalletBloc, WalletState>(
      listenWhen: (_, s) =>
          s is WalletAddingCard ||
          s is WalletSetupIntentReady ||
          (s is WalletData && s.cardJustAdded) ||
          s is WalletError,
      listener: (context, state) {
        if (state is WalletSetupIntentReady) {
          _runStripeFlow(context, state);
        } else if (state is WalletData && state.cardJustAdded) {
          if (mounted) {
            setState(() {
              _saveStatus = null;
            });
          }
          final messenger = ScaffoldMessenger.of(context);
          Navigator.of(context).pop();
          widget.onCardAdded?.call();
          messenger.showSnackBar(
            SnackBar(
              content: Text(widget.successMessage),
              backgroundColor: D.cyan,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is WalletError) {
          if (mounted) {
            setState(() {
              _saveStatus = null;
            });
          }
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
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final isBusy = state is WalletAddingCard || _isCreatingPaymentMethod;
        final statusText = state is WalletAddingCard
            ? 'Saving to server...'
            : _saveStatus;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.90,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              border: Border(
                top: BorderSide(color: D.cyan.withValues(alpha: 0.22)),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [D.bg, Color(0xFF080B10), Color(0xFF030507)]
                    : [
                        AppColors.lightBackground,
                        AppColors.lightSurface,
                        AppColors.lightSecondarySurface,
                      ],
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? D.cyan.withValues(alpha: 0.12)
                      : AppColors.lightTextPrimary.withValues(alpha: 0.08),
                  blurRadius: 42,
                  offset: Offset(0, -12),
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 14, 20, 26),
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
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.15)
                            : AppColors.lightBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            color: D.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (widget.showSkip)
                        TextButton(
                          onPressed: isBusy
                              ? null
                              : () {
                                  Navigator.of(context).pop();
                                  widget.onSkip?.call();
                                },
                          style: TextButton.styleFrom(
                            foregroundColor: D.textSub,
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            minimumSize: Size(0, 34),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            widget.skipLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    widget.subtitle,
                    style: TextStyle(color: D.textSub, fontSize: 12),
                  ),
                  SizedBox(height: 24),

                  _securityNotice(),
                  SizedBox(height: 18),

                  // Card holder name — the only field Flutter collects
                  Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Card Holder Name',
                      style: TextStyle(
                        color: D.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  _inputShell(
                    icon: Icons.person_outline_rounded,
                    label: 'Name on Card',
                    errorText: _holderError,
                    child: TextField(
                      controller: _holderCtrl,
                      textCapitalization: TextCapitalization.words,
                      enabled: !isBusy,
                      style: TextStyle(
                        color: D.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                      cursorColor: D.cyan,
                      decoration: _flatFieldDecoration('e.g. John Doe'),
                    ),
                  ),
                  SizedBox(height: 12),

                  // Stripe badge — reassures user card details stay with Stripe
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: D.cyan.withValues(alpha: 0.06),
                      borderRadius: D.r12,
                      border: Border.all(color: D.cyan.withValues(alpha: 0.20)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          color: D.cyan,
                          size: 15,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Card details are entered directly in Stripe\'s secure sheet — never stored in this app.',
                            style: TextStyle(
                              color: D.textSub,
                              fontSize: 11,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isBusy
                          ? null
                          : () => _requestStripeCardSetup(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: D.orange,
                        foregroundColor: isDark
                            ? D.white
                            : Theme.of(context).colorScheme.onSecondary,
                        disabledBackgroundColor: D.orange.withValues(
                          alpha: 0.45,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: D.r16),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      child: isBusy
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.3,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    statusText ?? 'Saving...',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              'Continue to Stripe',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
