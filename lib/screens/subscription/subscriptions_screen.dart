import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../blocs/reviews/reviews_bloc.dart';
import '../../blocs/subscription/subscription_bloc.dart';
import '../../blocs/wallet/wallet_bloc.dart';
import 'subscription_detail_screen.dart';

enum _StatusFilter { all, active, paused, cancelled }

enum _SortOption { renewalAsc, amountDesc, amountAsc }

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key, this.initialFilter});

  final String? initialFilter;

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  static const _background = Color(0xFF070B12);
  static const _card = Color(0xFF101722);
  static const _cardDark = Color(0xFF0B111A);
  static const _cyan = Color(0xFF00D9E8);
  static const _orange = Color(0xFFFF7A1A);
  static const _text = Color(0xFFF5F7FA);
  static const _muted = Color(0xFF8B98A8);
  static const _red = Color(0xFFFF4D5E);
  static const _amber = Color(0xFFFFB020);

  late _StatusFilter _statusFilter;
  _SortOption _sortOption = _SortOption.renewalAsc;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _applyInitialFilter(widget.initialFilter);
  }

  void _applyInitialFilter(String? filter) {
    switch (filter) {
      case 'active':
      case 'due_soon':
        _statusFilter = _StatusFilter.active;
      case 'paused':
        _statusFilter = _StatusFilter.paused;
      case 'cancelled':
        _statusFilter = _StatusFilter.cancelled;
      default:
        _statusFilter = _StatusFilter.all;
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

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

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list
          .where((s) =>
              s.serviceName.toLowerCase().contains(q) ||
              s.plan.toLowerCase().contains(q) ||
              s.billingCycle.toLowerCase().contains(q))
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
      _statusFilter != _StatusFilter.all || _searchQuery.trim().isNotEmpty;

  void _clearFilters() => setState(() {
        _statusFilter = _StatusFilter.all;
        _searchQuery = '';
        _searchCtrl.clear();
      });

  void _openDetail(BuildContext ctx, SubscriptionModel sub) {
    Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: ctx.read<SubscriptionBloc>()),
            BlocProvider.value(value: ctx.read<WalletBloc>()),
            BlocProvider.value(value: ctx.read<ReviewsBloc>()),
          ],
          child: SubscriptionDetailScreen(subscription: sub),
        ),
      ),
    );
  }

  void _showSortSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(
          20,
          14,
          20,
          20 + MediaQuery.of(ctx).viewPadding.bottom,
        ),
        decoration: const BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sort subscriptions',
              style: TextStyle(
                color: _text,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            _sortOptionTile(
              label: 'Renewal date',
              icon: Icons.calendar_month_rounded,
              selected: _sortOption == _SortOption.renewalAsc,
              onTap: () {
                setState(() => _sortOption = _SortOption.renewalAsc);
                Navigator.pop(ctx);
              },
            ),
            _sortOptionTile(
              label: 'Price: high to low',
              icon: Icons.south_rounded,
              selected: _sortOption == _SortOption.amountDesc,
              onTap: () {
                setState(() => _sortOption = _SortOption.amountDesc);
                Navigator.pop(ctx);
              },
            ),
            _sortOptionTile(
              label: 'Price: low to high',
              icon: Icons.north_rounded,
              selected: _sortOption == _SortOption.amountAsc,
              onTap: () {
                setState(() => _sortOption = _SortOption.amountAsc);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _sortOptionTile({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? _cyan.withValues(alpha: 0.10) : _cardDark,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? _cyan.withValues(alpha: 0.52)
                    : Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: selected ? _cyan : _muted, size: 19),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected ? _cyan : _text,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (selected)
                  const Icon(Icons.check_rounded, color: _cyan, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({
    required BuildContext context,
    required int totalCount,
    required bool isRefreshing,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Subscriptions',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _text,
                    fontSize: 32,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$totalCount subscription${totalCount == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _iconButton(
            icon: Icons.sort_rounded,
            onTap: () => _showSortSheet(context),
          ),
          const SizedBox(width: 10),
          _iconButton(
            icon: Icons.refresh_rounded,
            isLoading: isRefreshing,
            onTap: () => context
                .read<SubscriptionBloc>()
                .add(const SubscriptionsRefreshRequested()),
          ),
        ],
      ),
    );
  }

  Widget _iconButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _card.withValues(alpha: 0.92),
            border: Border.all(color: _cyan.withValues(alpha: 0.30)),
            boxShadow: [
              BoxShadow(
                color: _cyan.withValues(alpha: 0.12),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: isLoading
              ? const Padding(
                  padding: EdgeInsets.all(13),
                  child: CircularProgressIndicator(
                    color: _cyan,
                    strokeWidth: 2,
                  ),
                )
              : Icon(icon, color: _cyan, size: 22),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: _cardDark.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: _cyan.withValues(alpha: 0.58), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: _cyan.withValues(alpha: 0.10),
              blurRadius: 22,
              spreadRadius: -6,
            ),
          ],
        ),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (value) => setState(() => _searchQuery = value),
          style: const TextStyle(
            color: _text,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            hintText: 'Search Netflix, Spotify...',
            hintStyle: TextStyle(
              color: _muted.withValues(alpha: 0.72),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: const Icon(Icons.search_rounded, color: _cyan),
            suffixIcon: _searchQuery.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close_rounded, color: _muted),
                    onPressed: () => setState(() {
                      _searchQuery = '';
                      _searchCtrl.clear();
                    }),
                  ),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final chips = [
      (_StatusFilter.all, 'All'),
      (_StatusFilter.active, 'Active'),
      (_StatusFilter.paused, 'Paused'),
      (_StatusFilter.cancelled, 'Cancelled'),
    ];

    return SizedBox(
      height: 70,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, index) {
          final filter = chips[index].$1;
          final label = chips[index].$2;
          final selected = _statusFilter == filter;
          return GestureDetector(
            onTap: () => setState(() => _statusFilter = filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? null : _cardDark,
                gradient: selected
                    ? LinearGradient(
                        colors: [
                          _cyan.withValues(alpha: 0.95),
                          _cyan.withValues(alpha: 0.46),
                        ],
                      )
                    : null,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: selected
                      ? _cyan
                      : Colors.white.withValues(alpha: 0.10),
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: _cyan.withValues(alpha: 0.38),
                          blurRadius: 20,
                          spreadRadius: -4,
                        ),
                      ]
                    : [],
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? _background : _muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubscriptionCard(SubscriptionModel sub) {
    final now = DateTime.now();
    final totalDays = _cycleDays(sub.billingCycle);
    final rawDaysLeft = sub.nextRenewal.difference(now).inDays;
    final daysLeft = math.max(0, rawDaysLeft);
    final progress = sub.isActive
        ? (1 - (daysLeft / totalDays)).clamp(0.0, 1.0)
        : (sub.isPaused ? 0.45 : 1.0);
    final statusColor = _statusColor(sub);
    final planLine = _planLine(sub);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(26),
        child: InkWell(
          onTap: () => _openDetail(context, sub),
          borderRadius: BorderRadius.circular(26),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: _cyan.withValues(alpha: 0.24)),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_card, _cardDark],
              ),
              boxShadow: [
                BoxShadow(
                  color: _cyan.withValues(alpha: 0.10),
                  blurRadius: 30,
                  spreadRadius: -10,
                  offset: const Offset(0, 14),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.32),
                  blurRadius: 26,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _serviceIcon(sub),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sub.serviceName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: sub.isCancelled ? _muted : _text,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              decoration: sub.isCancelled
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            planLine,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _muted,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    _statusBadge(sub, statusColor),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        '\$${sub.amount.toStringAsFixed(2)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _text,
                          fontSize: 27,
                          height: 1,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                color: _cyan.withValues(alpha: 0.85),
                                size: 15,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  DateFormat('MMM d').format(sub.nextRenewal),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: _text,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            sub.isActive
                                ? (rawDaysLeft < 0
                                    ? 'due now'
                                    : 'in $daysLeft days')
                                : _statusLabel(sub),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: sub.isActive ? _muted : statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: _cyan,
                      size: 26,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      sub.isActive ? _cyan : statusColor,
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  sub.isActive
                      ? '$daysLeft days left'
                      : '${_statusLabel(sub)} subscription',
                  style: TextStyle(
                    color: sub.isActive ? _cyan : _muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() => const SizedBox.shrink();

  Widget _serviceIcon(SubscriptionModel sub) {
    final logo = sub.serviceLogoUrl;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cyan.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: _cyan.withValues(alpha: 0.12),
            blurRadius: 18,
            spreadRadius: -5,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: logo != null && logo.isNotEmpty
          ? Image.network(
              logo,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => _serviceEmoji(sub),
            )
          : _serviceEmoji(sub),
    );
  }

  Widget _serviceEmoji(SubscriptionModel sub) {
    return Center(
      child: Text(
        sub.serviceIcon,
        style: const TextStyle(fontSize: 27),
      ),
    );
  }

  Widget _statusBadge(SubscriptionModel sub, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Text(
        _statusLabel(sub),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Color _statusColor(SubscriptionModel sub) {
    if (sub.isCancelled) return _red;
    if (sub.isPaused) return _amber;
    return _cyan;
  }

  String _statusLabel(SubscriptionModel sub) {
    if (sub.isCancelled) return 'Cancelled';
    if (sub.isPaused) return 'Paused';
    return 'Active';
  }

  String _planLine(SubscriptionModel sub) {
    final plan = sub.plan.trim().isEmpty ? 'Plan' : sub.plan.trim();
    final cycle =
        sub.billingCycle.trim().isEmpty ? 'Monthly' : sub.billingCycle.trim();
    if (plan.toLowerCase() == cycle.toLowerCase()) return cycle;
    return '$plan • $cycle';
  }

  int _cycleDays(String cycle) {
    switch (cycle.toLowerCase()) {
      case 'weekly':
        return 7;
      case 'yearly':
        return 365;
      default:
        return 30;
    }
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: _cyan.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _cyan.withValues(alpha: 0.20)),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: _cyan,
                size: 34,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _hasFilters ? 'No matches found' : 'No subscriptions yet',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _text,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _hasFilters
                  ? 'Try a different status or search term.'
                  : 'Your subscriptions will appear here once available.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _muted,
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_hasFilters) ...[
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _clearFilters,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: _cyan.withValues(alpha: 0.55)),
                    color: _cyan.withValues(alpha: 0.08),
                  ),
                  child: const Text(
                    'Clear filters',
                    style: TextStyle(
                      color: _cyan,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _errorView(BuildContext context, String message) {
    return Container(
      color: _background,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 34),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: _orange.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _orange.withValues(alpha: 0.24)),
                ),
                child: const Icon(
                  Icons.cloud_off_rounded,
                  color: _orange,
                  size: 32,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Could not load subscriptions',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _text,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 13,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 22),
              _iconButton(
                icon: Icons.refresh_rounded,
                onTap: () => context
                    .read<SubscriptionBloc>()
                    .add(const SubscriptionsRefreshRequested()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SubscriptionBloc, SubscriptionState>(
      listener: (ctx, state) {
        if (state is SubscriptionData && state.actionError != null) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(state.actionError!),
              backgroundColor: _orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          );
        }
      },
      builder: (ctx, state) {
        if (state is SubscriptionsLoading) {
          return const ColoredBox(
            color: _background,
            child: Center(
              child: CircularProgressIndicator(color: _cyan, strokeWidth: 2.5),
            ),
          );
        }

        if (state is SubscriptionError) {
          return _errorView(ctx, state.message);
        }

        final allSubs =
            state is SubscriptionData ? state.subscriptions : <SubscriptionModel>[];
        final isRefreshing = state is SubscriptionData && state.isLoading;
        final shown = _applyFilters(allSubs);

        return Container(
          color: _background,
          child: Column(
            children: [
              _buildHeader(
                context: ctx,
                totalCount: allSubs.length,
                isRefreshing: isRefreshing,
              ),
              _buildSearchBar(),
              _buildFilterChips(),
              Expanded(
                child: RefreshIndicator(
                  color: _cyan,
                  backgroundColor: _card,
                  onRefresh: () async {
                    ctx
                        .read<SubscriptionBloc>()
                        .add(const SubscriptionsRefreshRequested());
                    await Future.delayed(const Duration(milliseconds: 700));
                  },
                  child: shown.isEmpty && !isRefreshing
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 30, 20, 120),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.42,
                              child: _emptyState(),
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                          itemCount: shown.length + (isRefreshing ? 1 : 0),
                          itemBuilder: (_, index) {
                            if (isRefreshing && index == 0) {
                              return const Padding(
                                padding: EdgeInsets.only(bottom: 14),
                                child: Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: _cyan,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              );
                            }
                            final sub = shown[isRefreshing ? index - 1 : index];
                            return _buildSubscriptionCard(sub);
                          },
                        ),
                ),
              ),
              _buildBottomNav(),
            ],
          ),
        );
      },
    );
  }
}
