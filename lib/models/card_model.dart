import 'package:equatable/equatable.dart';

class CardModel extends Equatable {
  const CardModel({
    required this.id,
    required this.nickname,
    required this.maskedPan,
    required this.expiry,
    required this.type,
    this.isPrimary = false,
  });

  final String id;
  final String nickname;
  final String maskedPan;
  final String expiry;
  final String type;
  final bool isPrimary;

  factory CardModel.fromJson(Map<String, dynamic> json) => CardModel(
        id: (json['card_id'] ?? json['id'])?.toString() ?? '',
        nickname: json['card_holder_name'] as String? ??
            json['nickname'] as String? ??
            '',
        // Backend may return last4 (Stripe) or a full masked pan
        maskedPan: json['last4'] as String? ??
            json['card_number'] as String? ??
            json['masked_pan'] as String? ??
            json['maskedPan'] as String? ??
            '',
        expiry: json['expired_date'] as String? ??
            json['expiry'] as String? ??
            _expiryFromParts(json) ??
            '',
        // Backend may return Stripe brand ("visa", "mastercard") or legacy type
        type: json['brand'] as String? ??
            json['card_brand'] as String? ??
            json['type'] as String? ??
            'Visa',
        isPrimary: _parsePrimary(json),
      );

  static bool _parsePrimary(Map<String, dynamic> json) {
    final v = json['is_primary'] ?? json['isPrimary'];
    if (v is bool) return v;
    if (v is String) {
      return v.toLowerCase() == 'yes' ||
          v == '1' ||
          v.toLowerCase() == 'true';
    }
    if (v is int) return v == 1;
    return false;
  }

  static String? _expiryFromParts(Map<String, dynamic> json) {
    final month = json['expiry_month'];
    final year = json['expiry_year'];
    if (month == null || year == null) return null;
    return '${month.toString().padLeft(2, '0')}/$year';
  }

  @override
  List<Object> get props => [id];
}
