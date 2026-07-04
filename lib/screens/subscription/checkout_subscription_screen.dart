import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/payment/payment_bloc.dart';
import '../../blocs/services/services_bloc.dart';
import '../../blocs/subscription/subscription_bloc.dart';
import '../../blocs/wallet/wallet_bloc.dart';
import '../../core/app_design.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/service_logo.dart';
import '../dashboard/dashboard_screen.dart';

class CheckoutSubscriptionScreen extends StatefulWidget {
  const CheckoutSubscriptionScreen({
    super.key,
    required this.service,
    this.initialPlan,
    this.initialCardId,
  });

  final ServiceModel service;
  final ServicePlan? initialPlan;
  final String? initialCardId;

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

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

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
      context.read<WalletBloc>().add(WalletLoaded());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _paymentBloc ??= context.read<PaymentBloc>();
    _selectInitialCard(context.read<WalletBloc>().state, notify: false);
  }

  void _selectInitialCard(WalletState state, {bool notify = true}) {
    if (_card != null) return;

    final cards = state is WalletData
        ? state.cards
        : state is WalletAddingCard
        ? state.cards
        : state is WalletSetupIntentReady
        ? state.cards
        : state is WalletError
        ? state.cards
        : <CardModel>[];
    final primaryCardId = state is WalletData
        ? state.primaryCardId
        : state is WalletAddingCard
        ? state.primaryCardId
        : state is WalletSetupIntentReady
        ? state.primaryCardId
        : state is WalletError
        ? state.primaryCardId
        : null;

    if (cards.isEmpty) return;
    CardModel? selectedCard;
    for (final card in cards) {
      if (card.id == widget.initialCardId) {
        selectedCard = card;
        break;
      }
    }
    if (selectedCard == null) {
      for (final card in cards) {
        if (card.id == primaryCardId || card.isPrimary) {
          selectedCard = card;
          break;
        }
      }
    }
    selectedCard ??= cards.first;

    if (notify && mounted) {
      setState(() => _card = selectedCard);
    } else {
      _card = selectedCard;
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _paymentBloc?.add(PaymentReset());
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
        return now.add(Duration(days: 7));
      case 'yearly':
        return now.add(Duration(days: 365));
      default:
        return now.add(Duration(days: 30));
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
        backgroundColor: _isDark ? Color(0xFF07111C) : AppColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Confirm checkout',
          style: TextStyle(color: D.white, fontWeight: FontWeight.w900),
        ),
        content: Text(
          'You are paying for ${widget.service.name} account: $email\n\nPlan: $_planName\nPayment ID: ${state.paymentId}',
          style: TextStyle(color: D.textSub, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text('Cancel', style: TextStyle(color: D.textSub)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: D.cyan,
              foregroundColor: Colors.black,
            ),
            child: Text(
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
      context.read<PaymentBloc>().add(PaymentDeclined());
    }
  }

  void _handlePaymentSuccess(PaymentSuccess state) {
    if (_savingSubscription) return;
    final sid = _serviceId;
    if (sid == null || _card == null) return;
    setState(() => _savingSubscription = true);

    // The backend creates the subscription when the payment is confirmed.
    // Refresh both affected stores so the new subscription and the card's
    // reduced balance are reflected throughout the app.
    context.read<SubscriptionBloc>().add(SubscriptionsRefreshRequested());
    context.read<WalletBloc>().add(WalletLoaded());

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
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: D.cardBg,
        border: Border.all(color: widget.service.color.withValues(alpha: .45)),
      ),
      clipBehavior: Clip.antiAlias,
      child: ServiceLogo(
        serviceName: widget.service.name,
        logoUrl: widget.service.logoUrl,
        fallbackIcon: widget.service.icon,
        fallbackFontSize: size * .45,
        padding: EdgeInsets.all(size * .1),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: EdgeInsets.only(top: 22, bottom: 10),
    child: Text(
      text,
      style: TextStyle(
        color: D.white,
        fontWeight: FontWeight.w800,
        fontSize: 14,
      ),
    ),
  );

  Widget _cardBox(Widget child) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(16),
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
        duration: Duration(milliseconds: 180),
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(14),
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
                  SizedBox(height: 4),
                  Text(
                    '\$${plan.price.toStringAsFixed(2)} / ${_cycleUnit(plan.billingCycle)}',
                    style: TextStyle(color: D.textSub, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (selected) Icon(Icons.check_circle_rounded, color: D.cyan),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text, bool selected, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? D.cyan : D.cardBg,
            borderRadius: D.r16,
            border: Border.all(
              color: selected
                  ? D.cyan
                  : _isDark
                  ? Colors.white.withValues(alpha: .08)
                  : AppColors.lightBorder,
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
    padding: EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(label, style: TextStyle(color: D.textSub, fontSize: 13)),
        ),
        SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
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
        backgroundColor: _isDark ? D.bg : AppColors.lightBackground,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(8, 14, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: D.white,
                      ),
                    ),
                    Text(
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
                    padding: EdgeInsets.fromLTRB(20, 14, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _cardBox(
                          Row(
                            children: [
                              _logo(size: 62),
                              SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.service.name,
                                      style: TextStyle(
                                        color: D.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      widget.service.category.isEmpty
                                          ? 'Subscription service'
                                          : widget.service.category,
                                      style: TextStyle(color: D.textSub),
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
                          style: TextStyle(color: D.white),
                          decoration: InputDecoration(
                            hintText: 'example@gmail.com',
                            hintStyle: TextStyle(color: D.textSub),
                            filled: true,
                            fillColor: D.cardBg,
                            prefixIcon: Icon(
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
                        SizedBox(height: 8),
                        Text(
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
                                : <ServicePlan>[];
                            if (plans.isNotEmpty) {
                              return Column(
                                children: plans.map(_planTile).toList(),
                              );
                            }
                            if (widget.service.plans.isEmpty) {
                              return _cardBox(
                                Text(
                                  _planName,
                                  style: TextStyle(
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
                        BlocConsumer<WalletBloc, WalletState>(
                          listener: (context, state) =>
                              _selectInitialCard(state),
                          builder: (context, state) {
                            final cards = state is WalletData
                                ? state.cards
                                : state is WalletAddingCard
                                ? state.cards
                                : state is WalletSetupIntentReady
                                ? state.cards
                                : state is WalletError
                                ? state.cards
                                : <CardModel>[];
                            if (cards.isEmpty) {
                              return _cardBox(
                                Row(
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
                                    duration: Duration(milliseconds: 180),
                                    margin: EdgeInsets.only(bottom: 10),
                                    padding: EdgeInsets.all(14),
                                    decoration: selected
                                        ? D.glowCard(
                                            accent: D.cyan,
                                            bg: D.cardBg,
                                            radius: D.r16,
                                          )
                                        : D.plainCard(radius: D.r16),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.credit_card_rounded,
                                          color: D.cyan,
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            '${card.nickname}  **** $last4',
                                            style: TextStyle(
                                              color: D.white,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                        if (selected)
                                          Icon(
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
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Renewal reminder',
                                    style: TextStyle(color: D.textSub),
                                  ),
                                  Text(
                                    '$_remindDays days before',
                                    style: TextStyle(
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
                        SizedBox(height: 28),
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
                                      ? _isDark
                                            ? Color(0xFF2A2A2A)
                                            : AppColors.lightSecondarySurface
                                      : D.orange,
                                  foregroundColor: _isDark
                                      ? D.white
                                      : Theme.of(
                                          context,
                                        ).colorScheme.onSecondary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: D.r20,
                                  ),
                                ),
                                child: loading
                                    ? SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          color: D.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : Text(
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
    padding: EdgeInsets.only(bottom: 13),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(label, style: TextStyle(color: D.textSub, fontSize: 13)),
        ),
        SizedBox(width: 14),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final last4 = card.maskedPan.length >= 4
        ? card.maskedPan.substring(card.maskedPan.length - 4)
        : card.maskedPan;
    return Scaffold(
      backgroundColor: isDark ? D.bg : AppColors.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close_rounded, color: D.white),
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
                        child: Icon(
                          Icons.check_rounded,
                          color: D.cyan,
                          size: 42,
                        ),
                      ),
                      SizedBox(height: 18),
                      Text(
                        '${service.name} activated',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: D.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your ${service.name} subscription has been activated for $serviceAccountEmail.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: D.textSub, height: 1.5),
                      ),
                      SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(18),
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
                    foregroundColor: isDark
                        ? D.white
                        : Theme.of(context).colorScheme.onSecondary,
                    shape: RoundedRectangleBorder(borderRadius: D.r20),
                  ),
                  child: Text(
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
