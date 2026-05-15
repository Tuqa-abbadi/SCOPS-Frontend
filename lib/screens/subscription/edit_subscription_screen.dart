import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../blocs/subscription/subscription_bloc.dart';
import '../../blocs/wallet/wallet_bloc.dart';
import '../../core/app_design.dart';

class EditSubscriptionScreen extends StatefulWidget {
  const EditSubscriptionScreen({super.key, required this.subscription});
  final SubscriptionModel subscription;

  @override
  State<EditSubscriptionScreen> createState() => _EditSubscriptionScreenState();
}

class _EditSubscriptionScreenState extends State<EditSubscriptionScreen>
    with SingleTickerProviderStateMixin {
  late String _plan;
  late String _cycle;
  late String _cardId;
  late int    _remindDays;
  late TabController _tabCtrl;

  static const _bg     = Color(0xFF020812);
  static const _card   = Color(0xFF07111C);
  static const _cyan   = Color(0xFF1DD8E8);
  static const _orange = Color(0xFFFF5A14);
  static const _white  = Colors.white;
  static const _muted  = Color(0xFF9BA4B0);
  static const _green  = Color(0xFF22C55E);

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

  bool get _isCancelled => !widget.subscription.isActive;

  List<_Payment> get _payments {
    final now    = DateTime.now();
    final amount = widget.subscription.amount;
    return [
      _Payment(id: 'p1', date: now,                                        amount: amount,        status: _PayStatus.upcoming),
      _Payment(id: 'p2', date: now.subtract(const Duration(days: 30)),      amount: amount,        status: _PayStatus.paid),
      _Payment(id: 'p3', date: now.subtract(const Duration(days: 60)),      amount: amount,        status: _PayStatus.paid),
      _Payment(id: 'p4', date: now.subtract(const Duration(days: 90)),      amount: amount * 0.75, status: _PayStatus.paid),
      _Payment(id: 'p5', date: now.subtract(const Duration(days: 120)),     amount: amount * 0.75, status: _PayStatus.failed),
      _Payment(id: 'p6', date: now.subtract(const Duration(days: 150)),     amount: amount * 0.75, status: _PayStatus.paid),
    ];
  }

  @override
  void initState() {
    super.initState();
    _plan       = widget.subscription.plan;
    _cycle      = widget.subscription.billingCycle;
    _cardId     = widget.subscription.cardId;
    _remindDays = widget.subscription.reminderDays;
    _tabCtrl    = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _save() {
    context.read<SubscriptionBloc>().add(SubscriptionUpdated(
      id: widget.subscription.id,
      plan: _plan, billingCycle: _cycle,
      amount: _computedAmount, cardId: _cardId,
      reminderDays: _remindDays, nextRenewal: _nextRenewal(),
    ));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${widget.subscription.serviceName} updated!'),
      backgroundColor: _cyan, behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  DateTime _nextRenewal() {
    final now = DateTime.now();
    switch (_cycle) {
      case 'Weekly': return now.add(const Duration(days: 7));
      case 'Yearly': return now.add(const Duration(days: 365));
      default:        return now.add(const Duration(days: 30));
    }
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.80),
      builder: (_) => _ConfirmDialog(
        icon: _isCancelled ? Icons.delete_outline_rounded : Icons.cancel_outlined,
        title: _isCancelled
            ? 'Delete ${widget.subscription.serviceName}?'
            : 'Cancel ${widget.subscription.serviceName}?',
        body: _isCancelled
            ? 'This will permanently remove this subscription and all its data. This cannot be undone.'
            : 'This will mark the subscription as cancelled. Your payment history will be preserved.',
        confirmLabel: _isCancelled ? 'Delete' : 'Cancel Sub',
        onConfirm: () {
          if (_isCancelled) {
            context.read<SubscriptionBloc>().add(SubscriptionDeleted(widget.subscription.id));
          } else {
            context.read<SubscriptionBloc>().add(SubscriptionCancelled(widget.subscription.id));
          }
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(_isCancelled
                ? '${widget.subscription.serviceName} deleted.'
                : '${widget.subscription.serviceName} cancelled.'),
            backgroundColor: _orange, behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sub      = widget.subscription;
    final daysLeft = sub.nextRenewal.difference(DateTime.now()).inDays;
    final isUrgent = daysLeft <= 3;
    final payments = _payments;
    final totalPaid = payments
        .where((p) => p.status == _PayStatus.paid)
        .fold(0.0, (s, p) => s + p.amount);

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(children: [
          // Top bar
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 12, 16, 0),
            child: Row(children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _white, size: 20)),
              Text(sub.serviceIcon, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(sub.serviceName,
                    style: const TextStyle(color: _white, fontSize: 18, fontWeight: FontWeight.w900)),
                Text(sub.plan, style: const TextStyle(color: _muted, fontSize: 12)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: (_isCancelled ? _orange : _green).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: (_isCancelled ? _orange : _green).withOpacity(0.30))),
                child: Text(_isCancelled ? 'Cancelled' : 'Active',
                    style: TextStyle(
                        color: _isCancelled ? _orange : _green,
                        fontSize: 11, fontWeight: FontWeight.w800)),
              ),
            ]),
          ),

          // Stats strip
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _cyan.withOpacity(0.18)),
                boxShadow: [BoxShadow(color: _cyan.withOpacity(0.08), blurRadius: 20)],
              ),
              child: Row(children: [
                _statCell('\$${sub.amount.toStringAsFixed(2)}', '/ ${sub.billingCycle}', _cyan),
                _divider(),
                _statCell(
                  _isCancelled ? '—' : '$daysLeft days',
                  _isCancelled ? 'Cancelled' : 'Until renewal',
                  _isCancelled ? _muted : (isUrgent ? _orange : _white)),
                _divider(),
                _statCell('\$${totalPaid.toStringAsFixed(0)}', 'Total paid', _green),
                _divider(),
                _statCell('${sub.reminderDays}d', 'Reminder', _muted),
              ]),
            ),
          ),

          // Tabs
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.07))),
              child: TabBar(
                controller: _tabCtrl,
                labelColor: const Color(0xFF0D1A1C),
                unselectedLabelColor: _muted,
                labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                indicator: BoxDecoration(color: _cyan, borderRadius: BorderRadius.circular(11)),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: const [Tab(text: 'Payment History'), Tab(text: 'Edit')],
              ),
            ),
          ),
          const SizedBox(height: 4),

          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _paymentHistoryTab(payments, totalPaid),
                _editTab(),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _paymentHistoryTab(List<_Payment> payments, double totalPaid) {
    final paidCount   = payments.where((p) => p.status == _PayStatus.paid).length;
    final failedCount = payments.where((p) => p.status == _PayStatus.failed).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: _card, borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.06))),
          child: Row(children: [
            _statCell('\$${totalPaid.toStringAsFixed(0)}', 'Total Paid', _cyan),
            _divider(),
            _statCell('$paidCount', 'Payments', _green),
            _divider(),
            _statCell('$failedCount', 'Failed', failedCount > 0 ? _orange : _muted),
          ]),
        ),
        const SizedBox(height: 22),
        const Text('Timeline', style: TextStyle(color: _white, fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 14),
        ...payments.asMap().entries.map((e) => _timelineTile(e.value, e.key == payments.length - 1)),
        const SizedBox(height: 12),
        Center(child: Text('TODO Sprint 4: real payment data from API',
            style: TextStyle(color: _muted.withOpacity(0.40), fontSize: 10))),
      ],
    );
  }

  Widget _timelineTile(_Payment p, bool isLast) {
    final color   = _statusColor(p.status);
    final isFirst = p.status == _PayStatus.upcoming;

    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 36, child: Column(children: [
          Container(
            width: 18, height: 18,
            margin: const EdgeInsets.only(top: 18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.15),
              border: Border.all(color: color, width: 2),
              boxShadow: [BoxShadow(color: color.withOpacity(0.30), blurRadius: 8)]),
            child: isFirst
                ? Center(child: Container(width: 6, height: 6,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: color)))
                : null),
          if (!isLast)
            Expanded(child: Container(
              width: 2,
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [color.withOpacity(0.40), Colors.white.withOpacity(0.04)]),
                borderRadius: BorderRadius.circular(1)))),
        ])),
        const SizedBox(width: 12),
        Expanded(child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isFirst ? color.withOpacity(0.06) : _card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: isFirst ? color.withOpacity(0.35) : Colors.white.withOpacity(0.06))),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(DateFormat('MMMM d, yyyy').format(p.date),
                  style: const TextStyle(color: _white, fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(widget.subscription.billingCycle,
                  style: const TextStyle(color: _muted, fontSize: 11)),
              const SizedBox(height: 8),
              _statusChip(p.status),
            ])),
            Text('\$${p.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: p.status == _PayStatus.failed ? _orange
                       : p.status == _PayStatus.refunded ? const Color(0xFFA855F7) : _white,
                  fontSize: 18, fontWeight: FontWeight.w900)),
          ]),
        )),
      ]),
    );
  }

  Widget _statusChip(_PayStatus s) {
    final color = _statusColor(s);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(_statusIcon(s), color: color, size: 11),
        const SizedBox(width: 4),
        Text(_statusLabel(s), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800)),
      ]));
  }

  Color    _statusColor(_PayStatus s) {
    switch (s) {
      case _PayStatus.paid:     return _green;
      case _PayStatus.upcoming: return _cyan;
      case _PayStatus.failed:   return _orange;
      case _PayStatus.refunded: return const Color(0xFFA855F7);
    }
  }
  IconData _statusIcon(_PayStatus s) {
    switch (s) {
      case _PayStatus.paid:     return Icons.check_circle_rounded;
      case _PayStatus.upcoming: return Icons.schedule_rounded;
      case _PayStatus.failed:   return Icons.cancel_rounded;
      case _PayStatus.refunded: return Icons.refresh_rounded;
    }
  }
  String   _statusLabel(_PayStatus s) {
    switch (s) {
      case _PayStatus.paid:     return 'Paid';
      case _PayStatus.upcoming: return 'Upcoming';
      case _PayStatus.failed:   return 'Failed';
      case _PayStatus.refunded: return 'Refunded';
    }
  }

  Widget _editTab() {
    final plans = _inferPlans();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        if (_isCancelled)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _orange.withOpacity(0.08), borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _orange.withOpacity(0.25))),
            child: Row(children: [
              const Icon(Icons.info_outline_rounded, color: _orange, size: 16),
              const SizedBox(width: 10),
              const Expanded(child: Text(
                'This subscription is cancelled. Delete it or contact support to reactivate.',
                style: TextStyle(color: _orange, fontSize: 12, height: 1.4))),
            ])),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _cyan.withOpacity(0.07), borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _cyan.withOpacity(0.18))),
          child: Row(children: [
            const Icon(Icons.info_outline_rounded, color: _cyan, size: 15),
            const SizedBox(width: 8),
            Expanded(child: Text(
              'Currently: ${widget.subscription.plan} · ${widget.subscription.billingCycle} · \$${widget.subscription.amount.toStringAsFixed(2)}',
              style: const TextStyle(color: _cyan, fontSize: 12, fontWeight: FontWeight.w600))),
          ])),
        const SizedBox(height: 20),
        _sectionLabel('Plan'),
        Wrap(spacing: 10, runSpacing: 10,
          children: plans.map((p) => _chip(p, _plan == p, () => setState(() => _plan = p))).toList()),
        const SizedBox(height: 20),
        _sectionLabel('Amount'),
        _box(child: Row(children: [
          const Text('\$ ', style: TextStyle(color: Color(0xFF1DD8E8), fontWeight: FontWeight.w900, fontSize: 20)),
          Text(_computedAmount.toStringAsFixed(2),
              style: const TextStyle(color: _white, fontWeight: FontWeight.w700, fontSize: 20)),
          const Spacer(),
          if (_plan != widget.subscription.plan)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: _orange.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
              child: Text('was \$${widget.subscription.amount.toStringAsFixed(2)}',
                  style: const TextStyle(color: _orange, fontSize: 11, fontWeight: FontWeight.w600))),
        ])),
        const SizedBox(height: 20),
        _sectionLabel('Billing Cycle'),
        Row(children: ['Monthly', 'Yearly', 'Weekly'].map((c) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: c != 'Weekly' ? 10 : 0),
            child: _chip(c, _cycle == c, () => setState(() => _cycle = c))))).toList()),
        const SizedBox(height: 20),
        _sectionLabel('Payment Card'),
        BlocBuilder<WalletBloc, WalletState>(
          builder: (_, state) {
            if (state is! WalletData || state.cards.isEmpty) {
              return _box(child: const Text('No cards. Add one in the Wallet tab.',
                  style: TextStyle(color: _muted)));
            }
            return Column(children: state.cards.map((card) => GestureDetector(
              onTap: () => setState(() => _cardId = card.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: _cardId == card.id
                    ? D.glowCard(accent: D.cyan, bg: D.cardBg, radius: D.r16)
                    : D.plainCard(radius: D.r16),
                child: Row(children: [
                  const Icon(Icons.credit_card_rounded, color: Color(0xFF1DD8E8)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(
                    '${card.nickname}  ····  ${card.maskedPan.length >= 4 ? card.maskedPan.substring(card.maskedPan.length - 4) : card.maskedPan}',
                    style: const TextStyle(color: _white, fontWeight: FontWeight.w700))),
                  if (_cardId == card.id)
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF1DD8E8), size: 20),
                ]),
              ),
            )).toList());
          }),
        const SizedBox(height: 20),
        _sectionLabel('Remind me before renewal'),
        _box(child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Days before renewal', style: TextStyle(color: _muted, fontWeight: FontWeight.w600)),
            Text('$_remindDays days', style: const TextStyle(color: Color(0xFF1DD8E8), fontWeight: FontWeight.w800)),
          ]),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _cyan,
              inactiveTrackColor: _cyan.withOpacity(0.15),
              thumbColor: _cyan, overlayColor: _cyan.withOpacity(0.15)),
            child: Slider(
              value: _remindDays.toDouble(), min: 1, max: 14, divisions: 13,
              onChanged: (v) => setState(() => _remindDays = v.round()))),
        ])),
        const SizedBox(height: 28),
        if (!_isCancelled) ...[
          SizedBox(width: double.infinity, height: 56,
            child: ElevatedButton(
              onPressed: _hasChanges ? _save : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _hasChanges ? _cyan : const Color(0xFF1E2530),
                foregroundColor: _hasChanges ? const Color(0xFF0D1A1C) : _muted,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
              child: const Text('Save Changes',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)))),
          const SizedBox(height: 12),
        ],
        SizedBox(width: double.infinity, height: 52,
          child: OutlinedButton.icon(
            onPressed: _showCancelDialog,
            icon: Icon(_isCancelled ? Icons.delete_outline_rounded : Icons.cancel_outlined,
                color: _orange, size: 18),
            label: Text(_isCancelled ? 'Delete Permanently' : 'Cancel Subscription',
                style: const TextStyle(color: _orange, fontWeight: FontWeight.w700, fontSize: 14)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: _orange.withOpacity(0.35)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))))),
      ],
    );
  }

  Widget _sectionLabel(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(t, style: const TextStyle(color: _white, fontWeight: FontWeight.w700, fontSize: 14)));

  Widget _box({required Widget child}) => Container(
    width: double.infinity, padding: const EdgeInsets.all(16),
    decoration: D.plainCard(), child: child);

  Widget _chip(String text, bool active, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: active ? _cyan : _card, borderRadius: D.r16,
        border: Border.all(color: active ? _cyan : Colors.white.withOpacity(0.08)),
        boxShadow: active ? [BoxShadow(color: _cyan.withOpacity(0.28), blurRadius: 10)] : []),
      child: Text(text, style: TextStyle(
          color: active ? const Color(0xFF0D1A1C) : _muted,
          fontWeight: FontWeight.w700))));

  Widget _statCell(String val, String label, Color color) => Expanded(
    child: Column(children: [
      Text(val, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w900)),
      const SizedBox(height: 3),
      Text(label, textAlign: TextAlign.center,
          style: const TextStyle(color: _muted, fontSize: 9)),
    ]));

  Widget _divider() => Container(width: 1, height: 36, color: Colors.white.withOpacity(0.07));

  List<String> _inferPlans() {
    final p = widget.subscription.plan.toLowerCase();
    if (['basic', 'standard', 'premium'].any((x) => p.contains(x)))          return ['Basic', 'Standard', 'Premium'];
    if (['individual', 'duo', 'family'].any((x) => p.contains(x)))           return ['Individual', 'Duo', 'Family'];
    if (['photography', 'single app', 'all apps'].any((x) => p.contains(x))) return ['Photography', 'Single App', 'All Apps'];
    if (['50gb', '200gb', '2tb'].any((x) => p.contains(x)))                  return ['50GB', '200GB', '2TB'];
    if (['personal', 'professional', 'business'].any((x) => p.contains(x)))  return ['Personal', 'Professional', 'Business'];
    return [widget.subscription.plan];
  }
}

enum _PayStatus { paid, upcoming, failed, refunded }

class _Payment {
  final String    id;
  final DateTime  date;
  final double    amount;
  final _PayStatus status;
  const _Payment({required this.id, required this.date, required this.amount, required this.status});
}

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.icon, required this.title, required this.body,
    required this.confirmLabel, required this.onConfirm,
  });
  final IconData icon;
  final String   title;
  final String   body;
  final String   confirmLabel;
  final VoidCallback onConfirm;

  static const _orange = Color(0xFFFF5A14);
  static const _white  = Colors.white;
  static const _muted  = Color(0xFF9BA4B0);

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.transparent,
    child: Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF07111C), borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _orange.withOpacity(0.25))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _orange.withOpacity(0.10),
            border: Border.all(color: _orange.withOpacity(0.30))),
          child: Icon(icon, color: _orange, size: 28)),
        const SizedBox(height: 18),
        Text(title, textAlign: TextAlign.center,
            style: const TextStyle(color: _white, fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        Text(body, textAlign: TextAlign.center,
            style: const TextStyle(color: _muted, fontSize: 13, height: 1.5)),
        const SizedBox(height: 24),
        Row(children: [
          Expanded(child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: _muted,
              side: BorderSide(color: Colors.white.withOpacity(0.10)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: const Text('Keep it'))),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton(
            onPressed: () { Navigator.pop(context); onConfirm(); },
            style: ElevatedButton.styleFrom(
              backgroundColor: _orange, foregroundColor: _white, elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: Text(confirmLabel, style: const TextStyle(fontWeight: FontWeight.w800)))),
        ]),
      ]),
    ),
  );
}