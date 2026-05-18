import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../blocs/subscription/subscription_bloc.dart';
import '../../blocs/wallet/wallet_bloc.dart';
import '../services/services_browser_screen.dart';
import '../wallet/wallet_screen.dart';
import '../profile/profile_screen.dart';
import '../subscription/edit_subscription_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  int _navFromIndex = 0;
  int _navToIndex = 0;
  late AnimationController _chartCtrl;
  late Animation<double> _chartAnim;
  late AnimationController _navCtrl;
  late Animation<double> _navAnim;

  static const _bg            = Color(0xFF0D0F12);
  static const _cyan          = Color(0xFF1DD8E8);
  static const _orange        = Color(0xFFFF5A14);
  static const _orangeLight   = Color(0xFFFF8C42);
  static const _textPrimary   = Color(0xFFFFFFFF);
  static const _textSecondary = Color(0xFF8A9BA8);
  static const _cardBg        = Color(0xFF141820);

  static const _navItems = [
    _NavDestination(Icons.home_rounded, Icons.home_outlined, 'Home', 0),
    _NavDestination(Icons.grid_view_rounded, Icons.grid_view_outlined, 'Services', 1),
    _NavDestination(Icons.account_balance_wallet_rounded,
        Icons.account_balance_wallet_outlined, 'Wallet', 3),
    _NavDestination(Icons.person_rounded, Icons.person_outline_rounded, 'Profile', 4),
  ];

  static const _catColors = <String, Color>{
    'Streaming': Color(0xFF1DD8E8),
    'Music': Color(0xFFFF5A14),
    'Work': Color(0xFFA855F7),
    'Storage': Color(0xFF22C55E),
    'Developer': Color(0xFFF59E0B),
    'Design': Color(0xFFEC4899),
    'AI': Color(0xFF38BDF8),
    'Gaming': Color(0xFF84CC16),
    'Fitness': Color(0xFFF43F5E),
    'Finance': Color(0xFF14B8A6),
    'Other': Color(0xFF64748B),
  };

  static const _catIcons = <String, IconData>{
    'Streaming': Icons.live_tv_rounded,
    'Music': Icons.music_note_rounded,
    'Work': Icons.work_rounded,
    'Storage': Icons.cloud_rounded,
    'Developer': Icons.code_rounded,
    'Design': Icons.brush_rounded,
    'AI': Icons.auto_awesome_rounded,
    'Gaming': Icons.sports_esports_rounded,
    'Fitness': Icons.fitness_center_rounded,
    'Finance': Icons.account_balance_wallet_rounded,
    'Other': Icons.category_rounded,
  };

  static String _guessCategory(String name) {
    final n = name.toLowerCase();
    if (['netflix', 'disney', 'youtube', 'hulu', 'hbo', 'prime', 'apple tv']
        .any((s) => n.contains(s))) { return 'Streaming'; }
    if (['spotify', 'apple music', 'tidal', 'deezer', 'soundcloud']
        .any((s) => n.contains(s))) { return 'Music'; }
    if (['notion', 'slack', 'zoom', 'monday', 'asana', 'office', 'microsoft']
        .any((s) => n.contains(s))) { return 'Work'; }
    if (['icloud', 'dropbox', 'google one', 'onedrive', 'drive']
        .any((s) => n.contains(s))) { return 'Storage'; }
    if (['github', 'gitlab', 'jetbrains', 'aws', 'vercel', 'digitalocean']
        .any((s) => n.contains(s))) { return 'Developer'; }
    if (['figma', 'adobe', 'canva', 'sketch']
        .any((s) => n.contains(s))) { return 'Design'; }
    if (['openai', 'chatgpt', 'claude', 'gemini', 'midjourney']
        .any((s) => n.contains(s))) { return 'AI'; }
    if (['xbox', 'playstation', 'steam', 'nintendo', 'game pass']
        .any((s) => n.contains(s))) { return 'Gaming'; }
    if (['gym', 'fitness', 'strava', 'peloton', 'calm', 'headspace']
        .any((s) => n.contains(s))) { return 'Fitness'; }
    if (['bank', 'wallet', 'trading', 'finance', 'quickbooks']
        .any((s) => n.contains(s))) { return 'Finance'; }
    return 'Other';
  }

  static List<_CategorySpend> _categoryBreakdown(List<SubscriptionModel> subs) {
    final totals = <String, double>{};
    final counts = <String, int>{};

    for (final sub in subs) {
      final category = _guessCategory(sub.serviceName);
      totals[category] = (totals[category] ?? 0) + sub.amount;
      counts[category] = (counts[category] ?? 0) + 1;
    }

    final items = totals.entries
        .map((entry) => _CategorySpend(
              name: entry.key,
              amount: entry.value,
              count: counts[entry.key] ?? 0,
            ))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    return items;
  }

  @override
  void initState() {
    super.initState();
    _chartCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _chartAnim = CurvedAnimation(parent: _chartCtrl, curve: Curves.easeOutCubic);
    _navCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 680));
    _navAnim = CurvedAnimation(parent: _navCtrl, curve: Curves.easeInOutCubic);
    _chartCtrl.forward();
    _navCtrl.value = 1;
  }

  @override
  void dispose() {
    _chartCtrl.dispose();
    _navCtrl.dispose();
    super.dispose();
  }

  // ── Navigation ────────────────────────────────────────────────────────────
  void _openSubDetail(SubscriptionModel sub) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<SubscriptionBloc>()),
            BlocProvider.value(value: context.read<WalletBloc>()),
          ],
          child: EditSubscriptionScreen(subscription: sub),
        ),
      ),
    );
  }

  void _selectNavIndex(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _navFromIndex = _currentIndex;
      _navToIndex = index;
      _currentIndex = index;
    });
    _navCtrl.forward(from: 0);
  }

  // ── Widgets ───────────────────────────────────────────────────────────────
  Widget _iconBtn(IconData icon, {VoidCallback? onTap}) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 50, height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF181E26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08))),
      child: Icon(icon, color: _textPrimary, size: 22)));

  Widget _summaryCard({required String value, required String label,
      required IconData icon, required Color iconColor, required Color glowColor}) {
    return Expanded(child: Stack(children: [
      Container(height: 140,
        decoration: BoxDecoration(
          color: const Color(0xFF080C10),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: glowColor.withValues(alpha: 0.28), width: 1.2))),
      Positioned.fill(child: ClipRRect(borderRadius: BorderRadius.circular(24),
        child: Container(decoration: BoxDecoration(gradient: RadialGradient(
          center: const Alignment(1.0, -1.0), radius: 1.4,
          colors: [glowColor.withValues(alpha: 0.30), glowColor.withValues(alpha: 0.10), Colors.transparent],
          stops: const [0.0, 0.35, 0.75]))))),
      Positioned.fill(child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 36, height: 36,
            decoration: BoxDecoration(color: glowColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, color: iconColor, size: 20)),
          const Spacer(),
          Text(value, style: const TextStyle(color: _textPrimary, fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(color: _textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
        ]))),
    ]));
  }

  Widget _activeSubsCard(int count) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      gradient: const LinearGradient(
        colors: [_cyan, _orangeLight, _orange], stops: [0.0, 0.55, 1.0],
        begin: Alignment.centerLeft, end: Alignment.centerRight),
      boxShadow: [
        BoxShadow(color: _cyan.withValues(alpha: 0.20), blurRadius: 25, offset: const Offset(-5, 8)),
        BoxShadow(color: _orange.withValues(alpha: 0.22), blurRadius: 25, offset: const Offset(5, 8))]),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Active Subscriptions',
            style: TextStyle(color: Color(0xFF0D1A1C), fontWeight: FontWeight.w800, fontSize: 14)),
        const SizedBox(height: 10),
        Text('$count', style: const TextStyle(
            color: Color(0xFF0D1A1C), fontSize: 42, fontWeight: FontWeight.w900, height: 1)),
        const SizedBox(height: 10),
        const Text('Tap any subscription to manage it',
            style: TextStyle(color: Color(0xFF0D1A1C), fontWeight: FontWeight.w700, fontSize: 12)),
      ])),
      Container(width: 60, height: 60,
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.subscriptions_rounded, color: Color(0xFF0D1A1C), size: 28)),
    ]));

  // ── Donut chart ────────────────────────────────────────────────────────────
  Widget _donutChart(List<SubscriptionModel> subs) {
    final categories = _categoryBreakdown(subs);
    final total = categories.fold(0.0, (sum, item) => sum + item.amount);
    final topCategory = categories.isNotEmpty ? categories.first : null;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 26,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('Spending by Category',
              style: TextStyle(color: _textPrimary, fontSize: 15, fontWeight: FontWeight.w800)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _cyan.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _cyan.withValues(alpha: 0.20))),
            child: const Text('This month',
                style: TextStyle(color: _cyan, fontSize: 10, fontWeight: FontWeight.w700))),
        ]),
        const SizedBox(height: 18),
        Row(children: [
          SizedBox(width: 142, height: 142,
            child: AnimatedBuilder(
              animation: _chartAnim,
              builder: (_, __) => CustomPaint(
                painter: _DonutPainter(
                  entries: categories,
                  total: total,
                  progress: _chartAnim.value,
                  colorMap: _catColors,
                  centerLabel: '\$${total.toStringAsFixed(0)}',
                  centerSub: topCategory?.name ?? 'Total'),
              ))),
          const SizedBox(width: 18),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (topCategory != null) ...[
              Text('Top category',
                  style: TextStyle(
                    color: _textSecondary.withValues(alpha: 0.8),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  )),
              const SizedBox(height: 6),
              Row(children: [
                Icon(
                  _catIcons[topCategory.name] ?? Icons.category_rounded,
                  color: _catColors[topCategory.name] ?? const Color(0xFF64748B),
                  size: 17,
                ),
                const SizedBox(width: 6),
                Expanded(child: Text(topCategory.name,
                    style: const TextStyle(
                      color: _textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ))),
              ]),
              const SizedBox(height: 12),
            ],
            ...categories.take(5).map((item) {
              final color = _catColors[item.name] ?? const Color(0xFF64748B);
              final pct = total > 0 ? item.amount / total : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(children: [
                  Row(children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: color.withValues(alpha: 0.22)),
                      ),
                      child: Icon(
                        _catIcons[item.name] ?? Icons.category_rounded,
                        color: color,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ))),
                    Text('\$${item.amount.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        )),
                    const SizedBox(width: 6),
                    Text('${(pct * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: _textSecondary.withValues(alpha: 0.58),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        )),
                  ]),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 3,
                      value: pct,
                      backgroundColor: Colors.white.withValues(alpha: 0.06),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ]));
            }),
          ])),
        ]),
      ]));
  }

  // ── Renewal tile ───────────────────────────────────────────────────────────
  Widget _renewalTile(SubscriptionModel s) {
    final daysLeft    = s.nextRenewal.difference(DateTime.now()).inDays;
    final isUrgent    = daysLeft <= 3 && s.isActive;
    final isCancelled = s.isCancelled;
    final isPaused    = s.isPaused;
    final isInactive  = isCancelled || isPaused;

    final badgeColor = isCancelled ? _orange : const Color(0xFFF59E0B);

    return GestureDetector(
      onTap: () => _openSubDetail(s),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _cardBg, borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isInactive ? badgeColor.withValues(alpha: 0.18) : Colors.white.withValues(alpha: 0.06))),
        child: Row(children: [
          Stack(clipBehavior: Clip.none, children: [
            Container(width: 44, height: 44,
              decoration: BoxDecoration(
                color: isInactive ? badgeColor.withValues(alpha: 0.08) : const Color(0xFF1E2730),
                borderRadius: BorderRadius.circular(14)),
              child: Center(child: Text(s.serviceIcon, style: const TextStyle(fontSize: 22)))),
            if (isInactive)
              Positioned(top: -4, right: -4,
                child: Container(width: 16, height: 16,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: badgeColor),
                  child: Icon(
                    isCancelled ? Icons.close : Icons.pause,
                    color: Colors.white, size: 9))),
          ]),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(child: Text(s.serviceName, style: TextStyle(
                color: isInactive ? _textSecondary : _textPrimary,
                fontWeight: FontWeight.w700, fontSize: 14,
                decoration: isCancelled ? TextDecoration.lineThrough : null))),
              if (isInactive) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                  child: Text(isCancelled ? 'Cancelled' : 'Paused',
                      style: TextStyle(color: badgeColor, fontSize: 9, fontWeight: FontWeight.w800))),
              ],
            ]),
            const SizedBox(height: 3),
            Text(isInactive ? s.plan : DateFormat('MMM d').format(s.nextRenewal),
                style: const TextStyle(color: _textSecondary, fontSize: 12)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('\$${s.amount.toStringAsFixed(2)}', style: TextStyle(
                color: isInactive ? _textSecondary : _textPrimary,
                fontWeight: FontWeight.w800, fontSize: 14)),
            const SizedBox(height: 3),
            if (s.isActive) Text(
              isUrgent ? '$daysLeft days left' : 'in $daysLeft days',
              style: TextStyle(
                  color: isUrgent ? _orange : _textSecondary,
                  fontSize: 11, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            const Icon(Icons.chevron_right_rounded, color: _textSecondary, size: 16),
          ]),
        ])));
  }

  // ── Home tab ───────────────────────────────────────────────────────────────
  Widget _homeTab() {
    return BlocConsumer<SubscriptionBloc, SubscriptionState>(
      listener: (context, subState) {
        if (subState is SubscriptionData && subState.actionError != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(subState.actionError!),
            backgroundColor: _orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ));
        }
      },
      builder: (context, subState) {
        // Full-page loading
        if (subState is SubscriptionsLoading) {
          return const Center(child: CircularProgressIndicator(color: _cyan));
        }

        // Full-page error with retry
        if (subState is SubscriptionError) {
          return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.wifi_off_rounded, color: _textSecondary, size: 48),
            const SizedBox(height: 16),
            Text(subState.message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _textSecondary, fontSize: 14)),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => context.read<SubscriptionBloc>().add(const SubscriptionsRefreshRequested()),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: _cyan.withValues(alpha: 0.65)),
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.refresh_rounded, color: _cyan, size: 18),
                  SizedBox(width: 8),
                  Text('Retry', style: TextStyle(color: _cyan, fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
          ]));
        }

        final allSubs    = subState is SubscriptionData ? subState.subscriptions : <SubscriptionModel>[];
        final activeSubs = allSubs.where((s) => s.isActive).toList();
        final totalSpend = activeSubs.fold(0.0, (sum, s) => sum + s.amount);
        final dueSoon    = activeSubs.where((s) => s.nextRenewal.difference(DateTime.now()).inDays <= 7).length;
        final upcoming   = [...allSubs]..sort((a, b) => a.nextRenewal.compareTo(b.nextRenewal));

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Image.asset('assets/images/owl_cyan.png', width: 32,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.nightlight_round, color: _cyan, size: 32)),
              const SizedBox(width: 10),
              Image.asset('assets/images/scops_white.png', width: 90, fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Text('scops',
                      style: TextStyle(color: _cyan, fontSize: 22, fontWeight: FontWeight.w900))),
              const Spacer(),
              _iconBtn(Icons.notifications_none_rounded),
              const SizedBox(width: 10),
              _iconBtn(Icons.search_rounded),
            ]),
            const SizedBox(height: 28),
            const Text('Dashboard',
                style: TextStyle(color: _textPrimary, fontSize: 32, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            const Text('Monthly spending and subscription overview',
                style: TextStyle(color: _textSecondary, fontSize: 13)),
            const SizedBox(height: 24),
            Row(children: [
              _summaryCard(value: '\$${totalSpend.toStringAsFixed(2)}', label: 'This Month',
                  icon: Icons.payments_rounded, iconColor: _cyan, glowColor: _cyan),
              const SizedBox(width: 14),
              _summaryCard(value: '$dueSoon', label: 'Due Soon',
                  icon: Icons.calendar_month_rounded, iconColor: _orange, glowColor: _orange),
            ]),
            const SizedBox(height: 18),
            _activeSubsCard(activeSubs.length),
            const SizedBox(height: 18),
            if (activeSubs.isNotEmpty) ...[
              _donutChart(activeSubs),
              const SizedBox(height: 28),
            ],
            const Text('Upcoming Renewals',
                style: TextStyle(color: _textPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('Tap to view, edit or cancel',
                style: TextStyle(color: _textSecondary, fontSize: 12)),
            const SizedBox(height: 14),
            if (upcoming.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 36),
                decoration: BoxDecoration(
                  color: _cardBg, borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _cyan.withValues(alpha: 0.35)),
                  boxShadow: [BoxShadow(color: _cyan.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, 10))]),
                child: const Column(children: [
                  Icon(Icons.calendar_today_rounded, color: _textSecondary, size: 36),
                  SizedBox(height: 12),
                  Text('No subscriptions yet.\nTap + to add one.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _textSecondary, fontSize: 13, height: 1.6)),
                ]))
            else
              ...upcoming.map(_renewalTile),
          ]));
      });
  }

  // ── Bottom nav ─────────────────────────────────────────────────────────────
  Widget _bottomNav() {
    final activeSlot = _navItems.indexWhere((item) => item.index == _currentIndex);
    final safeSlot = activeSlot < 0 ? 0 : activeSlot;
    final activeItem = _navItems[safeSlot];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
        child: SizedBox(
          height: 86,
          child: LayoutBuilder(builder: (context, constraints) {
            final width = constraints.maxWidth;
            final slotWidth = width / _navItems.length;

            double centerForIndex(int index) {
              final slot = _navItems.indexWhere((item) => item.index == index);
              final safe = slot < 0 ? 0 : slot;
              return (slotWidth * safe) + (slotWidth / 2);
            }

            return AnimatedBuilder(
              animation: _navAnim,
              builder: (context, _) {
                final t = _navAnim.value;
                final fromCenter = centerForIndex(_navFromIndex);
                final toCenter = centerForIndex(_navToIndex);
                final circleCenter = ui.lerpDouble(fromCenter, toCenter, t)!;
                final circleTop = 10 + (math.sin(t * math.pi) * 8);

                return Stack(clipBehavior: Clip.none, children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 4,
                    height: 72,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: const Color(0xFF08111C).withValues(alpha: 0.96),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.38),
                            blurRadius: 28,
                            offset: const Offset(0, 14),
                          ),
                          BoxShadow(
                            color: _cyan.withValues(alpha: 0.07),
                            blurRadius: 18,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 4,
                    height: 72,
                    child: Row(
                      children: _navItems
                          .map((item) => Expanded(child: _navItem(item)))
                          .toList(),
                    ),
                  ),
                  Positioned(
                    left: circleCenter - 20,
                    top: circleTop,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _selectNavIndex(activeItem.index),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [_orangeLight, _orange],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _orange.withValues(alpha: 0.32),
                              blurRadius: 18,
                              spreadRadius: 1,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: const Color(0xFF08111C).withValues(alpha: 0.90),
                              blurRadius: 10,
                              spreadRadius: -6,
                              offset: const Offset(0, 9),
                            ),
                          ],
                        ),
                        child: Icon(
                          activeItem.activeIcon,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ]);
              },
            );
          }),
        ),
      ),
    );
  }

  Widget _navItem(_NavDestination item) {
    final isActive = _currentIndex == item.index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _selectNavIndex(item.index),
      child: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 40,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: isActive ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 180),
                    child: Icon(
                      item.icon,
                      size: 23,
                      color: const Color(0xFF9BA4B0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: TextStyle(
                  color: isActive ? _orangeLight : const Color(0xFF9BA4B0),
                  fontSize: 10.5,
                  height: 1.0,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                ),
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _currentPage() {
    switch (_currentIndex) {
      case 1: return const ServicesBrowserScreen();
      case 3: return const WalletScreen();
      case 4: return const ProfileScreen();
      default: return _homeTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF05070A), Color(0xFF0D0F12), Color(0xFF081018)],
            begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SafeArea(bottom: true,
          child: Column(children: [
            Expanded(child: _currentPage()),
            _bottomNav(),
          ]))));
  }
}

class _CategorySpend {
  const _CategorySpend({
    required this.name,
    required this.amount,
    required this.count,
  });

  final String name;
  final double amount;
  final int count;
}

class _NavDestination {
  const _NavDestination(this.activeIcon, this.icon, this.label, this.index);

  final IconData activeIcon;
  final IconData icon;
  final String label;
  final int index;
}

// ── Donut chart painter ───────────────────────────────────────────────────
class _DonutPainter extends CustomPainter {
  final List<_CategorySpend> entries;
  final double total;
  final double progress;
  final Map<String, Color> colorMap;
  final String centerLabel;
  final String centerSub;

  const _DonutPainter({
    required this.entries, required this.total, required this.progress,
    required this.colorMap, required this.centerLabel, required this.centerSub,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0) return;
    final center    = size.center(Offset.zero);
    final radius    = size.width / 2 - 4;
    final thickness = radius * 0.40;
    const gap       = 0.03;

    double start = -math.pi / 2;
    for (final e in entries) {
      final sweep = (e.amount / total) * 2 * math.pi * progress;
      final color = colorMap[e.name] ?? const Color(0xFF64748B);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - thickness / 2),
        start + gap, (sweep - gap * 2).clamp(0.0, 2 * math.pi), false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = thickness
          ..strokeCap = StrokeCap.butt);
      start += sweep;
    }

    if (progress > 0.6) {
      final vp = ui.ParagraphBuilder(ui.ParagraphStyle(textAlign: TextAlign.center))
        ..pushStyle(ui.TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900))
        ..addText(centerLabel);
      final vPara = vp.build()..layout(ui.ParagraphConstraints(width: size.width));
      canvas.drawParagraph(vPara, Offset(center.dx - vPara.maxIntrinsicWidth / 2, center.dy - vPara.height - 2));

      final sp = ui.ParagraphBuilder(ui.ParagraphStyle(textAlign: TextAlign.center))
        ..pushStyle(ui.TextStyle(color: const Color(0xFF8A9BA8), fontSize: 9))
        ..addText(centerSub);
      final sPara = sp.build()..layout(ui.ParagraphConstraints(width: size.width));
      canvas.drawParagraph(sPara, Offset(center.dx - sPara.maxIntrinsicWidth / 2, center.dy + 4));
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.progress != progress || old.centerLabel != centerLabel;
}
