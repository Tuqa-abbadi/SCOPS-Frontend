// ── profile_screen.dart — Sprint 3 update ────────────────────────────────
// New in Sprint 3:
//   • Notifications tile → opens NotificationsScreen
//   • "Rate the App" tile → opens FeedbackScreen
//   • Admin panel (long-press on version) → opens AdminDashboardScreen
//
// Drop this file into: lib/screens/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/subscription/subscription_bloc.dart';
import '../../blocs/wallet/wallet_bloc.dart';
import '../notifications/notifications_screen.dart';
import '../feedback/feedback_screen.dart';
import '../analytics/spending_analytics_screen.dart';
import '../admin/admin_dashboard_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _bg     = Color(0xFF020812);
  static const _card   = Color(0xFF07111C);
  static const _cyan   = Color(0xFF18E8F2);
  static const _orange = Color(0xFFFF5A14);
  static const _white  = Colors.white;
  static const _muted  = Color(0xFF9BA4B0);

  Widget _section(String label) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
        child: Text(label.toUpperCase(),
            style: TextStyle(
                color: _muted.withOpacity(0.75),
                fontWeight: FontWeight.w800,
                fontSize: 11,
                letterSpacing: 1.3)),
      );

  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    Color iconColor = _cyan,
    VoidCallback? onTap,
    Widget? trailing,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _card.withOpacity(0.96),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _cyan.withOpacity(0.12)),
          ),
          child: Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(13)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: _white, fontSize: 14, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text(subtitle,
                        style: const TextStyle(color: _muted, fontSize: 11, height: 1.3)),
                  ],
                ),
              ),
              trailing ??
                  Icon(Icons.chevron_right_rounded,
                      color: Colors.white.withOpacity(0.45), size: 22),
            ],
          ),
        ),
      );

  Widget _stat({
    required IconData icon,
    required String value,
    required String label,
    Color color = _cyan,
  }) =>
      Expanded(
        child: Column(
          children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(11)),
              child: Icon(icon, color: color, size: 17),
            ),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    color: _white, fontSize: 15, fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _muted, fontSize: 10, fontWeight: FontWeight.w500)),
          ],
        ),
      );

  Widget _statsCard() => BlocBuilder<SubscriptionBloc, SubscriptionState>(
        builder: (context, subState) {
          final subs  = subState is SubscriptionData ? subState.subscriptions : [];
          final total = subs.fold(0.0, (sum, item) => sum + item.amount);
          return BlocBuilder<WalletBloc, WalletState>(
            builder: (context, walletState) {
              final cardCount = walletState is WalletData ? walletState.cards.length : 0;
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: _card.withOpacity(0.97),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _cyan.withOpacity(0.28)),
                  boxShadow: [BoxShadow(color: _cyan.withOpacity(0.10), blurRadius: 24, spreadRadius: -8)],
                ),
                child: Row(
                  children: [
                    _stat(icon: Icons.subscriptions_rounded, value: '${subs.length}', label: 'Subscriptions'),
                    Container(width: 1, height: 42, color: Colors.white.withOpacity(0.07)),
                    _stat(icon: Icons.payments_rounded, value: '\$${total.toStringAsFixed(0)}',
                        label: 'Monthly Spend', color: _orange),
                    Container(width: 1, height: 42, color: Colors.white.withOpacity(0.07)),
                    _stat(icon: Icons.credit_card_rounded, value: '$cardCount', label: 'Cards'),
                  ],
                ),
              );
            },
          );
        },
      );

  Widget _avatar() => Center(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 96, height: 96,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                        colors: [_cyan, _orange],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    boxShadow: [
                      BoxShadow(color: _cyan.withOpacity(0.20), blurRadius: 26, spreadRadius: -4),
                      BoxShadow(color: _orange.withOpacity(0.18), blurRadius: 26, spreadRadius: -4),
                    ],
                  ),
                  child: Container(
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: _card),
                    child: const Center(
                      child: Text('U',
                          style: TextStyle(color: _white, fontSize: 40, fontWeight: FontWeight.w900)),
                    ),
                  ),
                ),
                Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                      color: _card,
                      shape: BoxShape.circle,
                      border: Border.all(color: _cyan.withOpacity(0.8))),
                  child: const Icon(Icons.edit_rounded, color: _cyan, size: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('User',
                style: TextStyle(color: _white, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: const Text('user@scops.app',
                  style: TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      );

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Log Out',
            style: TextStyle(color: _white, fontWeight: FontWeight.w900)),
        content: const Text('Are you sure you want to log out?',
            style: TextStyle(color: _muted)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: _muted))),
          TextButton(
              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
              child: const Text('Log Out',
                  style: TextStyle(color: _orange, fontWeight: FontWeight.w900))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      child: SingleChildScrollView(
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
                      Text('Profile',
                          style: TextStyle(
                              color: _white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -0.7)),
                      SizedBox(height: 4),
                      Text('Account & settings',
                          style: TextStyle(color: _muted, fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: _cyan.withOpacity(0.18)),
                  ),
                  child: const Icon(Icons.settings_outlined, color: _muted, size: 21),
                ),
              ],
            ),
            const SizedBox(height: 22),
            _avatar(),
            const SizedBox(height: 22),
            _statsCard(),
            const SizedBox(height: 22),

            _section('Account'),
            _tile(icon: Icons.person_outline_rounded,
                title: 'Edit Profile', subtitle: 'Update your name and photo'),
            _tile(icon: Icons.lock_outline_rounded,
                title: 'Change Password', subtitle: 'Update your password'),
            _tile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Manage renewal alerts and preferences',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const NotificationsScreen())),
            ),

            const SizedBox(height: 8),
            _section('Insights'),
            _tile(
              icon: Icons.bar_chart_rounded,
              title: 'Spending Analytics',
              subtitle: 'Charts and trends across your subscriptions',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SpendingAnalyticsScreen())),
            ),
            _tile(
              icon: Icons.star_outline_rounded,
              title: 'Rate the App',
              subtitle: 'Share your feedback to help us improve',
              iconColor: const Color(0xFFFFB020),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const FeedbackScreen())),
            ),

            const SizedBox(height: 8),
            _section('Preferences'),
            _tile(icon: Icons.tune_rounded,
                title: 'Preferences', subtitle: 'Manage your account preferences'),
            _tile(icon: Icons.language_rounded,
                title: 'Currency', subtitle: 'USD — US Dollar'),
            _tile(icon: Icons.privacy_tip_outlined,
                title: 'Privacy & Security', subtitle: 'Data and permissions'),

            const SizedBox(height: 8),
            _section('Support'),
            _tile(icon: Icons.help_outline_rounded,
                title: 'Help Center', subtitle: 'FAQs and support'),

            // Long-press to open Admin — hidden entry point
            GestureDetector(
              onLongPress: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AdminDashboardScreen())),
              child: _tile(
                icon: Icons.info_outline_rounded,
                title: 'About SCOPS',
                subtitle: 'Version 1.0.0 · Long press for admin',
              ),
            ),

            const SizedBox(height: 8),
            _tile(
              icon: Icons.logout_rounded,
              title: 'Log Out',
              subtitle: 'Sign out of your account',
              iconColor: _orange,
              onTap: () => _showLogoutDialog(context),
            ),
          ],
        ),
      ),
    );
  }
}