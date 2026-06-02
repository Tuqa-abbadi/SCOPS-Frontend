part of 'services_bloc.dart';

// ── Service model ──────────────────────────────────────────────────────────────
class ServiceModel extends Equatable {
  const ServiceModel({
    required this.id,
    required this.name,
    required this.category,
    this.categoryId,
    this.logoUrl,
    required this.icon,
    required this.description,
    required this.plans,
    required this.startingPrice,
    required this.billingCycle,
    required this.color,
  });

  final String id;
  final String name;
  final String category;
  final int? categoryId;

  /// Network image URL from the backend (logo_url). Null if not set.
  final String? logoUrl;

  /// Emoji fallback icon when logoUrl is absent.
  final String icon;

  final String description;

  /// String plan names from the list-endpoint response (e.g. ["Basic", "Pro"]).
  /// Rich ServicePlan objects come from the detail endpoint and live in
  /// ServicesDataLoaded.detailPlans.
  final List<String> plans;

  /// Mapped from backend field: default_amount.
  final double startingPrice;

  /// Billing cycle from backend: "monthly", "weekly", or "yearly".
  final String billingCycle;

  final Color color;

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    // The backend embeds the full category object: { id, name, description, ... }
    // _extractCategoryName handles both a plain String and a nested Map.
    final category = _extractCategoryName(json['category']) ??
        json['category_name'] as String? ??
        '';
    return ServiceModel(
      id: (json['id'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      category: category,
      // Use safe int parsing — backend may send integers as strings or doubles.
      categoryId: _parseInt(json['category_id']),
      logoUrl: resolveLogoUrlFromJson(json),
      icon: json['icon'] as String? ?? '📦',
      description: json['description'] as String? ?? '',
      plans: _parsePlans(json['plans']),
      // Accept default_amount (real API), starting_price, or price (legacy).
      startingPrice: _parsePrice(
          json['default_amount'] ?? json['starting_price'] ?? json['price']),
      billingCycle: json['billing_cycle'] as String? ?? 'monthly',
      color: _colorFor(category),
    );
  }

  /// Handles both a plain category string and the embedded object the backend
  /// returns: { "id": 2, "name": "Music", "description": null, ... }
  static String? _extractCategoryName(dynamic raw) {
    if (raw is String) return raw.isEmpty ? null : raw;
    if (raw is Map) return raw['name'] as String?;
    return null;
  }

  ServiceModel copyWith({String? category, Color? color}) {
    return ServiceModel(
      id: id,
      name: name,
      category: category ?? this.category,
      categoryId: categoryId,
      logoUrl: logoUrl,
      icon: icon,
      description: description,
      plans: plans,
      startingPrice: startingPrice,
      billingCycle: billingCycle,
      color: color ?? this.color,
    );
  }

  // ── Type-safe helpers ────────────────────────────────────────────────────────

  static int? _parseInt(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is double) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  static List<String> _parsePlans(dynamic raw) {
    if (raw is List) return raw.map((e) => e.toString()).toList();
    return [];
  }

  static double _parsePrice(dynamic raw) {
    if (raw == null) return 0;
    if (raw is double) return raw;
    if (raw is int) return raw.toDouble();
    if (raw is String) return double.tryParse(raw) ?? 0;
    return 0;
  }

  static Color _colorFor(String category) {
    final c = category.toLowerCase();
    if (c.contains('entertain') || c.contains('stream') || c.contains('video')) {
      return const Color(0xFFE50914);
    }
    if (c.contains('music') || c.contains('audio') || c.contains('sound')) {
      return const Color(0xFF1DB954);
    }
    if (c.contains('product') || c.contains('work') || c.contains('office')) {
      return const Color(0xFF0078D4);
    }
    if (c.contains('cloud') || c.contains('storage')) {
      return const Color(0xFF0071E3);
    }
    if (c.contains('dev') || c.contains('code') || c.contains('tech')) {
      return const Color(0xFF6E40C9);
    }
    if (c.contains('design') || c.contains('creat') || c.contains('art')) {
      return const Color(0xFFF24E1E);
    }
    if (c.contains('ai') || c.contains('intelligen')) {
      return const Color(0xFF38BDF8);
    }
    if (c.contains('game') || c.contains('gaming')) {
      return const Color(0xFF84CC16);
    }
    if (c.contains('fit') || c.contains('health') || c.contains('sport')) {
      return const Color(0xFFF43F5E);
    }
    if (c.contains('financ') || c.contains('bank') || c.contains('money')) {
      return const Color(0xFF14B8A6);
    }
    return const Color(0xFF1DD8E8);
  }

  @override
  List<Object?> get props => [id];
}

// ── States ─────────────────────────────────────────────────────────────────────
abstract class ServicesState extends Equatable {
  const ServicesState();

  @override
  List<Object?> get props => [];
}

class ServicesInitial extends ServicesState {
  const ServicesInitial();
}

// Full-page loading on first fetch.
class ServicesLoading extends ServicesState {
  const ServicesLoading();
}

class ServicesDataLoaded extends ServicesState {
  const ServicesDataLoaded({
    required this.categories,
    this.categoriesError,
    required this.services,
    required this.filteredServices,
    this.selectedCategoryId,
    required this.searchQuery,
    this.servicesLoading = false,
    this.servicesError,
    // Service detail / plan selection
    this.detailServiceId,
    this.detailLoading = false,
    this.detailError,
    this.detailPlans = const [],
    this.selectedPlanId,
  });

  // Sentinel used by copyWith so that nullable fields can be explicitly set
  // to null (pass null) vs "keep current value" (omit the argument).
  static const Object _keep = Object();

  // ── Category chips ────────────────────────────────────────────────────────

  final List<CategoryModel> categories;
  final String? categoriesError;

  // ── Service list ──────────────────────────────────────────────────────────

  final List<ServiceModel> services;          // raw API result for current filter
  final List<ServiceModel> filteredServices;  // search-narrowed view
  final int? selectedCategoryId;              // null = "All"
  final String searchQuery;
  final bool servicesLoading;
  final String? servicesError;

  // ── Service detail / plan selection ──────────────────────────────────────

  /// ID of the service whose detail was last requested.
  final String? detailServiceId;
  final bool detailLoading;
  final String? detailError;

  /// Rich plan objects from GET /api/services/{id}.
  final List<ServicePlan> detailPlans;

  /// ID of the plan the user has tapped; null if none selected.
  /// Persists after the bottom sheet closes so it can be used when creating
  /// a subscription.
  final int? selectedPlanId;

  // ── copyWith ──────────────────────────────────────────────────────────────

  ServicesDataLoaded copyWith({
    List<CategoryModel>? categories,
    Object? categoriesError = _keep,
    List<ServiceModel>? services,
    List<ServiceModel>? filteredServices,
    Object? selectedCategoryId = _keep,
    String? searchQuery,
    bool? servicesLoading,
    Object? servicesError = _keep,
    Object? detailServiceId = _keep,
    bool? detailLoading,
    Object? detailError = _keep,
    List<ServicePlan>? detailPlans,
    Object? selectedPlanId = _keep,
  }) {
    return ServicesDataLoaded(
      categories: categories ?? this.categories,
      categoriesError: identical(categoriesError, _keep)
          ? this.categoriesError
          : categoriesError as String?,
      services: services ?? this.services,
      filteredServices: filteredServices ?? this.filteredServices,
      selectedCategoryId: identical(selectedCategoryId, _keep)
          ? this.selectedCategoryId
          : selectedCategoryId as int?,
      searchQuery: searchQuery ?? this.searchQuery,
      servicesLoading: servicesLoading ?? this.servicesLoading,
      servicesError: identical(servicesError, _keep)
          ? this.servicesError
          : servicesError as String?,
      detailServiceId: identical(detailServiceId, _keep)
          ? this.detailServiceId
          : detailServiceId as String?,
      detailLoading: detailLoading ?? this.detailLoading,
      detailError: identical(detailError, _keep)
          ? this.detailError
          : detailError as String?,
      detailPlans: detailPlans ?? this.detailPlans,
      selectedPlanId: identical(selectedPlanId, _keep)
          ? this.selectedPlanId
          : selectedPlanId as int?,
    );
  }

  @override
  List<Object?> get props => [
        categories,
        categoriesError,
        filteredServices,
        selectedCategoryId,
        searchQuery,
        servicesLoading,
        servicesError,
        detailServiceId,
        detailLoading,
        detailError,
        detailPlans,
        selectedPlanId,
      ];
}
