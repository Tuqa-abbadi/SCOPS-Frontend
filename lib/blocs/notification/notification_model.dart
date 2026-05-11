// ── Notification Model ────────────────────────────────────────────────────
// TODO Sprint 4: replace mockNotifications() with real API call.

enum NotificationType { renewal, payment, system, promo }
enum NotificationStatus { unread, read }

class NotificationModel {
  final String id;
  final NotificationType type;
  final NotificationStatus status;
  final String title;
  final String body;
  final DateTime createdAt;
  final String? subscriptionId;
  final String? serviceIcon;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.status,
    required this.title,
    required this.body,
    required this.createdAt,
    this.subscriptionId,
    this.serviceIcon,
  });

  NotificationModel copyWith({NotificationStatus? status}) => NotificationModel(
        id: id, type: type,
        status: status ?? this.status,
        title: title, body: body, createdAt: createdAt,
        subscriptionId: subscriptionId, serviceIcon: serviceIcon,
      );
}

List<NotificationModel> mockNotifications() {
  final now = DateTime.now();
  return [
    NotificationModel(id: '1', type: NotificationType.renewal,
      status: NotificationStatus.unread,
      title: 'Netflix renews in 3 days',
      body: 'Your Netflix Premium plan (\$13.98) renews on ${_d(now.add(const Duration(days: 3)))}.',
      createdAt: now.subtract(const Duration(hours: 2)),
      subscriptionId: 'sub_netflix', serviceIcon: '🎬'),
    NotificationModel(id: '2', type: NotificationType.payment,
      status: NotificationStatus.unread,
      title: 'Spotify payment successful',
      body: 'Your Spotify Individual plan was charged \$9.99.',
      createdAt: now.subtract(const Duration(hours: 5)),
      subscriptionId: 'sub_spotify', serviceIcon: '🎵'),
    NotificationModel(id: '3', type: NotificationType.renewal,
      status: NotificationStatus.read,
      title: 'Adobe CC renews soon',
      body: 'Adobe All Apps (\$21.98) renews in 7 days.',
      createdAt: now.subtract(const Duration(days: 1)),
      subscriptionId: 'sub_adobe', serviceIcon: '🎨'),
    NotificationModel(id: '4', type: NotificationType.system,
      status: NotificationStatus.read,
      title: 'Welcome to SCOPS!',
      body: 'Start tracking your subscriptions and never miss a payment again.',
      createdAt: now.subtract(const Duration(days: 3))),
    NotificationModel(id: '5', type: NotificationType.payment,
      status: NotificationStatus.read,
      title: 'iCloud+ payment successful',
      body: 'Your iCloud+ 200GB plan was charged \$1.49.',
      createdAt: now.subtract(const Duration(days: 5)), serviceIcon: '☁️'),
    NotificationModel(id: '6', type: NotificationType.promo,
      status: NotificationStatus.read,
      title: 'New services available',
      body: 'Disney+ and YouTube Premium are now in the services browser.',
      createdAt: now.subtract(const Duration(days: 7))),
  ];
}

String _d(DateTime d) => '${d.day}/${d.month}/${d.year}';