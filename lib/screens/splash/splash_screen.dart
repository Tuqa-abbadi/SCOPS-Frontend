import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/splash/splash_bloc.dart';
import '../onboarding/onboarding_screen.dart';
import '../dashboard/dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _cyan = Color(0xFF18E8F2);
  static const _orange = Color(0xFFFF5A14);
  static const _dark = Color(0xFF020812);

  @override
  void initState() {
    super.initState();
    context.read<SplashBloc>().add(const SplashStarted());
  }

  Widget _glow({
    required Alignment alignment,
    required Color color,
    required double size,
    double opacity = 0.18,
  }) {
    return Align(
      alignment: alignment,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(opacity),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashBloc, SplashState>(
      listener: (context, state) {
        if (state is SplashNavigateToOnboarding) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const OnboardingScreen(),
            ),
          );
        } else if (state is SplashNavigateToDashboard) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const DashboardScreen(),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: _dark,
        body: Stack(
          children: [
            // BACKGROUND
            Container(
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
            ),

            // CYAN GLOW
            _glow(
              alignment: const Alignment(-0.78, -0.55),
              color: _cyan,
              size: 320,
              opacity: 0.18,
            ),

            // SOFT ORANGE GLOW
            _glow(
              alignment: const Alignment(0.82, 0.90),
              color: _orange,
              size: 320,
              opacity: 0.10,
            ),

            // SOFT BOTTOM ORANGE
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      _orange.withOpacity(0.05),
                      _orange.withOpacity(0.09),
                    ],
                  ),
                ),
              ),
            ),

            // CONTENT
            Center(
              child: BlocBuilder<SplashBloc, SplashState>(
                builder: (context, state) {
                  return AnimatedOpacity(
                    opacity: state is SplashVisible ||
                            state is SplashNavigateToOnboarding
                        ? 1.0
                        : 0.0,
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOut,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // OWL
                        Image.asset(
                          'assets/images/owl_cyan.png',
                          width: 76,
                        ),

                        const SizedBox(height: 14),

                        // WHITE LOGO
                        Image.asset(
                          'assets/images/scops_white.png',
                          width: 180,
                          fit: BoxFit.contain,
                        ),

                        const SizedBox(height: 18),

                        // TAGLINE
                        Text(
                          'Track. Control. Save.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.72),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // LOADING BAR
            Positioned(
              left: 100,
              right: 100,
              bottom: 40,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(seconds: 4),
                  curve: Curves.easeInOut,
                  builder: (context, value, _) {
                    return Stack(
                      children: [
                        Container(
                          height: 3.5,
                          color: Colors.white.withOpacity(0.08),
                        ),
                        FractionallySizedBox(
                          widthFactor: value,
                          child: Container(
                            height: 3.5,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _cyan,
                                  _orange,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}