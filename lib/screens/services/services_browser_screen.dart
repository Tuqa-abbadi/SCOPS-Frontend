import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/payment/payment_bloc.dart';
import '../../blocs/reviews/reviews_bloc.dart';
import '../../blocs/services/services_bloc.dart';
import '../../blocs/subscription/subscription_bloc.dart';
import '../../blocs/wallet/wallet_bloc.dart';
import '../reviews/write_review_sheet.dart';

// ── Billing cycle label helpers ───────────────────────────────────────────────

String _cycleShort(String cycle) {
  switch (cycle.toLowerCase()) {
    case 'weekly':
      return 'wk';
    case 'yearly':
      return 'yr';
    default:
      return 'mo';
  }
}

String _cycleFull(String cycle) {
  switch (cycle.toLowerCase()) {
    case 'weekly':
      return 'week';
    case 'yearly':
      return 'year';
    default:
      return 'month';
  }
}

// ── Service avatar (network image with emoji fallback) ────────────────────────

Widget _serviceAvatar(ServiceModel svc, {double size = 58}) {
  final hasLogo = svc.logoUrl != null && svc.logoUrl!.isNotEmpty;
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.black.withValues(alpha: 0.35),
      border: Border.all(color: svc.color.withValues(alpha: 0.45)),
      boxShadow: [
        BoxShadow(
          color: svc.color.withValues(alpha: 0.20),
          blurRadius: 22,
          spreadRadius: -4,
        ),
      ],
    ),
    child: ClipOval(
      child: hasLogo
          ? Image.network(
              svc.logoUrl!,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Center(
                child: Text(svc.icon,
                    style: TextStyle(fontSize: size * 0.48)),
              ),
            )
          : Center(
              child: Text(svc.icon,
                  style: TextStyle(fontSize: size * 0.48)),
            ),
    ),
  );
}

// ── Screen ────────────────────────────────────────────────────────────────────

class ServicesBrowserScreen extends StatefulWidget {
  const ServicesBrowserScreen({super.key});

  @override
  State<ServicesBrowserScreen> createState() => _ServicesBrowserScreenState();
}

class _ServicesBrowserScreenState extends State<ServicesBrowserScreen> {
  final _search = TextEditingController();

  static const _bg     = Color(0xFF020812);
  static const _card   = Color(0xFF07111C);
  static const _cyan   = Color(0xFF18E8F2);
  static const _orange = Color(0xFFFF5A14);
  static const _white  = Colors.white;
  static const _muted  = Color(0xFF9BA4B0);

  @override
  void initState() {
    super.initState();
    context.read<ServicesBloc>().add(const ServicesLoaded());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  // ── Category icon mapping ─────────────────────────────────────────────────
  IconData _categoryIcon(String name) {
    final c = name.toLowerCase();
    if (c.contains('entertain') || c.contains('stream') || c.contains('video')) {
      return Icons.movie_creation_outlined;
    }
    if (c.contains('music') || c.contains('audio') || c.contains('sound')) {
      return Icons.music_note_rounded;
    }
    if (c.contains('product') || c.contains('work') || c.contains('office')) {
      return Icons.work_outline_rounded;
    }
    if (c.contains('cloud') || c.contains('storage')) {
      return Icons.cloud_outlined;
    }
    if (c.contains('dev') || c.contains('code') || c.contains('tech')) {
      return Icons.code_rounded;
    }
    if (c.contains('design') || c.contains('creat') || c.contains('art')) {
      return Icons.brush_outlined;
    }
    if (c.contains('ai') || c.contains('intelligen')) {
      return Icons.auto_awesome_outlined;
    }
    if (c.contains('game') || c.contains('gaming')) {
      return Icons.sports_esports_outlined;
    }
    if (c.contains('fit') || c.contains('health') || c.contains('sport')) {
      return Icons.fitness_center_outlined;
    }
    if (c.contains('financ') || c.contains('bank') || c.contains('money')) {
      return Icons.account_balance_outlined;
    }
    return Icons.apps_outlined;
  }

  // ── Header (search bar) ───────────────────────────────────────────────────
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Browse Services',
                      style: TextStyle(
                        color: _white,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Find and add subscriptions',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _card.withValues(alpha: 0.92),
                  shape: BoxShape.circle,
                  border: Border.all(color: _cyan.withValues(alpha: 0.30)),
                  boxShadow: [
                    BoxShadow(color: _cyan.withValues(alpha: 0.12), blurRadius: 20),
                  ],
                ),
                child: const Icon(Icons.tune_rounded, color: _cyan, size: 25),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            height: 58,
            decoration: BoxDecoration(
              color: _card.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: TextField(
              controller: _search,
              onChanged: (q) =>
                  context.read<ServicesBloc>().add(ServicesSearchChanged(q)),
              style: const TextStyle(color: _white, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Search services...',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 16,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Colors.white.withValues(alpha: 0.55),
                  size: 28,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Category chips ────────────────────────────────────────────────────────
  Widget _categoryChips() {
    return BlocBuilder<ServicesBloc, ServicesState>(
      buildWhen: (prev, curr) {
        if (prev is ServicesDataLoaded && curr is ServicesDataLoaded) {
          return prev.categories != curr.categories ||
              prev.selectedCategoryId != curr.selectedCategoryId ||
              prev.categoriesError != curr.categoriesError;
        }
        return prev.runtimeType != curr.runtimeType;
      },
      builder: (context, state) {
        if (state is ServicesInitial || state is ServicesLoading) {
          return _skeletonChips();
        }
        if (state is ServicesDataLoaded) {
          if (state.categories.isEmpty && state.categoriesError != null) {
            return _chipsError(state.categoriesError!);
          }
          return _chipsList(state);
        }
        return const SizedBox(height: 54);
      },
    );
  }

  Widget _skeletonChips() {
    return SizedBox(
      height: 54,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 5,
        itemBuilder: (_, __) => Container(
          width: 88,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
        ),
      ),
    );
  }

  Widget _chipsError(String message) {
    return SizedBox(
      height: 54,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: _orange.withValues(alpha: 0.80), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: _muted.withValues(alpha: 0.80),
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
            ),
            GestureDetector(
              onTap: () =>
                  context.read<ServicesBloc>().add(const ServicesLoaded()),
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text('Retry',
                    style: TextStyle(
                        color: _cyan,
                        fontSize: 13,
                        fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chipsList(ServicesDataLoaded state) {
    return SizedBox(
      height: 54,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _chip(
            label: 'All',
            icon: Icons.grid_view_rounded,
            isActive: state.selectedCategoryId == null,
            onTap: () => context
                .read<ServicesBloc>()
                .add(const ServicesCategorySelected(null)),
          ),
          ...state.categories.map(
            (cat) => _chip(
              label: cat.name,
              icon: _categoryIcon(cat.name),
              isActive: state.selectedCategoryId == cat.id,
              onTap: () => context
                  .read<ServicesBloc>()
                  .add(ServicesCategorySelected(cat.id)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? _cyan.withValues(alpha: 0.12) : _card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? _cyan.withValues(alpha: 0.95)
                : Colors.white.withValues(alpha: 0.10),
            width: isActive ? 1.4 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: _cyan.withValues(alpha: 0.28),
                    blurRadius: 18,
                    spreadRadius: -2,
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? _cyan : _muted, size: 20),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 100),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isActive ? _cyan : Colors.white.withValues(alpha: 0.78),
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section title ─────────────────────────────────────────────────────────
  Widget _sectionTitle() {
    return BlocBuilder<ServicesBloc, ServicesState>(
      buildWhen: (prev, curr) {
        if (prev is ServicesDataLoaded && curr is ServicesDataLoaded) {
          return prev.selectedCategoryId != curr.selectedCategoryId ||
              prev.categories != curr.categories;
        }
        return false;
      },
      builder: (context, state) {
        String title = 'All Services';
        if (state is ServicesDataLoaded && state.selectedCategoryId != null) {
          final cat = state.categories
              .where((c) => c.id == state.selectedCategoryId)
              .firstOrNull;
          if (cat != null) title = '${cat.name} Services';
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
          child: Row(
            children: [
              Text(title,
                  style: const TextStyle(
                      color: _white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900)),
              const Spacer(),
              Text('Sort: ',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
              const Text('A to Z',
                  style: TextStyle(
                      color: _cyan,
                      fontSize: 14,
                      fontWeight: FontWeight.w900)),
              const SizedBox(width: 5),
              const Icon(Icons.keyboard_arrow_down_rounded,
                  color: _cyan, size: 20),
            ],
          ),
        );
      },
    );
  }

  // ── Services list area ────────────────────────────────────────────────────
  Widget _servicesList(BuildContext context, ServicesState state) {
    if (state is ServicesInitial || state is ServicesLoading) {
      return const Center(child: CircularProgressIndicator(color: _cyan));
    }

    final loaded = state as ServicesDataLoaded;

    if (loaded.servicesLoading) {
      return const Center(child: CircularProgressIndicator(color: _cyan));
    }

    if (loaded.servicesError != null) {
      return _servicesError(context, loaded);
    }

    if (loaded.filteredServices.isEmpty) {
      return Center(
        child: Text(
          loaded.searchQuery.isNotEmpty
              ? 'No services match "${loaded.searchQuery}".'
              : 'No services found.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: _muted),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
      itemCount: loaded.filteredServices.length,
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: _serviceCard(loaded.filteredServices[i]),
      ),
    );
  }

  Widget _servicesError(BuildContext context, ServicesDataLoaded state) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded,
              color: _orange.withValues(alpha: 0.70), size: 48),
          const SizedBox(height: 16),
          Text(
            state.servicesError!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _muted, fontSize: 14),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => context
                .read<ServicesBloc>()
                .add(ServicesCategorySelected(state.selectedCategoryId)),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: _cyan.withValues(alpha: 0.65)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded, color: _cyan, size: 18),
                  SizedBox(width: 8),
                  Text('Try Again',
                      style: TextStyle(
                          color: _cyan, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Service card ──────────────────────────────────────────────────────────
  Widget _serviceCard(ServiceModel svc) {
    return GestureDetector(
      onTap: () => _showDetail(context, svc),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _card.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: svc.color.withValues(alpha: 0.32)),
          boxShadow: [
            BoxShadow(
              color: svc.color.withValues(alpha: 0.12),
              blurRadius: 22,
              spreadRadius: -6,
              offset: const Offset(-3, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _serviceAvatar(svc),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    svc.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: _white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    svc.category.isNotEmpty ? svc.category : 'Service',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: _muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${svc.startingPrice.toStringAsFixed(2)} /${_cycleShort(svc.billingCycle)}',
                    style: const TextStyle(
                        color: _cyan,
                        fontSize: 14,
                        fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFF0B1420),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: const Icon(Icons.add, color: _cyan, size: 30),
            ),
          ],
        ),
      ),
    );
  }

  // ── Navigation helpers ────────────────────────────────────────────────────

  void _showDetail(BuildContext context, ServiceModel svc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<ServicesBloc>()),
          BlocProvider.value(value: context.read<SubscriptionBloc>()),
          BlocProvider.value(value: context.read<WalletBloc>()),
          BlocProvider.value(value: context.read<ReviewsBloc>()),
          BlocProvider.value(value: context.read<PaymentBloc>()),
        ],
        child: _DetailSheet(svc: svc),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const SizedBox(height: 22),
          _categoryChips(),
          const SizedBox(height: 22),
          _sectionTitle(),
          Expanded(
            child: BlocBuilder<ServicesBloc, ServicesState>(
              builder: _servicesList,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Detail bottom sheet ───────────────────────────────────────────────────────

class _DetailSheet extends StatefulWidget {
  const _DetailSheet({required this.svc});

  final ServiceModel svc;

  @override
  State<_DetailSheet> createState() => _DetailSheetState();
}

class _DetailSheetState extends State<_DetailSheet> {
  static const _card   = Color(0xFF07111C);
  static const _cyan   = Color(0xFF18E8F2);
  static const _orange = Color(0xFFFF5A14);
  static const _white  = Colors.white;
  static const _muted  = Color(0xFF9BA4B0);

  int? get _serviceIdInt => int.tryParse(widget.svc.id);

  @override
  void initState() {
    super.initState();
    context.read<ServicesBloc>().add(ServiceDetailRequested(widget.svc.id));
    final sid = _serviceIdInt;
    if (sid != null) {
      context.read<ReviewsBloc>().add(ReviewsForServiceRequested(sid));
    }
  }

  @override
  void dispose() {
    context.read<PaymentBloc>().add(const PaymentReset());
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  // ── Payment confirmation dialog ────────────────────────────────────────────

  Future<void> _showConfirmDialog(
      BuildContext context, PaymentIntentReady state) async {
    final bloc = context.read<PaymentBloc>();

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: _card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Confirm Payment',
          style: TextStyle(
              color: _white, fontWeight: FontWeight.w900, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are about to pay for ${widget.svc.name}.',
              style: const TextStyle(color: _muted, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 14),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _cyan.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _cyan.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long_outlined,
                      color: _cyan, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Payment ID: ${state.paymentId}',
                    style: const TextStyle(
                        color: _cyan,
                        fontWeight: FontWeight.w800,
                        fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Do you want to confirm this payment?',
              style: TextStyle(color: _muted, fontSize: 13, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('No',
                style: TextStyle(color: _muted, fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _cyan,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Yes, Pay',
                style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      bloc.add(PaymentConfirmed(state.paymentId));
    } else {
      bloc.add(const PaymentDeclined());
    }
  }

  @override
  Widget build(BuildContext context) {
    final svc = widget.svc;
    return BlocListener<PaymentBloc, PaymentState>(
      listener: (context, state) {
        if (state is PaymentIntentReady) {
          _showConfirmDialog(context, state);
        } else if (state is PaymentSuccess) {
          // Capture messenger before pop — context is deactivated after pop.
          final messenger = ScaffoldMessenger.of(context);
          Navigator.of(context).pop();
          messenger.showSnackBar(
            SnackBar(
              content: const Text('Payment confirmed successfully!'),
              backgroundColor: _cyan.withValues(alpha: 0.90),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        } else if (state is PaymentFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: _orange.withValues(alpha: 0.90),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
          context.read<PaymentBloc>().add(const PaymentReset());
        }
      },
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: const BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Fixed header ─────────────────────────────────────────────────
          _buildHeader(svc),

          // ── Scrollable body (description + plans) ────────────────────────
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (svc.description.isNotEmpty) ...[
                    Text(
                      svc.description,
                      style: const TextStyle(
                          color: _muted, fontSize: 14, height: 1.55),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Plans — rebuilds only when detail state changes.
                  BlocBuilder<ServicesBloc, ServicesState>(
                    buildWhen: (prev, curr) {
                      if (prev is ServicesDataLoaded &&
                          curr is ServicesDataLoaded) {
                        return prev.detailLoading != curr.detailLoading ||
                            prev.detailError != curr.detailError ||
                            prev.detailPlans != curr.detailPlans ||
                            prev.selectedPlanId != curr.selectedPlanId ||
                            prev.detailServiceId != curr.detailServiceId;
                      }
                      return false;
                    },
                    builder: (context, state) =>
                        _buildPlansSection(context, state),
                  ),

                  const SizedBox(height: 28),

                  // ── Reviews section ──────────────────────────────────────
                  const Text(
                    'Reviews',
                    style: TextStyle(
                      color: _white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  BlocBuilder<ReviewsBloc, ReviewsState>(
                    builder: (context, state) =>
                        _buildReviewsSection(context, state),
                  ),

                  // ── Write review (if eligible) ───────────────────────────
                  const SizedBox(height: 8),
                  BlocBuilder<ReviewsBloc, ReviewsState>(
                    builder: (context, reviewState) =>
                        BlocBuilder<SubscriptionBloc, SubscriptionState>(
                      builder: (context, subState) =>
                          _buildWriteReviewButton(context, subState, reviewState),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ── Fixed CTA ────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              26,
              12,
              26,
              MediaQuery.of(context).viewInsets.bottom + 26,
            ),
            child: _buildCtaButton(context),
          ),
        ],
        ),
      ),
    );
  }

  // ── Header (drag handle + logo + price badge) ─────────────────────────────

  Widget _buildHeader(ServiceModel svc) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 14, 26, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Logo + name + category
          Row(
            children: [
              _serviceAvatar(svc, size: 70),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      svc.name,
                      style: const TextStyle(
                          color: _white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      svc.category.isNotEmpty ? svc.category : 'Service',
                      style: TextStyle(
                          color: svc.color,
                          fontSize: 13,
                          fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Starting price badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: _cyan.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _cyan.withValues(alpha: 0.30)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '\$${svc.startingPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: _cyan,
                      fontSize: 22,
                      fontWeight: FontWeight.w900),
                ),
                const SizedBox(width: 4),
                Text(
                  '/ ${_cycleFull(svc.billingCycle)}',
                  style: const TextStyle(color: _muted, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Plans section dispatcher ──────────────────────────────────────────────

  Widget _buildPlansSection(BuildContext context, ServicesState state) {
    if (state is! ServicesDataLoaded) return const SizedBox.shrink();

    if (state.detailLoading) return _buildPlansLoading();

    if (state.detailError != null &&
        state.detailServiceId == widget.svc.id) {
      return _buildPlansError(context, state.detailError!);
    }

    final plans = state.detailServiceId == widget.svc.id
        ? state.detailPlans
        : const <ServicePlan>[];

    if (plans.isEmpty) return _buildPlansEmpty();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose a Plan',
          style: TextStyle(
              color: _white, fontSize: 17, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 14),
        ...plans.map(
          (plan) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildPlanCard(
              context,
              plan,
              isSelected: state.selectedPlanId == plan.id,
            ),
          ),
        ),
      ],
    );
  }

  // ── Loading state ─────────────────────────────────────────────────────────

  Widget _buildPlansLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose a Plan',
          style: TextStyle(
              color: _white, fontSize: 17, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 24),
        Center(
          child: Column(
            children: [
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                    color: _cyan, strokeWidth: 2.5),
              ),
              const SizedBox(height: 12),
              Text(
                'Loading plans...',
                style: TextStyle(
                    color: _muted.withValues(alpha: 0.80), fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ── Error state ───────────────────────────────────────────────────────────

  Widget _buildPlansError(BuildContext context, String error) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose a Plan',
          style: TextStyle(
              color: _white, fontSize: 17, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 16),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _orange.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _orange.withValues(alpha: 0.28)),
          ),
          child: Row(
            children: [
              Icon(Icons.error_outline_rounded,
                  color: _orange.withValues(alpha: 0.80), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  error,
                  style: TextStyle(
                      color: _muted.withValues(alpha: 0.90),
                      fontSize: 13,
                      height: 1.4),
                ),
              ),
              GestureDetector(
                onTap: () => context
                    .read<ServicesBloc>()
                    .add(ServiceDetailRequested(widget.svc.id)),
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    'Retry',
                    style: TextStyle(
                        color: _cyan,
                        fontWeight: FontWeight.w900,
                        fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────

  Widget _buildPlansEmpty() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded,
                color: _muted.withValues(alpha: 0.60), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No plans returned by API yet.',
                style: TextStyle(
                    color: _muted.withValues(alpha: 0.80), fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Plan card ─────────────────────────────────────────────────────────────

  Widget _buildPlanCard(
    BuildContext context,
    ServicePlan plan, {
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => context
          .read<ServicesBloc>()
          .add(ServicePlanSelected(isSelected ? null : plan.id)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? _cyan.withValues(alpha: 0.09)
              : const Color(0xFF0B1420),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? _cyan
                : Colors.white.withValues(alpha: 0.10),
            width: isSelected ? 1.6 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _cyan.withValues(alpha: 0.18),
                    blurRadius: 18,
                    spreadRadius: -4,
                  ),
                ]
              : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.planName,
                    style: TextStyle(
                      color: isSelected ? _cyan : _white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '\$${plan.price.toStringAsFixed(2)} / ${_cycleFull(plan.billingCycle)}',
                    style: TextStyle(
                      color: isSelected
                          ? _cyan.withValues(alpha: 0.80)
                          : _muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (plan.features != null &&
                      plan.features!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      plan.features!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.50),
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? _cyan : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? _cyan
                      : Colors.white.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check,
                      color: Colors.black, size: 13)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ── Reviews section ───────────────────────────────────────────────────────

  Widget _buildReviewsSection(BuildContext context, ReviewsState state) {
    if (state is! ReviewsData) {
      return const Center(
        child: SizedBox(
          width: 24, height: 24,
          child: CircularProgressIndicator(color: _cyan, strokeWidth: 2.5),
        ),
      );
    }

    final sid = _serviceIdInt;

    if (state.detailLoading && state.detailServiceId == sid) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: SizedBox(
            width: 24, height: 24,
            child: CircularProgressIndicator(color: _cyan, strokeWidth: 2.5),
          ),
        ),
      );
    }

    if (state.detailError != null && state.detailServiceId == sid) {
      return _reviewsError(context, state.detailError!);
    }

    final reviews = state.detailServiceId == sid ? state.detailReviews : const [];

    if (reviews.isEmpty) {
      return _reviewsEmpty();
    }

    return Column(
      children: reviews
          .map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _reviewCard(r),
              ))
          .toList(),
    );
  }

  Widget _reviewsEmpty() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Icon(Icons.rate_review_outlined,
              color: _muted.withValues(alpha: 0.55), size: 20),
          const SizedBox(width: 12),
          Text('No reviews yet. Be the first!',
              style: TextStyle(
                  color: _muted.withValues(alpha: 0.80), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _reviewsError(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _orange.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _orange.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded,
              color: _orange.withValues(alpha: 0.80), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(error,
                style: TextStyle(
                    color: _muted.withValues(alpha: 0.90),
                    fontSize: 13,
                    height: 1.4)),
          ),
          GestureDetector(
            onTap: () {
              final sid = _serviceIdInt;
              if (sid != null) {
                context.read<ReviewsBloc>().add(ReviewsForServiceRequested(sid));
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text('Retry',
                  style: TextStyle(
                      color: _cyan,
                      fontWeight: FontWeight.w900,
                      fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewCard(dynamic r) {
    final rating    = r.rating as int;
    final comment   = r.comment as String?;
    final createdAt = r.createdAt as DateTime?;
    final dateStr   = createdAt != null
        ? '${createdAt.day}/${createdAt.month}/${createdAt.year}'
        : '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            ...List.generate(5, (i) {
              final filled = i < (rating / 2).round();
              return Icon(
                filled ? Icons.star_rounded : Icons.star_outline_rounded,
                color: const Color(0xFFFFB020),
                size: 15,
              );
            }),
            const Spacer(),
            if (dateStr.isNotEmpty)
              Text(dateStr,
                  style: TextStyle(
                      color: _muted.withValues(alpha: 0.65), fontSize: 11)),
          ]),
          if (comment != null && comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(comment,
                style: const TextStyle(
                    color: _white, fontSize: 13, height: 1.45)),
          ],
        ],
      ),
    );
  }

  // ── Write review button (shown only when user has an eligible subscription) ─

  Widget _buildWriteReviewButton(
    BuildContext context,
    SubscriptionState subState,
    ReviewsState reviewState,
  ) {
    if (subState is! SubscriptionData) return const SizedBox.shrink();
    if (reviewState is! ReviewsData) return const SizedBox.shrink();

    final sid = _serviceIdInt;
    if (sid == null) return const SizedBox.shrink();

    SubscriptionModel? eligible;
    for (final sub in subState.subscriptions) {
      if (sub.serviceId != sid) continue;
      if (!sub.isActive) continue;
      final startDate = sub.startDate;
      if (startDate == null) continue;
      final days = DateTime.now().difference(startDate).inDays;
      final hasRenewed = sub.nextRenewal.isBefore(DateTime.now());
      if (days < 7 && !hasRenewed) continue;
      if (reviewState.hasReviewForSubscription(sub.apiId)) continue;
      eligible = sub;
      break;
    }

    if (eligible == null) return const SizedBox.shrink();

    final sub = eligible;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: GestureDetector(
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => BlocProvider.value(
            value: context.read<ReviewsBloc>(),
            child: WriteReviewSheet(subscription: sub, serviceId: sid),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: const Color(0xFFFFB020).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: const Color(0xFFFFB020).withValues(alpha: 0.35)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star_outline_rounded,
                  color: Color(0xFFFFB020), size: 18),
              SizedBox(width: 8),
              Text(
                'Write a Review',
                style: TextStyle(
                  color: Color(0xFFFFB020),
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── CTA button ────────────────────────────────────────────────────────────

  Widget _buildCtaButton(BuildContext context) {
    return BlocBuilder<PaymentBloc, PaymentState>(
      builder: (context, paymentState) {
        final isLoading = paymentState is PaymentIntentLoading ||
            paymentState is PaymentConfirming;

        return Container(
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: isLoading
                  ? [
                      const Color(0xFFFF7A1F).withValues(alpha: 0.55),
                      const Color(0xFFFF5A14).withValues(alpha: 0.55),
                    ]
                  : const [Color(0xFFFF7A1F), Color(0xFFFF5A14)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF5A14).withValues(alpha: 0.35),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    final sid = _serviceIdInt;
                    if (sid != null) {
                      context
                          .read<PaymentBloc>()
                          .add(PaymentIntentRequested(sid));
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.black,
              disabledBackgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text(
                    'Add Subscription',
                    style:
                        TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                  ),
          ),
        );
      },
    );
  }
}
