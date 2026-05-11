import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../blocs/analytics/payment_model.dart';

// ── Payment History Screen ────────────────────────────────────────────────
// Called from anywhere with: Navigator.push(context, MaterialPageRoute(
//   builder: (_) => PaymentHistoryScreen(
//     serviceName: sub.serviceName,
//     serviceIcon: sub.serviceIcon,
//     plan: sub.plan,
//   )));
// TODO Sprint 4: pass subscriptionId and fetch real payment history from API.

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({
    super.key,
    required this.serviceName,
    required this.serviceIcon,
    required this.plan,
  });

  final String serviceName;
  final String serviceIcon;
  final String plan;

  static const _bg     = Color(0xFF020812);
  static const _card   = Color(0xFF07111C);
  static const _cyan   = Color(0xFF18E8F2);
  static const _orange = Color(0xFFFF5A14);
  static const _white  = Colors.white;
  static const _muted  = Color(0xFF9BA4B0);

  Color _statusColor(PaymentStatus s) {
    switch (s) {
      case PaymentStatus.paid:      return const Color(0xFF22C55E);
      case PaymentStatus.pending:   return _cyan;
      case PaymentStatus.failed:    return _orange;
      case PaymentStatus.refunded:  return const Color(0xFFA855F7);
    }
  }

  String _statusLabel(PaymentStatus s) {
    switch (s) {
      case PaymentStatus.paid:      return 'Paid';
      case PaymentStatus.pending:   return 'Upcoming';
      case PaymentStatus.failed:    return 'Failed';
      case PaymentStatus.refunded:  return 'Refunded';
    }
  }

  IconData _statusIcon(PaymentStatus s) {
    switch (s) {
      case PaymentStatus.paid:      return Icons.check_circle_rounded;
      case PaymentStatus.pending:   return Icons.schedule_rounded;
      case PaymentStatus.failed:    return Icons.cancel_rounded;
      case PaymentStatus.refunded:  return Icons.refresh_rounded;
    }
  }

  Widget _statusChip(PaymentStatus s) {
    final color = _statusColor(s);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_statusIcon(s), color: color, size: 12),
          const SizedBox(width: 4),
          Text(_statusLabel(s),
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _timelineTile(PaymentRecord record, bool isLast) {
    final color = _statusColor(record.status);
    final isFirst = record.status == PaymentStatus.pending;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column
          SizedBox(
            width: 36,
            child: Column(
              children: [
                // Node circle
                Container(
                  width: 18,
                  height: 18,
                  margin: const EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.15),
                    border: Border.all(color: color, width: 2),
                    boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8)],
                  ),
                  child: isFirst
                      ? Center(child: Container(
                          width: 6, height: 6,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: color)))
                      : null,
                ),
                // Connecting line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [color.withOpacity(0.4), Colors.white.withOpacity(0.05)],
                        ),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isFirst ? color.withOpacity(0.35) : Colors.white.withOpacity(0.06),
                ),
                boxShadow: isFirst
                    ? [BoxShadow(color: color.withOpacity(0.10), blurRadius: 20)]
                    : [],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('MMM d, yyyy').format(record.date),
                          style: const TextStyle(
                              color: _white, fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(record.billingCycle,
                            style: const TextStyle(color: _muted, fontSize: 12)),
                        const SizedBox(height: 8),
                        _statusChip(record.status),
                      ],
                    ),
                  ),
                  Text(
                    '\$${record.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: record.status == PaymentStatus.failed
                          ? _orange
                          : record.status == PaymentStatus.refunded
                              ? const Color(0xFFA855F7)
                              : _white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO Sprint 4: replace with API call using subscriptionId
    final payments = mockPayments(serviceName);

    final totalPaid = payments
        .where((p) => p.status == PaymentStatus.paid)
        .fold(0.0, (s, p) => s + p.amount);
    final paidCount = payments.where((p) => p.status == PaymentStatus.paid).length;
    final failedCount = payments.where((p) => p.status == PaymentStatus.failed).length;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: _white, size: 20),
                  ),
                  const SizedBox(width: 4),
                  Text(serviceIcon, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(serviceName,
                            style: const TextStyle(
                                color: _white, fontSize: 18, fontWeight: FontWeight.w900)),
                        Text(plan,
                            style: const TextStyle(color: _muted, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Summary strip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _cyan.withOpacity(0.22)),
                  boxShadow: [BoxShadow(color: _cyan.withOpacity(0.08), blurRadius: 24)],
                ),
                child: Row(
                  children: [
                    _summStat('\$${totalPaid.toStringAsFixed(0)}', 'Total Paid', _cyan),
                    _divider(),
                    _summStat('$paidCount', 'Payments', const Color(0xFF22C55E)),
                    _divider(),
                    _summStat('$failedCount', 'Failed', failedCount > 0 ? _orange : _muted),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text('Payment Timeline',
                      style: TextStyle(
                          color: _white, fontSize: 18, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  Text('${payments.length} records',
                      style: const TextStyle(color: _muted, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Timeline
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: payments.length,
                itemBuilder: (_, i) =>
                    _timelineTile(payments[i], i == payments.length - 1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summStat(String val, String label, Color color) => Expanded(
        child: Column(
          children: [
            Text(val, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: _muted, fontSize: 11)),
          ],
        ),
      );

  Widget _divider() => Container(
        width: 1, height: 36,
        color: Colors.white.withOpacity(0.07),
      );
}