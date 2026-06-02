import 'package:equatable/equatable.dart';

/// Pure API response model – mirrors the backend JSON exactly.
class SubscriptionApiModel extends Equatable {
  const SubscriptionApiModel({
    required this.id,
    required this.userId,
    required this.serviceId,
    this.cardId,
    this.planId,
    required this.amount,
    required this.billingCycle,
    required this.startDate,
    required this.renewalDate,
    required this.reminderDays,
    required this.status,
    required this.priority,
    this.serviceAccountEmail,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int userId;
  final int serviceId;
  final int? cardId;
  final int? planId;
  final double amount;
  final String billingCycle;
  final DateTime startDate;
  final DateTime renewalDate;
  final int reminderDays;
  final String status;   // active | cancelled | paused
  final String priority; // high | medium | low
  final String? serviceAccountEmail;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory SubscriptionApiModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionApiModel(
      id: _parseInt(json['id']) ?? 0,
      userId: _parseInt(json['user_id']) ?? 0,
      serviceId: _parseInt(json['service_id']) ?? 0,
      cardId: _parseInt(json['card_id']),
      planId: _parseInt(json['plan_id']),
      amount: _parseDouble(json['amount']) ?? 0.0,
      billingCycle: json['billing_cycle'] as String? ?? 'monthly',
      startDate: _parseDate(json['start_date']) ?? DateTime.now(),
      renewalDate: _parseDate(json['renewal_date']) ??
          DateTime.now().add(const Duration(days: 30)),
      reminderDays: _parseInt(json['reminder_days']) ?? 3,
      status: json['status'] as String? ?? 'active',
      priority: json['priority'] as String? ?? 'medium',
      serviceAccountEmail: json['service_account_email'] as String? ??
          json['serviceAccountEmail'] as String?,
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  static int? _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static double? _parseDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static DateTime? _parseDate(dynamic v) {
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }

  static DateTime? _parseDateTime(dynamic v) {
    if (v is String && v.isNotEmpty) {
      return DateTime.tryParse(v.replaceAll(' ', 'T'));
    }
    return null;
  }

  @override
  List<Object?> get props => [id];
}
