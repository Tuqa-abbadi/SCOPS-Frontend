import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/wallet/wallet_bloc.dart';
import '../../core/app_design.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  Widget _field({
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
  }) =>
      Container(
        decoration: BoxDecoration(color: D.fieldBg, borderRadius: D.r16),
        child: TextField(
          controller: ctrl,
          keyboardType: keyboard,
          style: const TextStyle(color: D.white, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: D.textSub),
            prefixIcon: Icon(icon, color: D.textSub),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      );

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
    final nicknameCtrl = TextEditingController();
    final panCtrl = TextEditingController();
    final expiryCtrl = TextEditingController();
    String selectedType = 'Visa';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<WalletBloc>(),
        child: StatefulBuilder(
          builder: (ctx, set) => Padding(
            padding:
                EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              decoration: const BoxDecoration(
                color: D.cardBg,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: D.r12),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Add New Card',
                      style: TextStyle(
                          color: D.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 20),
                  _field(
                      ctrl: nicknameCtrl,
                      hint: 'Card nickname (e.g. My Visa)',
                      icon: Icons.label_outline_rounded),
                  const SizedBox(height: 12),
                  _field(
                      ctrl: panCtrl,
                      hint: 'Card number ',
                      icon: Icons.credit_card_rounded,
                      keyboard: TextInputType.number),
                  const SizedBox(height: 12),
                  _field(
                      ctrl: expiryCtrl,
                      hint: 'Expiry  MM/YY',
                      icon: Icons.calendar_today_rounded),
                  const SizedBox(height: 14),
                  Row(
                    children: ['Visa', 'Mastercard', 'Amex']
                        .map((t) => Expanded(
                              child: GestureDetector(
                                onTap: () => set(() => selectedType = t),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: EdgeInsets.only(
                                      right: t != 'Amex' ? 10 : 0),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: selectedType == t
                                        ? D.cyan
                                        : D.fieldBg,
                                    borderRadius: D.r12,
                                    border: Border.all(
                                        color: selectedType == t
                                            ? D.cyan
                                            : Colors.white.withOpacity(0.07)),
                                    boxShadow: selectedType == t
                                        ? [
                                            BoxShadow(
                                                color:
                                                    D.cyan.withOpacity(0.28),
                                                blurRadius: 10)
                                          ]
                                        : [],
                                  ),
                                  child: Text(t,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: selectedType == t
                                              ? const Color(0xFF0D1A1C)
                                              : D.textSub,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12)),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nicknameCtrl.text.isEmpty ||
                            panCtrl.text.isEmpty ||
                            expiryCtrl.text.isEmpty) return;
                        ctx.read<WalletBloc>().add(WalletCardAdded(
                              nickname: nicknameCtrl.text,
                              maskedPan: panCtrl.text,
                              expiry: expiryCtrl.text,
                              type: selectedType,
                            ));
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: D.orange,
                        foregroundColor: D.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: D.r16),
                        elevation: 0,
                      ),
                      child: const Text('Save Card',
                          style: TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 15)),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, state) {
        final cards = state is WalletData ? state.cards : <CardModel>[];
        final primaryId = state is WalletData ? state.primaryCardId : null;

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