import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/subscription/subscription_bloc.dart';
import '../../blocs/wallet/wallet_bloc.dart';
import '../../core/app_design.dart';

/// Edit-only form for a subscription.
/// Navigation / destructive actions live in SubscriptionDetailScreen.
class EditSubscriptionScreen extends StatefulWidget {
  const EditSubscriptionScreen({super.key, required this.subscription});
  final SubscriptionModel subscription;

  @override
  State<EditSubscriptionScreen> createState() => _EditSubscriptionScreenState();
}

class _EditSubscriptionScreenState extends State<EditSubscriptionScreen> {
  // ── Colours ────────────────────────────────────────────────────────────────
  static const _bg     = Color(0xFF020812);
  static const _card   = Color(0xFF07111C);
  static const _cyan   = Color(0xFF1DD8E8);
  static const _orange = Color(0xFFFF5A14);
  static const _white  = Color(0xFFFFFFFF);
  static const _muted  = Color(0xFF9BA4B0);

  // ── Form state ─────────────────────────────────────────────────────────────
  late String _plan;
  late String _cycle;
  late String _cardId;
  late int    _remindDays;

  static const _planMultiplier = {
    'free': 0.0, 'basic': 1.0, 'starter': 1.0, 'individual': 1.0,
    'personal': 1.0, 'photography': 1.0, '50gb': 1.0, 'student': 0.6,
    'duo': 1.5, 'standard': 1.5, '200gb': 1.5, 'single app': 1.5,
    'team': 1.4, 'plus': 1.4, 'professional': 1.8, 'family': 1.8,
    'all apps': 2.2, 'premium': 2.0, 'business': 2.5,
    '2tb': 3.0, 'organization': 3.0, 'enterprise': 3.5,
  };

  double get _basePrice {
    final m = _planMultiplier[widget.subscription.plan.toLowerCase()] ?? 1.0;
    return m == 0 ? 0 : widget.subscription.amount / m;
  }

  double get _computedAmount =>
      _basePrice * (_planMultiplier[_plan.toLowerCase()] ?? 1.0);

  bool get _hasChanges =>
      _plan != widget.subscription.plan ||
      _cycle != widget.subscription.billingCycle ||
      _cardId != widget.subscription.cardId ||
      _remindDays != widget.subscription.reminderDays;

  @override
  void initState() {
    super.initState();
    _plan       = widget.subscription.plan;
    _cycle      = widget.subscription.billingCycle;
    _cardId     = widget.subscription.cardId;
    _remindDays = widget.subscription.reminderDays;
  }

  void _save() {
    context.read<SubscriptionBloc>().add(SubscriptionUpdated(
      id: widget.subscription.id,
      plan: _plan,
      billingCycle: _cycle,
      amount: _computedAmount,
      cardId: _cardId,
      reminderDays: _remindDays,
      nextRenewal: _nextRenewal(),
    ));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${widget.subscription.serviceName} updated!'),
      backgroundColor: _cyan,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  DateTime _nextRenewal() {
    final now = DateTime.now();
    switch (_cycle) {
      case 'Weekly': return now.add(const Duration(days: 7));
      case 'Yearly': return now.add(const Duration(days: 365));
      default:       return now.add(const Duration(days: 30));
    }
  }

  List<String> _inferPlans() {
    final p = widget.subscription.plan.toLowerCase();
    if (['basic', 'standard', 'premium'].any((x) => p.contains(x))) {
      return ['Basic', 'Standard', 'Premium'];
    }
    if (['individual', 'duo', 'family'].any((x) => p.contains(x))) {
      return ['Individual', 'Duo', 'Family'];
    }
    if (['photography', 'single app', 'all apps'].any((x) => p.contains(x))) {
      return ['Photography', 'Single App', 'All Apps'];
    }
    if (['50gb', '200gb', '2tb'].any((x) => p.contains(x))) {
      return ['50GB', '200GB', '2TB'];
    }
    if (['personal', 'professional', 'business'].any((x) => p.contains(x))) {
      return ['Personal', 'Professional', 'Business'];
    }
    return [widget.subscription.plan];
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final sub   = widget.subscription;
    final plans = _inferPlans();

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(children: [

          // ── Header ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 12, 16, 0),
            child: Row(children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    color: _white, size: 20)),
              Text(sub.serviceIcon,
                  style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Edit ${sub.serviceName}',
                    style: TextStyle(
                        color: _white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900)),
                Text(sub.plan,
                    style: TextStyle(color: _muted, fontSize: 12)),
              ])),
            ]),
          ),

          const SizedBox(height: 8),

          // ── Form ─────────────────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              children: [

                // Current summary
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _cyan.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _cyan.withValues(alpha: 0.18))),
                  child: Row(children: [
                    const Icon(Icons.info_outline_rounded,
                        color: _cyan, size: 15),
                    const SizedBox(width: 8),
                    Expanded(child: Text(
                      'Currently: ${sub.plan} · ${sub.billingCycle} · \$${sub.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: _cyan,
                          fontSize: 12,
                          fontWeight: FontWeight.w600))),
                  ])),
                const SizedBox(height: 22),

                // Plan
                _label('Plan'),
                Wrap(
                  spacing: 10, runSpacing: 10,
                  children: plans
                      .map((p) => _chip(p, _plan == p,
                          () => setState(() => _plan = p)))
                      .toList()),
                const SizedBox(height: 22),

                // Amount (computed)
                _label('Amount'),
                _box(child: Row(children: [
                  const Text('\$ ',
                      style: TextStyle(
                          color: _cyan,
                          fontWeight: FontWeight.w900,
                          fontSize: 20)),
                  Text(_computedAmount.toStringAsFixed(2),
                      style: TextStyle(
                          color: _white,
                          fontWeight: FontWeight.w700,
                          fontSize: 20)),
                  const Spacer(),
                  if (_plan != sub.plan)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _orange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10)),
                      child: Text('was \$${sub.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                              color: _orange,
                              fontSize: 11,
                              fontWeight: FontWeight.w600))),
                ])),
                const SizedBox(height: 22),

                // Billing cycle
                _label('Billing Cycle'),
                Row(children: ['Monthly', 'Yearly', 'Weekly'].map((c) {
                  final isLast = c == 'Weekly';
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: isLast ? 0 : 10),
                      child: _chip(c, _cycle == c,
                          () => setState(() => _cycle = c))));
                }).toList()),
                const SizedBox(height: 22),

                // Payment card
                _label('Payment Card'),
                BlocBuilder<WalletBloc, WalletState>(
                  builder: (_, walletState) {
                    if (walletState is! WalletData ||
                        walletState.cards.isEmpty) {
                      return _box(
                          child: Text(
                              'No cards. Add one in the Wallet tab.',
                              style: TextStyle(color: _muted)));
                    }
                    return Column(
                      children: walletState.cards.map((card) {
                        final selected = _cardId == card.id;
                        return GestureDetector(
                          onTap: () => setState(() => _cardId = card.id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: selected
                                ? D.glowCard(
                                    accent: D.cyan,
                                    bg: D.cardBg,
                                    radius: D.r16)
                                : D.plainCard(radius: D.r16),
                            child: Row(children: [
                              const Icon(Icons.credit_card_rounded,
                                  color: _cyan),
                              const SizedBox(width: 12),
                              Expanded(child: Text(
                                '${card.nickname}  ····  ${card.maskedPan.length >= 4 ? card.maskedPan.substring(card.maskedPan.length - 4) : card.maskedPan}',
                                style: TextStyle(
                                    color: _white,
                                    fontWeight: FontWeight.w700))),
                              if (selected)
                                const Icon(Icons.check_circle_rounded,
                                    color: _cyan, size: 20),
                            ]),
                          ),
                        );
                      }).toList());
                  }),
                const SizedBox(height: 22),

                // Reminder
                _label('Remind me before renewal'),
                _box(child: Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Days before renewal',
                          style: TextStyle(
                              color: _muted, fontWeight: FontWeight.w600)),
                      Text('$_remindDays days',
                          style: const TextStyle(
                              color: _cyan, fontWeight: FontWeight.w800)),
                    ]),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: _cyan,
                      inactiveTrackColor: _cyan.withValues(alpha: 0.15),
                      thumbColor: _cyan,
                      overlayColor: _cyan.withValues(alpha: 0.15)),
                    child: Slider(
                      value: _remindDays.toDouble(),
                      min: 1, max: 14, divisions: 13,
                      onChanged: (v) =>
                          setState(() => _remindDays = v.round()))),
                ])),
                const SizedBox(height: 32),

                // Save
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _hasChanges ? _save : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _hasChanges
                          ? _cyan
                          : const Color(0xFF1E2530),
                      foregroundColor: _hasChanges ? const Color(0xFF0D1A1C) : _muted,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18))),
                    child: const Text('Save Changes',
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 16)))),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(t,
        style: TextStyle(
            color: _white, fontWeight: FontWeight.w700, fontSize: 14)));

  Widget _box({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: D.plainCard(),
    child: child);

  Widget _chip(String text, bool active, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: active ? _cyan : _card,
            borderRadius: D.r16,
            border: Border.all(
                color: active
                    ? _cyan
                    : Colors.white.withValues(alpha: 0.08)),
            boxShadow: active
                ? [BoxShadow(
                    color: _cyan.withValues(alpha: 0.28), blurRadius: 10)]
                : []),
          child: Text(text,
              style: TextStyle(
                  color: active ? const Color(0xFF0D1A1C) : _muted,
                  fontWeight: FontWeight.w700))));
}
