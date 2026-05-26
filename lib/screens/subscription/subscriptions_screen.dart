import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../blocs/subscription/subscription_bloc.dart';
import '../../blocs/wallet/wallet_bloc.dart';
import '../../blocs/reviews/reviews_bloc.dart';
import 'subscription_detail_screen.dart';

enum _StatusFilter { all, active, paused, cancelled }

enum _SortOption { renewalAsc, amountDesc, amountAsc }

/// Standalone subscriptions list — clean cards, no action buttons.
/// Accepts an optional [initialFilter] from dashboard card shortcuts.
class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key, this.initialFilter});

  /// 'active' | 'paused' | 'cancelled' | 'due_soon' | null → All
  final String? initialFilter;

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  // ── Colours ────────────────────────────────────────────────────────────────
  static const _cyan        = Color(0xFF1DD8E8);
  static const _orange      = Color(0xFFFF5A14);
  static const _textPrimary = Color(0xFFFFFFFF);
  static const _textMuted   = Color(0xFF8A9BA8);

  // ── State ─────────────────────────────────────────────────────────────────
  late _StatusFilter _statusFilter;
  _SortOption _sortOption = _SortOption.renewalAsc;
  String _billingFilter = 'all';
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _applyInitialFilter(widget.initialFilter);
  }

  void _applyInitialFilter(String? f) {
    switch (f) {
      case 'active':
        _statusFilter = _StatusFilter.active;
      case 'paused':
        _statusFilter = _StatusFilter.paused;
      case 'cancelled':
        _statusFilter = _StatusFilter.cancelled;
      case 'due_soon':
        _statusFilter = _StatusFilter.active;
        _sortOption = _SortOption.renewalAsc;
      default:
        _statusFilter = _StatusFilter.all;
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Filtering & sorting ───────────────────────────────────────────────────
  List<SubscriptionModel> _applyFilters(List<SubscriptionModel> all) {
    var list = [...all];

    switch (_statusFilter) {
      case _StatusFilter.active:
        list = list.where((s) => s.isActive).toList();
      case _StatusFilter.paused:
        list = list.where((s) => s.isPaused).toList();
      case _StatusFilter.cancelled:
        list = list.where((s) => s.isCancelled).toList();
      case _StatusFilter.all:
        break;
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((s) =>
          s.serviceName.toLowerCase().contains(q) ||
          s.plan.toLowerCase().contains(q)).toList();
    }

    if (_billingFilter != 'all') {
      list = list
          .where((s) => s.billingCycle.toLowerCase() == _billingFilter)
          .toList();
    }

    switch (_sortOption) {
      case _SortOption.renewalAsc:
        list.sort((a, b) => a.nextRenewal.compareTo(b.nextRenewal));
      case _SortOption.amountDesc:
        list.sort((a, b) => b.amount.compareTo(a.amount));
      case _SortOption.amountAsc:
        list.sort((a, b) => a.amount.compareTo(b.amount));
    }

    return list;
  }

  bool get _hasFilters =>
      _statusFilter != _StatusFilter.all ||
      _searchQuery.isNotEmpty ||
      _billingFilter != 'all';

  void _clearFilters() => setState(() {
        _statusFilter = _StatusFilter.all;
        _billingFilter = 'all';
        _searchQuery = '';
        _searchCtrl.clear();
      });

  // ── Card helper ───────────────────────────────────────────────────────────
  String? _cardLabel(SubscriptionModel sub, List<CardModel> cards) {
    if (sub.cardId.isEmpty) return null;
    try {
      final c = cards.firstWhere((c) => c.id == sub.cardId);
      final digits = c.maskedPan.replaceAll(RegExp(r'[^\d]'), '');
      final last4 = digits.length >= 4 ? digits.substring(digits.length - 4) : digits;
      return '${c.type.isNotEmpty ? c.type : 'Card'} ••••$last4';
    } catch (_) {
      return null;
    }
  }

  // ── Navigation ────────────────────────────────────────────────────────────
  void _openDetail(BuildContext ctx, SubscriptionModel sub) {
    Navigator.push(ctx, MaterialPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: ctx.read<SubscriptionBloc>()),
          BlocProvider.value(value: ctx.read<WalletBloc>()),
          BlocProvider.value(value: ctx.read<ReviewsBloc>()),
        ],
        child: SubscriptionDetailScreen(subscription: sub),
      ),
    ));
  }

  // ── Sort sheet ────────────────────────────────────────────────────────────
  void _showSortSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(builder: (sheetCtx, setSheetState) {
          return Container(
            padding: EdgeInsets.fromLTRB(
                20, 16, 20, 20 + MediaQuery.of(sheetCtx).viewPadding.bottom),
            decoration: const BoxDecoration(
              color: Color(0xFF141820),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Sort & Filter',
                    style: TextStyle(
                        color: _textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 16)),
              ),
              const SizedBox(height: 16),
              _sheetSection('Sort by', [
                _sheetOption(sheetCtx, setSheetState,
                    label: 'Renewal date',
                    icon: Icons.calendar_today_rounded,
                    selected: _sortOption == _SortOption.renewalAsc,
                    onTap: () {
                      setState(() => _sortOption = _SortOption.renewalAsc);
                      Navigator.pop(ctx);
                    }),
                _sheetOption(sheetCtx, setSheetState,
                    label: 'Amount: high → low',
                    icon: Icons.arrow_downward_rounded,
                    selected: _sortOption == _SortOption.amountDesc,
                    onTap: () {
                      setState(() => _sortOption = _SortOption.amountDesc);
                      Navigator.pop(ctx);
                    }),
                _sheetOption(sheetCtx, setSheetState,
                    label: 'Amount: low → high',
                    icon: Icons.arrow_upward_rounded,
                    selected: _sortOption == _SortOption.amountAsc,
                    onTap: () {
                      setState(() => _sortOption = _SortOption.amountAsc);
                      Navigator.pop(ctx);
                    }),
              ]),
              const SizedBox(height: 16),
              _sheetSection('Billing cycle', [
                for (final opt in [
                  ('all', 'All cycles', Icons.all_inclusive_rounded),
                  ('monthly', 'Monthly', Icons.calendar_month_rounded),
                  ('yearly', 'Yearly', Icons.event_repeat_rounded),
                  ('weekly', 'Weekly', Icons.view_week_rounded),
                ])
                  _sheetOption(sheetCtx, setSheetState,
                      label: opt.$2,
                      icon: opt.$3,
                      selected: _billingFilter == opt.$1,
                      onTap: () {
                        setState(() => _billingFilter = opt.$1);
                        Navigator.pop(ctx);
                      }),
              ]),
            ]),
          );
        });
      },
    );
  }

  Widget _sheetSection(String title, List<Widget> items) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title,
          style: const TextStyle(
              color: _textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5)),
      const SizedBox(height: 8),
      ...items,
    ]);
  }

  Widget _sheetOption(
    BuildContext ctx,
    StateSetter setSheetState, {
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? _cyan.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected
                  ? _cyan.withValues(alpha: 0.30)
                  : Colors.transparent),
        ),
        child: Row(children: [
          Icon(icon, color: selected ? _cyan : _textMuted, size: 17),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                  color: selected ? _cyan : _textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const Spacer(),
          if (selected) const Icon(Icons.check_rounded, color: _cyan, size: 17),
        ]),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Main build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SubscriptionBloc, SubscriptionState>(
      listener: (ctx, state) {
        if (state is SubscriptionData && state.actionError != null) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
            content: Text(state.actionError!),
            backgroundColor: _orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ));
        }
      },
      builder: (ctx, state) {
        // ── Loading ──────────────────────────────────────────────────────────
        if (state is SubscriptionsLoading) {
          return const Center(
            child: CircularProgressIndicator(color: _cyan, strokeWidth: 2.5),
          );
        }

        // ── Error ────────────────────────────────────────────────────────────
        if (state is SubscriptionError) {
          return _ErrorView(
              message: state.message,
              onRetry: () => ctx
                  .read<SubscriptionBloc>()
                  .add(const SubscriptionsRefreshRequested()));
        }

        final allSubs = state is SubscriptionData
            ? state.subscriptions
            : <SubscriptionModel>[];
        final isRefreshing = state is SubscriptionData && state.isLoading;
        final shown = _applyFilters(allSubs);

        final walletState = context.watch<WalletBloc>().state;
        final cards = walletState is WalletData ? walletState.cards : <CardModel>[];

        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Top bar ─────────────────────────────────────────────────────────
          _TopBar(
            totalCount: allSubs.length,
            shownCount: shown.length,
            onSort: () => _showSortSheet(ctx),
            onRefresh: () => ctx
                .read<SubscriptionBloc>()
                .add(const SubscriptionsRefreshRequested()),
          ),

          // ── Search ───────────────────────────────────────────────────────
          _SearchBar(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _searchQuery = v),
          ),

          // ── Filter chips ─────────────────────────────────────────────────
          _FilterRow(
            selected: _statusFilter,
            onSelect: (f) => setState(() => _statusFilter = f),
          ),

          Divider(height: 1, color: Colors.white.withValues(alpha: 0.06)),

          // ── List ─────────────────────────────────────────────────────────
          Expanded(
            child: shown.isEmpty && !isRefreshing
                ? _EmptyState(hasFilters: _hasFilters, onClear: _clearFilters)
                : _SubList(
                    subs: shown,
                    cards: cards,
                    isRefreshing: isRefreshing,
                    cardLabel: (s) => _cardLabel(s, cards),
                    onTap: (s) => _openDetail(ctx, s),
                    onRefresh: () async {
                      ctx
                          .read<SubscriptionBloc>()
                          .add(const SubscriptionsRefreshRequested());
                      await Future.delayed(const Duration(milliseconds: 800));
                    },
                  ),
          ),
        ]);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.totalCount,
    required this.shownCount,
    required this.onSort,
    required this.onRefresh,
  });

  final int totalCount;
  final int shownCount;
  final VoidCallback onSort;
  final VoidCallback onRefresh;

  static const _textPrimary = Color(0xFFFFFFFF);
  static const _textMuted   = Color(0xFF8A9BA8);

  @override
  Widget build(BuildContext context) {
    final subtitle = shownCount == totalCount
        ? '$totalCount subscription${totalCount == 1 ? '' : 's'}'
        : 'Showing $shownCount of $totalCount';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Subscriptions',
                style: TextStyle(
                    color: _textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: const TextStyle(color: _textMuted, fontSize: 12)),
          ]),
        ),
        _IconBtn(icon: Icons.swap_vert_rounded, onTap: onSort),
        const SizedBox(width: 8),
        _IconBtn(icon: Icons.refresh_rounded, onTap: onRefresh),
      ]),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1E26),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Icon(icon, color: const Color(0xFFFFFFFF), size: 20),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  static const _textPrimary = Color(0xFFFFFFFF);
  static const _textMuted   = Color(0xFF8A9BA8);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1E26),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
        ),
        child: Row(children: [
          const SizedBox(width: 14),
          const Icon(Icons.search_rounded, color: _textMuted, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(color: _textPrimary, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Search Netflix, Spotify…',
                hintStyle: TextStyle(color: _textMuted, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: onChanged,
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller.clear();
                onChanged('');
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.close_rounded, color: _textMuted, size: 16),
              ),
            ),
        ]),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.selected, required this.onSelect});
  final _StatusFilter selected;
  final ValueChanged<_StatusFilter> onSelect;

  static const _cyan   = Color(0xFF1DD8E8);
  static const _amber  = Color(0xFFF59E0B);
  static const _red    = Color(0xFFEF4444);

  Color _chipColor(_StatusFilter f) {
    switch (f) {
      case _StatusFilter.all:       return _cyan;
      case _StatusFilter.active:    return _cyan;
      case _StatusFilter.paused:    return _amber;
      case _StatusFilter.cancelled: return _red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
        scrollDirection: Axis.horizontal,
        children: [
          for (final f in _StatusFilter.values) ...[
            _Chip(
              label: switch (f) {
                _StatusFilter.all       => 'All',
                _StatusFilter.active    => 'Active',
                _StatusFilter.paused    => 'Paused',
                _StatusFilter.cancelled => 'Cancelled',
              },
              color: _chipColor(f),
              selected: selected == f,
              onTap: () => onSelect(f),
            ),
            if (f != _StatusFilter.cancelled) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.14)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? color.withValues(alpha: 0.52)
                : Colors.white.withValues(alpha: 0.09),
            width: selected ? 1.3 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : const Color(0xFF8A9BA8),
            fontSize: 12,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── List ──────────────────────────────────────────────────────────────────────

class _SubList extends StatelessWidget {
  const _SubList({
    required this.subs,
    required this.cards,
    required this.isRefreshing,
    required this.cardLabel,
    required this.onTap,
    required this.onRefresh,
  });

  final List<SubscriptionModel> subs;
  final List<CardModel> cards;
  final bool isRefreshing;
  final String? Function(SubscriptionModel) cardLabel;
  final void Function(SubscriptionModel) onTap;
  final Future<void> Function() onRefresh;

  static const _cyan    = Color(0xFF1DD8E8);
  static const _surface = Color(0xFF141820);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: _cyan,
      backgroundColor: _surface,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        itemCount: subs.length + (isRefreshing ? 1 : 0),
        itemBuilder: (_, i) {
          if (isRefreshing && i == 0) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: _cyan, strokeWidth: 2),
                ),
              ),
            );
          }
          final sub = subs[isRefreshing ? i - 1 : i];
          return _SubCard(
            sub: sub,
            cardLabel: cardLabel(sub),
            onTap: () => onTap(sub),
          );
        },
      ),
    );
  }
}

// ── Subscription card ─────────────────────────────────────────────────────────

class _SubCard extends StatelessWidget {
  const _SubCard({
    required this.sub,
    required this.cardLabel,
    required this.onTap,
  });

  final SubscriptionModel sub;
  final String? cardLabel;
  final VoidCallback onTap;

  static const _surface     = Color(0xFF141820);
  static const _cyan        = Color(0xFF1DD8E8);
  static const _amber       = Color(0xFFF59E0B);
  static const _red         = Color(0xFFEF4444);
  static const _orange      = Color(0xFFFF5A14);
  static const _textPrimary = Color(0xFFFFFFFF);
  static const _textMuted   = Color(0xFF8A9BA8);

  Color get _statusColor =>
      sub.isCancelled ? _red : sub.isPaused ? _amber : _cyan;

  String get _statusLabel =>
      sub.isCancelled ? 'Cancelled' : sub.isPaused ? 'Paused' : 'Active';

  IconData get _statusIcon => sub.isCancelled
      ? Icons.cancel_outlined
      : sub.isPaused
          ? Icons.pause_circle_outline_rounded
          : Icons.check_circle_outline_rounded;

  String get _planLine {
    if (sub.plan.isEmpty || sub.plan == sub.billingCycle) return sub.billingCycle;
    return '${sub.plan} · ${sub.billingCycle}';
  }

  @override
  Widget build(BuildContext context) {
    final daysLeft = sub.nextRenewal.difference(DateTime.now()).inDays;
    final isUrgent = sub.isActive && daysLeft <= 3;
    final statusColor = _statusColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: statusColor.withValues(alpha: 0.22)),
          boxShadow: [
            BoxShadow(
                color: statusColor.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4)),
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.20),
                blurRadius: 14,
                offset: const Offset(0, 6)),
          ],
        ),
        child: Column(children: [

          // ── Row 1: icon + name + status badge ─────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _ServiceIcon(
                emoji: sub.serviceIcon,
                statusColor: statusColor,
                isActive: sub.isActive,
                isPaused: sub.isPaused,
                isCancelled: sub.isCancelled,
              ),
              const SizedBox(width: 12),
              Expanded(
                child:
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SizedBox(height: 2),
                  Text(
                    sub.serviceName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: sub.isCancelled ? _textMuted : _textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      decoration: sub.isCancelled ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(_planLine,
                      style: const TextStyle(color: _textMuted, fontSize: 12)),
                ]),
              ),
              const SizedBox(width: 8),
              _StatusBadge(
                  label: _statusLabel,
                  icon: _statusIcon,
                  color: statusColor),
            ]),
          ),

          const SizedBox(height: 14),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.06)),

          // ── Row 2: amount + renewal ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(children: [
              // Amount
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  '\$${sub.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                      color: sub.isCancelled ? _textMuted : _textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 18),
                ),
                const SizedBox(height: 2),
                Text('/ ${sub.billingCycle.toLowerCase()}',
                    style: const TextStyle(color: _textMuted, fontSize: 11)),
              ]),
              const Spacer(),
              // Renewal countdown (active only)
              if (sub.isActive)
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(
                    DateFormat('MMM d, yyyy').format(sub.nextRenewal),
                    style: TextStyle(
                        color: isUrgent ? _orange : _textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isUrgent ? '$daysLeft days left!' : 'in $daysLeft days',
                    style: TextStyle(
                        color: isUrgent ? _orange : _textMuted, fontSize: 11),
                  ),
                ]),
              // Tap hint arrow
              const SizedBox(width: 10),
              Icon(Icons.chevron_right_rounded,
                  color: statusColor.withValues(alpha: 0.50), size: 20),
            ]),
          ),

          // ── Row 3: linked card (optional) ─────────────────────────────────
          if (cardLabel != null) ...[
            Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 9, 16, 9),
              child: Row(children: [
                Icon(Icons.credit_card_rounded,
                    color: statusColor.withValues(alpha: 0.55), size: 14),
                const SizedBox(width: 6),
                Text(cardLabel!,
                    style: const TextStyle(
                        color: _textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ]),
            ),
          ],
        ]),
      ),
    );
  }
}

// ── Service icon ──────────────────────────────────────────────────────────────

class _ServiceIcon extends StatelessWidget {
  const _ServiceIcon({
    required this.emoji,
    required this.statusColor,
    required this.isActive,
    required this.isPaused,
    required this.isCancelled,
  });
  final String emoji;
  final Color statusColor;
  final bool isActive;
  final bool isPaused;
  final bool isCancelled;

  @override
  Widget build(BuildContext context) {
    return Stack(clipBehavior: Clip.none, children: [
      Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: statusColor.withValues(alpha: 0.22)),
        ),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
      ),
      if (!isActive)
        Positioned(
          top: -3,
          right: -3,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor,
              border: Border.all(color: const Color(0xFF141820), width: 1.5),
            ),
            child: Icon(
                isCancelled ? Icons.close : Icons.pause,
                color: Colors.white,
                size: 8),
          ),
        ),
    ]);
  }
}

// ── Status badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge(
      {required this.label, required this.icon, required this.color});
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 11),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w800)),
      ]),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasFilters, required this.onClear});
  final bool hasFilters;
  final VoidCallback onClear;

  static const _cyan        = Color(0xFF1DD8E8);
  static const _textPrimary = Color(0xFFFFFFFF);
  static const _textMuted   = Color(0xFF8A9BA8);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _cyan.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _cyan.withValues(alpha: 0.20)),
            ),
            child: const Icon(Icons.receipt_long_outlined, color: _cyan, size: 32),
          ),
          const SizedBox(height: 18),
          Text(
            hasFilters ? 'No matches found' : 'No subscriptions yet',
            style: const TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 17),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilters
                ? 'Try a different filter or search term.'
                : 'Head to the Services tab to add your first subscription.',
            textAlign: TextAlign.center,
            style:
                const TextStyle(color: _textMuted, fontSize: 13, height: 1.55),
          ),
          if (hasFilters) ...[
            const SizedBox(height: 20),
            GestureDetector(
              onTap: onClear,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                decoration: BoxDecoration(
                  color: _cyan.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _cyan.withValues(alpha: 0.35)),
                ),
                child: const Text('Clear filters',
                    style: TextStyle(
                        color: _cyan,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}

// ── Error view ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  static const _orange      = Color(0xFFFF5A14);
  static const _cyan        = Color(0xFF1DD8E8);
  static const _textPrimary = Color(0xFFFFFFFF);
  static const _textMuted   = Color(0xFF8A9BA8);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _orange.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.cloud_off_rounded, color: _orange, size: 30),
          ),
          const SizedBox(height: 16),
          const Text('Could not load subscriptions',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 16)),
          const SizedBox(height: 8),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: _textMuted, fontSize: 13, height: 1.5)),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: _cyan.withValues(alpha: 0.60)),
              ),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.refresh_rounded, color: _cyan, size: 18),
                SizedBox(width: 8),
                Text('Retry',
                    style: TextStyle(color: _cyan, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
