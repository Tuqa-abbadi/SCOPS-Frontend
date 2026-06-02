import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../blocs/notification/notification_model.dart';

// ── Notifications Screen ──────────────────────────────────────────────────
// TODO Sprint 4: connect to FCM + backend notification API.
// TODO Sprint 4: replace in-memory state with NotificationBloc.

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<NotificationModel> _notifications;

  static const _bg = Color(0xFF020812);
  static const _card = Color(0xFF07111C);
  static const _cyan = Color(0xFF18E8F2);
  static const _orange = Color(0xFFFF5A14);
  static const _white = Colors.white;
  static const _muted = Color(0xFF9BA4B0);

  @override
  void initState() {
    super.initState();
    _notifications = mockNotifications();
  }

  int get _unreadCount =>
      _notifications.where((n) => n.status == NotificationStatus.unread).length;

  void _markAllRead() => setState(() {
    _notifications = _notifications
        .map((n) => n.copyWith(status: NotificationStatus.read))
        .toList();
  });

  void _markRead(String id) => setState(() {
    _notifications = _notifications
        .map(
          (n) => n.id == id ? n.copyWith(status: NotificationStatus.read) : n,
        )
        .toList();
  });

  void _dismiss(String id) => setState(() {
    _notifications = _notifications.where((n) => n.id != id).toList();
  });

  Color _typeColor(NotificationType t) {
    switch (t) {
      case NotificationType.renewal:
        return _cyan;
      case NotificationType.payment:
        return const Color(0xFF22C55E);
      case NotificationType.system:
        return _muted;
      case NotificationType.promo:
        return _orange;
    }
  }

  IconData _typeIcon(NotificationType t) {
    switch (t) {
      case NotificationType.renewal:
        return Icons.schedule_rounded;
      case NotificationType.payment:
        return Icons.check_circle_rounded;
      case NotificationType.system:
        return Icons.info_outline_rounded;
      case NotificationType.promo:
        return Icons.local_offer_rounded;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(dt);
  }

  // Group notifications by Today / Yesterday / Earlier
  Map<String, List<NotificationModel>> _grouped() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yest = today.subtract(const Duration(days: 1));
    final groups = <String, List<NotificationModel>>{
      'Today': [],
      'Yesterday': [],
      'Earlier': [],
    };
    for (final n in _notifications) {
      final d = DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day);
      if (d == today) {
        groups['Today']!.add(n);
      } else if (d == yest)
        groups['Yesterday']!.add(n);
      else
        groups['Earlier']!.add(n);
    }
    groups.removeWhere((_, v) => v.isEmpty);
    return groups;
  }

  Widget _notifTile(NotificationModel n) {
    final color = _typeColor(n.type);
    final isUnread = n.status == NotificationStatus.unread;

    return Dismissible(
      key: Key(n.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _dismiss(n.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: _orange.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: _orange),
      ),
      child: GestureDetector(
        onTap: () {
          _markRead(n.id);
          // TODO Sprint 4: navigate to subscription if subscriptionId != null
          // if (n.subscriptionId != null) { ... }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isUnread ? _card.withOpacity(1) : _card.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isUnread
                  ? color.withOpacity(0.30)
                  : Colors.white.withOpacity(0.06),
            ),
            boxShadow: isUnread
                ? [BoxShadow(color: color.withOpacity(0.08), blurRadius: 16)]
                : [],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon pill
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: n.serviceIcon != null
                          ? Text(
                              n.serviceIcon!,
                              style: const TextStyle(fontSize: 20),
                            )
                          : Icon(_typeIcon(n.type), color: color, size: 20),
                    ),
                    if (isUnread)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.5),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
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
                            n.title,
                            style: TextStyle(
                              color: _white,
                              fontSize: 13,
                              fontWeight: isUnread
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          _timeAgo(n.createdAt),
                          style: TextStyle(
                            color: isUnread ? color : _muted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      n.body,
                      style: TextStyle(
                        color: isUnread ? _muted : _muted.withOpacity(0.65),
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                    if (n.subscriptionId != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'View subscription →',
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groups = _grouped();

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notifications',
                        style: TextStyle(
                          color: _white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (_unreadCount > 0)
                        Text(
                          '$_unreadCount unread',
                          style: const TextStyle(color: _cyan, fontSize: 13),
                        ),
                    ],
                  ),
                  const Spacer(),
                  if (_unreadCount > 0)
                    TextButton(
                      onPressed: _markAllRead,
                      child: const Text(
                        'Mark all read',
                        style: TextStyle(
                          color: _cyan,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // List
            Expanded(
              child: _notifications.isEmpty
                  ? _emptyState()
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        for (final entry in groups.entries) ...[
                          _groupHeader(entry.key),
                          ...entry.value.map(_notifTile),
                          const SizedBox(height: 8),
                        ],
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            'Swipe left to dismiss',
                            style: TextStyle(
                              color: _muted.withOpacity(0.45),
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _groupHeader(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 10, top: 4),
    child: Text(
      label.toUpperCase(),
      style: TextStyle(
        color: _muted.withOpacity(0.60),
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
    ),
  );

  Widget _emptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: _card,
            shape: BoxShape.circle,
            border: Border.all(color: _cyan.withOpacity(0.20)),
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: _muted,
            size: 34,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'All caught up!',
          style: TextStyle(
            color: _white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'No notifications yet',
          style: TextStyle(color: _muted, fontSize: 13),
        ),
      ],
    ),
  );
}
