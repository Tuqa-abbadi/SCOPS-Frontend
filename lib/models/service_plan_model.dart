import 'package:equatable/equatable.dart';

class ServicePlan extends Equatable {
  const ServicePlan({
    required this.id,
    required this.serviceId,
    required this.planName,
    required this.billingCycle,
    required this.price,
    this.features,
  });

  final int id;
  final int serviceId;
  final String planName;
  final String billingCycle;
  final double price;
  final String? features;

  factory ServicePlan.fromJson(Map<String, dynamic> json) {
    // Name: plan_name → name → title → label
    final planName = json['plan_name'] as String? ??
        json['name'] as String? ??
        json['title'] as String? ??
        json['label'] as String? ??
        '';

    // Billing cycle: billing_cycle → cycle → interval → period → frequency
    final billingCycle = json['billing_cycle'] as String? ??
        json['cycle'] as String? ??
        json['interval'] as String? ??
        json['period'] as String? ??
        json['frequency'] as String? ??
        'monthly';

    // Price: price → amount → default_amount → cost → monthly_price → value
    final price = _parseDouble(
      json['price'] ??
          json['amount'] ??
          json['default_amount'] ??
          json['cost'] ??
          json['monthly_price'] ??
          json['value'],
    );

    // Features: features → description → details → feature_list
    final rawFeatures = json['features'] ??
        json['description'] ??
        json['details'] ??
        json['feature_list'];
    final String? features;
    if (rawFeatures is String && rawFeatures.isNotEmpty) {
      features = rawFeatures;
    } else if (rawFeatures is List && rawFeatures.isNotEmpty) {
      features = rawFeatures.map((e) => e.toString()).join(', ');
    } else {
      features = null;
    }

    return ServicePlan(
      id: _parseInt(json['id']) ?? 0,
      serviceId: _parseInt(
            json['service_id'] ?? json['serviceId'] ?? json['service'],
          ) ??
          0,
      planName: planName,
      billingCycle: billingCycle,
      price: price,
      features: features,
    );
  }

  static int? _parseInt(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is double) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  static double _parseDouble(dynamic raw) {
    if (raw == null) return 0.0;
    if (raw is double) return raw;
    if (raw is int) return raw.toDouble();
    if (raw is String) return double.tryParse(raw) ?? 0.0;
    return 0.0;
  }

  @override
  List<Object?> get props =>
      [id, serviceId, planName, billingCycle, price, features];
}
