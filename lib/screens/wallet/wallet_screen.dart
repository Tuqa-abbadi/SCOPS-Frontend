import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/wallet/wallet_bloc.dart';
import '../../core/app_design.dart';

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

  @override
  Widget build(BuildContext context) {
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
                              color: D.orange.withOpacity(0.35),
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
                        color: D.cyan.withOpacity(0.25), width: 1.1),
                    boxShadow: [
                      BoxShadow(
                          color: D.cyan.withOpacity(0.08), blurRadius: 20)
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
                  return Container(
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: isPrimary
                        ? D.glowCard(
                            accent: D.cyan, bg: D.cardBg, radius: D.r24)
                        : BoxDecoration(
                            color: D.cardBg,
                            borderRadius: D.r24,
                            border: Border.all(
                                color: Colors.white.withOpacity(0.07))),
                    child: Column(
                      children: [
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
                                        color: D.cyan.withOpacity(0.15),
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
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                                top: BorderSide(
                                    color: Colors.white.withOpacity(0.06))),
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
                                                fontWeight: FontWeight.w700)),
                                      ],
                                    ),
                                  ),
                                ),
                              Container(
                                  width: 1,
                                  height: 36,
                                  color: Colors.white.withOpacity(0.06)),
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
  }
}

// ── Card number input formatter ────────────────────────────────────────────────

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 16 ? digits.substring(0, 16) : digits;
    final buffer = StringBuffer();
    for (int i = 0; i < limited.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write('  ');
      buffer.write(limited[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
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
  final _numberCtrl = TextEditingController();
  final _monthCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _yearFocus = FocusNode();

  String? _holderError;
  String? _numberError;
  String? _expiryError;

  @override
  void dispose() {
    _holderCtrl.dispose();
    _numberCtrl.dispose();
    _monthCtrl.dispose();
    _yearCtrl.dispose();
    _yearFocus.dispose();
    super.dispose();
  }

  String get _rawDigits => _numberCtrl.text.replaceAll(RegExp(r'\s'), '');

  String get _cardType {
    final d = _rawDigits;
    if (d.isEmpty) return '';
    if (d.length >= 2 && (d.startsWith('34') || d.startsWith('37'))) {
      return 'Amex';
    }
    if (d.startsWith('4')) return 'Visa';
    if (d.startsWith('5')) return 'Mastercard';
    return '';
  }

  Color _typeAccent(String type) {
    if (type == 'Visa') return const Color(0xFF4B79FF);
    if (type == 'Mastercard') return const Color(0xFFEB001B);
    if (type == 'Amex') return D.cyan;
    return Colors.transparent;
  }

  bool _validate() {
    String? he, ne, ee;
    bool ok = true;

    if (_holderCtrl.text.trim().isEmpty) {
      he = 'Card holder name is required';
      ok = false;
    }

    final d = _rawDigits;
    if (d.isEmpty) {
      ne = 'Card number is required';
      ok = false;
    } else if (d.length < 13 || d.length > 19) {
      ne = 'Card number must be 13–19 digits';
      ok = false;
    }

    final month = int.tryParse(_monthCtrl.text.trim());
    final year = int.tryParse(_yearCtrl.text.trim());
    final now = DateTime.now();
    if (month == null || month < 1 || month > 12) {
      ee = 'Enter a valid month (01–12)';
      ok = false;
    } else if (year == null ||
        _yearCtrl.text.trim().length != 4 ||
        year < now.year) {
      ee = 'Enter a valid expiry year';
      ok = false;
    }

    setState(() {
      _holderError = he;
      _numberError = ne;
      _expiryError = ee;
    });
    return ok;
  }

  void _submit() {
    if (!_validate()) return;
    context.read<WalletBloc>().add(WalletCardAdded(
          cardHolderName: _holderCtrl.text.trim(),
          cardNumber: _rawDigits,
          expiryMonth: int.parse(_monthCtrl.text.trim()),
          expiryYear: int.parse(_yearCtrl.text.trim()),
        ));
    Navigator.pop(context);
  }

  InputDecoration _fieldDec(
    String hint, {
    Widget? prefix,
    Widget? suffix,
  }) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: D.textSub, fontSize: 13),
        filled: true,
        fillColor: D.fieldBg,
        border: OutlineInputBorder(
            borderRadius: D.r16, borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: D.r16,
          borderSide:
              BorderSide(color: Colors.white.withOpacity(0.07), width: 1),
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
        suffixIcon: suffix,
        errorStyle: const TextStyle(color: D.orange, fontSize: 11),
      );

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text,
            style: const TextStyle(
                color: D.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 0.2)),
      );

  Widget _cardTypeBadge() {
    final type = _cardType;
    if (type.isEmpty) return const SizedBox.shrink();
    final accent = _typeAccent(type);
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: accent.withOpacity(0.45), width: 1),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(
            color: accent,
            fontWeight: FontWeight.w900,
            fontSize: 9,
            letterSpacing: 0.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    color: Colors.white.withOpacity(0.15),
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
            const Text('Your card details are securely stored.',
                style: TextStyle(color: D.textSub, fontSize: 12)),
            const SizedBox(height: 24),

            // Card Holder Name
            _label('Card Holder Name'),
            TextField(
              controller: _holderCtrl,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(
                  color: D.white, fontWeight: FontWeight.w600),
              decoration: _fieldDec(
                'e.g. John Doe',
                prefix: const Icon(Icons.person_outline_rounded,
                    color: D.textSub, size: 20),
              ).copyWith(errorText: _holderError),
            ),
            const SizedBox(height: 18),

            // Card Number
            _label('Card Number'),
            TextField(
              controller: _numberCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [_CardNumberFormatter()],
              onChanged: (_) => setState(() {}),
              style: const TextStyle(
                  color: D.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                  fontSize: 15),
              decoration: _fieldDec(
                '0000  0000  0000  0000',
                prefix: const Icon(Icons.credit_card_rounded,
                    color: D.textSub, size: 20),
                suffix: Align(
                  widthFactor: 1.0,
                  alignment: Alignment.centerRight,
                  child: _cardTypeBadge(),
                ),
              ).copyWith(errorText: _numberError),
            ),
            const SizedBox(height: 18),

            // Expiry Date
            _label('Expiry Date'),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month
                Expanded(
                  child: TextField(
                    controller: _monthCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 2,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (v) {
                      if (v.length == 2) _yearFocus.requestFocus();
                    },
                    style: const TextStyle(
                        color: D.white, fontWeight: FontWeight.w600),
                    decoration: _fieldDec('MM').copyWith(
                      counterText: '',
                      // Show red border on error without repeating the message
                      errorText: _expiryError != null ? '' : null,
                      errorStyle: const TextStyle(fontSize: 0, height: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Year
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _yearCtrl,
                    focusNode: _yearFocus,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(
                        color: D.white, fontWeight: FontWeight.w600),
                    decoration: _fieldDec('YYYY').copyWith(counterText: ''),
                  ),
                ),
              ],
            ),
            if (_expiryError != null)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Text(_expiryError!,
                    style:
                        const TextStyle(color: D.orange, fontSize: 11)),
              ),

            const SizedBox(height: 28),

            // Submit
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: D.orange,
                  foregroundColor: D.white,
                  shape: RoundedRectangleBorder(borderRadius: D.r16),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: const Text('Save Card',
                    style: TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
