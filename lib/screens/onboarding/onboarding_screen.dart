import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/onboarding/onboarding_bloc.dart';
import '../auth/auth_choice_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  static const _cyan = Color(0xFF18E8F2);
  static const _orange = Color(0xFFFF5A14);
  static const _dark = Color(0xFF020812);

  final pages = const [
    _OnboardingData(
      title1: 'Track All',
      title2: 'Your',
      highlight: 'Cards',
      description:
          'Keep every payment card organized in one place with clear financial control.',
      type: _GraphicType.cards,
      buttonText: 'Next',
      isCyanButton: false,
    ),
    _OnboardingData(
      title1: 'Never Miss',
      title2: '',
      highlight: 'a Payment',
      description: 'Get notified before every renewal and upcoming charge.',
      type: _GraphicType.bell,
      buttonText: 'Next Step',
      isCyanButton: false,
    ),
    _OnboardingData(
      title1: 'Understand Your',
      title2: '',
      highlight: 'Spending',
      description:
          'See where your money goes each month through visual insights.',
      type: _GraphicType.chart,
      buttonText: 'Next',
      isCyanButton: false,
    ),
    _OnboardingData(
      title1: 'Your Data,',
      title2: '',
      highlight: 'Your Control',
      description:
          'Security-focused tracking keeps your financial data protected.',
      type: _GraphicType.shield,
      buttonText: 'Get Started',
      isCyanButton: true,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _brand() {
    return Row(
      children: [
        Image.asset(
          'assets/images/owl_cyan.png',
          width: 27,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.auto_awesome, color: _cyan, size: 27),
        ),
        const SizedBox(width: 8),
        Image.asset(
          'assets/images/scops_white.png',
          width: 82,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Text(
            'scops',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _dots(int currentIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pages.length, (index) {
        final active = currentIndex == index;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: active ? 22 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: active ? _cyan : Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(20),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: _cyan.withOpacity(0.55),
                      blurRadius: 10,
                    ),
                  ]
                : [],
          ),
        );
      }),
    );
  }

  Widget _button(_OnboardingData page) {
    final isCyan = page.isCyanButton;

    return Container(
      height: 61,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: isCyan
              ? const [Color(0xFF20DFF1), Color(0xFF11C9DF)]
              : const [Color(0xFFFF7A1F), Color(0xFFFF4B09)],
        ),
        boxShadow: [
          BoxShadow(
            color: (isCyan ? _cyan : _orange).withOpacity(0.38),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () =>
            context.read<OnboardingBloc>().add(const OnboardingNextPage()),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: isCyan ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        child: Text(
          page.buttonText,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _title(_OnboardingData page) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 30,
          height: 1.16,
          fontWeight: FontWeight.w900,
        ),
        children: [
          TextSpan(text: '${page.title1}\n'),
          if (page.title2.isNotEmpty) TextSpan(text: '${page.title2} '),
          TextSpan(
            text: page.highlight,
            style: const TextStyle(color: _cyan),
          ),
        ],
      ),
    );
  }

  Widget _graphic(_GraphicType type) {
    switch (type) {
      case _GraphicType.cards:
        return const _CardsGraphic();
      case _GraphicType.bell:
        return const _BellGraphic();
      case _GraphicType.chart:
        return const _ChartGraphic();
      case _GraphicType.shield:
        return const _ShieldGraphic();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingComplete) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AuthChoiceScreen()),
          );
        } else if (state is OnboardingInProgress) {
          _controller.animateToPage(
            state.currentIndex,
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeInOutCubic,
          );
        }
      },
      builder: (context, state) {
        final currentIndex =
            state is OnboardingInProgress ? state.currentIndex : 0;

        return Scaffold(
          backgroundColor: _dark,
          body: Stack(
            children: [
              const _BackgroundGlow(),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(26, 20, 26, 24),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _brand(),
                          const Spacer(),
                          TextButton(
                            onPressed: () => context
                                .read<OnboardingBloc>()
                                .add(const OnboardingSkip()),
                            child: const Text(
                              'SKIP',
                              style: TextStyle(
                                color: _cyan,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: PageView.builder(
                          controller: _controller,
                          itemCount: pages.length,
                          onPageChanged: (i) => context
                              .read<OnboardingBloc>()
                              .add(OnboardingPageChanged(i)),
                          itemBuilder: (context, index) {
                            final page = pages[index];

                            return Column(
                              children: [
                                const SizedBox(height: 92),
                                _graphic(page.type),
                                const Spacer(),
                                _title(page),
                                const SizedBox(height: 18),
                                Text(
                                  page.description,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.52),
                                    fontSize: 15,
                                    height: 1.55,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 70),
                              ],
                            );
                          },
                        ),
                      ),
                      _dots(currentIndex),
                      const SizedBox(height: 34),
                      _button(pages[currentIndex]),
                      const SizedBox(height: 20),
                      Text(
                        currentIndex == pages.length - 1
                            ? 'ENCRYPTED BY SCOPS CONTROL SYSTEM'
                            : ' ',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.22),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

enum _GraphicType { cards, bell, chart, shield }

class _OnboardingData {
  final String title1;
  final String title2;
  final String highlight;
  final String description;
  final _GraphicType type;
  final String buttonText;
  final bool isCyanButton;

  const _OnboardingData({
    required this.title1,
    required this.title2,
    required this.highlight,
    required this.description,
    required this.type,
    required this.buttonText,
    required this.isCyanButton,
  });
}

class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.25,
          colors: [
            Color(0xFF071B2A),
            Color(0xFF020812),
            Color(0xFF010409),
          ],
        ),
      ),
    );
  }
}

class _GradientBorderBox extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final double radius;
  final EdgeInsets padding;
  final Color background;
  final bool strongGradient;

  const _GradientBorderBox({
    required this.child,
    required this.width,
    required this.height,
    this.radius = 22,
    this.padding = const EdgeInsets.all(20),
    this.background = const Color(0xFF0A1724),
    this.strongGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(1.1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: strongGradient
            ? const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF18E8F2),
                  Color(0xFF123A42),
                  Color(0xFFFF5A14),
                ],
                stops: [0.0, 0.52, 1.0],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF18E8F2),
                  Color(0xFF0E3940),
                  Color(0xFF1E4A4F),
                ],
                stops: [0.0, 0.55, 1.0],
              ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF18E8F2).withOpacity(
              strongGradient ? 0.18 : 0.13,
            ),
            blurRadius: strongGradient ? 24 : 18,
            spreadRadius: -4,
          ),
          if (strongGradient)
            BoxShadow(
              color: const Color(0xFFFF5A14).withOpacity(0.14),
              blurRadius: 22,
              spreadRadius: -5,
            ),
        ],
      ),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(radius - 1.1),
        ),
        child: child,
      ),
    );
  }
}

class _CardsGraphic extends StatelessWidget {
  const _CardsGraphic();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 245,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 210,
            height: 150,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF18E8F2).withOpacity(0.24),
                  blurRadius: 90,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: const Offset(42, -23),
            child: Transform.rotate(
              angle: -0.04,
              child: const _CardBox(back: true),
            ),
          ),
          Transform.translate(
            offset: const Offset(-16, 23),
            child: Transform.rotate(
              angle: -0.08,
              child: const _CardBox(back: false),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardBox extends StatelessWidget {
  final bool back;

  const _CardBox({required this.back});

  @override
  Widget build(BuildContext context) {
    return _GradientBorderBox(
      width: back ? 242 : 260,
      height: back ? 158 : 170,
      radius: 22,
      strongGradient: true,
      background: const Color(0xFF071522),
      child: back
          ? Align(
              alignment: Alignment.topRight,
              child: Text(
                'SCOPS',
                style: TextStyle(
                  color: const Color(0xFF18E8F2).withOpacity(0.9),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.memory_rounded,
                      color: Color(0xFFFF5A14),
                      size: 22,
                    ),
                    Spacer(),
                    Text(
                      'SCOPS',
                      style: TextStyle(
                        color: Color(0xFF18E8F2),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Text(
                  '5892  ···  ····',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    letterSpacing: 1.7,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'ALEX ARCHITECT',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.50),
                    fontSize: 10,
                    letterSpacing: 1.8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }
}

class _BellGraphic extends StatelessWidget {
  const _BellGraphic();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 245,
      height: 245,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(size: const Size(220, 220), painter: _OrbitPainter()),
          _GradientBorderBox(
            width: 92,
            height: 92,
            radius: 28,
            padding: EdgeInsets.zero,
            background: const Color(0xFF0A1420),
            child: const Icon(
              Icons.notifications_rounded,
              color: Color(0xFF18E8F2),
              size: 46,
            ),
          ),
          const Positioned(
            top: 42,
            right: 30,
            child: _MiniBox(
              icon: Icons.flash_on_rounded,
              color: Color(0xFFFF5A14),
            ),
          ),
          const Positioned(
            bottom: 42,
            left: 30,
            child: _MiniBox(
              icon: Icons.credit_card_rounded,
              color: Color(0xFF18E8F2),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartGraphic extends StatelessWidget {
  const _ChartGraphic();

  @override
  Widget build(BuildContext context) {
    final heights = [78.0, 112.0, 164.0, 116.0, 88.0];

    return SizedBox(
      width: 250,
      height: 245,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(heights.length, (i) {
              final active = i == 2;

              return Container(
                width: 33,
                height: heights[i],
                margin: const EdgeInsets.symmetric(horizontal: 7),
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: active
                      ? const Color(0xFF18E8F2)
                      : const Color(0xFF18E8F2).withOpacity(0.28),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: const Color(0xFF18E8F2).withOpacity(0.48),
                            blurRadius: 24,
                          ),
                        ]
                      : [],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xFF18E8F2)
                        : const Color(0xFF182637),
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              );
            }),
          ),
          Positioned(
            top: 25,
            child: _GradientBorderBox(
              width: 70,
              height: 34,
              radius: 8,
              padding: EdgeInsets.zero,
              background: const Color(0xFF0C1826),
              child: const Center(
                child: Text(
                  r'$2,449',
                  style: TextStyle(
                    color: Color(0xFF18E8F2),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShieldGraphic extends StatelessWidget {
  const _ShieldGraphic();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 245,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(size: const Size(180, 180), painter: _ShieldPainter()),
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF42F2FF), Color(0xFF11BFD5)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF18E8F2).withOpacity(0.48),
                  blurRadius: 32,
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 46,
            ),
          ),
          const Positioned(
            top: 40,
            right: 30,
            child: _MiniBox(
              icon: Icons.lock_rounded,
              color: Color(0xFFFF5A14),
            ),
          ),
          const Positioned(
            bottom: 42,
            left: 28,
            child: _MiniBox(
              icon: Icons.fingerprint_rounded,
              color: Color(0xFF18E8F2),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBox extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _MiniBox({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.16,
      child: Container(
        width: 52,
        height: 52,
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _OnboardingScreenState._cyan.withOpacity(0.65),
              _OnboardingScreenState._cyan.withOpacity(0.18),
              _OnboardingScreenState._orange.withOpacity(0.28),
            ],
            stops: const [0.0, 0.65, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: _OnboardingScreenState._cyan.withOpacity(0.12),
              blurRadius: 16,
              spreadRadius: -4,
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF09131F),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    for (final r in [58.0, 78.0, 98.0]) {
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..color = const Color(0xFFFF5A14).withOpacity(0.18 - (r - 58) / 700)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ShieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final outer = Path()
      ..moveTo(size.width / 2, 10)
      ..lineTo(size.width - 35, 38)
      ..lineTo(size.width - 45, 105)
      ..quadraticBezierTo(size.width / 2, 160, 45, 105)
      ..lineTo(35, 38)
      ..close();

    canvas.drawPath(
      outer,
      Paint()
        ..color = const Color(0xFF18E8F2).withOpacity(0.30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );

    final inner = Path()
      ..moveTo(size.width / 2, 38)
      ..lineTo(size.width - 60, 58)
      ..lineTo(size.width - 68, 103)
      ..quadraticBezierTo(size.width / 2, 135, 68, 103)
      ..lineTo(60, 58)
      ..close();

    canvas.drawPath(
      inner,
      Paint()
        ..color = const Color(0xFF18E8F2).withOpacity(0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
