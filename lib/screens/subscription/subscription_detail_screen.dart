import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../blocs/reviews/reviews_bloc.dart';
import '../../blocs/subscription/subscription_bloc.dart';
import '../../blocs/wallet/wallet_bloc.dart';
import 'edit_subscription_screen.dart';

class SubscriptionDetailScreen extends StatefulWidget {
  const SubscriptionDetailScreen({super.key, required this.subscription});
  final SubscriptionModel subscription;

  @override
  State<SubscriptionDetailScreen> createState() =>
      _SubscriptionDetailScreenState();
}

class _SubscriptionDetailScreenState extends State<SubscriptionDetailScreen> {
  // ── Colours ────────────────────────────────────────────────────────────────
  static const _bg     = Color(0xFF020812);
  static const _card   = Color(0xFF07111C);
  static const _cyan   = Color(0xFF1DD8E8);
  static const _orange = Color(0xFFFF5A14);
  static const _green  = Color(0xFF22C55E);
  static const _amber  = Color(0xFFF59E0B);
  static const _red    = Color(0xFFEF4444);
  static const _white  = Color(0xFFFFFFFF);
  static const _muted  = Color(0xFF9BA4B0);
  static const _gold   = Color(0xFFFFB020);

  // ── Review state ──────────────────────────────────────────────────────────
  int _rating = 0;
  final _commentCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final sid = widget.subscription.serviceId;
    if (sid != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<ReviewsBloc>().add(ReviewsForServiceRequested(sid));
        }
      });
    }
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Color _statusColor(SubscriptionModel sub) {
    if (sub.isCancelled) return _red;
    if (sub.isPaused)    return _amber;
    return _cyan;
  }

  String _statusLabel(SubscriptionModel sub) {
    if (sub.isCancelled) return 'Cancelled';
    if (sub.isPaused)    return 'Paused';
    return 'Active';
  }

  double _monthlyEquivalent(SubscriptionModel sub) {
    switch (sub.billingCycle.toLowerCase()) {
      case 'yearly': return sub.amount / 12;
      case 'weekly': return sub.amount * 52 / 12;
      default:       return sub.amount;
    }
  }

  String? _cardLabel(SubscriptionModel sub, List<CardModel> cards) {
    if (sub.cardId.isEmpty) return null;
    try {
      final c = cards.firstWhere((c) => c.id == sub.cardId);
      final digits = c.maskedPan.replaceAll(RegExp(r'[^\d]'), '');
      final last4  = digits.length >= 4 ? digits.substring(digits.length - 4) : digits;
      return '${c.type.isNotEmpty ? c.type : 'Card'} ••••$last4';
    } catch (_) {
      return null;
    }
  }

  bool _isReviewEligible(SubscriptionModel sub) =>
      sub.isActive && sub.serviceId != 0 && sub.apiId != 0;

  List<_Payment> _buildPayments(SubscriptionModel sub) {
    final now    = DateTime.now();
    final amount = sub.amount;
    return [
      _Payment(date: now,                                     amount: amount,        status: _PayStatus.upcoming),
      _Payment(date: now.subtract(const Duration(days: 30)), amount: amount,        status: _PayStatus.paid),
      _Payment(date: now.subtract(const Duration(days: 60)), amount: amount,        status: _PayStatus.paid),
      _Payment(date: now.subtract(const Duration(days: 90)), amount: amount * 0.75, status: _PayStatus.paid),
      _Payment(date: now.subtract(const Duration(days: 120)),amount: amount * 0.75, status: _PayStatus.failed),
      _Payment(date: now.subtract(const Duration(days: 150)),amount: amount * 0.75, status: _PayStatus.paid),
    ];
  }

  // ── Snack / dialogs ───────────────────────────────────────────────────────

  void _showSnack(String msg, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: bg,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _confirm({
    required IconData icon,
    required String title,
    required String body,
    required String confirmLabel,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.80),
      builder: (_) => _ConfirmDialog(
        icon: icon, title: title, body: body,
        confirmLabel: confirmLabel, confirmColor: confirmColor,
        onConfirm: onConfirm,
      ),
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  void _onPause(SubscriptionModel sub) => _confirm(
    icon: Icons.pause_circle_outline_rounded,
    title: 'Pause ${sub.serviceName}?',
    body: 'Pausing will temporarily stop billing. You can resume anytime.',
    confirmLabel: 'Pause',
    confirmColor: _amber,
    onConfirm: () {
      context.read<SubscriptionBloc>().add(SubscriptionPauseRequested(sub.apiId));
      _showSnack('${sub.serviceName} paused.', _amber);
    },
  );

  void _onResume(SubscriptionModel sub) => _confirm(
    icon: Icons.play_circle_outline_rounded,
    title: 'Resume ${sub.serviceName}?',
    body: 'Billing will resume from the next cycle.',
    confirmLabel: 'Resume',
    confirmColor: _green,
    onConfirm: () {
      context.read<SubscriptionBloc>().add(SubscriptionResumeRequested(sub.apiId));
      _showSnack('${sub.serviceName} resumed.', _green);
    },
  );

  void _onCancel(SubscriptionModel sub) {
    if (sub.isCancelled) {
      _confirm(
        icon: Icons.delete_outline_rounded,
        title: 'Remove ${sub.serviceName}?',
        body: 'Removes this cancelled subscription from your list.',
        confirmLabel: 'Remove',
        confirmColor: _orange,
        onConfirm: () {
          context.read<SubscriptionBloc>().add(SubscriptionDeleted(sub.id));
          Navigator.of(context).pop();
          _showSnack('${sub.serviceName} removed.', _orange);
        },
      );
    } else {
      _confirm(
        icon: Icons.cancel_outlined,
        title: 'Cancel ${sub.serviceName}?',
        body: 'This will cancel the subscription. Your payment history will be preserved.',
        confirmLabel: 'Cancel Sub',
        confirmColor: _orange,
        onConfirm: () {
          context.read<SubscriptionBloc>().add(SubscriptionCancelRequested(sub.apiId));
          _showSnack('${sub.serviceName} cancellation requested.', _orange);
        },
      );
    }
  }

  void _onEdit(SubscriptionModel sub) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<SubscriptionBloc>()),
          BlocProvider.value(value: context.read<WalletBloc>()),
          BlocProvider.value(value: context.read<ReviewsBloc>()),
        ],
        child: EditSubscriptionScreen(subscription: sub),
      ),
    ));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ReviewsBloc, ReviewsState>(
          listener: (ctx, state) {
            if (state is! ReviewsData) return;
            if (state.submitSuccess) {
              ctx.read<ReviewsBloc>().add(const ReviewSubmitReset());
              _showSnack('Review submitted! Thank you.', _cyan);
              setState(() { _rating = 0; _commentCtrl.clear(); });
            } else if (state.submitError != null) {
              _showSnack(state.submitError!, _orange);
              ctx.read<ReviewsBloc>().add(const ReviewSubmitReset());
            }
          },
        ),
      ],
      child: BlocConsumer<SubscriptionBloc, SubscriptionState>(
        listener: (ctx, state) {
          if (state is SubscriptionData) {
            if (state.actionError != null) _showSnack(state.actionError!, _orange);
            // Auto-pop if subscription was deleted
            final exists = state.subscriptions.any((s) => s.id == widget.subscription.id);
            if (!exists) Navigator.of(ctx).maybePop();
          }
        },
        builder: (ctx, state) {
          // Always use the freshest version from the bloc if available
          SubscriptionModel sub = widget.subscription;
          if (state is SubscriptionData) {
            final matches = state.subscriptions.where((s) => s.id == widget.subscription.id);
            if (matches.isNotEmpty) sub = matches.first;
          }

          final statusColor = _statusColor(sub);
          final payments    = _buildPayments(sub);
          final totalPaid   = payments
              .where((p) => p.status == _PayStatus.paid)
              .fold(0.0, (s, p) => s + p.amount);
          final daysLeft  = sub.nextRenewal.difference(DateTime.now()).inDays;
          final isUrgent  = daysLeft <= 3 && sub.isActive;

          final walletState = ctx.watch<WalletBloc>().state;
          final cards = walletState is WalletData ? walletState.cards : <CardModel>[];

          return Scaffold(
            backgroundColor: _bg,
            body: SafeArea(
              child: Column(children: [

                // ── Header ─────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 12, 16, 0),
                  child: Row(children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back_ios_new_rounded,
                          color: _white, size: 20)),
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: statusColor.withValues(alpha: 0.28)),
                      ),
                      child: Center(
                        child: Text(sub.serviceIcon,
                            style: const TextStyle(fontSize: 22)))),
                    const SizedBox(width: 10),
                    Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(sub.serviceName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: _white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900)),
                      Text(sub.plan,
                          style: TextStyle(color: _muted, fontSize: 12)),
                    ])),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: statusColor.withValues(alpha: 0.32))),
                      child: Text(_statusLabel(sub),
                          style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w800)),
                    ),
                  ]),
                ),

                // ── Stats strip ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: statusColor.withValues(alpha: 0.20)),
                      boxShadow: [
                        BoxShadow(
                            color: statusColor.withValues(alpha: 0.07),
                            blurRadius: 22)
                      ],
                    ),
                    child: Row(children: [
                      _statCell('\$${sub.amount.toStringAsFixed(2)}',
                          '/ ${sub.billingCycle}', _cyan),
                      _vDivider(),
                      _statCell(
                        sub.isActive ? '$daysLeft d' : '—',
                        sub.isActive
                            ? (isUrgent ? 'Renews soon!' : 'Until renewal')
                            : _statusLabel(sub),
                        sub.isActive
                            ? (isUrgent ? _orange : _white)
                            : _muted),
                      _vDivider(),
                      _statCell('\$${totalPaid.toStringAsFixed(0)}',
                          'Total paid', _green),
                      _vDivider(),
                      _statCell('${sub.reminderDays}d', 'Reminder', _muted),
                    ]),
                  ),
                ),

                const SizedBox(height: 6),

                // ── Scrollable body ────────────────────────────────────────
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 48),
                    children: [

                      // ── Info card ────────────────────────────────────────
                      _buildInfoCard(sub, cards, daysLeft, isUrgent),
                      const SizedBox(height: 24),

                      // ── Payment history ──────────────────────────────────
                      const Text('Payment History',
                          style: TextStyle(
                              color: _white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 14),
                      ...payments.asMap().entries.map((e) =>
                          _timelineTile(sub, e.value,
                              e.key == payments.length - 1)),

                      const SizedBox(height: 28),

                      // ── Status banner ────────────────────────────────────
                      if (sub.isCancelled)
                        _banner(_red, Icons.cancel_outlined,
                            'This subscription is cancelled.'),
                      if (sub.isPaused)
                        _banner(_amber, Icons.pause_circle_outline_rounded,
                            'This subscription is paused. Tap "Resume" below to restart billing.'),

                      // ── Edit button ──────────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () => _onEdit(sub),
                          icon: const Icon(Icons.edit_rounded, size: 18),
                          label: const Text('Edit Subscription',
                              style: TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 15)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _cyan,
                            foregroundColor: const Color(0xFF0D1A1C),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18))),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Pause ────────────────────────────────────────────
                      if (sub.isActive)
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: () => _onPause(sub),
                            icon: const Icon(
                                Icons.pause_circle_outline_rounded,
                                color: _amber,
                                size: 18),
                            label: const Text('Pause Subscription',
                                style: TextStyle(
                                    color: _amber,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14)),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: _amber.withValues(alpha: 0.45)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18))),
                          ),
                        ),

                      // ── Resume ───────────────────────────────────────────
                      if (sub.isPaused) ...[
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () => _onResume(sub),
                            icon: const Icon(
                                Icons.play_circle_outline_rounded, size: 18),
                            label: const Text('Resume Subscription',
                                style: TextStyle(
                                    fontWeight: FontWeight.w900, fontSize: 15)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _green,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18))),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // ── Cancel / Remove ──────────────────────────────────
                      if (!sub.isCancelled) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: () => _onCancel(sub),
                            icon: const Icon(Icons.cancel_outlined,
                                color: _orange, size: 18),
                            label: const Text('Cancel Subscription',
                                style: TextStyle(
                                    color: _orange,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14)),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: _orange.withValues(alpha: 0.35)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18))),
                          ),
                        ),
                      ],
                      if (sub.isCancelled)
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: () => _onCancel(sub),
                            icon: const Icon(Icons.delete_outline_rounded,
                                color: _orange, size: 18),
                            label: const Text('Remove from list',
                                style: TextStyle(
                                    color: _orange,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14)),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: _orange.withValues(alpha: 0.35)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18))),
                          ),
                        ),

                      // ── Review ───────────────────────────────────────────
                      if (_isReviewEligible(sub)) ...[
                        const SizedBox(height: 28),
                        _buildReviewSection(sub),
                      ],
                    ],
                  ),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }

  // ── Info card ─────────────────────────────────────────────────────────────

  Widget _buildInfoCard(
    SubscriptionModel sub,
    List<CardModel> cards,
    int daysLeft,
    bool isUrgent,
  ) {
    final linkedCard = _cardLabel(sub, cards);
    final monthly    = _monthlyEquivalent(sub);
    final isNotMonthly = sub.billingCycle.toLowerCase() != 'monthly';

    final priorityColor = switch (sub.priority.toLowerCase()) {
      'high' => _orange,
      'low'  => _muted,
      _      => _amber,
    };
    final priorityLabel = switch (sub.priority.toLowerCase()) {
      'high' => 'High',
      'low'  => 'Low',
      _      => 'Medium',
    };
    final priorityIcon = switch (sub.priority.toLowerCase()) {
      'high' => Icons.keyboard_double_arrow_up_rounded,
      'low'  => Icons.keyboard_double_arrow_down_rounded,
      _      => Icons.remove_rounded,
    };

    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(children: [
        _infoRow(Icons.loop_rounded, 'Billing Cycle', sub.billingCycle),
        _hDivider(),
        _infoRow(
          Icons.event_rounded,
          'Renewal Date',
          sub.isActive
              ? DateFormat('MMM d, yyyy').format(sub.nextRenewal)
              : '—',
          valueColor: isUrgent && sub.isActive ? _orange : null,
        ),
        if (sub.startDate != null) ...[
          _hDivider(),
          _infoRow(
            Icons.play_circle_outline_rounded,
            'Start Date',
            DateFormat('MMM d, yyyy').format(sub.startDate!),
          ),
        ],
        if (linkedCard != null) ...[
          _hDivider(),
          _infoRow(Icons.credit_card_rounded, 'Linked Card', linkedCard),
        ],
        _hDivider(),
        _infoRow(
          Icons.show_chart_rounded,
          'Monthly Spend',
          '\$${monthly.toStringAsFixed(2)} /mo',
          note: isNotMonthly
              ? '(${sub.billingCycle.toLowerCase()} billing)'
              : null,
        ),
        _hDivider(),
        _infoRow(
          Icons.flag_rounded,
          'Priority',
          priorityLabel,
          valueColor: priorityColor,
          trailingIcon: priorityIcon,
        ),
      ]),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
    String? note,
    IconData? trailingIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(children: [
        Icon(icon, color: _muted, size: 16),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: _muted, fontSize: 13)),
        const Spacer(),
        if (trailingIcon != null) ...[
          Icon(trailingIcon, color: valueColor ?? _white, size: 14),
          const SizedBox(width: 4),
        ],
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(value,
              style: TextStyle(
                  color: valueColor ?? _white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
          if (note != null)
            Text(note, style: TextStyle(color: _muted, fontSize: 10)),
        ]),
      ]),
    );
  }

  // ── Payment timeline ──────────────────────────────────────────────────────

  Widget _timelineTile(
      SubscriptionModel sub, _Payment p, bool isLast) {
    final color   = _payColor(p.status);
    final isFirst = p.status == _PayStatus.upcoming;

    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 36, child: Column(children: [
          Container(
            width: 18, height: 18,
            margin: const EdgeInsets.only(top: 18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.15),
              border: Border.all(color: color, width: 2),
              boxShadow: [
                BoxShadow(
                    color: color.withValues(alpha: 0.30), blurRadius: 8)
              ]),
            child: isFirst
                ? Center(
                    child: Container(
                        width: 6, height: 6,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: color)))
                : null),
          if (!isLast)
            Expanded(child: Container(
              width: 2,
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [
                    color.withValues(alpha: 0.40),
                    Colors.white.withValues(alpha: 0.04),
                  ]),
                borderRadius: BorderRadius.circular(1)))),
        ])),
        const SizedBox(width: 12),
        Expanded(child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isFirst ? color.withValues(alpha: 0.06) : _card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: isFirst
                    ? color.withValues(alpha: 0.35)
                    : Colors.white.withValues(alpha: 0.06))),
          child: Row(children: [
            Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(DateFormat('MMMM d, yyyy').format(p.date),
                  style: TextStyle(
                      color: _white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(sub.billingCycle,
                  style: TextStyle(color: _muted, fontSize: 11)),
              const SizedBox(height: 8),
              _payChip(p.status),
            ])),
            Text('\$${p.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: p.status == _PayStatus.failed
                      ? _orange
                      : p.status == _PayStatus.refunded
                          ? const Color(0xFFA855F7)
                          : _white,
                  fontSize: 18, fontWeight: FontWeight.w900)),
          ]),
        )),
      ]),
    );
  }

  Widget _payChip(_PayStatus s) {
    final c = _payColor(s);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withValues(alpha: 0.35))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(_payIcon(s), color: c, size: 11),
        const SizedBox(width: 4),
        Text(_payLabel(s),
            style: TextStyle(
                color: c, fontSize: 10, fontWeight: FontWeight.w800)),
      ]));
  }

  Color _payColor(_PayStatus s) => switch (s) {
    _PayStatus.paid     => _green,
    _PayStatus.upcoming => _cyan,
    _PayStatus.failed   => _orange,
    _PayStatus.refunded => const Color(0xFFA855F7),
  };

  IconData _payIcon(_PayStatus s) => switch (s) {
    _PayStatus.paid     => Icons.check_circle_rounded,
    _PayStatus.upcoming => Icons.schedule_rounded,
    _PayStatus.failed   => Icons.cancel_rounded,
    _PayStatus.refunded => Icons.refresh_rounded,
  };

  String _payLabel(_PayStatus s) => switch (s) {
    _PayStatus.paid     => 'Paid',
    _PayStatus.upcoming => 'Upcoming',
    _PayStatus.failed   => 'Failed',
    _PayStatus.refunded => 'Refunded',
  };

  // ── Review section ────────────────────────────────────────────────────────

  Widget _buildReviewSection(SubscriptionModel sub) {
    return BlocBuilder<ReviewsBloc, ReviewsState>(
      builder: (ctx, reviewsState) {
        final data = reviewsState is ReviewsData ? reviewsState : null;
        final alreadyReviewed =
            data?.hasReviewForSubscription(sub.apiId) ?? false;
        final isSubmitting = data?.isSubmitting ?? false;

        if (alreadyReviewed) {
          final reviews = data?.detailReviews
                  .where((r) => r.subscriptionId == sub.apiId)
                  .toList() ??
              [];
          final myReview = reviews.isNotEmpty ? reviews.first : null;
          return _reviewedCard(myReview);
        }

        return Container(
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // ── Header ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(children: [
                const Icon(Icons.rate_review_rounded, color: _cyan, size: 18),
                const SizedBox(width: 8),
                const Text('Rate this service',
                    style: TextStyle(
                        color: _white, fontSize: 15, fontWeight: FontWeight.w800)),
                const Spacer(),
                if (_rating > 0)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      _starLabel(_rating),
                      key: ValueKey(_rating),
                      style: const TextStyle(
                          color: _gold, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
              ])),

            const SizedBox(height: 14),

            // ── Star rating (1–5 stars; sent as stars×2 to backend) ──────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final star = i + 1;
                  return GestureDetector(
                    onTap: () => setState(() => _rating = star),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        _rating >= star
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: _rating >= star ? _gold : _muted,
                        size: 36,
                      ),
                    ),
                  );
                }),
              )),

            const SizedBox(height: 14),

            // ── Comment field (optional) ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08))),
                child: TextField(
                  controller: _commentCtrl,
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  style: TextStyle(color: _white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Share your experience (optional)…',
                    hintStyle: TextStyle(color: _muted, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(14)),
                ))),

            const SizedBox(height: 14),

            // ── Submit ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity, height: 48,
                child: ElevatedButton(
                  onPressed: (_rating < 1 || isSubmitting) ? null : () {
                    final comment = _commentCtrl.text.trim();
                    ctx.read<ReviewsBloc>().add(ReviewSubmitRequested(
                      serviceId:      sub.serviceId,
                      subscriptionId: sub.apiId,
                      rating:         _rating * 2, // map 1–5 stars → 2–10
                      comment:        comment.isEmpty ? null : comment,
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _rating >= 1
                        ? _cyan
                        : Colors.white.withValues(alpha: 0.05),
                    foregroundColor:
                        _rating >= 1 ? const Color(0xFF0D1A1C) : _muted,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14))),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Submit Review',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 14)),
                ),
              )),
          ]),
        );
      },
    );
  }

  Widget _reviewedCard(dynamic myReview) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cyan.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cyan.withValues(alpha: 0.20)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.check_circle_rounded, color: _cyan, size: 18),
          const SizedBox(width: 8),
          const Text('You reviewed this service',
              style: TextStyle(
                  color: _cyan, fontSize: 14, fontWeight: FontWeight.w800)),
        ]),
        if (myReview != null) ...[
          const SizedBox(height: 12),
          Row(
            children: List.generate(5, (i) {
              final filled = i < ((myReview.rating as int) / 2).round();
              return Icon(
                filled ? Icons.star_rounded : Icons.star_border_rounded,
                color: filled ? _gold : _muted,
                size: 18,
              );
            }),
          ),
          if ((myReview.comment as String?) != null &&
              (myReview.comment as String).isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(myReview.comment as String,
                style: const TextStyle(color: _white, fontSize: 13, height: 1.4)),
          ],
          if (myReview.createdAt != null) ...[
            const SizedBox(height: 6),
            Text(
              _formatDate(myReview.createdAt as DateTime),
              style: TextStyle(color: _muted.withValues(alpha: 0.65), fontSize: 11),
            ),
          ],
        ],
      ]),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}';

  String _starLabel(int stars) {
    switch (stars) {
      case 1:  return 'Poor';
      case 2:  return 'Average';
      case 3:  return 'Good';
      case 4:  return 'Great';
      case 5:  return 'Excellent!';
      default: return '';
    }
  }

  // ── Shared widget helpers ─────────────────────────────────────────────────

  Widget _banner(Color color, IconData icon, String text) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withValues(alpha: 0.25))),
    child: Row(children: [
      Icon(icon, color: color, size: 16),
      const SizedBox(width: 10),
      Expanded(child: Text(text,
          style: TextStyle(color: color, fontSize: 12, height: 1.4))),
    ]));

  Widget _statCell(String val, String label, Color color) => Expanded(
    child: Column(children: [
      Text(val, style: TextStyle(
          color: color, fontSize: 14, fontWeight: FontWeight.w900)),
      const SizedBox(height: 3),
      Text(label,
          textAlign: TextAlign.center,
          style: TextStyle(color: _muted, fontSize: 9)),
    ]));

  Widget _vDivider() =>
      Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.07));

  Widget _hDivider() =>
      Divider(height: 1, color: Colors.white.withValues(alpha: 0.06));
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal types
// ─────────────────────────────────────────────────────────────────────────────

enum _PayStatus { paid, upcoming, failed, refunded }

class _Payment {
  const _Payment({required this.date, required this.amount, required this.status});
  final DateTime   date;
  final double     amount;
  final _PayStatus status;
}

// ── Confirm dialog ────────────────────────────────────────────────────────────

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.icon,
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.confirmColor,
    required this.onConfirm,
  });

  final IconData     icon;
  final String       title;
  final String       body;
  final String       confirmLabel;
  final Color        confirmColor;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    const white = Color(0xFFFFFFFF);
    const muted = Color(0xFF9BA4B0);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xFF07111C),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: confirmColor.withValues(alpha: 0.25))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: confirmColor.withValues(alpha: 0.10),
              border: Border.all(color: confirmColor.withValues(alpha: 0.30))),
            child: Icon(icon, color: confirmColor, size: 28)),
          const SizedBox(height: 18),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: white, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Text(body,
              textAlign: TextAlign.center,
              style: const TextStyle(color: muted, fontSize: 13, height: 1.5)),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: muted,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14))),
              child: const Text('Keep it'))),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(
              onPressed: () { Navigator.pop(context); onConfirm(); },
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor,
                foregroundColor: white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14))),
              child: Text(confirmLabel,
                  style: const TextStyle(fontWeight: FontWeight.w800)))),
          ]),
        ]),
      ),
    );
  }
}
