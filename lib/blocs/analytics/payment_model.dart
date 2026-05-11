// ── Payment History Model ─────────────────────────────────────────────────
// TODO Sprint 4: replace mock with real payment history API per subscription.

enum PaymentStatus { paid, pending, failed, refunded }

class PaymentRecord {
  final String id;
  final DateTime date;
  final double amount;
  final PaymentStatus status;
  final String billingCycle;

  const PaymentRecord({
    required this.id,
    required this.date,
    required this.amount,
    required this.status,
    required this.billingCycle,
  });
}

List<PaymentRecord> mockPayments(String serviceName) {
  final now = DateTime.now();
  return [
    PaymentRecord(id: 'p1', date: now.subtract(const Duration(days: 0)),
      amount: 13.98, status: PaymentStatus.pending, billingCycle: 'Monthly'),
    PaymentRecord(id: 'p2', date: now.subtract(const Duration(days: 30)),
      amount: 13.98, status: PaymentStatus.paid, billingCycle: 'Monthly'),
    PaymentRecord(id: 'p3', date: now.subtract(const Duration(days: 60)),
      amount: 13.98, status: PaymentStatus.paid, billingCycle: 'Monthly'),
    PaymentRecord(id: 'p4', date: now.subtract(const Duration(days: 90)),
      amount: 6.99, status: PaymentStatus.paid, billingCycle: 'Monthly'),
    PaymentRecord(id: 'p5', date: now.subtract(const Duration(days: 120)),
      amount: 6.99, status: PaymentStatus.failed, billingCycle: 'Monthly'),
    PaymentRecord(id: 'p6', date: now.subtract(const Duration(days: 150)),
      amount: 6.99, status: PaymentStatus.refunded, billingCycle: 'Monthly'),
  ];
}