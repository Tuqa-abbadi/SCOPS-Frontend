import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/payment/payment_bloc.dart';
import '../../blocs/services/services_bloc.dart';
import '../../blocs/subscription/subscription_bloc.dart';
import '../../blocs/wallet/wallet_bloc.dart';
import '../../core/app_design.dart';
import '../dashboard/dashboard_screen.dart';

class CheckoutSubscriptionScreen extends StatefulWidget {
  const CheckoutSubscriptionScreen({
    super.key,
    required this.service,
    this.initialPlan,
  });

  final ServiceModel service;
  final ServicePlan? initialPlan;

  @override
  State<CheckoutSubscriptionScreen> createState() =>
      _CheckoutSubscriptionScreenState();
}

class _CheckoutSubscriptionScreenState
    extends State<CheckoutSubscriptionScreen> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  ServicePlan? _plan;
  String? _fallbackPlan;
  CardModel? _card;
  PaymentBloc? _paymentBloc;
  int _remindDays = 3;
  String _priority = 'medium';
  bool _savingSubscription = false;

  static const _priorities = ['high', 'medium', 'low'];

  @override
  void initState() {
    super.initState();
    _plan = widget.initialPlan;
    _emailCtrl.addListener(() => setState(() {}));
    final services = context.read<ServicesBloc>().state;
    if (services is! ServicesDataLoaded ||
        services.detailServiceId != widget.service.id) {
      context.read<ServicesBloc>().add(
        ServiceDetailRequested(widget.service.id),
      );
    }
    if (context.read<WalletBloc>().state is WalletInitial) {
      context.read<WalletBloc>().add(const WalletLoaded());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _paymentBloc ??= context.read<PaymentBloc>();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _paymentBloc?.add(const PaymentReset());
    super.dispose();
  }

  int? get _serviceId => int.tryParse(widget.service.id);
  String get _billingCycle =>
      _capitalizeCycle(_plan?.billingCycle ?? widget.service.billingCycle);
  String get _planName => _plan?.planName ?? _fallbackPlan ?? 'Default';
  int? get _planId => _plan?.id;
  double get _amount => _plan?.price ?? widget.service.startingPrice;
  DateTime get _renewalDate {
    final now = DateTime.now();
    switch (_billingCycle.toLowerCase()) {
      case 'weekly':
        return now.add(const Duration(days: 7));
      case 'yearly':
        return now.add(const Duration(days: 365));
      default:
        return now.add(const Duration(days: 30));
    }
  }

  bool get _isPaymentBusy =>
      _savingSubscription ||
      context.read<PaymentBloc>().state is PaymentIntentLoading ||
      context.read<PaymentBloc>().state is PaymentConfirming;

  String _capitalizeCycle(String c) {
    switch (c.toLowerCase()) {
      case 'weekly':
        return 'Weekly';
      case 'yearly':
        return 'Yearly';
      default:
        return 'Monthly';
    }
  }

  String _cycleUnit(String c) {
    switch (c.toLowerCase()) {
      case 'weekly':
        return 'week';
      case 'yearly':
        return 'year';
      default:
        return 'month';
    }
  }

  String _date(DateTime d) => '${d.day}/${d.month}/${d.year}';

  void _startCheckout() {
    if (!_formKey.currentState!.validate()) return;
    final missing = _missingCheckoutMessage();
    if (missing != null) {
      _showAlert(missing);
      return;
    }
    if (_hasActiveDuplicateEmail()) {
      _showAlert(
        'This ${widget.service.name} account email already has an active subscription. You can subscribe again after the current subscription period ends.',
      );
      return;
    }
    final sid = _serviceId;
    if (sid == null || _card == null) return;
    context.read<PaymentBloc>().add(
      PaymentIntentRequested(
        sid,
        planId: _plan?.id,
        serviceAccountEmail: _emailCtrl.text.trim(),
      ),
    );
  }

  String? _missingCheckoutMessage() {
    final state = context.read<ServicesBloc>().state;
    final hasRichPlans =
        state is ServicesDataLoaded &&
        state.detailServiceId == widget.service.id &&
        state.detailPlans.isNotEmpty;
    final hasFallbackPlans = widget.service.plans.isNotEmpty;
    if (_card == null) return 'Choose a payment card before checking out.';
    if (hasRichPlans && _plan == null) {
      return 'Choose a subscription plan before checking out.';
    }
    if (!hasRichPlans && hasFallbackPlans && _fallbackPlan == null) {
      return 'Choose a subscription plan before checking out.';
    }
    if (_serviceId == null) {
      return 'Service details are not ready yet. Please try again.';
    }
    return null;
  }

  bool _hasActiveDuplicateEmail() {
    final subState = context.read<SubscriptionBloc>().state;
    if (subState is! SubscriptionData) return false;
    final email = _emailCtrl.text.trim().toLowerCase();
    final now = DateTime.now();
    return subState.subscriptions.any((sub) {
      final subEmail = sub.serviceAccountEmail?.trim().toLowerCase();
      if (subEmail == null || subEmail.isEmpty) return false;
      return sub.serviceId == _serviceId &&
          subEmail == email &&
          sub.isActive &&
          sub.nextRenewal.isAfter(now);
    });
  }

  void _showAlert(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: D.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: D.r12),
      ),
    );
  }

  Future<void> _confirmPayment(PaymentIntentReady state) async {
    final email = _emailCtrl.text.trim();
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF07111C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Confirm checkout',
          style: TextStyle(color: D.white, fontWeight: FontWeight.w900),
        ),
        content: Text(
          'You are paying for ${widget.service.name} account: $email\n\nPlan: $_planName\nPayment ID: ${state.paymentId}',
          style: const TextStyle(color: D.textSub, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancel', style: TextStyle(color: D.textSub)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: D.cyan,
              foregroundColor: Colors.black,
            ),
            child: const Text(
              'Confirm',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      context.read<PaymentBloc>().add(PaymentConfirmed(state.paymentId));
    } else {
      context.read<PaymentBloc>().add(const PaymentDeclined());
    }
  }

  void _handlePaymentSuccess(PaymentSuccess state) {
    if (_savingSubscription) return;
    final sid = _serviceId;
    if (sid == null || _card == null) return;
    setState(() => _savingSubscription = true);

    // The backend creates the subscription when the payment is confirmed.
    // Just refresh the local subscription list so the new one appears.
    context.read<SubscriptionBloc>().add(const SubscriptionsRefreshRequested());

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => CheckoutReceiptScreen(
          service: widget.service,
          planName: _planName,
          planId: _planId,
          amount: _amount,
          billingCycle: _billingCycle,
          card: _card!,
          serviceAccountEmail: _emailCtrl.text.trim(),
          paymentId: state.paymentId,
          renewalDate: _renewalDate,
          receipt: state.receipt,
        ),
      ),
    );
  }

  Widget _logo({double size = 56}) {
    final logo = widget.service.logoUrl;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: D.cardBg,
        border: Border.all(color: widget.service.color.withValues(alpha: .45)),
      ),
      clipBehavior: Clip.antiAlias,
      child: logo != null && logo.isNotEmpty
          ? Image.network(
              logo,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  Center(child: Text(widget.service.icon)),
            )
          : Center(
              child: Text(
                widget.service.icon,
                style: TextStyle(fontSize: size * .45),
              ),
            ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(top: 22, bottom: 10),
    child: Text(
      text,
      style: const TextStyle(
        color: D.white,
        fontWeight: FontWeight.w800,
        fontSize: 14,
      ),
    ),
  );

  Widget _cardBox(Widget child) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: D.plainCard(radius: D.r16),
    child: child,
  );

  Widget _planTile(ServicePlan plan) {
    final selected = _plan?.id == plan.id;
    return GestureDetector(
      onTap: () => setState(() {
        _plan = plan;
        _fallbackPlan = null;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: selected
            ? D.glowCard(accent: D.cyan, bg: D.cardBg, radius: D.r16)
            : D.plainCard(radius: D.r16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.planName,
                    style: TextStyle(
                      color: selected ? D.cyan : D.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${plan.price.toStringAsFixed(2)} / ${_cycleUnit(plan.billingCycle)}',
                    style: const TextStyle(color: D.textSub, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (selected) const Icon(Icons.check_circle_rounded, color: D.cyan),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text, bool selected, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? D.cyan : D.cardBg,
            borderRadius: D.r16,
            border: Border.all(
              color: selected ? D.cyan : Colors.white.withValues(alpha: .08),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: selected ? Colors.black : D.textSub,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );

  Widget _summaryRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: D.textSub, fontSize: 13),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: D.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentBloc, PaymentState>(
      listener: (context, state) {
        if (state is PaymentIntentReady) _confirmPayment(state);
        if (state is PaymentSuccess) _handlePaymentSuccess(state);
        if (state is PaymentFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: D.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: D.bg,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 14, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: D.white,
                      ),
                    ),
                    const Text(
                      'Checkout',
                      style: TextStyle(
                        color: D.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _cardBox(
                          Row(
                            children: [
                              _logo(size: 62),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.service.name,
                                      style: const TextStyle(
                                        color: D.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      widget.service.category.isEmpty
                                          ? 'Subscription service'
                                          : widget.service.category,
                                      style: const TextStyle(color: D.textSub),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        _label('Service account email'),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: D.white),
                          decoration: InputDecoration(
                            hintText: 'example@gmail.com',
                            hintStyle: const TextStyle(color: D.textSub),
                            filled: true,
                            fillColor: D.cardBg,
                            prefixIcon: const Icon(
                              Icons.alternate_email_rounded,
                              color: D.cyan,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: D.r16,
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (v) {
                            final value = v?.trim() ?? '';
                            if (value.isEmpty) {
                              return 'Enter the email used for this service.';
                            }
                            if (!value.contains('@') || !value.contains('.')) {
                              return 'Enter a valid email address.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'This can be different from your SCOPS account email.',
                          style: TextStyle(color: D.textSub, fontSize: 12),
                        ),
                        _label('Plan'),
                        BlocBuilder<ServicesBloc, ServicesState>(
                          builder: (context, state) {
                            final plans =
                                state is ServicesDataLoaded &&
                                    state.detailServiceId == widget.service.id
                                ? state.detailPlans
                                : const <ServicePlan>[];
                            if (plans.isNotEmpty) {
                              return Column(
                                children: plans.map(_planTile).toList(),
                              );
                            }
                            if (widget.service.plans.isEmpty) {
                              return _cardBox(
                                Text(
                                  _planName,
                                  style: const TextStyle(
                                    color: D.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              );
                            }
                            return Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: widget.service.plans
                                  .map(
                                    (p) => _chip(p, _fallbackPlan == p, () {
                                      setState(() {
                                        _fallbackPlan = p;
                                        _plan = null;
                                      });
                                    }),
                                  )
                                  .toList(),
                            );
                          },
                        ),
                        _label('Payment card'),
                        BlocBuilder<WalletBloc, WalletState>(
                          builder: (context, state) {
                            final cards = state is WalletData
                                ? state.cards
                                : state is WalletAddingCard
                                ? state.cards
                                : state is WalletError
                                ? state.cards
                                : const <CardModel>[];
                            if (cards.isEmpty) {
                              return _cardBox(
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline_rounded,
                                      color: D.cyan,
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Add a card from the Wallet tab before checkout.',
                                        style: TextStyle(color: D.textSub),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return Column(
                              children: cards.map((card) {
                                final selected = _card?.id == card.id;
                                final last4 = card.maskedPan.length >= 4
                                    ? card.maskedPan.substring(
                                        card.maskedPan.length - 4,
                                      )
                                    : card.maskedPan;
                                return GestureDetector(
                                  onTap: () => setState(() => _card = card),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(14),
                                    decoration: selected
                                        ? D.glowCard(
                                            accent: D.cyan,
                                            bg: D.cardBg,
                                            radius: D.r16,
                                          )
                                        : D.plainCard(radius: D.r16),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.credit_card_rounded,
                                          color: D.cyan,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            '${card.nickname}  **** $last4',
                                            style: const TextStyle(
                                              color: D.white,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                        if (selected)
                                          const Icon(
                                            Icons.check_circle_rounded,
                                            color: D.cyan,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                        _label('Activation details'),
                        _cardBox(
                          Column(
                            children: [
                              Row(
                                children: _priorities.map((p) {
                                  final label =
                                      p[0].toUpperCase() + p.substring(1);
                                  return Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        right: p == _priorities.last ? 0 : 8,
                                      ),
                                      child: _chip(
                                        label,
                                        _priority == p,
                                        () => setState(() => _priority = p),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Renewal reminder',
                                    style: TextStyle(color: D.textSub),
                                  ),
                                  Text(
                                    '$_remindDays days before',
                                    style: const TextStyle(
                                      color: D.cyan,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              Slider(
                                value: _remindDays.toDouble(),
                                min: 1,
                                max: 14,
                                divisions: 13,
                                activeColor: D.cyan,
                                inactiveColor: D.cyan.withValues(alpha: .14),
                                onChanged: (v) =>
                                    setState(() => _remindDays = v.round()),
                              ),
                            ],
                          ),
                        ),
                        _label('Order summary'),
                        _cardBox(
                          Column(
                            children: [
                              _summaryRow(
                                'Service account',
                                _emailCtrl.text.trim().isEmpty
                                    ? 'Enter email above'
                                    : _emailCtrl.text.trim(),
                              ),
                              _summaryRow('Plan', _planName),
                              _summaryRow(
                                'Plan ID',
                                _planId?.toString() ?? 'N/A',
                              ),
                              _summaryRow('Billing', _billingCycle),
                              _summaryRow('Starts', _date(DateTime.now())),
                              _summaryRow('Renews', _date(_renewalDate)),
                              _summaryRow(
                                'Total',
                                '\$${_amount.toStringAsFixed(2)} / ${_cycleUnit(_billingCycle)}',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        BlocBuilder<PaymentBloc, PaymentState>(
                          builder: (context, state) {
                            final loading =
                                state is PaymentIntentLoading ||
                                state is PaymentConfirming ||
                                _savingSubscription;
                            return SizedBox(
                              width: double.infinity,
                              height: 58,
                              child: ElevatedButton(
                                onPressed: loading ? null : _startCheckout,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isPaymentBusy
                                      ? const Color(0xFF2A2A2A)
                                      : D.orange,
                                  foregroundColor: D.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: D.r20,
                                  ),
                                ),
                                child: loading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          color: D.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Text(
                                        'Pay and activate',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CheckoutReceiptScreen extends StatelessWidget {
  const CheckoutReceiptScreen({
    super.key,
    required this.service,
    required this.planName,
    required this.planId,
    required this.amount,
    required this.billingCycle,
    required this.card,
    required this.serviceAccountEmail,
    required this.paymentId,
    required this.renewalDate,
    this.receipt,
  });

  final ServiceModel service;
  final String planName;
  final int? planId;
  final double amount;
  final String billingCycle;
  final CardModel card;
  final String serviceAccountEmail;
  final int paymentId;
  final DateTime renewalDate;
  final Map<String, dynamic>? receipt;

  String _value(String key, String fallback) {
    final v = receipt?[key];
    if (v == null || v.toString().isEmpty) return fallback;
    return v.toString();
  }

  String _date(DateTime d) => '${d.day}/${d.month}/${d.year}';

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 13),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: D.textSub, fontSize: 13),
          ),
        ),
        const SizedBox(width: 14),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: D.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final last4 = card.maskedPan.length >= 4
        ? card.maskedPan.substring(card.maskedPan.length - 4)
        : card.maskedPan;
    return Scaffold(
      backgroundColor: D.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: D.white),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: D.cyan.withValues(alpha: .12),
                          border: Border.all(
                            color: D.cyan.withValues(alpha: .35),
                          ),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: D.cyan,
                          size: 42,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        '${service.name} activated',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: D.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your ${service.name} subscription has been activated for $serviceAccountEmail.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: D.textSub, height: 1.5),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: D.glowCard(
                          accent: D.cyan,
                          bg: D.cardBg,
                          radius: D.r20,
                        ),
                        child: Column(
                          children: [
                            _row(
                              'Receipt ID',
                              _value(
                                'receipt_id',
                                _value('id', 'PAY-$paymentId'),
                              ),
                            ),
                            _row('Payment ID', paymentId.toString()),
                            _row('Service', service.name),
                            _row('Service account', serviceAccountEmail),
                            _row('Plan', _value('plan', planName)),
                            _row(
                              'Plan ID',
                              _value('plan_id', planId?.toString() ?? 'N/A'),
                            ),
                            _row(
                              'Payment status',
                              _value(
                                'payment_status',
                                _value('status', 'paid'),
                              ),
                            ),
                            _row('Card', '${card.type} **** $last4'),
                            _row(
                              'Amount',
                              _value(
                                'amount',
                                '\$${amount.toStringAsFixed(2)}',
                              ),
                            ),
                            _row(
                              'Start date',
                              _value('start_date', _date(DateTime.now())),
                            ),
                            _row(
                              'Renewal date',
                              _value('renewal_date', _date(renewalDate)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const DashboardScreen(
                        initialIndex: 1,
                        showSubscriptionAddedMessage: true,
                      ),
                    ),
                    (_) => false,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: D.orange,
                    foregroundColor: D.white,
                    shape: RoundedRectangleBorder(borderRadius: D.r20),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
