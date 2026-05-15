import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/services/services_bloc.dart';
import '../../blocs/subscription/subscription_bloc.dart';
import '../../blocs/wallet/wallet_bloc.dart';
import '../subscription/add_subscription_screen.dart';

class ServicesBrowserScreen extends StatefulWidget {
  const ServicesBrowserScreen({super.key});

  @override
  State<ServicesBrowserScreen> createState() => _ServicesBrowserScreenState();
}

class _ServicesBrowserScreenState extends State<ServicesBrowserScreen> {
  final _search = TextEditingController();

  static const _bg = Color(0xFF020812);
  static const _card = Color(0xFF07111C);
  static const _cyan = Color(0xFF18E8F2);
  static const _orange = Color(0xFFFF5A14);
  static const _white = Colors.white;
  static const _muted = Color(0xFF9BA4B0);

  final _cats = const [
    'All',
    'Entertainment',
    'Music',
    'Productivity',
    'Cloud Storage',
    'Developer',
  ];

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

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'Entertainment':
        return Icons.movie_creation_outlined;
      case 'Music':
        return Icons.music_note_rounded;
      case 'Productivity':
        return Icons.work_outline_rounded;
      case 'Cloud Storage':
        return Icons.cloud_outlined;
      case 'Developer':
        return Icons.code_rounded;
      default:
        return Icons.grid_view_rounded;
    }
  }

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
                  color: _card.withOpacity(0.92),
                  shape: BoxShape.circle,
                  border: Border.all(color: _cyan.withOpacity(0.30)),
                  boxShadow: [
                    BoxShadow(
                      color: _cyan.withOpacity(0.12),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: _cyan,
                  size: 25,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            height: 58,
            decoration: BoxDecoration(
              color: _card.withOpacity(0.92),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.10)),
            ),
            child: TextField(
              controller: _search,
              onChanged: (q) =>
                  context.read<ServicesBloc>().add(ServicesSearchChanged(q)),
              style: const TextStyle(
                color: _white,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'Search services...',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.45),
                  fontSize: 16,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Colors.white.withOpacity(0.55),
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

  Widget _categoryChips() {
    return BlocBuilder<ServicesBloc, ServicesState>(
      builder: (context, state) {
        final selected =
            state is ServicesDataLoaded ? state.selectedCategory : 'All';

        return SizedBox(
          height: 54,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _cats.length,
            itemBuilder: (context, i) {
              final cat = _cats[i];
              final active = cat == selected;

              return GestureDetector(
                onTap: () =>
                    context.read<ServicesBloc>().add(ServicesCategoryChanged(cat)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: active ? _cyan.withOpacity(0.12) : _card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: active
                          ? _cyan.withOpacity(0.95)
                          : Colors.white.withOpacity(0.10),
                      width: active ? 1.4 : 1,
                    ),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: _cyan.withOpacity(0.28),
                              blurRadius: 18,
                              spreadRadius: -2,
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _categoryIcon(cat),
                        color: active ? _cyan : _muted,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        cat == 'Cloud Storage' ? 'Cloud' : cat,
                        style: TextStyle(
                          color: active ? _cyan : Colors.white.withOpacity(0.78),
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _sectionTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Row(
        children: [
          const Text(
            'All Services',
            style: TextStyle(
              color: _white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          Text(
            'Sort: ',
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Text(
            'A to Z',
            style: TextStyle(
              color: _cyan,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 5),
          const Icon(Icons.keyboard_arrow_down_rounded, color: _cyan, size: 20),
        ],
      ),
    );
  }

  Widget _logoPlaceholder(ServiceModel svc) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.35),
        border: Border.all(color: svc.color.withOpacity(0.45)),
        boxShadow: [
          BoxShadow(
            color: svc.color.withOpacity(0.20),
            blurRadius: 22,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Center(
        child: Text(
          svc.icon,
          style: const TextStyle(fontSize: 28),
        ),
      ),
    );
  }

  Widget _serviceCard(ServiceModel svc) {
    return GestureDetector(
      onTap: () => _showDetail(context, svc),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _card.withOpacity(0.96),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: svc.color.withOpacity(0.32),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: svc.color.withOpacity(0.12),
              blurRadius: 22,
              spreadRadius: -6,
              offset: const Offset(-3, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _logoPlaceholder(svc),
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
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    svc.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${svc.startingPrice.toStringAsFixed(2)} /mo',
                    style: const TextStyle(
                      color: _cyan,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
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
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: const Icon(Icons.add, color: _cyan, size: 30),
            ),
          ],
        ),
      ),
    );
  }

  Widget _manualCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 22),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _cyan.withOpacity(0.65)),
          boxShadow: [
            BoxShadow(
              color: _cyan.withOpacity(0.12),
              blurRadius: 20,
              spreadRadius: -4,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _cyan.withOpacity(0.75)),
              ),
              child: const Icon(Icons.add, color: _cyan, size: 30),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Can't find your service?",
                    style: TextStyle(
                      color: _white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Add any subscription manually\nin just a few taps.',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _cyan.withOpacity(0.85)),
              ),
              child: const Row(
                children: [
                  Text(
                    'Add Manually',
                    style: TextStyle(
                      color: _cyan,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward_rounded, color: _cyan, size: 22),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openManualAdd() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<SubscriptionBloc>()),
            BlocProvider.value(value: context.read<WalletBloc>()),
          ],
          child: const AddSubscriptionScreen(),
        ),
      ),
    );
  }

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
              builder: (context, state) {
                if (state is ServicesLoading || state is ServicesInitial) {
                  return const Center(
                    child: CircularProgressIndicator(color: _cyan),
                  );
                }

                final loaded = state as ServicesDataLoaded;

                if (loaded.filteredServices.isEmpty) {
                  return const Center(
                    child: Text(
                      'No services found.',
                      style: TextStyle(color: _muted),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                  itemCount: loaded.filteredServices.length + 1,
                  itemBuilder: (context, i) {
                    if (i == loaded.filteredServices.length) {
                      return GestureDetector(
                        onTap: _openManualAdd,
                        child: _manualCard(),
                      );
                    }

                    final svc = loaded.filteredServices[i];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _serviceCard(svc),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

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
        ],
        child: _DetailSheet(svc: svc),
      ),
    );
  }
}

class _DetailSheet extends StatelessWidget {
  const _DetailSheet({required this.svc});

  final ServiceModel svc;

  static const _card = Color(0xFF07111C);
  static const _cyan = Color(0xFF18E8F2);
  static const _orange = Color(0xFFFF5A14);
  static const _white = Colors.white;
  static const _muted = Color(0xFF9BA4B0);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.68,
      padding: const EdgeInsets.all(26),
      decoration: const BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.35),
                  border: Border.all(color: svc.color.withOpacity(0.45)),
                  boxShadow: [
                    BoxShadow(
                      color: svc.color.withOpacity(0.22),
                      blurRadius: 24,
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(svc.icon, style: const TextStyle(fontSize: 34)),
                ),
              ),
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
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      svc.category,
                      style: TextStyle(
                        color: svc.color,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            svc.description,
            style: const TextStyle(
              color: _muted,
              fontSize: 14,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Available Plans',
            style: TextStyle(
              color: _white,
              fontWeight: FontWeight.w900,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: svc.plans.map((p) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: _cyan.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _cyan.withOpacity(0.35)),
                ),
                child: Text(
                  p,
                  style: const TextStyle(
                    color: _cyan,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Text(
            'Starting from \$${svc.startingPrice.toStringAsFixed(2)}/month',
            style: const TextStyle(color: _muted, fontSize: 13),
          ),
          const Spacer(),
          Container(
            height: 56,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFFFF7A1F), _orange],
              ),
              boxShadow: [
                BoxShadow(
                  color: _orange.withOpacity(0.35),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(
                      providers: [
                        BlocProvider.value(
                          value: context.read<SubscriptionBloc>(),
                        ),
                        BlocProvider.value(value: context.read<WalletBloc>()),
                      ],
                      child: AddSubscriptionScreen(preSelectedService: svc),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Add Subscription',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}