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
import '../subscription/add_subscription_screen.dart';
import '../subscription/edit_subscription_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isOpeningAdd = false;
  late AnimationController _chartCtrl;
  late Animation<double> _chartAnim;

  static const _bg            = Color(0xFF0D0F12);
  static const _cyan          = Color(0xFF1DD8E8);
  static const _orange        = Color(0xFFFF5A14);
  static const _orangeLight   = Color(0xFFFF8C42);
  static const _textPrimary   = Color(0xFFFFFFFF);
  static const _textSecondary = Color(0xFF8A9BA8);
  static const _cardBg        = Color(0xFF141820);

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
        .any((s) => n.contains(s))) return 'Streaming';
    if (['spotify', 'apple music', 'tidal', 'deezer', 'soundcloud']
        .any((s) => n.contains(s))) return 'Music';
    if (['notion', 'slack', 'zoom', 'monday', 'asana', 'office', 'microsoft']
        .any((s) => n.contains(s))) return 'Work';
    if (['icloud', 'dropbox', 'google one', 'onedrive', 'drive']
        .any((s) => n.contains(s))) return 'Storage';
    if (['github', 'gitlab', 'jetbrains', 'aws', 'vercel', 'digitalocean']
        .any((s) => n.contains(s))) return 'Developer';
    if (['figma', 'adobe', 'canva', 'sketch']
        .any((s) => n.contains(s))) return 'Design';
    if (['openai', 'chatgpt', 'claude', 'gemini', 'midjourney']
        .any((s) => n.contains(s))) return 'AI';
    if (['xbox', 'playstation', 'steam', 'nintendo', 'game pass']
        .any((s) => n.contains(s))) return 'Gaming';
    if (['gym', 'fitness', 'strava', 'peloton', 'calm', 'headspace']
        .any((s) => n.contains(s))) return 'Fitness';
    if (['bank', 'wallet', 'trading', 'finance', 'quickbooks']
        .any((s) => n.contains(s))) return 'Finance';
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
    _chartCtrl.forward();
  }

  @override
  void dispose() {
    _chartCtrl.dispose();
    super.dispose();
  }

  // ── Navigation ────────────────────────────────────────────────────────────
  void _openAddSubscription() {
    if (_isOpeningAdd) return;
    _isOpeningAdd = true;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<SubscriptionBloc>()),
          BlocProvider.value(value: context.read<WalletBloc>()),
        ],
        child: const AddSubscriptionScreen(),
      ),
    )).whenComplete(() => mounted ? setState(() => _isOpeningAdd = false) : null);
  }

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

  // ── Widgets ───────────────────────────────────────────────────────────────
  Widget _iconBtn(IconData icon, {VoidCallback? onTap}) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 50, height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF181E26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08))),
      child: Icon(icon, color: _textPrimary, size: 22)));

  Widget _summaryCard({required String value, required String label,
      required IconData icon, required Color iconColor, required Color glowColor}) {
    return Expanded(child: Stack(children: [
      Container(height: 140,
        decoration: BoxDecoration(
          color: const Color(0xFF080C10),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: glowColor.withOpacity(0.28), width: 1.2))),
      Positioned.fill(child: ClipRRect(borderRadius: BorderRadius.circular(24),
        child: Container(decoration: BoxDecoration(gradient: RadialGradient(
          center: const Alignment(1.0, -1.0), radius: 1.4,
          colors: [glowColor.withOpacity(0.30), glowColor.withOpacity(0.10), Colors.transparent],
          stops: const [0.0, 0.35, 0.75]))))),
      Positioned.fill(child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 36, height: 36,
            decoration: BoxDecoration(color: glowColor.withOpacity(0.15), borderRadius: BorderRadius.circular(11)),
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
        BoxShadow(color: _cyan.withOpacity(0.20), blurRadius: 25, offset: const Offset(-5, 8)),
        BoxShadow(color: _orange.withOpacity(0.22), blurRadius: 25, offset: const Offset(5, 8))]),
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
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
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
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
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
              color: _cyan.withOpacity(0.10), borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _cyan.withOpacity(0.20))),
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
                    color: _textSecondary.withOpacity(0.8),
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
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: color.withOpacity(0.22)),
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
                          color: _textSecondary.withOpacity(0.58),
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
                      backgroundColor: Colors.white.withOpacity(0.06),
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
    final isUrgent    = daysLeft <= 3;
    final isCancelled = !s.isActive;

    return GestureDetector(
      onTap: () => _openSubDetail(s),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _cardBg, borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isCancelled ? _orange.withOpacity(0.18) : Colors.white.withOpacity(0.06))),
        child: Row(children: [
          Stack(clipBehavior: Clip.none, children: [
            Container(width: 44, height: 44,
              decoration: BoxDecoration(
                color: isCancelled ? _orange.withOpacity(0.08) : const Color(0xFF1E2730),
                borderRadius: BorderRadius.circular(14)),
              child: Center(child: Text(s.serviceIcon, style: const TextStyle(fontSize: 22)))),
            if (isCancelled)
              Positioned(top: -4, right: -4,
                child: Container(width: 16, height: 16,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: _orange),
                  child: const Icon(Icons.close, color: Colors.white, size: 10))),
          ]),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(child: Text(s.serviceName, style: TextStyle(
                color: isCancelled ? _textSecondary : _textPrimary,
                fontWeight: FontWeight.w700, fontSize: 14,
                decoration: isCancelled ? TextDecoration.lineThrough : null))),
              if (isCancelled) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _orange.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                  child: const Text('Cancelled',
                      style: TextStyle(color: _orange, fontSize: 9, fontWeight: FontWeight.w800))),
              ],
            ]),
            const SizedBox(height: 3),
            Text(isCancelled ? s.plan : DateFormat('MMM d').format(s.nextRenewal),
                style: const TextStyle(color: _textSecondary, fontSize: 12)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('\$${s.amount.toStringAsFixed(2)}', style: TextStyle(
                color: isCancelled ? _textSecondary : _textPrimary,
                fontWeight: FontWeight.w800, fontSize: 14)),
            const SizedBox(height: 3),
            if (!isCancelled) Text(
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
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, subState) {
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
                  border: Border.all(color: _cyan.withOpacity(0.35)),
                  boxShadow: [BoxShadow(color: _cyan.withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 10))]),
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
    return SizedBox(
      height: 78,
      child: Stack(clipBehavior: Clip.none, children: [
        Positioned(left: 0, right: 0, bottom: 0,
          child: CustomPaint(
            painter: _BottomNavNotchPainter(),
            child: const SizedBox(height: 68))),
        Positioned(left: 0, bottom: 0,
          child: SizedBox(
            width: MediaQuery.of(context).size.width / 2 - 44, height: 68,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _navItem(Icons.home_outlined, 'Home', 0),
              _navItem(Icons.grid_view_rounded, 'Services', 1),
            ]))),
        Positioned(right: 0, bottom: 0,
          child: SizedBox(
            width: MediaQuery.of(context).size.width / 2 - 44, height: 68,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _navItem(Icons.account_balance_wallet_outlined, 'Wallet', 3),
              _navItem(Icons.person_outline_rounded, 'Profile', 4),
            ]))),
        Positioned(
          top: 0,
          left: MediaQuery.of(context).size.width / 2 - 33,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _openAddSubscription,
            child: Container(
              width: 66, height: 66,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF7A1F), Color(0xFFFF4B09)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
                boxShadow: [BoxShadow(
                    color: _orange.withOpacity(0.45), blurRadius: 22, spreadRadius: 1)]),
              child: const Icon(Icons.add, color: Colors.white, size: 38)))),
      ]));
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _isOpeningAdd ? null : () => setState(() => _currentIndex = index),
      child: SizedBox(width: 68,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 27, color: isActive ? _cyan : const Color(0xFF9BA4B0)),
          const SizedBox(height: 5),
          Text(label, style: TextStyle(
            color: isActive ? _cyan : const Color(0xFF9BA4B0),
            fontSize: 13, fontWeight: isActive ? FontWeight.w800 : FontWeight.w600)),
        ])));
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

// ── Bottom nav painter ────────────────────────────────────────────────────
class _BottomNavNotchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fill   = Paint()..color = const Color(0xFF08111C).withOpacity(0.92)..style = PaintingStyle.fill;
    final border = Paint()..color = Colors.white.withOpacity(0.07)..style = PaintingStyle.stroke..strokeWidth = 1;
    final path   = Path();
    final cx     = size.width / 2;
    const corner = 24.0;

    path.moveTo(corner, 0);
    path.lineTo(cx - 58, 0);
    path.cubicTo(cx - 50, 0, cx - 48, 20, cx - 38, 34);
    path.cubicTo(cx - 28, 52, cx - 18, 64, cx,      64);
    path.cubicTo(cx + 18, 64, cx + 28, 52, cx + 38, 34);
    path.cubicTo(cx + 48, 20, cx + 50, 0,  cx + 58,  0);
    path.lineTo(size.width - corner, 0);
    path.quadraticBezierTo(size.width, 0, size.width, corner);
    path.lineTo(size.width, size.height - corner);
    path.quadraticBezierTo(size.width, size.height, size.width - corner, size.height);
    path.lineTo(corner, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - corner);
    path.lineTo(0, corner);
    path.quadraticBezierTo(0, 0, corner, 0);
    path.close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, border);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
