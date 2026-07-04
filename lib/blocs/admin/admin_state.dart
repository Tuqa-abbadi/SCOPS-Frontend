part of 'admin_bloc.dart';

// ── Data models ───────────────────────────────────────────────────────────────

class AdminStatisticsModel {
  const AdminStatisticsModel({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalServices,
    required this.totalSubscriptions,
    required this.activeSubscriptions,
    this.monthlyRevenue,
    this.churnRate,
    this.retentionRate,
  });

  final int totalUsers;
  final int activeUsers;
  final int totalServices;
  final int totalSubscriptions;
  final int activeSubscriptions;
  final double? monthlyRevenue;
  final double? churnRate;
  final double? retentionRate;

  static int _i(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static double? _d(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  factory AdminStatisticsModel.fromJson(Map<String, dynamic> json) =>
      AdminStatisticsModel(
        totalUsers: _i(json['total_users'] ?? json['users_count'] ?? json['users']),
        activeUsers: _i(json['active_users'] ?? json['active_users_count']),
        totalServices: _i(json['total_services'] ?? json['services_count'] ?? json['services']),
        totalSubscriptions: _i(
          json['total_subscriptions'] ?? json['subscriptions_count'] ?? json['subscriptions'],
        ),
        activeSubscriptions: _i(
          json['active_subscriptions'] ?? json['active_subscriptions_count'],
        ),
        monthlyRevenue: _d(
          json['monthly_revenue'] ?? json['total_revenue'] ?? json['revenue'],
        ),
        churnRate: _d(json['churn_rate']),
        retentionRate: _d(json['retention_rate']),
      );
}

// ─────────────────────────────────────────────────────────────────────────────

class AdminUserModel extends Equatable {
  const AdminUserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.isActive,
    this.phone,
    this.createdAt,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final bool isActive;
  final String? phone;
  final DateTime? createdAt;

  String get fullName => '$firstName $lastName'.trim();
  String get initials => fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';

  static bool _parseBool(dynamic v, {String? statusField}) {
    if (v is bool) return v;
    if (v is int) return v != 0;
    if (v is String) {
      final s = v.toLowerCase();
      return s == '1' || s == 'true' || s == 'active';
    }
    if (statusField is String) return statusField.toLowerCase() == 'active';
    return true;
  }

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? json['user_id'] ?? json['uuid'] ?? '').toString();

    final isActive = _parseBool(
      json['is_active'] ?? json['active'],
      statusField: json['status']?.toString(),
    );

    return AdminUserModel(
      id: id,
      firstName: json['first_name'] as String? ?? json['firstName'] as String? ?? '',
      lastName: json['last_name'] as String? ?? json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      isActive: isActive,
      phone: json['phone'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  @override
  List<Object?> get props => [id, email, isActive, role];
}

// ─────────────────────────────────────────────────────────────────────────────

class AdminServiceModel extends Equatable {
  const AdminServiceModel({
    required this.id,
    required this.name,
    required this.defaultAmount,
    required this.billingCycle,
    required this.description,
    this.categoryId,
    this.categoryName = '',
    this.logoUrl,
  });

  final int id;
  final String name;
  final double defaultAmount;
  final String billingCycle;
  final String description;
  final int? categoryId;
  final String categoryName;
  final String? logoUrl;

  String get initials => name.isNotEmpty ? name[0].toUpperCase() : '?';

  static double _d(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  factory AdminServiceModel.fromJson(Map<String, dynamic> json) {
    int id = 0;
    final rawId = json['id'];
    if (rawId is int) id = rawId;
    if (rawId is String) id = int.tryParse(rawId) ?? 0;

    int? catId;
    final rawCatId = json['category_id'];
    if (rawCatId is int) catId = rawCatId;
    if (rawCatId is String) catId = int.tryParse(rawCatId);

    // category name may be nested { "category": { "name": "..." } } or flat
    String catName = '';
    final catField = json['category'];
    if (catField is Map) {
      catName = catField['name']?.toString() ?? '';
    } else if (catField is String) {
      catName = catField;
    }
    catName = catName.isNotEmpty
        ? catName
        : (json['category_name'] as String? ?? '');

    return AdminServiceModel(
      id: id,
      name: json['name'] as String? ?? '',
      defaultAmount: _d(json['default_amount'] ?? json['price'] ?? json['amount']),
      billingCycle: _capitalizeCycle(
        json['billing_cycle'] as String? ?? json['billingCycle'] as String? ?? 'monthly',
      ),
      description: json['description'] as String? ?? '',
      categoryId: catId,
      categoryName: catName,
      logoUrl: resolveLogoUrlFromJson(json),
    );
  }

  static String _capitalizeCycle(String cycle) {
    switch (cycle.toLowerCase()) {
      case 'weekly': return 'Weekly';
      case 'yearly': return 'Yearly';
      default: return 'Monthly';
    }
  }

  @override
  List<Object?> get props => [id, name, defaultAmount, billingCycle];
}

// ─────────────────────────────────────────────────────────────────────────────

class AdminUserSubscriptionModel extends Equatable {
  const AdminUserSubscriptionModel({
    required this.id,
    required this.serviceName,
    this.serviceLogoUrl,
    required this.plan,
    required this.amount,
    required this.billingCycle,
    required this.status,
    this.renewalDate,
    this.cardInfo,
  });

  final int id;
  final String serviceName;
  final String? serviceLogoUrl;
  final String plan;
  final double amount;
  final String billingCycle;
  final String status;
  final DateTime? renewalDate;
  final String? cardInfo;

  bool get isActive => status.toLowerCase() == 'active';

  static double _d(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  factory AdminUserSubscriptionModel.fromJson(Map<String, dynamic> json) {
    int id = 0;
    final rawId = json['id'];
    if (rawId is int) id = rawId;
    if (rawId is String) id = int.tryParse(rawId) ?? 0;

    // Resolve service name from nested or flat
    String serviceName = '';
    String? serviceLogoUrl;
    final svcField = json['service'];
    if (svcField is Map) {
      serviceName = svcField['name']?.toString() ?? '';
      serviceLogoUrl = resolveLogoUrlFromJson(
        svcField.map((k, v) => MapEntry(k.toString(), v)),
      );
    }
    if (serviceName.isEmpty) {
      serviceName = json['service_name'] as String? ?? 'Service #${json['service_id'] ?? id}';
    }
    serviceLogoUrl ??= resolveLogoUrlFromJson(json);

    // Plan name
    String plan = json['plan_name'] as String? ?? '';
    if (plan.isEmpty) {
      final planField = json['plan'];
      if (planField is Map) {
        plan = planField['plan_name']?.toString() ?? planField['name']?.toString() ?? '';
      } else if (planField is String) {
        plan = planField;
      }
    }
    if (plan.isEmpty) plan = 'Standard';

    // Card info
    String? cardInfo;
    final cardField = json['card'];
    if (cardField is Map) {
      final masked = cardField['masked_pan'] ?? cardField['card_number'];
      if (masked != null) cardInfo = masked.toString();
    }
    cardInfo ??= json['card_info'] as String?;

    return AdminUserSubscriptionModel(
      id: id,
      serviceName: serviceName,
      serviceLogoUrl: serviceLogoUrl,
      plan: plan,
      amount: _d(json['amount']),
      billingCycle: AdminServiceModel._capitalizeCycle(
        json['billing_cycle'] as String? ?? 'monthly',
      ),
      status: json['status'] as String? ?? 'active',
      renewalDate: json['renewal_date'] != null
          ? DateTime.tryParse(json['renewal_date'].toString())
          : null,
      cardInfo: cardInfo,
    );
  }

  @override
  List<Object?> get props => [id, serviceName, serviceLogoUrl, status];
}

// ─────────────────────────────────────────────────────────────────────────────

class AdminCategoryModel extends Equatable {
  const AdminCategoryModel({required this.id, required this.name});

  final int id;
  final String name;

  factory AdminCategoryModel.fromJson(Map<String, dynamic> json) {
    int id = 0;
    final rawId = json['id'];
    if (rawId is int) id = rawId;
    if (rawId is String) id = int.tryParse(rawId) ?? 0;
    return AdminCategoryModel(
      id: id,
      name: json['name'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name];
}

// ── States ────────────────────────────────────────────────────────────────────

abstract class AdminState extends Equatable {
  const AdminState();
  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {
  const AdminInitial();
}

class AdminLoading extends AdminState {
  const AdminLoading();
}

class AdminData extends AdminState {
  const AdminData({
    this.statistics,
    this.users = const [],
    this.services = const [],
    this.categories = const [],
    this.isActionLoading = false,
    this.actionError,
    this.actionSuccess,
    this.viewingUserId,
    this.viewingUserSubscriptions = const [],
    this.subscriptionsLoading = false,
  });

  final AdminStatisticsModel? statistics;
  final List<AdminUserModel> users;
  final List<AdminServiceModel> services;
  final List<AdminCategoryModel> categories;
  final bool isActionLoading;
  final String? actionError;
  final String? actionSuccess;
  final String? viewingUserId;
  final List<AdminUserSubscriptionModel> viewingUserSubscriptions;
  final bool subscriptionsLoading;

  AdminData copyWith({
    AdminStatisticsModel? statistics,
    List<AdminUserModel>? users,
    List<AdminServiceModel>? services,
    List<AdminCategoryModel>? categories,
    bool? isActionLoading,
    String? actionError,
    String? actionSuccess,
    String? viewingUserId,
    List<AdminUserSubscriptionModel>? viewingUserSubscriptions,
    bool? subscriptionsLoading,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearViewingUser = false,
  }) =>
      AdminData(
        statistics: statistics ?? this.statistics,
        users: users ?? this.users,
        services: services ?? this.services,
        categories: categories ?? this.categories,
        isActionLoading: isActionLoading ?? this.isActionLoading,
        actionError: clearError ? null : actionError ?? this.actionError,
        actionSuccess: clearSuccess ? null : actionSuccess ?? this.actionSuccess,
        viewingUserId: clearViewingUser ? null : viewingUserId ?? this.viewingUserId,
        viewingUserSubscriptions: viewingUserSubscriptions ?? this.viewingUserSubscriptions,
        subscriptionsLoading: subscriptionsLoading ?? this.subscriptionsLoading,
      );

  @override
  List<Object?> get props => [
        statistics,
        users,
        services,
        categories,
        isActionLoading,
        actionError,
        actionSuccess,
        viewingUserId,
        viewingUserSubscriptions,
        subscriptionsLoading,
      ];
}

class AdminError extends AdminState {
  const AdminError({required this.message});
  final String message;
  @override
  List<Object?> get props => [message];
}
