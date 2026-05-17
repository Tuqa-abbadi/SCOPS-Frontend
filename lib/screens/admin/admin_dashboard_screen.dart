import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

enum _UserFilter { all, active, inactive, highSpend }

class _AdminStats {
  static const totalUsers = 1247;
  static const activeUsers = 893;
  static const totalServices = 48;
  static const activeServices = 41;
  static const totalSubscriptions = 4821;
  static const activeSubscriptions = 4256;
  static const inactiveSubscriptions = 565;
  static const monthlyUserSpending = 38492.50;
  static const churnRate = 3.2;
  static const retentionRate = 91.4;
}

class _AdminSubscription {
  final String service;
  final String plan;
  final double price;
  final String status;
  final DateTime renewsAt;

  const _AdminSubscription({
    required this.service,
    required this.plan,
    required this.price,
    required this.status,
    required this.renewsAt,
  });
}

class _AdminUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final int subscriptions;
  final double monthlySpend;
  final DateTime joinedAt;
  final bool isActive;
  final List<_AdminSubscription> subscriptionsList;

  const _AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.subscriptions,
    required this.monthlySpend,
    required this.joinedAt,
    required this.isActive,
    required this.subscriptionsList,
  });
}

class _AdminService {
  final String id;
  final String icon;
  final String name;
  final String category;
  final String cycle;
  final String description;
  final double price;
  final int activeSubscribers;
  final bool isActive;

  const _AdminService({
    required this.id,
    required this.icon,
    required this.name,
    required this.category,
    required this.cycle,
    required this.description,
    required this.price,
    required this.activeSubscribers,
    required this.isActive,
  });
}

class _RecentFeedback {
  final String user;
  final int rating;
  final String comment;
  final DateTime date;

  const _RecentFeedback({
    required this.user,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

class _ActivityEvent {
  final IconData icon;
  final String title;
  final String detail;
  final Color color;
  final DateTime date;

  const _ActivityEvent({
    required this.icon,
    required this.title,
    required this.detail,
    required this.color,
    required this.date,
  });
}

const _bg = Color(0xFF020812);
const _card = Color(0xFF07111C);
const _field = Color(0xFF0B1521);
const _cyan = Color(0xFF18E8F2);
const _orange = Color(0xFFFF5A14);
const _green = Color(0xFF22C55E);
const _red = Color(0xFFFF4D4D);
const _purple = Color(0xFFA855F7);
const _yellow = Color(0xFFFFB020);
const _white = Colors.white;
const _muted = Color(0xFF9BA4B0);

final _currency = NumberFormat.currency(symbol: r'$', decimalDigits: 0);

final _mockUsers = [
  _AdminUser(
    id: 'u1',
    name: 'Alex Architect',
    email: 'alex@scops.app',
    role: 'Power user',
    subscriptions: 7,
    monthlySpend: 124.50,
    joinedAt: DateTime(2024, 9, 1),
    isActive: true,
    subscriptionsList: [
      _AdminSubscription(service: 'Netflix', plan: 'Premium', price: 22.99, status: 'Active', renewsAt: DateTime(2026, 6, 2)),
      _AdminSubscription(service: 'Adobe CC', plan: 'All Apps', price: 59.99, status: 'Active', renewsAt: DateTime(2026, 6, 8)),
      _AdminSubscription(service: 'iCloud+', plan: '2 TB', price: 9.99, status: 'Active', renewsAt: DateTime(2026, 5, 28)),
    ],
  ),
  _AdminUser(
    id: 'u2',
    name: 'Sara Builder',
    email: 'sara@scops.app',
    role: 'Team owner',
    subscriptions: 5,
    monthlySpend: 87.20,
    joinedAt: DateTime(2024, 10, 15),
    isActive: true,
    subscriptionsList: [
      _AdminSubscription(service: 'Spotify', plan: 'Family', price: 16.99, status: 'Active', renewsAt: DateTime(2026, 6, 5)),
      _AdminSubscription(service: 'Figma', plan: 'Professional', price: 15.00, status: 'Active', renewsAt: DateTime(2026, 6, 10)),
    ],
  ),
  _AdminUser(
    id: 'u3',
    name: 'Omar Dev',
    email: 'omar@scops.app',
    role: 'Developer',
    subscriptions: 3,
    monthlySpend: 42.00,
    joinedAt: DateTime(2024, 11, 3),
    isActive: false,
    subscriptionsList: [
      _AdminSubscription(service: 'GitHub', plan: 'Team', price: 4.00, status: 'Canceled', renewsAt: DateTime(2026, 5, 19)),
      _AdminSubscription(service: 'ChatGPT', plan: 'Plus', price: 20.00, status: 'Inactive', renewsAt: DateTime(2026, 5, 22)),
    ],
  ),
  _AdminUser(
    id: 'u4',
    name: 'Lena Manager',
    email: 'lena@scops.app',
    role: 'Finance lead',
    subscriptions: 9,
    monthlySpend: 210.80,
    joinedAt: DateTime(2024, 8, 20),
    isActive: true,
    subscriptionsList: [
      _AdminSubscription(service: 'Notion', plan: 'Business', price: 18.00, status: 'Active', renewsAt: DateTime(2026, 6, 1)),
      _AdminSubscription(service: 'Dropbox', plan: 'Advanced', price: 30.00, status: 'Active', renewsAt: DateTime(2026, 5, 30)),
      _AdminSubscription(service: 'Canva', plan: 'Teams', price: 14.99, status: 'Active', renewsAt: DateTime(2026, 6, 3)),
    ],
  ),
];

final _mockServices = [
  _AdminService(id: 's1', icon: 'N', name: 'Netflix', category: 'Streaming', price: 22.99, cycle: 'Monthly', activeSubscribers: 342, isActive: true, description: 'Entertainment streaming subscription.'),
  _AdminService(id: 's2', icon: 'S', name: 'Spotify', category: 'Music', price: 10.99, cycle: 'Monthly', activeSubscribers: 298, isActive: true, description: 'Music and podcast platform.'),
  _AdminService(id: 's3', icon: 'A', name: 'Adobe CC', category: 'Design', price: 59.99, cycle: 'Monthly', activeSubscribers: 187, isActive: true, description: 'Creative cloud tools and storage.'),
  _AdminService(id: 's4', icon: 'Y', name: 'YouTube Premium', category: 'Streaming', price: 13.99, cycle: 'Monthly', activeSubscribers: 156, isActive: false, description: 'Ad-free video and music bundle.'),
  _AdminService(id: 's5', icon: 'I', name: 'iCloud+', category: 'Storage', price: 9.99, cycle: 'Monthly', activeSubscribers: 134, isActive: true, description: 'Cloud storage and privacy services.'),
];

final _mockFeedback = [
  _RecentFeedback(user: 'Alex A.', rating: 5, comment: 'Love the design, very intuitive.', date: DateTime.now().subtract(const Duration(hours: 3))),
  _RecentFeedback(user: 'Sara B.', rating: 4, comment: 'Great app. Would love dark widgets.', date: DateTime.now().subtract(const Duration(days: 1))),
  _RecentFeedback(user: 'Omar D.', rating: 3, comment: 'Notifications sometimes late.', date: DateTime.now().subtract(const Duration(days: 2))),
  _RecentFeedback(user: 'Lena M.', rating: 5, comment: 'The spending analytics are exactly what our team needed.', date: DateTime.now().subtract(const Duration(days: 4))),
];

final _activity = [
  _ActivityEvent(icon: Icons.person_add_alt_1_rounded, title: 'User created', detail: 'Nadine H. was added by admin', color: _cyan, date: DateTime.now().subtract(const Duration(minutes: 18))),
  _ActivityEvent(icon: Icons.lock_reset_rounded, title: 'Password reset', detail: 'Reset link sent to sara@scops.app', color: _orange, date: DateTime.now().subtract(const Duration(hours: 1))),
  _ActivityEvent(icon: Icons.edit_rounded, title: 'Service edited', detail: 'Adobe CC pricing updated', color: _purple, date: DateTime.now().subtract(const Duration(hours: 4))),
  _ActivityEvent(icon: Icons.cancel_rounded, title: 'Subscription canceled', detail: 'GitHub Team canceled for Omar Dev', color: _red, date: DateTime.now().subtract(const Duration(hours: 8))),
  _ActivityEvent(icon: Icons.credit_card_off_rounded, title: 'Failed payment', detail: 'Netflix renewal failed for 3 users', color: _yellow, date: DateTime.now().subtract(const Duration(days: 1))),
];

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  final _searchCtrl = TextEditingController();
  _UserFilter _filter = _UserFilter.all;
  String _reportPeriod = 'This Month';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _searchCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_AdminUser> get _filteredUsers {
    final query = _searchCtrl.text.trim().toLowerCase();
    return _mockUsers.where((user) {
      final matchesSearch = query.isEmpty ||
          user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query);
      final matchesFilter = switch (_filter) {
        _UserFilter.all => true,
        _UserFilter.active => user.isActive,
        _UserFilter.inactive => !user.isActive,
        _UserFilter.highSpend => user.monthlySpend >= 100,
      };
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            _tabs(),
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  _overviewTab(),
                  _usersTab(),
                  _servicesTab(),
                  _feedbackTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() => Padding(
        padding: const EdgeInsets.fromLTRB(8, 14, 16, 8),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _white, size: 20),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _orange.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _orange.withOpacity(0.34)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_rounded, color: _orange, size: 14),
                  SizedBox(width: 6),
                  Text('ADMIN', style: TextStyle(color: _orange, fontSize: 11, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('SCOPS Control', style: TextStyle(color: _white, fontSize: 20, fontWeight: FontWeight.w900)),
            ),
            IconButton(
              tooltip: 'Send push',
              onPressed: _showNotificationSheet,
              icon: const Icon(Icons.notifications_active_rounded, color: _orange),
            ),
          ],
        ),
      );

  Widget _tabs() => TabBar(
        controller: _tabCtrl,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: _cyan,
        unselectedLabelColor: _muted,
        indicatorColor: _cyan,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Users'),
          Tab(text: 'Services'),
          Tab(text: 'Feedback'),
        ],
      );

  Widget _overviewTab() => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _heroSpendingCard(),
            const SizedBox(height: 18),
            Row(
              children: [
                const AdminSectionTitle('Reports'),
                const Spacer(),
                _periodSelector(),
              ],
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.18,
              children: const [
                AdminMetricCard(value: '1,247', label: 'Total Users', icon: Icons.people_rounded, color: _cyan, trend: '+12%'),
                AdminMetricCard(value: '893', label: 'Active Users', icon: Icons.verified_user_rounded, color: _green, trend: '72% active'),
                AdminMetricCard(value: '48', label: 'Total Services', icon: Icons.apps_rounded, color: _orange, trend: '41 active'),
                AdminMetricCard(value: '4,821', label: 'Subscriptions', icon: Icons.subscriptions_rounded, color: _purple, trend: '4,256 active'),
                AdminMetricCard(value: r'$38.5k', label: 'Monthly Spending', icon: Icons.payments_rounded, color: _orange, trend: '+8.4%'),
                AdminMetricCard(value: '3.2%', label: 'Churn Rate', icon: Icons.trending_down_rounded, color: _red, trend: '-0.6%'),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: _miniInsight('Retention', '91.4%', _green, Icons.favorite_rounded)),
                const SizedBox(width: 12),
                Expanded(child: _miniInsight('Canceled', '565', _red, Icons.remove_circle_rounded)),
              ],
            ),
            const SizedBox(height: 18),
            AdminChartCard(
              title: 'User Growth',
              subtitle: 'New users by month',
              child: _growthBarChart(),
            ),
            const SizedBox(height: 14),
            AdminChartCard(
              title: 'Subscription Distribution',
              subtitle: 'Status split',
              child: _donutChart(),
            ),
            const SizedBox(height: 14),
            AdminChartCard(
              title: 'Top Services',
              subtitle: 'Subscribers by service',
              child: Column(children: _mockServices.map(_topServiceBar).toList()),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                AdminActionButton(icon: Icons.download_rounded, label: 'Export CSV', color: _cyan, onTap: () => _mockMessage('CSV export queued')),
                AdminActionButton(icon: Icons.notifications_active_rounded, label: 'Send Push', color: _orange, onTap: _showNotificationSheet),
                AdminActionButton(icon: Icons.person_add_alt_1_rounded, label: 'Add User', color: _orange, onTap: _showAddUserSheet),
                AdminActionButton(icon: Icons.add_business_rounded, label: 'Add Service', color: _cyan, onTap: () => _showServiceSheet()),
              ],
            ),
            const SizedBox(height: 22),
            const AdminSectionTitle('Recent Activity'),
            const SizedBox(height: 12),
            ..._activity.map((event) => AdminActivityTile(event: event)),
          ],
        ),
      );

  Widget _usersTab() => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(child: _searchField()),
                const SizedBox(width: 10),
                _squareButton(Icons.person_add_alt_1_rounded, _orange, _showAddUserSheet),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _filterChip('All', _UserFilter.all),
                _filterChip('Active', _UserFilter.active),
                _filterChip('Inactive', _UserFilter.inactive),
                _filterChip('High Spend', _UserFilter.highSpend),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: _filteredUsers.length,
              itemBuilder: (_, index) => AdminUserCard(
                user: _filteredUsers[index],
                onTap: () => _showUserDetail(_filteredUsers[index]),
              ),
            ),
          ),
        ],
      );

  Widget _servicesTab() => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const AdminSectionTitle('Services'),
                const Spacer(),
                AdminActionButton(icon: Icons.add_rounded, label: 'Add Service', color: _orange, onTap: () => _showServiceSheet()),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _miniInsight('Active Services', '${_AdminStats.activeServices}', _cyan, Icons.check_circle_rounded)),
                const SizedBox(width: 12),
                Expanded(child: _miniInsight('Subscribers', '1,117', _green, Icons.groups_rounded)),
              ],
            ),
            const SizedBox(height: 14),
            AdminChartCard(
              title: 'Subscriptions by Service',
              subtitle: 'Active subscriber concentration',
              child: Column(children: _mockServices.map(_topServiceBar).toList()),
            ),
            const SizedBox(height: 14),
            ..._mockServices.map((service) => AdminServiceCard(
                  service: service,
                  onEdit: () => _showServiceSheet(service: service),
                  onToggle: () => _mockMessage(service.isActive ? 'Service deactivated' : 'Service activated'),
                  onDelete: () => _confirmDanger('Delete service?', 'This mock action would remove ${service.name}.'),
                )),
          ],
        ),
      );

  Widget _feedbackTab() => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ratingSummary(),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: _miniInsight('Avg Rating', '4.3', _yellow, Icons.star_rounded)),
                const SizedBox(width: 12),
                Expanded(child: _miniInsight('Open Issues', '7', _orange, Icons.report_problem_rounded)),
              ],
            ),
            const SizedBox(height: 22),
            const AdminSectionTitle('Recent Feedback'),
            const SizedBox(height: 12),
            ..._mockFeedback.map(_feedbackTile),
          ],
        ),
      );

  Widget _heroSpendingCard() => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 750),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) => Transform.translate(
          offset: Offset(0, 18 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF080C10),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _cyan.withOpacity(0.28), width: 1.2),
              ),
            ),
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(1.0, -1.0),
                      radius: 1.4,
                      colors: [
                        _cyan.withOpacity(0.30),
                        _cyan.withOpacity(0.10),
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
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _AdminHeroIcon(),
                              SizedBox(height: 16),
                              Text(r'$38,492', style: TextStyle(color: Color(0xFFF4FBFC), fontSize: 38, fontWeight: FontWeight.w900, height: 1)),
                              SizedBox(height: 4),
                              Text('Monthly User Spending', style: TextStyle(color: Color(0xFFA8B9C3), fontSize: 12, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        _trendPill('+8.4%', _green),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Compared to last month', style: TextStyle(color: Color(0xFFA8B9C3), fontSize: 11, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 16),
                    SizedBox(height: 132, child: _spendingLineChart()),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _spendingLineChart() => LineChart(
        LineChartData(
          minY: 18,
          maxY: 42,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: _cyan.withOpacity(0.045), strokeWidth: 1)),
          titlesData: const FlTitlesData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: const [FlSpot(0, 22), FlSpot(1, 25), FlSpot(2, 24), FlSpot(3, 29), FlSpot(4, 31), FlSpot(5, 35), FlSpot(6, 38.5)],
              isCurved: true,
              color: _cyan,
              barWidth: 2.4,
              shadow: Shadow(color: _cyan.withOpacity(0.24), blurRadius: 12),
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [_cyan.withOpacity(0.18), _cyan.withOpacity(0.055), _cyan.withOpacity(0.00)]),
              ),
            ),
            LineChartBarData(
              spots: const [FlSpot(0, 20), FlSpot(1, 21), FlSpot(2, 23), FlSpot(3, 25), FlSpot(4, 26), FlSpot(5, 29), FlSpot(6, 31)],
              isCurved: true,
              color: const Color(0xFF7BA6B5).withOpacity(0.26),
              barWidth: 1.4,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      );

  Widget _growthBarChart() => SizedBox(
        height: 180,
        child: BarChart(
          BarChartData(
            borderData: FlBorderData(show: false),
            gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: _white.withOpacity(0.05), strokeWidth: 1)),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, getTitlesWidget: (value, meta) {
                const labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                final index = value.toInt();
                return Text(index >= 0 && index < labels.length ? labels[index] : '', style: const TextStyle(color: _muted, fontSize: 10));
              })),
            ),
            barGroups: [84, 96, 118, 141, 166, 193].asMap().entries.map((entry) {
              return BarChartGroupData(x: entry.key, barRods: [
                BarChartRodData(toY: entry.value.toDouble(), width: 14, borderRadius: BorderRadius.circular(8), color: entry.key.isEven ? _cyan : _orange),
              ]);
            }).toList(),
          ),
        ),
      );

  Widget _donutChart() => Column(
        children: [
          const SizedBox(height: 8),
          SizedBox(
            height: 142,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 46,
                sectionsSpace: 5,
                startDegreeOffset: -90,
                pieTouchData: PieTouchData(enabled: false),
                borderData: FlBorderData(show: false),
                sections: [
                  PieChartSectionData(value: 72, color: _cyan, title: '', radius: 24, showTitle: false),
                  PieChartSectionData(value: 18, color: _orange, title: '', radius: 24, showTitle: false),
                  PieChartSectionData(value: 10, color: const Color(0xFFE66A6A), title: '', radius: 24, showTitle: false),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          _donutLegendItem('Active', '72%', _cyan, '4,256 subscriptions'),
          _donutLegendItem('Inactive', '18%', _orange, '392 subscriptions'),
          _donutLegendItem('Canceled', '10%', const Color(0xFFE66A6A), '173 subscriptions'),
        ],
      );

  Widget _donutLegendItem(String label, String percent, Color color, String detail) => Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _field.withOpacity(0.72),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _white.withOpacity(0.055)),
        ),
        child: Row(
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withOpacity(0.22), blurRadius: 8)]),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: _white, fontSize: 12, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 2),
                  Text(detail, style: TextStyle(color: _muted.withOpacity(0.70), fontSize: 10, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Text(percent, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w900)),
          ],
        ),
      );

  Widget _topServiceBar(_AdminService service) {
    final maxSubscribers = _mockServices.map((s) => s.activeSubscribers).reduce(math.max);
    final pct = service.activeSubscribers / maxSubscribers;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          _serviceAvatar(service.icon, service.isActive ? _cyan : _muted),
          const SizedBox(width: 10),
          SizedBox(
            width: 96,
            child: Text(service.name, style: const TextStyle(color: _white, fontSize: 12, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(value: pct, minHeight: 8, backgroundColor: _white.withOpacity(0.06), valueColor: AlwaysStoppedAnimation(service.isActive ? _cyan : _muted)),
            ),
          ),
          const SizedBox(width: 10),
          Text('${service.activeSubscribers}', style: const TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _searchField() => Container(
        height: 48,
        decoration: _adminDecoration(_cyan, radius: 16, opacity: 0.08),
        child: TextField(
          controller: _searchCtrl,
          style: const TextStyle(color: _white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search users',
            hintStyle: TextStyle(color: _muted.withOpacity(0.65), fontSize: 13),
            prefixIcon: const Icon(Icons.search_rounded, color: _muted, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 13),
          ),
        ),
      );

  Widget _filterChip(String label, _UserFilter filter) {
    final selected = _filter == filter;
    return GestureDetector(
      onTap: () => setState(() => _filter = filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _cyan.withOpacity(0.12) : _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? _cyan.withOpacity(0.45) : _white.withOpacity(0.07)),
        ),
        child: Text(label, style: TextStyle(color: selected ? _cyan : _muted, fontSize: 12, fontWeight: FontWeight.w800)),
      ),
    );
  }

  Widget _ratingSummary() => Container(
        padding: const EdgeInsets.all(18),
        decoration: _adminDecoration(_yellow, radius: 22, opacity: 0.18),
        child: Row(
          children: [
            Column(
              children: [
                const Text('4.3', style: TextStyle(color: _white, fontSize: 42, fontWeight: FontWeight.w900)),
                Row(children: List.generate(5, (i) => Icon(i < 4 ? Icons.star_rounded : Icons.star_half_rounded, color: _yellow, size: 18))),
                const SizedBox(height: 4),
                const Text('58 reviews', style: TextStyle(color: _muted, fontSize: 11)),
              ],
            ),
            const SizedBox(width: 22),
            Expanded(
              child: Column(
                children: [5, 4, 3, 2, 1].map((star) {
                  const pcts = {5: 0.58, 4: 0.24, 3: 0.11, 2: 0.05, 1: 0.02};
                  final pct = pcts[star]!;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Text('$star', style: const TextStyle(color: _muted, fontSize: 11)),
                        const SizedBox(width: 7),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(value: pct, minHeight: 7, backgroundColor: _white.withOpacity(0.06), valueColor: const AlwaysStoppedAnimation(_yellow)),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text('${(pct * 100).round()}%', style: const TextStyle(color: _muted, fontSize: 10)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );

  Widget _feedbackTile(_RecentFeedback feedback) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: _adminDecoration(_cyan, radius: 18, opacity: 0.07),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(feedback.user, style: const TextStyle(color: _white, fontSize: 13, fontWeight: FontWeight.w900))),
                Row(children: List.generate(5, (i) => Icon(i < feedback.rating ? Icons.star_rounded : Icons.star_outline_rounded, color: _yellow, size: 14))),
              ],
            ),
            const SizedBox(height: 8),
            Text(feedback.comment, style: const TextStyle(color: _muted, fontSize: 12, height: 1.45)),
            const SizedBox(height: 8),
            Text(DateFormat('MMM d, yyyy').format(feedback.date), style: TextStyle(color: _muted.withOpacity(0.60), fontSize: 10)),
          ],
        ),
      );

  Widget _miniInsight(String label, String value, Color color, IconData icon) => Container(
        padding: const EdgeInsets.all(14),
        decoration: _adminDecoration(color, radius: 18, opacity: 0.15),
        child: Row(
          children: [
            Container(width: 34, height: 34, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 17)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: TextStyle(color: color, fontSize: 17, fontWeight: FontWeight.w900)),
                  Text(label, style: const TextStyle(color: _muted, fontSize: 10, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _squareButton(IconData icon, Color color, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.28))),
          child: Icon(icon, color: color, size: 20),
        ),
      );

  Widget _periodSelector() => PopupMenuButton<String>(
        color: _card,
        initialValue: _reportPeriod,
        onSelected: (value) => setState(() => _reportPeriod = value),
        itemBuilder: (_) => ['This Month', '3 Months', 'Year'].map((period) => PopupMenuItem(value: period, child: Text(period, style: const TextStyle(color: _white)))).toList(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(color: _field, borderRadius: BorderRadius.circular(12), border: Border.all(color: _white.withOpacity(0.08))),
          child: Row(
            children: [
              Text(_reportPeriod, style: const TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w800)),
              const SizedBox(width: 5),
              const Icon(Icons.keyboard_arrow_down_rounded, color: _muted, size: 16),
            ],
          ),
        ),
      );

  Widget _serviceAvatar(String icon, Color color) => Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.12), border: Border.all(color: color.withOpacity(0.35))),
        child: Center(child: Text(icon, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w900))),
      );

  void _showUserDetail(_AdminUser user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AdminSheet(
        title: 'User Detail',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _serviceAvatar(user.name[0], user.isActive ? _cyan : _muted),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name, style: const TextStyle(color: _white, fontSize: 18, fontWeight: FontWeight.w900)),
                      Text(user.email, style: const TextStyle(color: _muted, fontSize: 12)),
                    ],
                  ),
                ),
                _statusPill(user.isActive ? 'Active' : 'Inactive', user.isActive ? _green : _muted),
              ],
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _infoPill('Role', user.role, _cyan),
                _infoPill('Joined', DateFormat('MMM d, yyyy').format(user.joinedAt), _purple),
                _infoPill('Subscriptions', '${user.subscriptions}', _green),
                _infoPill('Monthly Spend', _currency.format(user.monthlySpend), _orange),
              ],
            ),
            const SizedBox(height: 20),
            const AdminSectionTitle('Subscriptions'),
            const SizedBox(height: 10),
            ...user.subscriptionsList.map(_subscriptionTile),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                AdminActionButton(icon: Icons.edit_rounded, label: 'Edit User', color: _cyan, onTap: () => _mockMessage('Edit user opened')),
                AdminActionButton(icon: Icons.lock_reset_rounded, label: 'Reset Password', color: _orange, onTap: () => _mockMessage('Password reset sent')),
                AdminActionButton(icon: user.isActive ? Icons.block_rounded : Icons.check_circle_rounded, label: user.isActive ? 'Deactivate' : 'Activate', color: user.isActive ? _orange : _green, onTap: () => _mockMessage('Status updated')),
                AdminActionButton(icon: Icons.delete_rounded, label: 'Delete User', color: _red, onTap: () => _confirmDanger('Delete user?', 'This mock action would remove ${user.name}.')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _subscriptionTile(_AdminSubscription sub) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: _field, borderRadius: BorderRadius.circular(16), border: Border.all(color: _white.withOpacity(0.06))),
        child: Row(
          children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(sub.service, style: const TextStyle(color: _white, fontSize: 13, fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text('${sub.plan} - ${DateFormat('MMM d').format(sub.renewsAt)}', style: const TextStyle(color: _muted, fontSize: 11)),
              ]),
            ),
            Text(_currency.format(sub.price), style: const TextStyle(color: _orange, fontSize: 12, fontWeight: FontWeight.w900)),
            const SizedBox(width: 8),
            _statusPill(sub.status, sub.status == 'Active' ? _green : _red),
          ],
        ),
      );

  Widget _infoPill(String label, String value, Color color) => Container(
        width: 142,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: color.withOpacity(0.09), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.18))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: _muted, fontSize: 10, fontWeight: FontWeight.w700)),
          const SizedBox(height: 5),
          Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w900), overflow: TextOverflow.ellipsis),
        ]),
      );

  void _showAddUserSheet() => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _AdminSheet(
          title: 'Add User',
          child: Column(
            children: [
              const _AdminTextField(label: 'Full name', icon: Icons.person_rounded),
              const SizedBox(height: 12),
              const _AdminTextField(label: 'Email address', icon: Icons.email_rounded),
              const SizedBox(height: 12),
              const _AdminTextField(label: 'Role', icon: Icons.badge_rounded),
              const SizedBox(height: 16),
              AdminActionButton(icon: Icons.person_add_alt_1_rounded, label: 'Create User', color: _orange, expanded: true, onTap: () => _mockMessage('User created locally')),
            ],
          ),
        ),
      );

  void _showServiceSheet({_AdminService? service}) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _AdminSheet(
          title: service == null ? 'Add Service' : 'Edit Service',
          child: Column(
            children: [
              _AdminTextField(label: 'Service name', icon: Icons.apps_rounded, initialValue: service?.name),
              const SizedBox(height: 12),
              _AdminTextField(label: 'Category', icon: Icons.category_rounded, initialValue: service?.category),
              const SizedBox(height: 12),
              _AdminTextField(label: 'Price', icon: Icons.attach_money_rounded, initialValue: service?.price.toStringAsFixed(2)),
              const SizedBox(height: 12),
              _AdminTextField(label: 'Billing cycle', icon: Icons.calendar_month_rounded, initialValue: service?.cycle),
              const SizedBox(height: 12),
              _AdminTextField(label: 'Logo/Icon', icon: Icons.image_rounded, initialValue: service?.icon),
              const SizedBox(height: 12),
              _AdminTextField(label: 'Description', icon: Icons.description_rounded, initialValue: service?.description, maxLines: 3),
              const SizedBox(height: 16),
              AdminActionButton(icon: Icons.save_rounded, label: service == null ? 'Create Service' : 'Save Service', color: _orange, expanded: true, onTap: () => _mockMessage('Service saved locally')),
            ],
          ),
        ),
      );

  void _showNotificationSheet() => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _AdminSheet(
          title: 'Send Push',
          child: Column(
            children: [
              const _AdminTextField(label: 'Notification title', icon: Icons.title_rounded),
              const SizedBox(height: 12),
              const _AdminTextField(label: 'Message', icon: Icons.message_rounded, maxLines: 3),
              const SizedBox(height: 12),
              const _AdminTextField(label: 'Target audience', icon: Icons.groups_rounded, initialValue: 'All active users'),
              const SizedBox(height: 16),
              AdminActionButton(icon: Icons.send_rounded, label: 'Send Notification', color: _orange, expanded: true, onTap: () => _mockMessage('Notification sent locally')),
            ],
          ),
        ),
      );

  void _confirmDanger(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22), side: BorderSide(color: _red.withOpacity(0.24))),
        title: Text(title, style: const TextStyle(color: _white, fontWeight: FontWeight.w900)),
        content: Text(message, style: const TextStyle(color: _muted)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: _muted))),
          TextButton(onPressed: () { Navigator.pop(context); _mockMessage('Mock delete complete'); }, child: const Text('Delete', style: TextStyle(color: _red, fontWeight: FontWeight.w900))),
        ],
      ),
    );
  }

  void _mockMessage(String message) {
    Navigator.maybePop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$message - backend pending'),
        backgroundColor: _card,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class AdminMetricCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final String trend;

  const AdminMetricCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(14),
      decoration: _adminDecoration(color, radius: 20, opacity: 0.16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 34, height: 34, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 17)),
          const Spacer(),
          Text(value, style: TextStyle(color: color, fontSize: 21, fontWeight: FontWeight.w900), maxLines: 1),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          Text(trend, style: TextStyle(color: _muted.withOpacity(0.65), fontSize: 9, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _AdminHeroIcon extends StatelessWidget {
  const _AdminHeroIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: _cyan.withOpacity(0.15),
        borderRadius: BorderRadius.circular(11),
      ),
      child: const Icon(Icons.account_balance_wallet_rounded, color: _cyan, size: 20),
    );
  }
}

class AdminChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const AdminChartCard({super.key, required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _adminDecoration(_cyan, radius: 22, opacity: 0.12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: _white, fontSize: 15, fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          Text(subtitle, style: const TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class AdminUserCard extends StatelessWidget {
  final _AdminUser user;
  final VoidCallback onTap;

  const AdminUserCard({super.key, required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: _adminDecoration(user.isActive ? _cyan : _muted, radius: 18, opacity: 0.09),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(shape: BoxShape.circle, color: (user.isActive ? _cyan : _muted).withOpacity(0.12), border: Border.all(color: (user.isActive ? _cyan : _muted).withOpacity(0.35))),
              child: Center(child: Text(user.name[0], style: TextStyle(color: user.isActive ? _cyan : _muted, fontSize: 18, fontWeight: FontWeight.w900))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(user.name, style: const TextStyle(color: _white, fontSize: 13, fontWeight: FontWeight.w900), overflow: TextOverflow.ellipsis)),
                      _statusPill(user.isActive ? 'Active' : 'Inactive', user.isActive ? _green : _muted),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(user.email, style: const TextStyle(color: _muted, fontSize: 11), overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 7),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _smallBadge('${user.subscriptions} subs', _purple),
                      _smallBadge('${_currency.format(user.monthlySpend)}/mo', _orange),
                      _smallBadge('Joined ${DateFormat('MMM yy').format(user.joinedAt)}', _muted),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: _white.withOpacity(0.25), size: 20),
          ],
        ),
      ),
    );
  }
}

class AdminServiceCard extends StatelessWidget {
  final _AdminService service;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const AdminServiceCard({
    super.key,
    required this.service,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = service.isActive ? _green : _muted;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: _adminDecoration(service.isActive ? _cyan : _muted, radius: 20, opacity: 0.10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(shape: BoxShape.circle, color: _cyan.withOpacity(0.12), border: Border.all(color: _cyan.withOpacity(0.28))), child: Center(child: Text(service.icon, style: const TextStyle(color: _cyan, fontSize: 18, fontWeight: FontWeight.w900)))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(service.name, style: const TextStyle(color: _white, fontSize: 14, fontWeight: FontWeight.w900), overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text('${service.category} - ${service.cycle}', style: const TextStyle(color: _muted, fontSize: 11), overflow: TextOverflow.ellipsis),
                ]),
              ),
              _statusPill(service.isActive ? 'Active' : 'Inactive', statusColor),
            ],
          ),
          const SizedBox(height: 12),
          Text(service.description, style: const TextStyle(color: _muted, fontSize: 12, height: 1.4)),
          const SizedBox(height: 12),
          Row(
            children: [
              _smallBadge('${_currency.format(service.price)}/mo', _orange),
              const SizedBox(width: 7),
              _smallBadge('${service.activeSubscribers} active', _cyan),
              const Spacer(),
              _iconAction(Icons.edit_rounded, _cyan, onEdit),
              _iconAction(service.isActive ? Icons.pause_circle_rounded : Icons.play_circle_rounded, _orange, onToggle),
              _iconAction(Icons.delete_rounded, _red, onDelete),
            ],
          ),
        ],
      ),
    );
  }
}

class AdminActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool expanded;

  const AdminActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: color.withOpacity(0.11), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.28))),
        child: Row(
          mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 7),
            Flexible(child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w900), overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class AdminActivityTile extends StatelessWidget {
  final _ActivityEvent event;

  const AdminActivityTile({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: _adminDecoration(event.color, radius: 18, opacity: 0.08),
      child: Row(
        children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: event.color.withOpacity(0.13), borderRadius: BorderRadius.circular(12)), child: Icon(event.icon, color: event.color, size: 17)),
          const SizedBox(width: 11),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(event.title, style: const TextStyle(color: _white, fontSize: 13, fontWeight: FontWeight.w900)),
              const SizedBox(height: 3),
              Text(event.detail, style: const TextStyle(color: _muted, fontSize: 11), overflow: TextOverflow.ellipsis),
            ]),
          ),
          Text(_relativeTime(event.date), style: TextStyle(color: _muted.withOpacity(0.65), fontSize: 10, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class AdminSectionTitle extends StatelessWidget {
  final String title;

  const AdminSectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(color: _white, fontSize: 15, fontWeight: FontWeight.w900));
  }
}

class _AdminSheet extends StatelessWidget {
  final String title;
  final Widget child;

  const _AdminSheet({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.45,
      maxChildSize: 0.94,
      builder: (_, controller) => Container(
        padding: EdgeInsets.fromLTRB(16, 10, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
        decoration: const BoxDecoration(color: _bg, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: ListView(
          controller: controller,
          children: [
            Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: _white.withOpacity(0.16), borderRadius: BorderRadius.circular(99)))),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: Text(title, style: const TextStyle(color: _white, fontSize: 20, fontWeight: FontWeight.w900))),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, color: _muted)),
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _AdminTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? initialValue;
  final int maxLines;

  const _AdminTextField({required this.label, required this.icon, this.initialValue, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      maxLines: maxLines,
      style: const TextStyle(color: _white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _muted, fontSize: 12),
        prefixIcon: Icon(icon, color: _cyan, size: 19),
        filled: true,
        fillColor: _field,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: _white.withOpacity(0.07))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: _cyan.withOpacity(0.42))),
      ),
    );
  }
}

BoxDecoration _adminDecoration(Color color, {double radius = 18, double opacity = 0.14}) => BoxDecoration(
      color: _card,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: color.withOpacity(opacity)),
      boxShadow: [BoxShadow(color: color.withOpacity(0.045), blurRadius: 22, offset: const Offset(0, 12))],
    );

Widget _statusPill(String label, Color color) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(999), border: Border.all(color: color.withOpacity(0.18))),
      child: Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900)),
    );

Widget _smallBadge(String label, Color color) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.10), borderRadius: BorderRadius.circular(9)),
      child: Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900)),
    );

Widget _trendPill(String label, Color color) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(999), border: Border.all(color: color.withOpacity(0.20))),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900)),
    );

Widget _iconAction(IconData icon, Color color, VoidCallback onTap) => IconButton(
      visualDensity: VisualDensity.compact,
      onPressed: onTap,
      icon: Icon(icon, color: color, size: 19),
    );

String _relativeTime(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  return '${diff.inDays}d';
}
