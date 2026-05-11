import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/services/services_bloc.dart';
import '../../blocs/subscription/subscription_bloc.dart';
import '../../blocs/wallet/wallet_bloc.dart';
import '../../core/app_design.dart';

class AddSubscriptionScreen extends StatefulWidget {
  const AddSubscriptionScreen({super.key, this.preSelectedService});
  final ServiceModel? preSelectedService;
  @override
  State<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  ServiceModel? _svc;
  String? _plan;
  String _cycle = 'Monthly';
  String? _cardId;
  int _remindDays = 3;
  final _cycles = ['Monthly', 'Yearly', 'Weekly'];

  // Temporary pricing multipliers per plan tier.
  // TODO: replace with real API/token-based pricing from each provider.
  static const Map<String, double> _planMultiplier = {
    'free': 0.0,
    'basic': 1.0,
    'starter': 1.0,
    'individual': 1.0,
    'personal': 1.0,
    'photography': 1.0,
    '50gb': 1.0,
    'student': 0.6,
    'duo': 1.5,
    'standard': 1.5,
    '200gb': 1.5,
    'single app': 1.5,
    'team': 1.4,
    'plus': 1.4,
    'professional': 1.8,
    'family': 1.8,
    'all apps': 2.2,
    'premium': 2.0,
    'business': 2.5,
    '2tb': 3.0,
    'organization': 3.0,
    'enterprise': 3.5,
  };

  double get _computedAmount {
    if (_svc == null) return 0.0;
    final multiplier = _planMultiplier[_plan?.toLowerCase() ?? ''] ?? 1.0;
    return _svc!.startingPrice * multiplier;
  }

  @override
  void initState() {
    super.initState();
    _svc = widget.preSelectedService;
    // Load services only if not already loaded
    final state = context.read<ServicesBloc>().state;
    if (state is! ServicesDataLoaded) {
      context.read<ServicesBloc>().add(const ServicesLoaded());
    }
  }

  bool get _canSubmit => _svc != null && _plan != null && _cardId != null;

  void _submit() {
    context.read<SubscriptionBloc>().add(SubscriptionAdded(
          serviceName: _svc!.name,
          serviceIcon: _svc!.icon,
          plan: _plan!,
          billingCycle: _cycle,
          amount: _computedAmount,
          nextRenewal: DateTime.now().add(const Duration(days: 30)),
          cardId: _cardId!,
          reminderDays: _remindDays,
        ));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${_svc!.name} added!'),
      backgroundColor: D.cyan,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: D.r12),
    ));
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(top: 22, bottom: 10),
        child: Text(t,
            style: const TextStyle(
                color: D.white, fontWeight: FontWeight.w700, fontSize: 14)),
      );

  Widget _box({required Widget child, bool glowCyan = false}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: glowCyan
            ? D.glowCard(accent: D.cyan, bg: D.cardBg, radius: D.r20)
            : D.plainCard(),
        child: child,
      );

  Widget _chip(String text, bool active, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: active ? D.cyan : D.cardBg,
            borderRadius: D.r16,
            border: Border.all(
                color: active ? D.cyan : Colors.white.withOpacity(0.08)),
            boxShadow: active
                ? [BoxShadow(color: D.cyan.withOpacity(0.28), blurRadius: 10)]
                : [],
          ),
          child: Text(text,
              style: TextStyle(
                  color: active ? const Color(0xFF0D1A1C) : D.textSub,
                  fontWeight: FontWeight.w700)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: D.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: D.white),
                  ),
                  const Text('Add Subscription',
                      style: TextStyle(
                          color: D.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service
                    _label('Service'),
                    if (_svc != null)
                      _box(
                        glowCyan: true,
                        child: Row(
                          children: [
                            Text(_svc!.icon,
                                style: const TextStyle(fontSize: 28)),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Text(_svc!.name,
                                    style: const TextStyle(
                                        color: D.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16))),
                            TextButton(
                              onPressed: () =>
                                  setState(() { _svc = null; _plan = null; }),
                              child: const Text('Change',
                                  style: TextStyle(color: D.cyan)),
                            ),
                          ],
                        ),
                      )
                    else
                      BlocBuilder<ServicesBloc, ServicesState>(
                        builder: (context, state) {
                          final list = state is ServicesDataLoaded
                              ? state.allServices
                              : [];
                          return Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: list
                                .map((s) => GestureDetector(
                                      onTap: () => setState(() {
                                        _svc = s;
                                        _plan = null;
                                      }),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: D.cardBg,
                                          borderRadius: D.r16,
                                          border: Border.all(
                                              color: Colors.white
                                                  .withOpacity(0.07)),
                                        ),
                                        child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(s.icon),
                                              const SizedBox(width: 6),
                                              Text(s.name,
                                                  style: const TextStyle(
                                                      color: D.white,
                                                      fontWeight:
                                                          FontWeight.w700)),
                                            ]),
                                      ),
                                    ))
                                .toList(),
                          );
                        },
                      ),

                    // Plan
                    if (_svc != null) ...[
                      _label('Plan'),
                      Wrap(
                        spacing: 10,
                        children: _svc!.plans
                            .map((p) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _chip(p, _plan == p,
                                      () => setState(() => _plan = p)),
                                ))
                            .toList(),
                      ),
                    ],

                    // Amount — read-only, computed from service + plan
                    _label('Amount'),
                    _box(
                      child: Row(
                        children: [
                          const Text(
                            '\$ ',
                            style: TextStyle(
                              color: D.cyan,
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            _svc == null
                                ? '—'
                                : _computedAmount.toStringAsFixed(2),
                            style: const TextStyle(
                              color: D.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                          const Spacer(),
                          if (_svc != null)
                            Tooltip(
                              message: 'Pricing is estimated.\nReal prices will be fetched via API.',
                              child: Icon(
                                Icons.info_outline_rounded,
                                color: D.textSub,
                                size: 16,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Billing cycle
                    _label('Billing Cycle'),
                    Row(
                      children: _cycles
                          .map((c) => Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      right: c != _cycles.last ? 10 : 0),
                                  child: _chip(c, _cycle == c,
                                      () => setState(() => _cycle = c)),
                                ),
                              ))
                          .toList(),
                    ),

                    // Card
                    _label('Payment Card'),
                    BlocBuilder<WalletBloc, WalletState>(
                      builder: (context, state) {
                        if (state is! WalletData || state.cards.isEmpty) {
                          return _box(
                            child: const Text(
                                'No cards yet. Add a card in the Wallet tab.',
                                style: TextStyle(color: D.textSub)),
                          );
                        }
                        return Column(
                          children: state.cards
                              .map((card) => GestureDetector(
                                    onTap: () =>
                                        setState(() => _cardId = card.id),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      margin:
                                          const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(14),
                                      decoration: _cardId == card.id
                                          ? D.glowCard(
                                              accent: D.cyan,
                                              bg: D.cardBg,
                                              radius: D.r16)
                                          : D.plainCard(radius: D.r16),
                                      child: Row(
                                        children: [
                                          const Icon(
                                              Icons.credit_card_rounded,
                                              color: D.cyan),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              '${card.nickname}  ••••  ${card.maskedPan.length >= 4 ? card.maskedPan.substring(card.maskedPan.length - 4) : card.maskedPan}',
                                              style: const TextStyle(
                                                  color: D.white,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                          if (_cardId == card.id)
                                            const Icon(
                                                Icons.check_circle_rounded,
                                                color: D.cyan,
                                                size: 20),
                                        ],
                                      ),
                                    ),
                                  ))
                              .toList(),
                        );
                      },
                    ),

                    // Reminder
                    _label('Remind me before renewal'),
                    _box(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Days before renewal',
                                  style: TextStyle(
                                      color: D.textSub,
                                      fontWeight: FontWeight.w600)),
                              Text('$_remindDays days',
                                  style: const TextStyle(
                                      color: D.cyan,
                                      fontWeight: FontWeight.w800)),
                            ],
                          ),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: D.cyan,
                              inactiveTrackColor: D.cyan.withOpacity(0.15),
                              thumbColor: D.cyan,
                              overlayColor: D.cyan.withOpacity(0.15),
                            ),
                            child: Slider(
                              value: _remindDays.toDouble(),
                              min: 1,
                              max: 14,
                              divisions: 13,
                              onChanged: (v) =>
                                  setState(() => _remindDays = v.round()),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: _canSubmit ? _submit : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _canSubmit
                              ? D.orange
                              : const Color(0xFF2A2A2A),
                          foregroundColor: D.white,
                          shape: RoundedRectangleBorder(borderRadius: D.r20),
                          elevation: 0,
                        ),
                        child: const Text('Add Subscription',
                            style: TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}