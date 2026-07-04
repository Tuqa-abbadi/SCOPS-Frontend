import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../blocs/analytics/analytics_model.dart';
import '../../blocs/notification/notification_model.dart';
import '../../blocs/reviews/reviews_bloc.dart';
import '../../blocs/subscription/subscription_bloc.dart';
import '../../blocs/wallet/wallet_bloc.dart';
import '../../services/token_storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/service_logo.dart';
import '../analytics/spending_analytics_screen.dart';
import '../notifications/notifications_screen.dart';
import '../services/services_browser_screen.dart';
import '../wallet/wallet_screen.dart';
import '../profile/profile_screen.dart';
import '../subscription/edit_subscription_screen.dart';
import '../subscription/subscriptions_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    this.initialIndex = 0,
    this.showSubscriptionAddedMessage = false,
    this.showAddCardAfterSignup = false,
  });

  final int initialIndex;
  final bool showSubscriptionAddedMessage;
  final bool showAddCardAfterSignup;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late int _currentIndex;
  String? _subsInitialFilter;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _bg => _isDark ? Color(0xFF0D0F12) : AppColors.lightBackground;
  static const _cyan = Color(0xFF1DD8E8);
  static const _orange = Color(0xFFFF5A14);
  static const _orangeLight = Color(0xFFFF8C42);
  Color get _textPrimary =>
      _isDark ? Color(0xFFFFFFFF) : AppColors.lightTextPrimary;
  Color get _textSecondary =>
      _isDark ? Color(0xFF8A9BA8) : AppColors.lightTextSecondary;
  Color get _cardBg => _isDark ? Color(0xFF141820) : AppColors.lightSurface;
  Color get _secondarySurface =>
      _isDark ? Color(0xFF181E26) : AppColors.lightSecondarySurface;
  Color get _border =>
      _isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.lightBorder;
  Color get _navBg => _isDark ? Color(0xFF07111B) : AppColors.lightNavBar;

  static const _navItems = [
    _NavDestination(Icons.home_rounded, Icons.home_outlined, 'Home', 0),
    _NavDestination(
      Icons.grid_view_rounded,
      Icons.grid_view_outlined,
      'Subscriptions',
      1,
    ),
    _NavDestination(
      Icons.account_balance_wallet_rounded,
      Icons.account_balance_wallet_outlined,
      'Wallet',
      2,
    ),
    _NavDestination(
      Icons.person_rounded,
      Icons.person_outline_rounded,
      'Profile',
      3,
    ),
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

  static String _guessCategory(String name) {
    final n = name.toLowerCase();
    if ([
      'netflix',
      'disney',
      'youtube',
      'hulu',
      'hbo',
      'prime',
      'apple tv',
    ].any((s) => n.contains(s))) {
      return 'Streaming';
    }
    if ([
      'spotify',
      'apple music',
      'tidal',
      'deezer',
      'soundcloud',
    ].any((s) => n.contains(s))) {
      return 'Music';
    }
    if ([
      'notion',
      'slack',
      'zoom',
      'monday',
      'asana',
      'office',
      'microsoft',
    ].any((s) => n.contains(s))) {
      return 'Work';
    }
    if ([
      'icloud',
      'dropbox',
      'google one',
      'onedrive',
      'drive',
    ].any((s) => n.contains(s))) {
      return 'Storage';
    }
    if ([
      'github',
      'gitlab',
      'jetbrains',
      'aws',
      'vercel',
      'digitalocean',
    ].any((s) => n.contains(s))) {
      return 'Developer';
    }
    if (['figma', 'adobe', 'canva', 'sketch'].any((s) => n.contains(s))) {
      return 'Design';
    }
    if ([
      'openai',
      'chatgpt',
      'claude',
      'gemini',
      'midjourney',
    ].any((s) => n.contains(s))) {
      return 'AI';
    }
    if ([
      'xbox',
      'playstation',
      'steam',
      'nintendo',
      'game pass',
    ].any((s) => n.contains(s))) {
      return 'Gaming';
    }
    if ([
      'gym',
      'fitness',
      'strava',
      'peloton',
      'calm',
      'headspace',
    ].any((s) => n.contains(s))) {
      return 'Fitness';
    }
    if ([
      'bank',
      'wallet',
      'trading',
      'finance',
      'quickbooks',
    ].any((s) => n.contains(s))) {
      return 'Finance';
    }
    return 'Other';
  }

  static AnalyticsData _analyticsFromSubscriptions(
    List<SubscriptionModel> subs,
  ) {
    final now = DateTime.now();
    final monthStarts = List.generate(
      6,
      (index) => DateTime(now.year, now.month - (5 - index)),
    );

    final monthly = monthStarts.map((monthStart) {
      final monthEnd = DateTime(
        monthStart.year,
        monthStart.month + 1,
        0,
        23,
        59,
        59,
      );
      final total = subs
          .where((sub) {
            final startDate = sub.startDate;
            return startDate == null || !startDate.isAfter(monthEnd);
          })
          .fold(0.0, (sum, sub) => sum + _monthlyAmount(sub));

      return MonthlySpend(DateFormat('MMM').format(monthStart), total);
    }).toList();

    final categories = _analyticsCategories(subs);
    final totalThisMonth = monthly.isEmpty ? 0.0 : monthly.last.amount;
    final totalLastMonth = monthly.length < 2
        ? 0.0
        : monthly[monthly.length - 2].amount;
    final monthsWithSpend = monthly.where((month) => month.amount > 0).toList();
    final avgMonthly = monthsWithSpend.isEmpty
        ? 0.0
        : monthsWithSpend.fold(0.0, (sum, month) => sum + month.amount) /
              monthsWithSpend.length;

    return AnalyticsData(
      monthly: monthly,
      byCategory: categories,
      totalThisMonth: totalThisMonth,
      totalLastMonth: totalLastMonth,
      avgMonthly: avgMonthly,
    );
  }

  static List<CategorySpend> _analyticsCategories(
    List<SubscriptionModel> subs,
  ) {
    final totals = <String, double>{};
    for (final sub in subs) {
      final category = _guessCategory(sub.serviceName);
      totals[category] = (totals[category] ?? 0) + _monthlyAmount(sub);
    }

    final items =
        totals.entries
            .map(
              (entry) => CategorySpend(
                entry.key,
                entry.value,
                _colorHex(_catColors[entry.key] ?? _catColors['Other']!),
              ),
            )
            .toList()
          ..sort((a, b) => b.amount.compareTo(a.amount));
    return items;
  }

  static double _monthlyAmount(SubscriptionModel sub) {
    final cycle = sub.billingCycle.toLowerCase();
    if (cycle.contains('year')) return sub.amount / 12;
    if (cycle.contains('week')) return sub.amount * 52 / 12;
    if (cycle.contains('day')) return sub.amount * 365 / 12;
    return sub.amount;
  }

  static String _colorHex(Color color) =>
      '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, _navItems.length - 1).toInt();

    _loadInitialAuthenticatedData();

    if (widget.showSubscriptionAddedMessage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Subscription added successfully!'),
            backgroundColor: _cyan,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      });
    }

    if (widget.showAddCardAfterSignup) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showAddCardAfterSignup();
      });
    }
  }

  Future<void> _loadInitialAuthenticatedData() async {
    final hasAccessToken = await TokenStorageService().hasAccessToken();
    if (!mounted || !hasAccessToken) return;

    final walletBloc = context.read<WalletBloc>();
    if (walletBloc.state is WalletInitial) {
      walletBloc.add(WalletLoaded());
    }

    final subscriptionBloc = context.read<SubscriptionBloc>();
    if (subscriptionBloc.state is SubscriptionInitial) {
      subscriptionBloc.add(SubscriptionLoaded());
    }
  }

  @override
  void dispose() {
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
            BlocProvider.value(value: context.read<ReviewsBloc>()),
          ],
          child: EditSubscriptionScreen(subscription: sub),
        ),
      ),
    );
  }

  void _selectNavIndex(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
      if (index == 1) _subsInitialFilter = null; // direct tap = no pre-filter
    });
  }

  void _goToSubscriptions([String? filter]) {
    setState(() {
      _subsInitialFilter = filter;
      _currentIndex = 1;
    });
  }

  void _openServicesPage() {
    setState(() {
      _currentIndex = 4;
    });
  }

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }

  // ── Widgets ───────────────────────────────────────────────────────────────
  void _showAddCardAfterSignup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<WalletBloc>(),
        child: AddCardSheet(
          title: 'Add your first card',
          subtitle:
              'Save a card now so future subscription payments are ready.',
          successMessage: 'Card saved successfully.',
          showSkip: true,
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, {VoidCallback? onTap, int badgeCount = 0}) {
    final badgeText = badgeCount > 9 ? '9+' : '$badgeCount';

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _secondarySurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
            ),
            child: Icon(icon, color: _textPrimary, size: 22),
          ),
          if (badgeCount > 0)
            Positioned(
              top: -5,
              right: -5,
              child: Container(
                constraints: BoxConstraints(minWidth: 20, minHeight: 20),
                padding: EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: _orange,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: _bg, width: 2),
                ),
                child: Center(
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
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
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: _isDark
                    ? Color(0xFF080C10)
                    : AppColors.lightSecondarySurface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: glowColor.withValues(alpha: 0.28),
                  width: 1.2,
                ),
              ),
            ),
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(1.0, -1.0),
                      radius: 1.4,
                      colors: [
                        glowColor.withValues(alpha: 0.30),
                        glowColor.withValues(alpha: 0.10),
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.35, 0.75],
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.fromLTRB(18, 16, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: glowColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(icon, color: iconColor, size: 20),
                    ),
                    Spacer(),
                    Text(
                      value,
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      label,
                      style: TextStyle(
                        color: _textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _activeSubsCard(int count, {VoidCallback? onTap}) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [_cyan, _orangeLight, _orange],
          stops: [0.0, 0.55, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _cyan.withValues(alpha: 0.20),
            blurRadius: 25,
            offset: Offset(-5, 8),
          ),
          BoxShadow(
            color: _orange.withValues(alpha: 0.22),
            blurRadius: 25,
            offset: Offset(5, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Subscriptions',
                  style: TextStyle(
                    color: Color(0xFF0D1A1C),
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '$count',
                  style: TextStyle(
                    color: Color(0xFF0D1A1C),
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Tap to view all active subscriptions',
                  style: TextStyle(
                    color: Color(0xFF0D1A1C),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.subscriptions_rounded,
              color: Color(0xFF0D1A1C),
              size: 28,
            ),
          ),
        ],
      ),
    ),
  );

  // ── Donut chart ────────────────────────────────────────────────────────────
  // ── Renewal tile ───────────────────────────────────────────────────────────
  Widget _subscriptionLogo(SubscriptionModel sub) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: ServiceLogo(
        serviceName: sub.serviceName,
        logoUrl: sub.serviceLogoUrl,
        fallbackIcon: sub.serviceIcon,
        fallbackFontSize: 22,
        padding: const EdgeInsets.all(5),
      ),
    );
  }

  Widget _renewalTile(SubscriptionModel s) {
    final daysLeft = s.nextRenewal.difference(DateTime.now()).inDays;
    final isUrgent = daysLeft <= 3 && s.isActive;
    final isCancelled = s.isCancelled;
    final isPaused = s.isPaused;
    final isInactive = isCancelled || isPaused;

    final badgeColor = isCancelled ? _orange : const Color(0xFFF59E0B);

    return GestureDetector(
      onTap: () => _openSubDetail(s),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isInactive
                ? badgeColor.withValues(alpha: 0.18)
                : (_isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : AppColors.lightBorder),
          ),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isInactive
                        ? badgeColor.withValues(alpha: 0.08)
                        : (_isDark
                              ? Color(0xFF1E2730)
                              : AppColors.lightSecondarySurface),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _subscriptionLogo(s),
                ),
                if (isInactive)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: badgeColor,
                      ),
                      child: Icon(
                        isCancelled ? Icons.close : Icons.pause,
                        color: Colors.white,
                        size: 9,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          s.serviceName,
                          style: TextStyle(
                            color: isInactive ? _textSecondary : _textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            decoration: isCancelled
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                      if (isInactive) ...[
                        SizedBox(width: 6),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isCancelled ? 'Cancelled' : 'Paused',
                            style: TextStyle(
                              color: badgeColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 3),
                  Text(
                    isInactive
                        ? s.plan
                        : DateFormat('MMM d').format(s.nextRenewal),
                    style: TextStyle(color: _textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${s.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: isInactive ? _textSecondary : _textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 3),
                if (s.isActive)
                  Text(
                    isUrgent ? '$daysLeft days left' : 'in $daysLeft days',
                    style: TextStyle(
                      color: isUrgent ? _orange : _textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                SizedBox(height: 2),
                Icon(
                  Icons.chevron_right_rounded,
                  color: _textSecondary,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Home tab ───────────────────────────────────────────────────────────────
  Widget _homeTab() {
    return BlocConsumer<SubscriptionBloc, SubscriptionState>(
      listener: (context, subState) {
        if (subState is SubscriptionData && subState.actionError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(subState.actionError!),
              backgroundColor: _orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      builder: (context, subState) {
        // Full-page loading
        if (subState is SubscriptionsLoading) {
          return Center(child: CircularProgressIndicator(color: _cyan));
        }

        // Full-page error with retry
        if (subState is SubscriptionError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wifi_off_rounded, color: _textSecondary, size: 48),
                SizedBox(height: 16),
                Text(
                  subState.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _textSecondary, fontSize: 14),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () => context.read<SubscriptionBloc>().add(
                    const SubscriptionsRefreshRequested(),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: _cyan.withValues(alpha: 0.65)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh_rounded, color: _cyan, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Retry',
                          style: TextStyle(
                            color: _cyan,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final allSubs = subState is SubscriptionData
            ? subState.subscriptions
            : <SubscriptionModel>[];
        final activeSubs = allSubs.where((s) => s.isActive).toList();
        final totalSpend = activeSubs.fold(0.0, (sum, s) => sum + s.amount);
        final dueSoon = activeSubs
            .where((s) => s.nextRenewal.difference(DateTime.now()).inDays <= 7)
            .length;
        final upcoming = [...allSubs]
          ..sort((a, b) => a.nextRenewal.compareTo(b.nextRenewal));
        final analytics = _analyticsFromSubscriptions(activeSubs);
        final unreadNotifications = mockNotifications()
            .where((n) => n.status == NotificationStatus.unread)
            .length;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/images/owl_cyan.png',
                    width: 32,
                    errorBuilder: (_, __, ___) =>
                        Icon(Icons.nightlight_round, color: _cyan, size: 32),
                  ),
                  SizedBox(width: 10),
                  Image.asset(
                    Theme.of(context).brightness == Brightness.dark
                        ? 'assets/images/scops_white.png'
                        : 'assets/images/scops_black.png',
                    width: 90,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Text(
                      'scops',
                      style: TextStyle(
                        color: _cyan,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Spacer(),
                  _iconBtn(
                    Icons.notifications_none_rounded,
                    onTap: _openNotifications,
                    badgeCount: unreadNotifications,
                  ),
                  SizedBox(width: 10),
                  _iconBtn(Icons.search_rounded),
                ],
              ),
              SizedBox(height: 28),
              Text(
                'Dashboard',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Monthly spending and subscription overview',
                style: TextStyle(color: _textSecondary, fontSize: 13),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  _summaryCard(
                    value: '\$${totalSpend.toStringAsFixed(2)}',
                    label: 'This Month',
                    icon: Icons.payments_rounded,
                    iconColor: _cyan,
                    glowColor: _cyan,
                  ),
                  SizedBox(width: 14),
                  _summaryCard(
                    value: '$dueSoon',
                    label: 'Due Soon',
                    icon: Icons.calendar_month_rounded,
                    iconColor: _orange,
                    glowColor: _orange,
                    onTap: () => _goToSubscriptions('due_soon'),
                  ),
                ],
              ),
              SizedBox(height: 18),
              _activeSubsCard(
                activeSubs.length,
                onTap: () => _goToSubscriptions('active'),
              ),
              SizedBox(height: 18),
              SpendingAnalyticsView(data: analytics),
              SizedBox(height: 28),
              Text(
                'Upcoming Renewals',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Tap to view, edit or cancel',
                style: TextStyle(color: _textSecondary, fontSize: 12),
              ),
              SizedBox(height: 14),
              if (upcoming.isEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 36),
                  decoration: BoxDecoration(
                    color: _cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _cyan.withValues(alpha: 0.35)),
                    boxShadow: [
                      BoxShadow(
                        color: _cyan.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        color: _textSecondary,
                        size: 36,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No subscriptions yet.\nTap + to add one.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _textSecondary,
                          fontSize: 13,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...upcoming.map(_renewalTile),
            ],
          ),
        );
      },
    );
  }

  // ── Bottom nav ─────────────────────────────────────────────────────────────
  Widget _bottomNav() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(8, 4, 8, 8),
        child: SizedBox(
          height: 96,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 76,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: _navBg.withValues(alpha: 0.98),
                    border: Border.all(
                      color: _isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : AppColors.lightBorder,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: _isDark ? 0.42 : 0.10,
                        ),
                        blurRadius: 22,
                        offset: Offset(0, 12),
                      ),
                      BoxShadow(
                        color: _cyan.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 2,
                height: 72,
                child: Row(
                  children: [
                    Expanded(child: _navItem(_navItems[0])),
                    Expanded(child: _navItem(_navItems[1])),
                    SizedBox(width: 74),
                    Expanded(child: _navItem(_navItems[2])),
                    Expanded(child: _navItem(_navItems[3])),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _openServicesPage,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [_orangeLight, _orange],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.10),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _orange.withValues(alpha: 0.42),
                          blurRadius: 22,
                          spreadRadius: 1,
                          offset: Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.45),
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ),
            ],
          ),
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
          padding: EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: Duration(milliseconds: 180),
                child: Icon(
                  isActive ? item.activeIcon : item.icon,
                  key: ValueKey('${item.label}-$isActive'),
                  size: 22,
                  color: isActive ? _cyan : _textSecondary,
                ),
              ),
              SizedBox(height: 6),
              AnimatedDefaultTextStyle(
                duration: Duration(milliseconds: 180),
                style: TextStyle(
                  color: isActive ? _cyan : _textPrimary,
                  fontSize: 9.5,
                  height: 1.0,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(item.label, maxLines: 1),
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
      case 1:
        return SubscriptionsScreen(initialFilter: _subsInitialFilter);
      case 2:
        return WalletScreen();
      case 3:
        return ProfileScreen();
      case 4:
        return ServicesBrowserScreen();
      default:
        return _homeTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isDark
                ? [Color(0xFF05070A), Color(0xFF0D0F12), Color(0xFF081018)]
                : [
                    AppColors.lightBackground,
                    AppColors.lightBackground,
                    AppColors.lightSecondarySurface,
                  ],
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

class _NavDestination {
  const _NavDestination(this.activeIcon, this.icon, this.label, this.index);

  final IconData activeIcon;
  final IconData icon;
  final String label;
  final int index;
}

// ── Donut chart painter ───────────────────────────────────────────────────
