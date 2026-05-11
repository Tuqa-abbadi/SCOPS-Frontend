import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ── Admin Dashboard Screen ────────────────────────────────────────────────
//
// HOW TO OPEN (no backend integration yet):
//   Add this anywhere in your app — e.g. a hidden tap in ProfileScreen:
//
//   GestureDetector(
//     onLongPress: () => Navigator.push(context,
//       MaterialPageRoute(builder: (_) => const AdminDashboardScreen())),
//     child: Text('v1.0.0', ...),
//   )
//
//   Or add a direct route in your router for testing:
//   '/admin': (_) => const AdminDashboardScreen()
//
// TODO Sprint 4: wrap with admin role check before navigation.
// TODO Sprint 4: replace all mock data with real API calls.
// TODO Sprint 4: add authentication guard (admin JWT scope).

// ── Mock Admin Data ───────────────────────────────────────────────────────
// Replace each section with its API endpoint when backend is ready.

class _AdminStats {
  // TODO: GET /admin/stats
  static const totalUsers         = 1_247;
  static const activeUsers        = 893;
  static const totalSubscriptions = 4_821;
  static const monthlyRevenue     = 38_492.50;
  static const churnRate          = 3.2;      // %
  static const avgSubsPerUser     = 3.9;
}

class _AdminUser {
  final String id;
  final String name;
  final String email;
  final int subscriptions;
  final double monthlySpend;
  final DateTime joinedAt;
  final bool isActive;
  const _AdminUser({required this.id, required this.name, required this.email,
      required this.subscriptions, required this.monthlySpend,
      required this.joinedAt, required this.isActive});
}

// TODO: GET /admin/users?page=1&limit=10&sort=spend_desc
final _mockUsers = [
  _AdminUser(id: 'u1', name: 'Alex Architect', email: 'alex@scops.app',
      subscriptions: 7, monthlySpend: 124.50, joinedAt: DateTime(2024, 9, 1), isActive: true),
  _AdminUser(id: 'u2', name: 'Sara Builder', email: 'sara@scops.app',
      subscriptions: 5, monthlySpend: 87.20, joinedAt: DateTime(2024, 10, 15), isActive: true),
  _AdminUser(id: 'u3', name: 'Omar Dev', email: 'omar@scops.app',
      subscriptions: 3, monthlySpend: 42.00, joinedAt: DateTime(2024, 11, 3), isActive: false),
  _AdminUser(id: 'u4', name: 'Lena Manager', email: 'lena@scops.app',
      subscriptions: 9, monthlySpend: 210.80, joinedAt: DateTime(2024, 8, 20), isActive: true),
];

class _RecentFeedback {
  final String user;
  final int rating;
  final String comment;
  final DateTime date;
  const _RecentFeedback({required this.user, required this.rating,
      required this.comment, required this.date});
}

// TODO: GET /admin/feedback?limit=5
final _mockFeedback = [
  _RecentFeedback(user: 'Alex A.', rating: 5,
      comment: 'Love the design, very intuitive!', date: DateTime.now().subtract(const Duration(hours: 3))),
  _RecentFeedback(user: 'Sara B.', rating: 4,
      comment: 'Great app. Would love dark widgets.', date: DateTime.now().subtract(const Duration(days: 1))),
  _RecentFeedback(user: 'Omar D.', rating: 3,
      comment: 'Notifications sometimes late.', date: DateTime.now().subtract(const Duration(days: 2))),
];

// ── Screen ────────────────────────────────────────────────────────────────

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  static const _bg     = Color(0xFF020812);
  static const _card   = Color(0xFF07111C);
  static const _cyan   = Color(0xFF18E8F2);
  static const _orange = Color(0xFFFF5A14);
  static const _purple = Color(0xFFA855F7);
  static const _green  = Color(0xFF22C55E);
  static const _white  = Colors.white;
  static const _muted  = Color(0xFF9BA4B0);

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
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
                  _feedbackTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────
  Widget _header() => Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 20, 0),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: _white, size: 20),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _orange.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _orange.withOpacity(0.35)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_rounded, color: _orange, size: 14),
                  SizedBox(width: 5),
                  Text('ADMIN', style: TextStyle(
                      color: _orange, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Text('Dashboard',
                style: TextStyle(color: _white, fontSize: 20, fontWeight: FontWeight.w900)),
            const Spacer(),
            // TODO Sprint 4: real-time refresh button
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('API integration pending — Sprint 4'),
                  backgroundColor: _card,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ));
              },
              icon: const Icon(Icons.refresh_rounded, color: _muted),
            ),
          ],
        ),
      );

  // ── Tabs ─────────────────────────────────────────────────────────────────
  Widget _tabs() => TabBar(
        controller: _tabCtrl,
        labelColor: _cyan,
        unselectedLabelColor: _muted,
        indicatorColor: _cyan,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Users'),
          Tab(text: 'Feedback'),
        ],
      );

  // ── Overview Tab ──────────────────────────────────────────────────────────
  Widget _overviewTab() => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // API status banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _orange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _orange.withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: _orange, size: 16),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Showing mock data. API integration available in Sprint 4.',
                      style: TextStyle(color: _orange, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _sectionLabel('Key Metrics'),
            const SizedBox(height: 12),

            // KPI Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.25,
              children: [
                _kpiCard('${_AdminStats.totalUsers.toString()}',
                    'Total Users', Icons.people_rounded, _cyan,
                    sub: '+12% this month'),
                _kpiCard('${_AdminStats.activeUsers}',
                    'Active Users', Icons.person_rounded, _green,
                    sub: '${((_AdminStats.activeUsers / _AdminStats.totalUsers) * 100).toStringAsFixed(0)}% retention'),
                _kpiCard('\$${(_AdminStats.monthlyRevenue / 1000).toStringAsFixed(1)}k',
                    'Monthly Revenue', Icons.attach_money_rounded, _orange,
                    sub: 'Estimated MRR'),
                _kpiCard('${_AdminStats.totalSubscriptions}',
                    'Subscriptions', Icons.subscriptions_rounded, _purple,
                    sub: '${_AdminStats.avgSubsPerUser} avg/user'),
              ],
            ),
            const SizedBox(height: 24),

            // Secondary stats row
            Row(children: [
              _miniStat('${_AdminStats.churnRate}%', 'Churn Rate', _orange),
              const SizedBox(width: 12),
              _miniStat('${_AdminStats.avgSubsPerUser}', 'Avg Subs/User', _cyan),
              const SizedBox(width: 12),
              _miniStat('${(_AdminStats.activeUsers / _AdminStats.totalUsers * 100).toStringAsFixed(0)}%',
                  'Retention', _green),
            ]),
            const SizedBox(height: 28),

            _sectionLabel('Top Services (mock)'),
            const SizedBox(height: 12),
            // TODO Sprint 4: GET /admin/analytics/top-services
            ...[
              ('🎬', 'Netflix',     342, 0.85),
              ('🎵', 'Spotify',     298, 0.74),
              ('🎨', 'Adobe CC',    187, 0.46),
              ('📺', 'YouTube',     156, 0.39),
              ('☁️', 'iCloud+',     134, 0.33),
            ].map((e) => _serviceBar(e.$1, e.$2, e.$3, e.$4)),
            const SizedBox(height: 28),

            _sectionLabel('Quick Actions'),
            const SizedBox(height: 12),
            // TODO Sprint 4: wire each action to its API
            Wrap(
              spacing: 10, runSpacing: 10,
              children: [
                _actionChip(Icons.download_rounded, 'Export CSV', _cyan),
                _actionChip(Icons.notifications_active_rounded, 'Send Push', _orange),
                _actionChip(Icons.people_rounded, 'Manage Users', _purple),
                _actionChip(Icons.bar_chart_rounded, 'Full Analytics', _green),
                _actionChip(Icons.settings_rounded, 'App Config', _muted),
              ],
            ),
          ],
        ),
      );

  // ── Users Tab ─────────────────────────────────────────────────────────────
  Widget _usersTab() => Column(
        children: [
          // Search bar — TODO Sprint 4: wire to GET /admin/users?search=query
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: TextField(
                style: const TextStyle(color: _white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search users... (API pending)',
                  hintStyle: TextStyle(color: _muted.withOpacity(0.55), fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded, color: _muted, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Filter chips — TODO Sprint 4: filter params for API
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: ['All', 'Active', 'Inactive', 'High Spend']
                  .map((f) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: f == 'All' ? _cyan.withOpacity(0.12) : _card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: f == 'All' ? _cyan.withOpacity(0.40) : Colors.white.withOpacity(0.07)),
                        ),
                        child: Text(f,
                            style: TextStyle(
                                color: f == 'All' ? _cyan : _muted,
                                fontSize: 12, fontWeight: FontWeight.w600)),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _mockUsers.length,
              itemBuilder: (_, i) => _userTile(_mockUsers[i]),
            ),
          ),
        ],
      );

  Widget _userTile(_AdminUser u) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _cyan.withOpacity(0.12),
                border: Border.all(
                    color: u.isActive ? _cyan.withOpacity(0.35) : Colors.white.withOpacity(0.08)),
              ),
              child: Center(
                child: Text(u.name[0],
                    style: TextStyle(
                        color: u.isActive ? _cyan : _muted,
                        fontSize: 18, fontWeight: FontWeight.w900)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(u.name,
                          style: const TextStyle(
                              color: _white, fontSize: 13, fontWeight: FontWeight.w800)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: (u.isActive ? _green : _muted).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(u.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                                color: u.isActive ? _green : _muted,
                                fontSize: 9, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(u.email, style: const TextStyle(color: _muted, fontSize: 11)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      _userBadge('${u.subscriptions} subs', _purple),
                      const SizedBox(width: 6),
                      _userBadge('\$${u.monthlySpend.toStringAsFixed(0)}/mo', _orange),
                      const SizedBox(width: 6),
                      _userBadge('Joined ${DateFormat('MMM yy').format(u.joinedAt)}', _muted),
                    ],
                  ),
                ],
              ),
            ),
            // TODO Sprint 4: tap to open user detail / manage
            Icon(Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.25), size: 20),
          ],
        ),
      );

  // ── Feedback Tab ──────────────────────────────────────────────────────────
  Widget _feedbackTab() => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating summary — TODO Sprint 4: GET /admin/feedback/summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _cyan.withOpacity(0.18)),
              ),
              child: Row(
                children: [
                  Column(
                    children: [
                      const Text('4.2',
                          style: TextStyle(color: _white, fontSize: 42, fontWeight: FontWeight.w900)),
                      Row(
                        children: List.generate(5, (i) => Icon(
                          i < 4 ? Icons.star_rounded : Icons.star_half_rounded,
                          color: const Color(0xFFFFB020), size: 18)),
                      ),
                      const SizedBox(height: 4),
                      const Text('42 reviews',
                          style: TextStyle(color: _muted, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      children: [5, 4, 3, 2, 1].map((star) {
                        // TODO Sprint 4: real distribution from API
                        const pcts = {5: 0.55, 4: 0.25, 3: 0.12, 2: 0.05, 1: 0.03};
                        final pct = pcts[star]!;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Row(
                            children: [
                              Text('$star', style: const TextStyle(color: _muted, fontSize: 11)),
                              const SizedBox(width: 6),
                              const Icon(Icons.star_rounded,
                                  color: Color(0xFFFFB020), size: 11),
                              const SizedBox(width: 6),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: pct,
                                    backgroundColor: Colors.white.withOpacity(0.06),
                                    valueColor: const AlwaysStoppedAnimation(Color(0xFFFFB020)),
                                    minHeight: 6,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text('${(pct * 100).toInt()}%',
                                  style: const TextStyle(color: _muted, fontSize: 10)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _sectionLabel('Recent Feedback'),
            const SizedBox(height: 12),
            ..._mockFeedback.map(_feedbackTile),
          ],
        ),
      );

  Widget _feedbackTile(_RecentFeedback f) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(f.user,
                    style: const TextStyle(
                        color: _white, fontSize: 13, fontWeight: FontWeight.w800)),
                const Spacer(),
                Row(
                  children: List.generate(5, (i) => Icon(
                    i < f.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: const Color(0xFFFFB020), size: 14)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(f.comment,
                style: const TextStyle(color: _muted, fontSize: 12, height: 1.45)),
            const SizedBox(height: 6),
            Text(DateFormat('MMM d, yyyy').format(f.date),
                style: TextStyle(color: _muted.withOpacity(0.55), fontSize: 10)),
          ],
        ),
      );

  // ── Reusable widgets ─────────────────────────────────────────────────────
  Widget _sectionLabel(String t) => Text(t,
      style: const TextStyle(
          color: _white, fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 0.2));

  Widget _kpiCard(String val, String label, IconData icon, Color color,
      {String? sub}) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.22)),
          boxShadow: [BoxShadow(color: color.withOpacity(0.06), blurRadius: 20)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 10),
            Text(val,
                style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: _muted, fontSize: 11),
                overflow: TextOverflow.ellipsis),
            if (sub != null) ...[
              const SizedBox(height: 2),
              Text(sub,
                  style: TextStyle(color: _muted.withOpacity(0.55), fontSize: 9),
                  overflow: TextOverflow.ellipsis),
            ],
          ],
        ),
      );

  Widget _miniStat(String val, String label, Color color) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.18)),
          ),
          child: Column(
            children: [
              Text(val, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _muted, fontSize: 9)),
            ],
          ),
        ),
      );

  Widget _serviceBar(String icon, String name, int count, double pct) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            SizedBox(
              width: 100,
              child: Text(name,
                  style: const TextStyle(color: _white, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: pct,
                  backgroundColor: Colors.white.withOpacity(0.05),
                  valueColor: AlwaysStoppedAnimation(_cyan.withOpacity(0.75)),
                  minHeight: 8,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text('$count', style: const TextStyle(color: _muted, fontSize: 11)),
          ],
        ),
      );

  Widget _actionChip(IconData icon, String label, Color color) => GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('$label — API integration in Sprint 4'),
            backgroundColor: _card,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 15),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      );

  Widget _userBadge(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w700)),
      );
}