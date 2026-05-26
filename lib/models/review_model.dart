import 'package:equatable/equatable.dart';

class ReviewModel extends Equatable {
  const ReviewModel({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.subscriptionId,
    required this.rating,
    this.comment,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int userId;
  final int serviceId;
  final int subscriptionId;
  final int rating;    // 1–10
  final String? comment;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id:             _parseInt(json['id'])             ?? 0,
      userId:         _parseInt(json['user_id'])        ?? 0,
      serviceId:      _parseInt(json['service_id'])     ?? 0,
      subscriptionId: _parseInt(json['subscription_id']) ?? 0,
      rating:         _parseInt(json['rating'])         ?? 0,
      comment:        json['comment'] as String?,
      createdAt:      _parseDateTime(json['created_at']),
      updatedAt:      _parseDateTime(json['updated_at']),
    );
  }

  static int? _parseInt(dynamic v) {
    if (v is int)    return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static DateTime? _parseDateTime(dynamic v) {
    if (v is String && v.isNotEmpty) {
      return DateTime.tryParse(v.replaceAll(' ', 'T'));
    }
    return null;
  }

  @override
  List<Object?> get props =>
      [id, userId, serviceId, subscriptionId, rating, comment];
}
