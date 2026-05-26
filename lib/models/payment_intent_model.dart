class PaymentIntentModel {
  const PaymentIntentModel({
    required this.clientSecret,
    required this.paymentId,
  });

  final String clientSecret;
  final int paymentId;

  factory PaymentIntentModel.fromJson(Map<String, dynamic> json) {
    // client_secret — required
    final secret = json['client_secret'] as String? ??
        json['clientSecret'] as String? ??
        '';

    // payment_id — backend may return int or String; try both key names
    final rawId = json['payment_id'] ?? json['id'] ?? json['paymentId'];
    final id = rawId is int
        ? rawId
        : int.tryParse(rawId?.toString() ?? '') ?? 0;

    return PaymentIntentModel(clientSecret: secret, paymentId: id);
  }
}
