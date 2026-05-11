// ── dashboard_screen.dart — Sprint 3 update ───────────────────────────────
// Changes from Sprint 2:
//   • Bell icon → opens NotificationsScreen (with unread badge)
//   • Search icon → opens SpendingAnalyticsScreen
//   • Renewal tiles → tap opens PaymentHistoryScreen
//   • FAB double-open bug fixed (Positioned split-nav approach)
//
// Drop this file into: lib/screens/dashboard/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../blocs/subscription/subscription_bloc.dart';
import '../../blocs/wallet/wallet_bloc.dart';
import '../services/services_browser_screen.dart';
import '../wallet/wallet_screen.dart';
import '../profile/profile_screen.dart';
import '../subscription/add_subscription_screen.dart';
import '../notifications/notifications_screen.dart';
import '../analytics/spending_analytics_screen.dart';
import '../payment_history/payment_history_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  bool _isOpeningAdd = false;
  // TODO Sprint 4: derive from NotificationBloc
  int _unreadNotifCount = 2;

  static const _bg            = Color(0xFF0D0F12);
  static const _cyan          = Color(0xFF1DD8E8);
  static const _orange        = Color(0xFFFF5A14);
  static const _orangeLight   = Color(0xFFFF8C42);
  static const _textPrimary   = Color(0xFFFFFFFF);
  static const _textSecondary = Color(0xFF8A9BA8);
  static const _cardBg        = Color(0xFF141820);

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
    )).whenComplete(() {
      if (mounted) setState(() => _isOpeningAdd = false);
    });
  }

  void _openNotifications() {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const NotificationsScreen()));
    setState(() => _unreadNotifCount = 0); // mark all read on open
  }

  void _openAnalytics() {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const SpendingAnalyticsScreen()));
  }

  Widget _iconBtn(IconData icon, {VoidCallback? onTap, int badge = 0}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF181E26),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Icon(icon, color: _textPrimary, size: 22),
          ),
          if (badge > 0)
            Positioned(
              top: -4, right: -4,
              child: Container(
                width: 18, height: 18,
                decoration: BoxDecoration(
                  color: _orange,
                  shape: BoxShape.circle,
                  border: Border.all(color: _bg, width: 2),
                ),
                child: Center(
                  child: Text('$badge',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required String value,
    required String label,
    required IconData icon,
    required Color iconColor,
    required Color glowColor,
    bool spotLeft = false,
  }) {
    return Expanded(
      child: Stack(
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFF080C10),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: glowColor.withOpacity(0.28), width: 1.2),
            ),
          ),
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(1.0, -1.0),
                    radius: 1.4,
                    colors: [
                      glowColor.withOpacity(0.30),
                      glowColor.withOpacity(0.10),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.35, 0.75],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: glowColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                  const Spacer(),
                  Text(value, style: const TextStyle(
                      color: _textPrimary, fontSize: 27, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(label, style: const TextStyle(
                      color: _textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _activeSubsCard(int count) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [_cyan, _orangeLight, _orange],
            stops: [0.0, 0.55, 1.0],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(color: _cyan.withOpacity(0.20), blurRadius: 25, offset: const Offset(-5, 8)),
            BoxShadow(color: _orange.withOpacity(0.22), blurRadius: 25, offset: const Offset(5, 8)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Active Subscriptions',
                      style: TextStyle(color: Color(0xFF0D1A1C), fontWeight: FontWeight.w800, fontSize: 14)),
                  const SizedBox(height: 10),
                  Text('$count', style: const TextStyle(
                      color: Color(0xFF0D1A1C), fontSize: 42, fontWeight: FontWeight.w900, height: 1)),
                  const SizedBox(height: 10),
                  const Text('Manage your services efficiently',
                      style: TextStyle(color: Color(0xFF0D1A1C), fontWeight: FontWeight.w700, fontSize: 13)),
                ],
              ),
            ),
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.subscriptions_rounded, color: Color(0xFF0D1A1C), size: 28),
            ),
          ],
        ),
      );

  Widget _renewalTile(dynamic s) {
    final daysLeft = s.nextRenewal.difference(DateTime.now()).inDays;
    final isUrgent = daysLeft <= 3;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentHistoryScreen(
            serviceName: s.serviceName,
            serviceIcon: s.serviceIcon,
            plan: s.plan,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF1E2730),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: Text(s.serviceIcon, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.serviceName, style: const TextStyle(
                      color: _textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 3),
                  Text(DateFormat('MMM d').format(s.nextRenewal),
                      style: const TextStyle(color: _textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('\$${s.amount.toStringAsFixed(2)}', style: const TextStyle(
                    color: _textPrimary, fontWeight: FontWeight.w800, fontSize: 14)),
                const SizedBox(height: 3),
                Text(
                  isUrgent ? '$daysLeft days left' : 'in $daysLeft days',
                  style: TextStyle(
                      color: isUrgent ? _orange : _textSecondary,
                      fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _homeTab() {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, subState) {
        final subs       = subState is SubscriptionData ? subState.subscriptions : [];
        final totalSpend = subs.fold(0.0, (sum, s) => sum + s.amount);
        final dueSoon    = subs.where((s) => s.nextRenewal.difference(DateTime.now()).inDays <= 7).length;
        final upcoming   = [...subs]..sort((a, b) => a.nextRenewal.compareTo(b.nextRenewal));

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset('assets/images/owl_cyan.png', width: 32,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.nightlight_round, color: _cyan, size: 32)),
                  const SizedBox(width: 10),
                  Image.asset('assets/images/scops_white.png', width: 90, fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Text('scops',
                          style: TextStyle(color: _cyan, fontSize: 22, fontWeight: FontWeight.w900))),
                  const Spacer(),
                  _iconBtn(Icons.notifications_none_rounded,
                      onTap: _openNotifications, badge: _unreadNotifCount),
                  const SizedBox(width: 10),
                  _iconBtn(Icons.bar_chart_rounded, onTap: _openAnalytics),
                ],
              ),
              const SizedBox(height: 28),
              const Text('Dashboard',
                  style: TextStyle(color: _textPrimary, fontSize: 32, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              const Text('Monthly spending and subscription overview',
                  style: TextStyle(color: _textSecondary, fontSize: 13)),
              const SizedBox(height: 24),
              Row(
                children: [
                  _summaryCard(value: '\$${totalSpend.toStringAsFixed(2)}', label: 'This Month',
                      icon: Icons.payments_rounded, iconColor: _cyan, glowColor: _cyan, spotLeft: true),
                  const SizedBox(width: 14),
                  _summaryCard(value: '$dueSoon', label: 'Due Soon',
                      icon: Icons.calendar_month_rounded, iconColor: _orange, glowColor: _orange),
                ],
              ),
              const SizedBox(height: 22),
              _activeSubsCard(subs.length),
              const SizedBox(height: 28),
              const Text('Upcoming Renewals',
                  style: TextStyle(color: _textPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              if (upcoming.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 36),
                  decoration: BoxDecoration(
                    color: _cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _cyan.withOpacity(0.35)),
                    boxShadow: [BoxShadow(color: _cyan.withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 10))],
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.calendar_today_rounded, color: _textSecondary, size: 36),
                      SizedBox(height: 12),
                      Text('No subscriptions yet.\nTap + to add one.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: _textSecondary, fontSize: 13, height: 1.6)),
                    ],
                  ),
                )
              else
                ...upcoming.take(6).map(_renewalTile),
            ],
          ),
        );
      },
    );
  }

  Widget _bottomNav() {
    return SizedBox(
      height: 78,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: CustomPaint(
              painter: _BottomNavNotchPainter(),
              child: const SizedBox(height: 68),
            ),
          ),
          Positioned(
            left: 0, bottom: 0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 2 - 44,
              height: 68,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _navItem(Icons.home_outlined, 'Home', 0),
                  _navItem(Icons.grid_view_rounded, 'Services', 1),
                ],
              ),
            ),
          ),
          Positioned(
            right: 0, bottom: 0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 2 - 44,
              height: 68,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _navItem(Icons.account_balance_wallet_outlined, 'Wallet', 3),
                  _navItem(Icons.person_outline_rounded, 'Profile', 4),
                ],
              ),
            ),
          ),
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
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [BoxShadow(
                      color: _orange.withOpacity(0.45), blurRadius: 22, spreadRadius: 1)],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 38),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _isOpeningAdd ? null : () => setState(() => _currentIndex = index),
      child: SizedBox(
        width: 68,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 27, color: isActive ? _cyan : const Color(0xFF9BA4B0)),
            const SizedBox(height: 5),
            Text(label, style: TextStyle(
                color: isActive ? _cyan : const Color(0xFF9BA4B0),
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600)),
          ],
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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          bottom: true,
          child: Column(
            children: [
              Expanded(child: _currentPage()),
              _bottomNav(),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavNotchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fill   = Paint()..color = const Color(0xFF08111C).withOpacity(0.92)..style = PaintingStyle.fill;
    final border = Paint()..color = Colors.white.withOpacity(0.07)..style = PaintingStyle.stroke..strokeWidth = 1;
    final path = Path();
    final centerX = size.width / 2;
    const corner = 24.0;
    path.moveTo(corner, 0);
    path.lineTo(centerX - 58, 0);
    path.cubicTo(centerX - 50, 0, centerX - 48, 20, centerX - 38, 34);
    path.cubicTo(centerX - 28, 52, centerX - 18, 64, centerX, 64);
    path.cubicTo(centerX + 18, 64, centerX + 28, 52, centerX + 38, 34);
    path.cubicTo(centerX + 48, 20, centerX + 50, 0, centerX + 58, 0);
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