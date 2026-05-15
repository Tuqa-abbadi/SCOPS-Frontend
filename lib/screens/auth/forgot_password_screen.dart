import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_bloc.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();

  static const _cyan = Color(0xFF18E8F2);
  static const _orange = Color(0xFFFF5A14);
  static const _dark = Color(0xFF020812);

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
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

  Widget _topBar(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Login',
            style: TextStyle(
              color: _cyan,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      height: 58,
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _cyan.withOpacity(0.22),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _cyan.withOpacity(0.08),
            blurRadius: 18,
            spreadRadius: -5,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(
          color: Color(0xFFE9F3F4),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.45),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.white.withOpacity(0.55),
            size: 20,
          ),
          filled: true,
          fillColor: const Color(0xFF07121C),
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _submitButton(BuildContext context, bool isLoading) {
    return Container(
      height: 58,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
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
        onPressed: isLoading
            ? null
            : () {
                context.read<ForgotPasswordBloc>().add(
                      ForgotPasswordSubmitted(
                        email: emailController.text.trim(),
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
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.black,
                ),
              )
            : const Text(
                'Send Reset Link',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
      ),
    );
  }

  Widget _glassCard({
    required ForgotPasswordState forgotPasswordState,
    required BuildContext context,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF07121C).withOpacity(0.70),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: _cyan.withOpacity(0.25),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.40),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: _cyan.withOpacity(0.07),
                blurRadius: 25,
                spreadRadius: -8,
              ),
            ],
          ),
          child: Column(
            children: [
              _inputField(
                controller: emailController,
                hint: 'Email address',
                icon: Icons.email_outlined,
              ),
              if (forgotPasswordState.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Text(
                    forgotPasswordState.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _orange,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              if (forgotPasswordState.successMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Text(
                    forgotPasswordState.successMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _cyan,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              const SizedBox(height: 22),
              _submitButton(context, forgotPasswordState.isLoading),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForgotPasswordBloc, AuthState>(
      builder: (context, state) {
        final forgotPasswordState = state is ForgotPasswordState
            ? state
            : const ForgotPasswordState();

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
                alignment: const Alignment(-0.55, -0.25),
                color: _cyan,
                size: 290,
                opacity: 0.16,
              ),
              _glow(
                alignment: const Alignment(0.65, 0.70),
                color: _orange,
                size: 310,
                opacity: 0.14,
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
                  child: Column(
                    children: [
                      _topBar(context),
                      const SizedBox(height: 58),
                      Image.asset(
                        'assets/images/scops_white.png',
                        width: 150,
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
                      const SizedBox(height: 16),
                      const Text(
                        'Reset your password',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 46),
                      _glassCard(
                        forgotPasswordState: forgotPasswordState,
                        context: context,
                      ),
                      const Spacer(),
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
