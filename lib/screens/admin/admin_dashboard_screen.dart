import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../blocs/admin/admin_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/user/user_cubit.dart';
import '../splash/splash_screen.dart';

// ── Palette ───────────────────────────────────────────────────────────────────
const _bg = Color(0xFF020812);
const _card = Color(0xFF07111C);
const _field = Color(0xFF0B1521);
const _cyan = Color(0xFF18E8F2);
const _orange = Color(0xFFFF5A14);
const _orangeLight = Color(0xFFFF8C42);
const _green = Color(0xFF22C55E);
const _red = Color(0xFFFF4D4D);
const _purple = Color(0xFFA855F7);
const _white = Colors.white;
const _muted = Color(0xFF9BA4B0);

final _fmt = NumberFormat.currency(symbol: r'$', decimalDigits: 0);

// ── Nav destinations ──────────────────────────────────────────────────────────

class _NavDest {
  const _NavDest(this.activeIcon, this.icon, this.label, this.index);
  final IconData activeIcon;
  final IconData icon;
  final String label;
  final int index;
}

const _navItems = [
  _NavDest(Icons.dashboard_rounded, Icons.dashboard_outlined, 'Dashboard', 0),
  _NavDest(Icons.people_rounded, Icons.people_outline_rounded, 'Users', 1),
  _NavDest(Icons.apps_rounded, Icons.apps_outlined, 'Services', 2),
  _NavDest(Icons.person_rounded, Icons.person_outline_rounded, 'Profile', 3),
];

// ─────────────────────────────────────────────────────────────────────────────

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

enum _UserFilter { all, active, inactive }

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with TickerProviderStateMixin {
  // ── Page state ─────────────────────────────────────────────────────────────
  int _currentIndex = 0;
  int _navFromIndex = 0;
  int _navToIndex = 0;

  // ── Nav animation (mirrors DashboardScreen) ────────────────────────────────
  late final AnimationController _navCtrl;
  late final Animation<double> _navAnim;

  // ── Users tab state ────────────────────────────────────────────────────────
  final _searchCtrl = TextEditingController();
  _UserFilter _filter = _UserFilter.all;

  @override
  void initState() {
    super.initState();
    _navCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 680),
    );
    _navAnim = CurvedAnimation(parent: _navCtrl, curve: Curves.easeInOutCubic);
    _navCtrl.value = 1;

    _searchCtrl.addListener(() => setState(() {}));

    final bloc = context.read<AdminBloc>();
    if (bloc.state is AdminInitial) bloc.add(const AdminLoaded());
  }

  @override
  void dispose() {
    _navCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
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

  // ── Filtered users ─────────────────────────────────────────────────────────

  List<AdminUserModel> _filteredUsers(List<AdminUserModel> all) {
    final q = _searchCtrl.text.trim().toLowerCase();
    return all.where((u) {
      final matchSearch =
          q.isEmpty ||
          u.fullName.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q) ||
          u.role.toLowerCase().contains(q);
      final matchFilter = switch (_filter) {
        _UserFilter.all => true,
        _UserFilter.active => u.isActive,
        _UserFilter.inactive => !u.isActive,
      };
      return matchSearch && matchFilter;
    }).toList();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final user = context.read<UserCubit>().state;
    if (user != null && !user.isAdmin) {
      return _AccessDeniedScreen(onBack: () => Navigator.pop(context));
    }

    return BlocListener<LogoutBloc, AuthState>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const SplashScreen()),
            (_) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          bottom: true,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildBody()),
              _bottomNav(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() => Container(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
    decoration: BoxDecoration(
      color: _bg,
      border: Border(
        bottom: BorderSide(color: _cyan.withValues(alpha: 0.10)),
      ),
      boxShadow: [
        BoxShadow(
          color: _cyan.withValues(alpha: 0.04),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        Image.asset(
          'assets/images/scops_admin.png',
          width: 30,
          height: 30,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 10),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'SCOPS',
                style: TextStyle(
                  color: _white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
              TextSpan(
                text: ' | ',
                style: TextStyle(
                  color: _muted,
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0,
                ),
              ),
              TextSpan(
                text: 'ADMIN',
                style: TextStyle(
                  color: _orange,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        if (_currentIndex != 3)
          BlocBuilder<AdminBloc, AdminState>(
            builder: (_, state) => IconButton(
              tooltip: 'Refresh',
              onPressed: state is AdminLoading
                  ? null
                  : () => context.read<AdminBloc>().add(
                      const AdminRefreshRequested(),
                    ),
              icon: Icon(
                Icons.refresh_rounded,
                color: state is AdminLoading
                    ? _muted.withValues(alpha: 0.35)
                    : _muted,
              ),
            ),
          ),
      ],
    ),
  );

  // ── Body ───────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    if (_currentIndex == 3) return _profilePage();

    return BlocConsumer<AdminBloc, AdminState>(
      listener: _handleState,
      builder: (context, state) {
        if (state is AdminLoading) {
          return const Center(child: CircularProgressIndicator(color: _orange));
        }
        if (state is AdminError) {
          return _ErrorView(
            message: state.message,
            onRetry: () =>
                context.read<AdminBloc>().add(const AdminRefreshRequested()),
          );
        }
        if (state is AdminData) {
          return Stack(
            children: [
              IndexedStack(
                index: _currentIndex,
                children: [
                  _overviewTab(state),
                  _usersTab(state),
                  _servicesTab(state),
                ],
              ),
              if (state.isActionLoading) const _ActionLoadingOverlay(),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _handleState(BuildContext context, AdminState state) {
    if (state is! AdminData) return;
    if (state.actionError != null) {
      _showSnack(state.actionError!, isError: true);
      context.read<AdminBloc>().add(const AdminActionErrorCleared());
    }
    if (state.actionSuccess != null) {
      _showSnack(state.actionSuccess!);
      context.read<AdminBloc>().add(const AdminActionErrorCleared());
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? _red : _green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  // ── SCOPS-style bottom nav ─────────────────────────────────────────────────

  Widget _bottomNav() {
    final activeSlot = _navItems.indexWhere(
      (item) => item.index == _currentIndex,
    );
    final safeSlot = activeSlot < 0 ? 0 : activeSlot;
    final activeItem = _navItems[safeSlot];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
        child: SizedBox(
          height: 86,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final slotWidth = width / _navItems.length;

              double centerForIndex(int index) {
                final slot = _navItems.indexWhere(
                  (item) => item.index == index,
                );
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

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Floating pill container
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 4,
                        height: 72,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: const Color(
                              0xFF08111C,
                            ).withValues(alpha: 0.96),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.07),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.38),
                                blurRadius: 28,
                                offset: const Offset(0, 14),
                              ),
                              BoxShadow(
                                color: _orange.withValues(alpha: 0.07),
                                blurRadius: 18,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Nav items row
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
                      // Animated floating circle indicator
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
                                  color: const Color(
                                    0xFF08111C,
                                  ).withValues(alpha: 0.90),
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
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _navItem(_NavDest item) {
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
                    child: Icon(item.icon, size: 23, color: _muted),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: TextStyle(
                  color: isActive ? _orangeLight : _muted,
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

  // ── Profile page ───────────────────────────────────────────────────────────

  Widget _profilePage() {
    final user = context.watch<UserCubit>().state;
    final adminState = context.watch<AdminBloc>().state;
    final stats = adminState is AdminData ? adminState.statistics : null;
    final initials = user != null && user.firstName.isNotEmpty
        ? (user.firstName[0] +
                  (user.lastName.isNotEmpty ? user.lastName[0] : ''))
              .toUpperCase()
        : 'A';
    final fullName = user != null
        ? '${user.firstName} ${user.lastName}'.trim()
        : 'Administrator';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _orange.withValues(alpha: 0.12),
              border: Border.all(
                color: _orange.withValues(alpha: 0.45),
                width: 2.5,
              ),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: _orange,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            fullName,
            style: const TextStyle(
              color: _white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          if (user != null)
            Text(
              user.email,
              style: const TextStyle(color: _muted, fontSize: 13),
            ),
          const SizedBox(height: 12),
          // Role badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: _orange.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: _orange.withValues(alpha: 0.30)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield_rounded, color: _orange, size: 14),
                SizedBox(width: 6),
                Text(
                  'SCOPS Administrator',
                  style: TextStyle(
                    color: _orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Stats row
          if (stats != null) ...[
            Row(
              children: [
                Expanded(
                  child: _ProfileStatCard(
                    value: '${stats.totalUsers}',
                    label: 'Total Users',
                    icon: Icons.people_rounded,
                    color: _cyan,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ProfileStatCard(
                    value: '${stats.totalServices}',
                    label: 'Services',
                    icon: Icons.apps_rounded,
                    color: _purple,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ProfileStatCard(
                    value: '${stats.activeSubscriptions}',
                    label: 'Active Subs',
                    icon: Icons.subscriptions_rounded,
                    color: _green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
          ],

          Divider(color: _white.withValues(alpha: 0.07)),
          const SizedBox(height: 24),

          _ProfileAction(
            icon: Icons.exit_to_app_rounded,
            label: 'Exit Admin Panel',
            subtitle: 'Return to the SCOPS app',
            color: _cyan,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 12),
          _ProfileAction(
            icon: Icons.logout_rounded,
            label: 'Sign Out',
            subtitle: 'Log out of your account',
            color: _red,
            onTap: () => _confirmAction(
              context,
              title: 'Sign out?',
              body: 'You will be logged out of SCOPS.',
              confirmLabel: 'Sign Out',
              confirmColor: _red,
              onConfirm: () =>
                  context.read<LogoutBloc>().add(const LogoutRequested()),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'SCOPS Control Panel',
            style: TextStyle(
              color: _muted.withValues(alpha: 0.45),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  // ── Overview tab ───────────────────────────────────────────────────────────

  Widget _overviewTab(AdminData data) {
    final stats = data.statistics;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (stats?.monthlyRevenue != null) _heroCard(stats!.monthlyRevenue!),
          if (stats?.monthlyRevenue != null) const SizedBox(height: 18),

          const _SectionTitle('Platform Statistics'),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.22,
            children: [
              _MetricCard(
                value: stats != null ? '${stats.totalUsers}' : '—',
                label: 'Total Users',
                icon: Icons.people_rounded,
                color: _cyan,
                sub: stats != null ? '${stats.activeUsers} active' : '',
              ),
              _MetricCard(
                value: stats != null ? '${stats.totalServices}' : '—',
                label: 'Services',
                icon: Icons.apps_rounded,
                color: _orange,
                sub: data.services.length != stats?.totalServices
                    ? '${data.services.length} loaded'
                    : '',
              ),
              _MetricCard(
                value: stats?.monthlyRevenue != null
                    ? _fmt.format(stats!.monthlyRevenue!)
                    : '—',
                label: 'Revenue',
                icon: Icons.account_balance_wallet_rounded,
                color: _green,
                sub: 'This month',
              ),
              _MetricCard(
                value: stats != null
                    ? '${(stats.totalSubscriptions - stats.activeSubscriptions).clamp(0, stats.totalSubscriptions)}'
                    : '—',
                label: 'Cancelled',
                icon: Icons.cancel_rounded,
                color: _red,
                sub: stats?.churnRate != null
                    ? '${stats!.churnRate!.toStringAsFixed(1)}% churn'
                    : '',
              ),
            ],
          ),

          const SizedBox(height: 22),
          const _SectionTitle('Revenue Overview'),
          const SizedBox(height: 12),
          const _RevenueLineChart(),

          const SizedBox(height: 22),
          const _SectionTitle('Subscription Status'),
          const SizedBox(height: 12),
          _StatusDonutChart(stats: stats),

          const SizedBox(height: 22),
          const _SectionTitle('Quick Actions'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _ActionBtn(
                icon: Icons.person_add_alt_1_rounded,
                label: 'Add User',
                color: _orange,
                onTap: () => _showUserForm(context),
              ),
              _ActionBtn(
                icon: Icons.add_business_rounded,
                label: 'Add Service',
                color: _cyan,
                onTap: () => _showServiceForm(context),
              ),
              _ActionBtn(
                icon: Icons.people_rounded,
                label: 'Manage Users',
                color: _purple,
                onTap: () => _selectNavIndex(1),
              ),
              _ActionBtn(
                icon: Icons.apps_rounded,
                label: 'Manage Services',
                color: _green,
                onTap: () => _selectNavIndex(2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroCard(double revenue) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFF070F1A),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: _cyan.withValues(alpha: 0.22), width: 1.0),
      boxShadow: [
        BoxShadow(
          color: _cyan.withValues(alpha: 0.10),
          blurRadius: 36,
          offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.30),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _cyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: _cyan,
                  size: 20,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                _fmt.format(revenue),
                style: const TextStyle(
                  color: _white,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Monthly Revenue',
                style: TextStyle(
                  color: _muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        _trendPill('Live', _cyan),
      ],
    ),
  );

  // ignore: unused_element
  Widget _subscriptionDistribution(AdminStatisticsModel stats) {
    final active = stats.activeSubscriptions;
    final total = stats.totalSubscriptions;
    final inactive = (total - active).clamp(0, total);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _adminDeco(_cyan, radius: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Subscription Status',
                  style: TextStyle(
                    color: _white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _trendPill('$total total', _muted),
            ],
          ),
          const SizedBox(height: 14),
          _distBar('Active', active, total, _green),
          const SizedBox(height: 8),
          _distBar('Inactive / Cancelled', inactive, total, _orange),
        ],
      ),
    );
  }

  Widget _distBar(String label, int value, int total, Color color) {
    final pct = total > 0 ? value / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '$value  ${(pct * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 7,
            value: pct,
            backgroundColor: _white.withValues(alpha: 0.06),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }

  // ── Users tab ──────────────────────────────────────────────────────────────

  Widget _usersTab(AdminData data) {
    final filtered = _filteredUsers(data.users);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: [
              Expanded(child: _searchField('Search users…')),
              const SizedBox(width: 10),
              _squareBtn(
                Icons.person_add_alt_1_rounded,
                _orange,
                () => _showUserForm(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _filterChip('All', _UserFilter.all),
              _filterChip('Active', _UserFilter.active),
              _filterChip('Inactive', _UserFilter.inactive),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: filtered.isEmpty
              ? _emptyState(
                  icon: Icons.people_outline_rounded,
                  message: data.users.isEmpty
                      ? 'No users found.'
                      : 'No users match your search.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _UserCard(
                    user: filtered[i],
                    onTap: () => _showUserDetail(context, filtered[i]),
                  ),
                ),
        ),
      ],
    );
  }

  // ── Services tab ───────────────────────────────────────────────────────────

  Widget _servicesTab(AdminData data) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'Services',
                style: TextStyle(
                  color: _white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            _ActionBtn(
              icon: Icons.add_rounded,
              label: 'Add Service',
              color: _orange,
              onTap: () => _showServiceForm(context),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      Expanded(
        child: data.services.isEmpty
            ? _emptyState(
                icon: Icons.apps_outlined,
                message: 'No services found.',
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: data.services.length,
                itemBuilder: (_, i) {
                  final svc = data.services[i];
                  return _ServiceCard(
                    service: svc,
                    onEdit: () => _showServiceForm(context, service: svc),
                    onDelete: () => _confirmDelete(
                      context,
                      title: 'Delete service?',
                      body: 'Remove "${svc.name}" from the platform?',
                      onConfirm: () => context.read<AdminBloc>().add(
                        AdminServiceDeleteRequested(svc.id),
                      ),
                    ),
                  );
                },
              ),
      ),
    ],
  );

  // ── Search / filter ────────────────────────────────────────────────────────

  Widget _searchField(String hint) => Container(
    height: 48,
    decoration: _adminDeco(_cyan, radius: 16),
    child: TextField(
      controller: _searchCtrl,
      style: const TextStyle(color: _white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: _muted.withValues(alpha: 0.65),
          fontSize: 13,
        ),
        prefixIcon: const Icon(Icons.search_rounded, color: _muted, size: 20),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 13),
      ),
    ),
  );

  Widget _filterChip(String label, _UserFilter f) {
    final selected = _filter == f;
    return GestureDetector(
      onTap: () => setState(() => _filter = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _cyan.withValues(alpha: 0.12) : _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? _cyan.withValues(alpha: 0.45)
                : _white.withValues(alpha: 0.07),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? _cyan : _muted,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _squareBtn(IconData icon, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.28)),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      );

  Widget _emptyState({required IconData icon, required String message}) =>
      Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: _muted, size: 48),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(color: _muted, fontSize: 13)),
          ],
        ),
      );

  // ── User detail / subscriptions sheets ────────────────────────────────────

  void _showUserDetail(BuildContext ctx, AdminUserModel user) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: ctx.read<AdminBloc>(),
        child: _UserDetailSheet(
          user: user,
          onEdit: () {
            Navigator.pop(ctx);
            _showUserForm(ctx, user: user);
          },
          onToggle: () => _confirmAction(
            ctx,
            title: user.isActive ? 'Deactivate user?' : 'Activate user?',
            body: user.isActive
                ? 'Deactivating will prevent ${user.fullName} from logging in.'
                : 'Activate ${user.fullName}\'s account?',
            confirmLabel: user.isActive ? 'Deactivate' : 'Activate',
            confirmColor: user.isActive ? _red : _green,
            onConfirm: () {
              Navigator.pop(ctx);
              ctx.read<AdminBloc>().add(AdminUserToggleRequested(user.id));
            },
          ),
          onResetPassword: () {
            Navigator.pop(ctx);
            _showResetPasswordSheet(ctx, user);
          },
          onDelete: () => _confirmDelete(
            ctx,
            title: 'Delete user?',
            body: 'This will permanently remove ${user.fullName}.',
            onConfirm: () {
              Navigator.pop(ctx);
              ctx.read<AdminBloc>().add(AdminUserDeleteRequested(user.id));
            },
          ),
          onViewSubscriptions: () {
            ctx.read<AdminBloc>().add(AdminUserSubscriptionsRequested(user.id));
            _showUserSubscriptionsSheet(ctx, user);
          },
        ),
      ),
    );
  }

  void _showUserSubscriptionsSheet(BuildContext ctx, AdminUserModel user) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: ctx.read<AdminBloc>(),
        child: _UserSubscriptionsSheet(user: user),
      ),
    );
  }

  void _showResetPasswordSheet(BuildContext ctx, AdminUserModel user) {
    final pwCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AdminSheet(
        title: 'Reset Password',
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Text(
                'Set a new password for ${user.fullName}.',
                style: const TextStyle(color: _muted, fontSize: 13),
              ),
              const SizedBox(height: 16),
              _AdminTextField(
                label: 'New Password',
                icon: Icons.lock_outline_rounded,
                controller: pwCtrl,
                obscureText: true,
                validator: (v) => (v == null || v.length < 6)
                    ? 'Password must be at least 6 characters'
                    : null,
              ),
              const SizedBox(height: 16),
              _ActionBtn(
                icon: Icons.lock_reset_rounded,
                label: 'Reset Password',
                color: _orange,
                expanded: true,
                onTap: () {
                  if (!formKey.currentState!.validate()) return;
                  Navigator.pop(ctx);
                  ctx.read<AdminBloc>().add(
                    AdminUserPasswordResetRequested(
                      id: user.id,
                      newPassword: pwCtrl.text.trim(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── User form ──────────────────────────────────────────────────────────────

  void _showUserForm(BuildContext ctx, {AdminUserModel? user}) {
    final firstCtrl = TextEditingController(text: user?.firstName ?? '');
    final lastCtrl = TextEditingController(text: user?.lastName ?? '');
    final emailCtrl = TextEditingController(text: user?.email ?? '');
    final pwCtrl = TextEditingController();
    final phoneCtrl = TextEditingController(text: user?.phone ?? '');
    String role = user?.role ?? 'user';
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (_, setSheet) => _AdminSheet(
          title: user == null ? 'Add User' : 'Edit User',
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _AdminTextField(
                        label: 'First Name',
                        icon: Icons.person_rounded,
                        controller: firstCtrl,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _AdminTextField(
                        label: 'Last Name',
                        icon: Icons.person_rounded,
                        controller: lastCtrl,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _AdminTextField(
                  label: 'Email',
                  icon: Icons.email_rounded,
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || !v.contains('@'))
                      ? 'Valid email required'
                      : null,
                ),
                if (user == null) ...[
                  const SizedBox(height: 12),
                  _AdminTextField(
                    label: 'Password',
                    icon: Icons.lock_outline_rounded,
                    controller: pwCtrl,
                    obscureText: true,
                    validator: (v) =>
                        (v == null || v.length < 6) ? 'Min 6 characters' : null,
                  ),
                ],
                const SizedBox(height: 12),
                _AdminTextField(
                  label: 'Phone (optional)',
                  icon: Icons.phone_rounded,
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _field,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _white.withValues(alpha: 0.07)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: role,
                      dropdownColor: _field,
                      style: const TextStyle(color: _white, fontSize: 14),
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: _muted,
                      ),
                      items: ['user', 'admin']
                          .map(
                            (r) => DropdownMenuItem(
                              value: r,
                              child: Row(
                                children: [
                                  Icon(
                                    r == 'admin'
                                        ? Icons.shield_rounded
                                        : Icons.person_rounded,
                                    color: r == 'admin' ? _orange : _cyan,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    r[0].toUpperCase() + r.substring(1),
                                    style: const TextStyle(color: _white),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setSheet(() => role = v ?? role),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _ActionBtn(
                  icon: user == null
                      ? Icons.person_add_alt_1_rounded
                      : Icons.save_rounded,
                  label: user == null ? 'Create User' : 'Save Changes',
                  color: _orange,
                  expanded: true,
                  onTap: () {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.pop(sheetCtx);
                    if (user == null) {
                      ctx.read<AdminBloc>().add(
                        AdminUserCreateRequested(
                          firstName: firstCtrl.text.trim(),
                          lastName: lastCtrl.text.trim(),
                          email: emailCtrl.text.trim(),
                          password: pwCtrl.text.trim(),
                          role: role,
                          phone: phoneCtrl.text.trim(),
                        ),
                      );
                    } else {
                      ctx.read<AdminBloc>().add(
                        AdminUserUpdateRequested(
                          id: user.id,
                          firstName: firstCtrl.text.trim(),
                          lastName: lastCtrl.text.trim(),
                          email: emailCtrl.text.trim(),
                          role: role,
                          phone: phoneCtrl.text.trim(),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Service form ───────────────────────────────────────────────────────────

  void _showServiceForm(BuildContext ctx, {AdminServiceModel? service}) {
    final nameCtrl = TextEditingController(text: service?.name ?? '');
    final amountCtrl = TextEditingController(
      text: service != null ? service.defaultAmount.toStringAsFixed(2) : '',
    );
    final descCtrl = TextEditingController(text: service?.description ?? '');
    final logoCtrl = TextEditingController(text: service?.logoUrl ?? '');
    String cycle = service?.billingCycle.toLowerCase() ?? 'monthly';
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (_, setSheet) => _AdminSheet(
          title: service == null ? 'Add Service' : 'Edit Service',
          child: Form(
            key: formKey,
            child: Column(
              children: [
                _AdminTextField(
                  label: 'Service Name',
                  icon: Icons.apps_rounded,
                  controller: nameCtrl,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                _AdminTextField(
                  label: 'Default Amount (\$)',
                  icon: Icons.attach_money_rounded,
                  controller: amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  validator: (v) => double.tryParse(v ?? '') == null
                      ? 'Valid number required'
                      : null,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _field,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _white.withValues(alpha: 0.07)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: cycle,
                      dropdownColor: _field,
                      style: const TextStyle(color: _white, fontSize: 14),
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: _muted,
                      ),
                      items: ['monthly', 'weekly', 'yearly']
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(
                                c[0].toUpperCase() + c.substring(1),
                                style: const TextStyle(color: _white),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setSheet(() => cycle = v ?? cycle),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _AdminTextField(
                  label: 'Logo URL (optional)',
                  icon: Icons.image_rounded,
                  controller: logoCtrl,
                ),
                const SizedBox(height: 12),
                _AdminTextField(
                  label: 'Description',
                  icon: Icons.description_rounded,
                  controller: descCtrl,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                _ActionBtn(
                  icon: service == null
                      ? Icons.add_business_rounded
                      : Icons.save_rounded,
                  label: service == null ? 'Create Service' : 'Save Changes',
                  color: _orange,
                  expanded: true,
                  onTap: () {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.pop(sheetCtx);
                    if (service == null) {
                      ctx.read<AdminBloc>().add(
                        AdminServiceCreateRequested(
                          name: nameCtrl.text.trim(),
                          defaultAmount: double.parse(amountCtrl.text.trim()),
                          billingCycle: cycle,
                          description: descCtrl.text.trim(),
                          logoUrl: logoCtrl.text.trim(),
                        ),
                      );
                    } else {
                      ctx.read<AdminBloc>().add(
                        AdminServiceUpdateRequested(
                          id: service.id,
                          name: nameCtrl.text.trim(),
                          defaultAmount: double.parse(amountCtrl.text.trim()),
                          billingCycle: cycle,
                          description: descCtrl.text.trim(),
                          logoUrl: logoCtrl.text.trim(),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Dialogs ────────────────────────────────────────────────────────────────

  void _confirmDelete(
    BuildContext ctx, {
    required String title,
    required String body,
    required VoidCallback onConfirm,
  }) => _confirmAction(
    ctx,
    title: title,
    body: body,
    confirmLabel: 'Delete',
    confirmColor: _red,
    onConfirm: onConfirm,
  );

  void _confirmAction(
    BuildContext ctx, {
    required String title,
    required String body,
    required String confirmLabel,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) => showDialog<void>(
    context: ctx,
    builder: (_) => AlertDialog(
      backgroundColor: _card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: confirmColor.withValues(alpha: 0.24)),
      ),
      title: Text(
        title,
        style: const TextStyle(color: _white, fontWeight: FontWeight.w900),
      ),
      content: Text(body, style: const TextStyle(color: _muted)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel', style: TextStyle(color: _muted)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            onConfirm();
          },
          child: Text(
            confirmLabel,
            style: TextStyle(color: confirmColor, fontWeight: FontWeight.w900),
          ),
        ),
      ],
    ),
  );
}

// ── Profile stat card ─────────────────────────────────────────────────────────

class _ProfileStatCard extends StatelessWidget {
  const _ProfileStatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: _card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withValues(alpha: 0.18)),
    ),
    child: Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 7),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _muted,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

// ── Profile action ────────────────────────────────────────────────────────────

class _ProfileAction extends StatelessWidget {
  const _ProfileAction({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: _muted, fontSize: 11),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: color.withValues(alpha: 0.50),
            size: 20,
          ),
        ],
      ),
    ),
  );
}

// ── Access denied ─────────────────────────────────────────────────────────────

class _AccessDeniedScreen extends StatelessWidget {
  const _AccessDeniedScreen({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _bg,
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _red.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: _red.withValues(alpha: 0.28)),
                ),
                child: const Icon(Icons.block_rounded, color: _red, size: 36),
              ),
              const SizedBox(height: 20),
              const Text(
                'Access Denied',
                style: TextStyle(
                  color: _white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You do not have permission to access the admin panel.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _muted, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: onBack,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: _cyan.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _cyan.withValues(alpha: 0.35)),
                  ),
                  child: const Text(
                    'Go Back',
                    style: TextStyle(color: _cyan, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// ── Error view ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, color: _muted, size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _muted, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: _cyan.withValues(alpha: 0.65)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded, color: _cyan, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Retry',
                    style: TextStyle(color: _cyan, fontWeight: FontWeight.w700),
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

// ── Action loading overlay ────────────────────────────────────────────────────

class _ActionLoadingOverlay extends StatelessWidget {
  const _ActionLoadingOverlay();

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.black.withValues(alpha: 0.45),
    child: const Center(child: CircularProgressIndicator(color: _orange)),
  );
}

// ── User card ─────────────────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user, required this.onTap});
  final AdminUserModel user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = user.isActive ? _cyan : _muted;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: _adminDeco(color, radius: 18),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.12),
                border: Border.all(color: color.withValues(alpha: 0.35)),
              ),
              child: Center(
                child: Text(
                  user.initials,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.fullName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _white,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      _statusPill(
                        user.isActive ? 'Active' : 'Inactive',
                        user.isActive ? _green : _muted,
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    user.email,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _muted, fontSize: 11),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _smallBadge(
                        user.role,
                        user.role == 'admin' ? _orange : _purple,
                      ),
                      if (user.createdAt != null)
                        _smallBadge(
                          'Joined ${DateFormat('MMM yy').format(user.createdAt!)}',
                          _muted,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: _white.withValues(alpha: 0.25),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ── User detail sheet ─────────────────────────────────────────────────────────

class _UserDetailSheet extends StatelessWidget {
  const _UserDetailSheet({
    required this.user,
    required this.onEdit,
    required this.onToggle,
    required this.onResetPassword,
    required this.onDelete,
    required this.onViewSubscriptions,
  });
  final AdminUserModel user;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onResetPassword;
  final VoidCallback onDelete;
  final VoidCallback onViewSubscriptions;

  @override
  Widget build(BuildContext context) => _AdminSheet(
    title: 'User Detail',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (user.isActive ? _cyan : _muted).withValues(alpha: 0.12),
                border: Border.all(
                  color: (user.isActive ? _cyan : _muted).withValues(
                    alpha: 0.35,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  user.initials,
                  style: TextStyle(
                    color: user.isActive ? _cyan : _muted,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: const TextStyle(
                      color: _white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    user.email,
                    style: const TextStyle(color: _muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            _statusPill(
              user.isActive ? 'Active' : 'Inactive',
              user.isActive ? _green : _muted,
            ),
          ],
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _infoPill('Role', user.role, _cyan),
            if (user.createdAt != null)
              _infoPill(
                'Joined',
                DateFormat('MMM d, yyyy').format(user.createdAt!),
                _purple,
              ),
            if (user.phone != null && user.phone!.isNotEmpty)
              _infoPill('Phone', user.phone!, _muted),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _ActionBtn(
              icon: Icons.edit_rounded,
              label: 'Edit',
              color: _cyan,
              onTap: onEdit,
            ),
            _ActionBtn(
              icon: user.isActive
                  ? Icons.block_rounded
                  : Icons.check_circle_rounded,
              label: user.isActive ? 'Deactivate' : 'Activate',
              color: user.isActive ? _red : _green,
              onTap: onToggle,
            ),
            _ActionBtn(
              icon: Icons.lock_reset_rounded,
              label: 'Reset Password',
              color: _orange,
              onTap: onResetPassword,
            ),
            _ActionBtn(
              icon: Icons.subscriptions_rounded,
              label: 'Subscriptions',
              color: _purple,
              onTap: onViewSubscriptions,
            ),
            _ActionBtn(
              icon: Icons.delete_rounded,
              label: 'Delete',
              color: _red,
              onTap: onDelete,
            ),
          ],
        ),
      ],
    ),
  );
}

// ── User subscriptions sheet ──────────────────────────────────────────────────

class _UserSubscriptionsSheet extends StatelessWidget {
  const _UserSubscriptionsSheet({required this.user});
  final AdminUserModel user;

  @override
  Widget build(BuildContext context) => _AdminSheet(
    title: '${user.fullName}\'s Subscriptions',
    child: BlocBuilder<AdminBloc, AdminState>(
      builder: (_, state) {
        if (state is! AdminData) return const SizedBox.shrink();
        if (state.subscriptionsLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator(color: _cyan)),
          );
        }
        final subs = state.viewingUserSubscriptions;
        if (subs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                'No subscriptions found.',
                style: TextStyle(color: _muted, fontSize: 13),
              ),
            ),
          );
        }
        return Column(children: subs.map((s) => _SubTile(sub: s)).toList());
      },
    ),
  );
}

class _SubTile extends StatelessWidget {
  const _SubTile({required this.sub});
  final AdminUserSubscriptionModel sub;

  @override
  Widget build(BuildContext context) {
    final color = sub.isActive ? _green : _muted;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: _adminDeco(color, radius: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sub.serviceName,
                  style: const TextStyle(
                    color: _white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${sub.plan} · ${sub.billingCycle}',
                  style: const TextStyle(color: _muted, fontSize: 11),
                ),
                if (sub.renewalDate != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Renews ${DateFormat('MMM d, yyyy').format(sub.renewalDate!)}',
                    style: TextStyle(
                      color: _muted.withValues(alpha: 0.7),
                      fontSize: 10,
                    ),
                  ),
                ],
                if (sub.cardInfo != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Card: ${sub.cardInfo}',
                    style: TextStyle(
                      color: _muted.withValues(alpha: 0.7),
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${sub.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: _orange,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              _statusPill(sub.status, color),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Service card ──────────────────────────────────────────────────────────────

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.service,
    required this.onEdit,
    required this.onDelete,
  });
  final AdminServiceModel service;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(14),
    decoration: _adminDeco(_cyan, radius: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _cyan.withValues(alpha: 0.12),
                border: Border.all(color: _cyan.withValues(alpha: 0.28)),
              ),
              child: Center(
                child:
                    service.logoUrl != null &&
                        service.logoUrl!.startsWith('http')
                    ? ClipOval(
                        child: Image.network(
                          service.logoUrl!,
                          width: 28,
                          height: 28,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Text(
                            service.initials,
                            style: const TextStyle(
                              color: _cyan,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      )
                    : Text(
                        service.initials,
                        style: const TextStyle(
                          color: _cyan,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    [
                      if (service.categoryName.isNotEmpty) service.categoryName,
                      service.billingCycle,
                    ].join(' · '),
                    style: const TextStyle(color: _muted, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        if (service.description.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            service.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: _muted, fontSize: 12, height: 1.4),
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            _smallBadge(
              '\$${service.defaultAmount.toStringAsFixed(2)}/${service.billingCycle.toLowerCase()}',
              _orange,
            ),
            const Spacer(),
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: onEdit,
              icon: const Icon(Icons.edit_rounded, color: _cyan, size: 19),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: onDelete,
              icon: const Icon(Icons.delete_rounded, color: _red, size: 19),
            ),
          ],
        ),
      ],
    ),
  );
}

// ── Metric card ───────────────────────────────────────────────────────────────

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    this.sub = '',
  });
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final String sub;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: _adminDeco(color, radius: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 17),
        ),
        const Spacer(),
        Text(
          value,
          maxLines: 1,
          style: TextStyle(
            color: color,
            fontSize: 21,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _muted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (sub.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            sub,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _muted.withValues(alpha: 0.65),
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    ),
  );
}

// ── Section title ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;
  @override
  Widget build(BuildContext context) => Text(
    title,
    style: const TextStyle(
      color: _white,
      fontSize: 15,
      fontWeight: FontWeight.w900,
    ),
  );
}

// ── Bottom sheet wrapper ──────────────────────────────────────────────────────

class _AdminSheet extends StatelessWidget {
  const _AdminSheet({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
    initialChildSize: 0.78,
    minChildSize: 0.45,
    maxChildSize: 0.94,
    builder: (_, ctrl) => Container(
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: ListView(
        controller: ctrl,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: _white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: _white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: _muted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    ),
  );
}

// ── Action button ─────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.expanded = false,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final btn = GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.11),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.28)),
        ),
        child: Row(
          mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return expanded ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}

// ── Text field ────────────────────────────────────────────────────────────────

class _AdminTextField extends StatelessWidget {
  const _AdminTextField({
    required this.label,
    required this.icon,
    this.controller,
    this.obscureText = false,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });
  final String label;
  final IconData icon;
  final TextEditingController? controller;
  final bool obscureText;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    obscureText: obscureText,
    maxLines: maxLines,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    validator: validator,
    style: const TextStyle(color: _white, fontSize: 14),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: _muted, fontSize: 12),
      prefixIcon: Icon(icon, color: _cyan, size: 19),
      filled: true,
      fillColor: _field,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _white.withValues(alpha: 0.07)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _cyan.withValues(alpha: 0.42)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _red.withValues(alpha: 0.55)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _red),
      ),
    ),
  );
}

// ── Revenue line chart ────────────────────────────────────────────────────────

class _RevenueLineChart extends StatelessWidget {
  const _RevenueLineChart();

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
  static const _data = [3200.0, 4800.0, 4100.0, 5600.0, 4900.0, 6800.0];

  @override
  Widget build(BuildContext context) {
    final spots = List.generate(
      _data.length,
      (i) => FlSpot(i.toDouble(), _data[i]),
    );

    return Container(
      height: 196,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: const Color(0xFF070F1A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _cyan.withValues(alpha: 0.20), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: _cyan.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 9000,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 3000,
            getDrawingHorizontalLine: (_) => FlLine(
              color: _white.withValues(alpha: 0.05),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                interval: 3000,
                getTitlesWidget: (v, _) => Text(
                  '\$${(v / 1000).toStringAsFixed(0)}k',
                  style: TextStyle(
                    color: _muted.withValues(alpha: 0.60),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= _months.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _months[i],
                      style: TextStyle(
                        color: _muted.withValues(alpha: 0.60),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.35,
              color: _cyan,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                  radius: 3.5,
                  color: _cyan,
                  strokeWidth: 2,
                  strokeColor: const Color(0xFF070F1A),
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _cyan.withValues(alpha: 0.18),
                    _cyan.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Status donut chart ────────────────────────────────────────────────────────

class _StatusDonutChart extends StatelessWidget {
  const _StatusDonutChart({required this.stats});
  final AdminStatisticsModel? stats;

  @override
  Widget build(BuildContext context) {
    final total = stats?.totalSubscriptions ?? 100;
    final active = stats?.activeSubscriptions ?? 68;
    final cancelled = (total - active).clamp(0, total);
    final activePct = total > 0 ? active / total * 100 : 68.0;
    final cancelledPct = total > 0 ? cancelled / total * 100 : 32.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF070F1A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _cyan.withValues(alpha: 0.20), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: _cyan.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            height: 130,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 40,
                startDegreeOffset: -90,
                sections: [
                  PieChartSectionData(
                    value: activePct,
                    color: _green,
                    title: '${activePct.toStringAsFixed(0)}%',
                    radius: 26,
                    titleStyle: const TextStyle(
                      color: _white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  PieChartSectionData(
                    value: cancelledPct,
                    color: _orange.withValues(alpha: 0.75),
                    title: '${cancelledPct.toStringAsFixed(0)}%',
                    radius: 22,
                    titleStyle: const TextStyle(
                      color: _white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _DonutLegend(
                  color: _green,
                  label: 'Active',
                  value: '$active',
                  pct: activePct,
                ),
                const SizedBox(height: 16),
                _DonutLegend(
                  color: _orange,
                  label: 'Cancelled',
                  value: '$cancelled',
                  pct: cancelledPct,
                ),
                const SizedBox(height: 14),
                Text(
                  '$total total subscriptions',
                  style: TextStyle(
                    color: _muted.withValues(alpha: 0.55),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutLegend extends StatelessWidget {
  const _DonutLegend({
    required this.color,
    required this.label,
    required this.value,
    required this.pct,
  });
  final Color color;
  final String label;
  final String value;
  final double pct;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.45),
                blurRadius: 6,
              ),
            ],
          ),
        ),
      ),
      const SizedBox(width: 9),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _muted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$value  (${pct.toStringAsFixed(0)}%)',
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    ],
  );
}

// ── Helpers ───────────────────────────────────────────────────────────────────

BoxDecoration _adminDeco(Color color, {double radius = 18}) => BoxDecoration(
  color: const Color(0xFF070F1A),
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: color.withValues(alpha: 0.20), width: 1.0),
  boxShadow: [
    BoxShadow(
      color: color.withValues(alpha: 0.08),
      blurRadius: 28,
      offset: const Offset(0, 10),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.22),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ],
);

Widget _statusPill(String label, Color color) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: color.withValues(alpha: 0.12),
    borderRadius: BorderRadius.circular(999),
    border: Border.all(color: color.withValues(alpha: 0.18)),
  ),
  child: Text(
    label,
    style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900),
  ),
);

Widget _smallBadge(String label, Color color) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: color.withValues(alpha: 0.10),
    borderRadius: BorderRadius.circular(9),
  ),
  child: Text(
    label,
    style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900),
  ),
);

Widget _trendPill(String label, Color color) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
  decoration: BoxDecoration(
    color: color.withValues(alpha: 0.12),
    borderRadius: BorderRadius.circular(999),
    border: Border.all(color: color.withValues(alpha: 0.20)),
  ),
  child: Text(
    label,
    style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900),
  ),
);

Widget _infoPill(String label, String value, Color color) => Container(
  constraints: const BoxConstraints(minWidth: 100, maxWidth: 180),
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: color.withValues(alpha: 0.09),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: color.withValues(alpha: 0.18)),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: _muted,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 5),
      Text(
        value,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
    ],
  ),
);
