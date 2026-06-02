import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/payment/payment_bloc.dart';
import '../../blocs/services/services_bloc.dart';
import '../../blocs/subscription/subscription_bloc.dart';
import '../../blocs/wallet/wallet_bloc.dart';
import '../../core/app_design.dart';
import 'checkout_subscription_screen.dart';

class AddSubscriptionScreen extends StatefulWidget {
  const AddSubscriptionScreen({super.key, this.preSelectedService});
  final ServiceModel? preSelectedService;
  @override
  State<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  ServiceModel? _svc;
  String? _plan;          // plan display name
  ServicePlan? _richPlan; // full plan object from detail sheet
  String _cycle = 'Monthly';
  String? _cardId;
  int _remindDays = 3;
  String _priority = 'medium';
  bool _isSubmitting = false;

  static const _cycles = ['Monthly', 'Yearly', 'Weekly'];
  static const _priorities = ['high', 'medium', 'low'];

  static const Map<String, double> _planMultiplier = {
    'free': 0.0, 'basic': 1.0, 'starter': 1.0, 'individual': 1.0,
    'personal': 1.0, 'photography': 1.0, '50gb': 1.0, 'student': 0.6,
    'duo': 1.5, 'standard': 1.5, '200gb': 1.5, 'single app': 1.5,
    'team': 1.4, 'plus': 1.4, 'professional': 1.8, 'family': 1.8,
    'all apps': 2.2, 'premium': 2.0, 'business': 2.5,
    '2tb': 3.0, 'organization': 3.0, 'enterprise': 3.5,
  };

  double get _computedAmount {
    if (_svc == null) return 0.0;
    if (_richPlan != null) return _richPlan!.price;
    if (_svc!.plans.isEmpty) return _svc!.startingPrice;
    final multiplier = _planMultiplier[_plan?.toLowerCase() ?? ''] ?? 1.0;
    return _svc!.startingPrice * multiplier;
  }

  @override
  void initState() {
    super.initState();
    _svc = widget.preSelectedService;

    if (_svc != null) {
      final svcState = context.read<ServicesBloc>().state;
      if (svcState is ServicesDataLoaded && svcState.selectedPlanId != null) {
        final selected = svcState.detailPlans
            .where((p) => p.id == svcState.selectedPlanId)
            .firstOrNull;
        if (selected != null) {
          _richPlan = selected;
          _plan = selected.planName;
          _cycle = _capitalizeCycle(selected.billingCycle);
        }
      }
      // Load plans if not already loaded for this service
      if (svcState is! ServicesDataLoaded ||
          svcState.detailServiceId != _svc!.id) {
        context.read<ServicesBloc>().add(ServiceDetailRequested(_svc!.id));
      }
    }

    final state = context.read<ServicesBloc>().state;
    if (state is! ServicesDataLoaded) {
      context.read<ServicesBloc>().add(const ServicesLoaded());
    }
  }

  String _capitalizeCycle(String c) {
    switch (c.toLowerCase()) {
      case 'weekly': return 'Weekly';
      case 'yearly': return 'Yearly';
      default: return 'Monthly';
    }
  }

  String _cycleFull(String c) {
    switch (c.toLowerCase()) {
      case 'weekly': return 'week';
      case 'yearly': return 'year';
      default: return 'month';
    }
  }

  bool get _canSubmit =>
      _svc != null &&
      (_svc!.plans.isEmpty || _plan != null) &&
      _cardId != null &&
      !_isSubmitting;

  void _submit() {
    if (_svc == null) return;

    // Hand off to CheckoutSubscriptionScreen which handles the full
    // payment flow (email, payment intent, confirm) before creating
    // the subscription record.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<PaymentBloc>()),
            BlocProvider.value(value: context.read<ServicesBloc>()),
            BlocProvider.value(value: context.read<WalletBloc>()),
            BlocProvider.value(value: context.read<SubscriptionBloc>()),
          ],
          child: CheckoutSubscriptionScreen(
            service: _svc!,
            initialPlan: _richPlan,
          ),
        ),
      ),
    );
    Navigator.pop(context);
  }

  Widget _svcLogo(ServiceModel svc, {double size = 28}) {
    final hasLogo = svc.logoUrl != null && svc.logoUrl!.isNotEmpty;
    if (hasLogo) {
      return SizedBox(
        width: size, height: size,
        child: Image.network(svc.logoUrl!, fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Text(svc.icon, style: TextStyle(fontSize: size * 0.9))),
      );
    }
    return Text(svc.icon, style: TextStyle(fontSize: size * 0.9));
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(top: 22, bottom: 10),
        child: Text(t, style: const TextStyle(color: D.white, fontWeight: FontWeight.w700, fontSize: 14)),
      );

  Widget _box({required Widget child, bool glowCyan = false}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: glowCyan
            ? D.glowCard(accent: D.cyan, bg: D.cardBg, radius: D.r20)
            : D.plainCard(),
        child: child,
      );

  Widget _chip(String text, bool active, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: active ? D.cyan : D.cardBg,
            borderRadius: D.r16,
            border: Border.all(color: active ? D.cyan : Colors.white.withValues(alpha: 0.08)),
            boxShadow: active ? [BoxShadow(color: D.cyan.withValues(alpha: 0.28), blurRadius: 10)] : [],
          ),
          child: Text(text,
              style: TextStyle(
                  color: active ? const Color(0xFF0D1A1C) : D.textSub,
                  fontWeight: FontWeight.w700)),
        ),
      );

  Widget _richPlanCard(ServicePlan plan) {
    final isSelected = _richPlan?.id == plan.id;
    return GestureDetector(
      onTap: () => setState(() {
        _richPlan = plan;
        _plan = plan.planName;
        _cycle = _capitalizeCycle(plan.billingCycle);
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? D.cyan.withValues(alpha: 0.08) : D.cardBg,
          borderRadius: D.r16,
          border: Border.all(
            color: isSelected ? D.cyan : Colors.white.withValues(alpha: 0.10),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: D.cyan.withValues(alpha: 0.18), blurRadius: 16)]
              : [],
        ),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(plan.planName,
                style: TextStyle(
                    color: isSelected ? D.cyan : D.white,
                    fontWeight: FontWeight.w800, fontSize: 14)),
            const SizedBox(height: 4),
            Text('\$${plan.price.toStringAsFixed(2)} / ${_cycleFull(plan.billingCycle)}',
                style: TextStyle(
                    color: isSelected ? D.cyan.withValues(alpha: 0.75) : D.textSub,
                    fontSize: 12, fontWeight: FontWeight.w600)),
          ])),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 20, height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? D.cyan : Colors.transparent,
              border: Border.all(
                color: isSelected ? D.cyan : Colors.white.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: isSelected ? const Icon(Icons.check, color: Colors.black, size: 12) : null,
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SubscriptionBloc, SubscriptionState>(
      listener: (context, subState) {
        if (!_isSubmitting) return;
        if (subState is SubscriptionData && !subState.isLoading &&
            subState.actionError != null) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(subState.actionError!),
            backgroundColor: D.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: D.r12),
          ));
        }
      },
      child: Scaffold(
        backgroundColor: D.bg,
        body: SafeArea(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 20, 0),
              child: Row(children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: D.white),
                ),
                const Text('Add Subscription',
                    style: TextStyle(color: D.white, fontSize: 22, fontWeight: FontWeight.w900)),
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Service ────────────────────────────────────────────
                    _label('Service'),
                    if (_svc != null)
                      _box(
                        glowCyan: true,
                        child: Row(children: [
                          _svcLogo(_svc!),
                          const SizedBox(width: 12),
                          Expanded(child: Text(_svc!.name,
                              style: const TextStyle(color: D.white, fontWeight: FontWeight.w800, fontSize: 16))),
                          TextButton(
                            onPressed: () => setState(() { _svc = null; _plan = null; _richPlan = null; }),
                            child: const Text('Change', style: TextStyle(color: D.cyan)),
                          ),
                        ]),
                      )
                    else
                      BlocBuilder<ServicesBloc, ServicesState>(
                        builder: (context, state) {
                          final list = state is ServicesDataLoaded ? state.services : <ServiceModel>[];
                          if (list.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('Loading services...', style: TextStyle(color: D.textSub)),
                            );
                          }
                          return Wrap(
                            spacing: 10, runSpacing: 10,
                            children: list.map((s) => GestureDetector(
                              onTap: () {
                                setState(() { _svc = s; _plan = null; _richPlan = null; });
                                context.read<ServicesBloc>().add(ServiceDetailRequested(s.id));
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: D.cardBg, borderRadius: D.r16,
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                                ),
                                child: Row(mainAxisSize: MainAxisSize.min, children: [
                                  _svcLogo(s, size: 22),
                                  const SizedBox(width: 6),
                                  Text(s.name, style: const TextStyle(color: D.white, fontWeight: FontWeight.w700)),
                                ]),
                              ),
                            )).toList(),
                          );
                        },
                      ),

                    // ── Plan ───────────────────────────────────────────────
                    if (_svc != null)
                      Builder(builder: (context) {
                        final svcState = context.read<ServicesBloc>().state;
                        final detailPlans = svcState is ServicesDataLoaded &&
                                svcState.detailServiceId == _svc!.id
                            ? svcState.detailPlans
                            : const <ServicePlan>[];

                        if (detailPlans.isNotEmpty) {
                          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _label('Plan'),
                            ...detailPlans.map(_richPlanCard),
                          ]);
                        }
                        if (_svc!.plans.isNotEmpty) {
                          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _label('Plan'),
                            Wrap(spacing: 10, children: _svc!.plans.map((p) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _chip(p, _plan == p, () => setState(() => _plan = p)),
                            )).toList()),
                          ]);
                        }
                        return const SizedBox.shrink();
                      }),

                    // ── Amount ─────────────────────────────────────────────
                    _label('Amount'),
                    _box(
                      child: Row(children: [
                        const Text('\$ ', style: TextStyle(color: D.cyan, fontWeight: FontWeight.w900, fontSize: 20)),
                        Text(
                          _svc == null ? '—' : _computedAmount.toStringAsFixed(2),
                          style: const TextStyle(color: D.white, fontWeight: FontWeight.w700, fontSize: 20),
                        ),
                        const Spacer(),
                        if (_svc != null && _richPlan == null)
                          Tooltip(
                            message: 'Pricing is estimated. Select a plan for exact pricing.',
                            child: Icon(Icons.info_outline_rounded, color: D.textSub, size: 16),
                          ),
                        if (_richPlan != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: D.cyan.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: D.cyan.withValues(alpha: 0.30)),
                            ),
                            child: const Text('Exact price',
                                style: TextStyle(color: D.cyan, fontSize: 10, fontWeight: FontWeight.w700)),
                          ),
                      ]),
                    ),

                    // ── Billing cycle ──────────────────────────────────────
                    _label('Billing Cycle'),
                    Row(children: _cycles.map((c) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: c != _cycles.last ? 10 : 0),
                        child: _chip(c, _cycle == c, () => setState(() => _cycle = c)),
                      ),
                    )).toList()),

                    // ── Card ───────────────────────────────────────────────
                    _label('Payment Card'),
                    BlocBuilder<WalletBloc, WalletState>(
                      builder: (context, walletState) {
                        if (walletState is! WalletData || walletState.cards.isEmpty) {
                          return _box(
                            child: Row(children: [
                              const Icon(Icons.info_outline_rounded, color: D.cyan, size: 16),
                              const SizedBox(width: 10),
                              const Expanded(child: Text(
                                'Please add a card in the Wallet tab first.',
                                style: TextStyle(color: D.textSub),
                              )),
                            ]),
                          );
                        }
                        return Column(
                          children: walletState.cards.map((card) => GestureDetector(
                            onTap: () => setState(() {
                              _cardId = card.id;
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: _cardId == card.id
                                  ? D.glowCard(accent: D.cyan, bg: D.cardBg, radius: D.r16)
                                  : D.plainCard(radius: D.r16),
                              child: Row(children: [
                                const Icon(Icons.credit_card_rounded, color: D.cyan),
                                const SizedBox(width: 12),
                                Expanded(child: Text(
                                  '${card.nickname}  ••••  ${card.maskedPan.length >= 4 ? card.maskedPan.substring(card.maskedPan.length - 4) : card.maskedPan}',
                                  style: const TextStyle(color: D.white, fontWeight: FontWeight.w700),
                                )),
                                if (_cardId == card.id)
                                  const Icon(Icons.check_circle_rounded, color: D.cyan, size: 20),
                              ]),
                            ),
                          )).toList(),
                        );
                      },
                    ),

                    // ── Priority ───────────────────────────────────────────
                    _label('Priority'),
                    Row(children: _priorities.map((p) {
                      const labels = {'high': 'High', 'medium': 'Medium', 'low': 'Low'};
                      return Expanded(child: Padding(
                        padding: EdgeInsets.only(right: p != _priorities.last ? 10 : 0),
                        child: _chip(labels[p]!, _priority == p, () => setState(() => _priority = p)),
                      ));
                    }).toList()),

                    // ── Reminder ───────────────────────────────────────────
                    _label('Remind me before renewal'),
                    _box(
                      child: Column(children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          const Text('Days before renewal',
                              style: TextStyle(color: D.textSub, fontWeight: FontWeight.w600)),
                          Text('$_remindDays days',
                              style: const TextStyle(color: D.cyan, fontWeight: FontWeight.w800)),
                        ]),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: D.cyan,
                            inactiveTrackColor: D.cyan.withValues(alpha: 0.15),
                            thumbColor: D.cyan,
                            overlayColor: D.cyan.withValues(alpha: 0.15),
                          ),
                          child: Slider(
                            value: _remindDays.toDouble(), min: 1, max: 14, divisions: 13,
                            onChanged: (v) => setState(() => _remindDays = v.round()),
                          ),
                        ),
                      ]),
                    ),

                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity, height: 58,
                      child: ElevatedButton(
                        onPressed: _canSubmit ? _submit : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _canSubmit ? D.orange : const Color(0xFF2A2A2A),
                          foregroundColor: D.white,
                          shape: RoundedRectangleBorder(borderRadius: D.r20),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 22, height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Text('Add Subscription',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
