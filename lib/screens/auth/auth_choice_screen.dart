import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_bloc.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class AuthChoiceScreen extends StatelessWidget {
  const AuthChoiceScreen({super.key});

  static const _cyan = Color(0xFF18E8F2);
  static const _orange = Color(0xFFFF5A14);
  static const _dark = Color(0xFF020812);

  void _goToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<LoginBloc>()),
          ],
          child: const LoginScreen(),
        ),
      ),
    );
  }

  void _goToSignup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<SignupBloc>()),
          ],
          child: const SignupScreen(),
        ),
      ),
    );
  }

  Widget _glow({
    required Alignment alignment,
    required Color color,
    required double size,
    double opacity = 0.16,
  }) {
    return Align(
      alignment: alignment,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
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

  Widget _button({
    required String text,
    required VoidCallback onTap,
    bool outlined = false,
  }) {
    if (outlined) {
      return SizedBox(
        width: double.infinity,
        height: 58,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: _cyan.withOpacity(0.85), width: 1.2),
            foregroundColor: _cyan,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF7A1F), Color(0xFFFF4B09)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _orange.withOpacity(0.42),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _dark,
      body: Stack(
        children: [
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
          _glow(
            alignment: const Alignment(-0.7, -0.25),
            color: _cyan,
            size: 290,
            opacity: 0.20,
          ),
          _glow(
            alignment: const Alignment(0.55, 0.78),
            color: _orange,
            size: 310,
            opacity: 0.20,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 26),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  Image.asset(
                    'assets/images/owl_cyan.png',
                    width: 78,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.auto_awesome,
                      color: _cyan,
                      size: 78,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Image.asset(
                    'assets/images/scops_white.png',
                    width: 180,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Text(
                      'scops',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Subscription & Card Management',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.58),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(flex: 3),
                  _button(
                    text: 'Login',
                    onTap: () => _goToLogin(context),
                  ),
                  const SizedBox(height: 16),
                  _button(
                    text: 'Sign Up',
                    outlined: true,
                    onTap: () => _goToSignup(context),
                  ),
                  const SizedBox(height: 34),
                  
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}