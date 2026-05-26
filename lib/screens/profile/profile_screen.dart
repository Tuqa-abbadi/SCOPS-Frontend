import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/admin/admin_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/profile/change_password_bloc.dart';
import '../../blocs/reviews/reviews_bloc.dart';
import '../../blocs/subscription/subscription_bloc.dart';
import '../../blocs/user/user_cubit.dart';
import '../../blocs/wallet/wallet_bloc.dart';
import '../../models/user_model.dart';
import '../auth/auth_choice_screen.dart';
import '../reviews/write_review_sheet.dart';
import 'change_password_screen.dart';
import '../notifications/notifications_screen.dart';
import '../feedback/feedback_screen.dart';
import '../analytics/spending_analytics_screen.dart';
import '../admin/admin_dashboard_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _bg     = Color(0xFF020812);
  static const _card   = Color(0xFF07111C);
  static const _cyan   = Color(0xFF18E8F2);
  static const _orange = Color(0xFFFF5A14);
  static const _gold   = Color(0xFFFFB020);
  static const _white  = Colors.white;
  static const _muted  = Color(0xFF9BA4B0);

  @override
  void initState() {
    super.initState();
    // Trigger pending reviews check once subscriptions are available.
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkPending());
  }

  void _checkPending() {
    if (!mounted) return;
    final subState = context.read<SubscriptionBloc>().state;
    if (subState is SubscriptionData) {
      context.read<ReviewsBloc>().add(PendingReviewsRequested(subState.subscriptions));
    }
  }

  // ── Reusable widgets ──────────────────────────────────────────────────────

  Widget _section(String label) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
        child: Text(label.toUpperCase(),
            style: TextStyle(
                color: _muted.withValues(alpha: 0.75),
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
            color: _card.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _cyan.withValues(alpha: 0.12)),
          ),
          child: Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
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
                      color: Colors.white.withValues(alpha: 0.45), size: 22),
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
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11)),
              child: Icon(icon, color: color, size: 17),
            ),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    color: _white, fontSize: 15, fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: _muted, fontSize: 10, fontWeight: FontWeight.w500)),
          ],
        ),
      );

  // ── Stats card ────────────────────────────────────────────────────────────

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
                  color: _card.withValues(alpha: 0.97),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _cyan.withValues(alpha: 0.28)),
                  boxShadow: [BoxShadow(color: _cyan.withValues(alpha: 0.10), blurRadius: 24, spreadRadius: -8)],
                ),
                child: Row(
                  children: [
                    _stat(icon: Icons.subscriptions_rounded,
                        value: '${subs.length}', label: 'Subscriptions'),
                    Container(width: 1, height: 42, color: Colors.white.withValues(alpha: 0.07)),
                    _stat(icon: Icons.payments_rounded,
                        value: '\$${total.toStringAsFixed(0)}',
                        label: 'Monthly Spend', color: _orange),
                    Container(width: 1, height: 42, color: Colors.white.withValues(alpha: 0.07)),
                    _stat(icon: Icons.credit_card_rounded,
                        value: '$cardCount', label: 'Cards'),
                  ],
                ),
              );
            },
          );
        },
      );

  // ── Avatar ────────────────────────────────────────────────────────────────

  Widget _avatar(UserModel? user) => Center(
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
                      BoxShadow(color: _cyan.withValues(alpha: 0.20), blurRadius: 26, spreadRadius: -4),
                      BoxShadow(color: _orange.withValues(alpha: 0.18), blurRadius: 26, spreadRadius: -4),
                    ],
                  ),
                  child: Container(
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: _card),
                    child: Center(
                      child: Text(
                          user?.firstName.isNotEmpty == true
                              ? user!.firstName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                              color: _white, fontSize: 40, fontWeight: FontWeight.w900)),
                    ),
                  ),
                ),
                Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                      color: _card,
                      shape: BoxShape.circle,
                      border: Border.all(color: _cyan.withValues(alpha: 0.8))),
                  child: const Icon(Icons.edit_rounded, color: _cyan, size: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
                user?.fullName.isNotEmpty == true ? user!.fullName : 'User',
                style: const TextStyle(
                    color: _white, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Text(
                  user?.email.isNotEmpty == true ? user!.email : '',
                  style: const TextStyle(
                      color: _muted, fontSize: 11, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      );

  // ── Reviews section ───────────────────────────────────────────────────────

  /// Computes eligible-but-unreviewed subscriptions from current bloc state.
  List<SubscriptionModel> _pendingSubs(
    SubscriptionData subData,
    ReviewsData reviewData,
  ) {
    return subData.subscriptions.where((sub) {
      if (!sub.isActive) return false;
      final startDate = sub.startDate;
      if (startDate == null) return false;
      final days = DateTime.now().difference(startDate).inDays;
      final hasRenewed = sub.nextRenewal.isBefore(DateTime.now());
      if (days < 7 && !hasRenewed) return false;
      return !reviewData.hasReviewForSubscription(sub.apiId);
    }).toList();
  }

  Widget _reviewsSection() {
    return BlocBuilder<ReviewsBloc, ReviewsState>(
      builder: (context, reviewState) {
        return BlocBuilder<SubscriptionBloc, SubscriptionState>(
          builder: (context, subState) {
            final reviewData = reviewState is ReviewsData ? reviewState : null;
            final subData =
                subState is SubscriptionData ? subState : null;

            if (reviewData == null) return const SizedBox.shrink();

            final myReviewCount = reviewData.myReviews.length;
            final pendingSubs = subData != null
                ? _pendingSubs(subData, reviewData)
                : <SubscriptionModel>[];

            if (myReviewCount == 0 && pendingSubs.isEmpty) {
              return const SizedBox.shrink();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _section('Reviews'),

                // ── My Reviews tile ──────────────────────────────────────
                if (myReviewCount > 0)
                  _tile(
                    icon: Icons.rate_review_rounded,
                    title: 'My Reviews',
                    subtitle:
                        '$myReviewCount review${myReviewCount == 1 ? '' : 's'} written',
                    iconColor: _gold,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _gold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$myReviewCount',
                        style: const TextStyle(
                            color: _gold, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),

                // ── Pending Reviews ──────────────────────────────────────
                if (pendingSubs.isNotEmpty) ...[
                  _section('Pending Reviews'),
                  if (reviewData.pendingLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                              color: _cyan, strokeWidth: 2.5),
                        ),
                      ),
                    )
                  else
                    ...pendingSubs.map(
                        (sub) => _pendingReviewCard(context, sub)),
                ],

                const SizedBox(height: 8),
              ],
            );
          },
        );
      },
    );
  }

  Widget _pendingReviewCard(BuildContext context, SubscriptionModel sub) {
    return GestureDetector(
      onTap: () => _showWriteReviewSheet(context, sub),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _card.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _gold.withValues(alpha: 0.30)),
          boxShadow: [
            BoxShadow(
                color: _gold.withValues(alpha: 0.07),
                blurRadius: 20,
                spreadRadius: -6),
          ],
        ),
        child: Row(
          children: [
            // Service icon badge
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: _gold.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(sub.serviceIcon,
                    style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sub.serviceName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: _white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  const Text('Share your experience',
                      style: TextStyle(color: _muted, fontSize: 11)),
                ],
              ),
            ),
            // Review button badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: _gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _gold.withValues(alpha: 0.40)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_outline_rounded, color: _gold, size: 15),
                  SizedBox(width: 5),
                  Text('Review',
                      style: TextStyle(
                          color: _gold,
                          fontSize: 12,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWriteReviewSheet(BuildContext context, SubscriptionModel sub) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<ReviewsBloc>(),
        child: WriteReviewSheet(
          subscription: sub,
          serviceId: sub.serviceId,
        ),
      ),
    );
  }

  // ── Logout dialog ─────────────────────────────────────────────────────────

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
              onPressed: () {
                Navigator.pop(context);
                context.read<LogoutBloc>().add(const LogoutRequested());
              },
              child: const Text('Log Out',
                  style: TextStyle(color: _orange, fontWeight: FontWeight.w900))),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<LogoutBloc, AuthState>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
          context.read<UserCubit>().clearUser();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AuthChoiceScreen()),
            (route) => false,
          );
        }
      },
      child: BlocListener<SubscriptionBloc, SubscriptionState>(
        // Re-check pending reviews whenever subscriptions reload.
        listenWhen: (prev, curr) =>
            curr is SubscriptionData && prev is! SubscriptionData,
        listener: (context, state) {
          if (state is SubscriptionData) {
            context
                .read<ReviewsBloc>()
                .add(PendingReviewsRequested(state.subscriptions));
          }
        },
        child: Container(
          color: _bg,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Profile',
                              style: TextStyle(
                                  color: _white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.7)),
                          SizedBox(height: 4),
                          Text('Account & settings',
                              style: TextStyle(
                                  color: _muted,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: _cyan.withValues(alpha: 0.18)),
                      ),
                      child: const Icon(Icons.settings_outlined,
                          color: _muted, size: 21),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                BlocBuilder<UserCubit, UserModel?>(
                  builder: (context, user) => _avatar(user),
                ),
                const SizedBox(height: 22),

                _statsCard(),
                const SizedBox(height: 22),

                // ── Account ────────────────────────────────────────────────
                _section('Account'),
                _tile(
                    icon: Icons.person_outline_rounded,
                    title: 'Edit Profile',
                    subtitle: 'Update your name and photo'),
                _tile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Change Password',
                  subtitle: 'Update your password',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<ChangePasswordBloc>(),
                        child: const ChangePasswordScreen(),
                      ),
                    ),
                  ),
                ),
                _tile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Manage renewal alerts and preferences',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const NotificationsScreen())),
                ),

                const SizedBox(height: 8),

                // ── Reviews (My Reviews + Pending Reviews) ─────────────────
                _reviewsSection(),

                // ── Insights ───────────────────────────────────────────────
                _section('Insights'),
                _tile(
                  icon: Icons.bar_chart_rounded,
                  title: 'Spending Analytics',
                  subtitle: 'Charts and trends across your subscriptions',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const SpendingAnalyticsScreen())),
                ),
                _tile(
                  icon: Icons.star_outline_rounded,
                  title: 'Rate the App',
                  subtitle: 'Share your feedback to help us improve',
                  iconColor: _gold,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const FeedbackScreen())),
                ),

                const SizedBox(height: 8),

                // ── Preferences ────────────────────────────────────────────
                _section('Preferences'),
                _tile(
                    icon: Icons.tune_rounded,
                    title: 'Preferences',
                    subtitle: 'Manage your account preferences'),
                _tile(
                    icon: Icons.language_rounded,
                    title: 'Currency',
                    subtitle: 'USD — US Dollar'),
                _tile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy & Security',
                    subtitle: 'Data and permissions'),

                const SizedBox(height: 8),

                // ── Support ────────────────────────────────────────────────
                _section('Support'),
                _tile(
                    icon: Icons.help_outline_rounded,
                    title: 'Help Center',
                    subtitle: 'FAQs and support'),

                _tile(
                  icon: Icons.info_outline_rounded,
                  title: 'About SCOPS',
                  subtitle: 'Version 1.0.0',
                ),

                // Admin Panel — visible only when the logged-in user is admin
                BlocBuilder<UserCubit, UserModel?>(
                  builder: (context, user) {
                    if (user == null || !user.isAdmin) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        _section('Admin'),
                        _tile(
                          icon: Icons.shield_rounded,
                          iconColor: _orange,
                          title: 'Admin Panel',
                          subtitle: 'Manage users, services and statistics',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<AdminBloc>(),
                                child: const AdminDashboardScreen(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
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
        ),
      ),
    );
  }
}
