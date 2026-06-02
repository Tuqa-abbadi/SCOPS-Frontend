import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_bloc.dart';
import 'login_screen.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key, required this.email, required this.code});

  final String email;
  final String code;

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _showPassword = false;
  bool _showConfirm = false;

  static const _cyan = Color(0xFF18E8F2);
  static const _orange = Color(0xFFFF5A14);
  static const _dark = Color(0xFF020812);

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    context.read<ResetPasswordBloc>().add(
      ResetPasswordSubmitted(
        email: widget.email,
        token: widget.code,
        password: _passwordCtrl.text,
        passwordConfirmation: _confirmCtrl.text,
      ),
    );
  }

  void _goToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
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

  Widget _passwordField({
    required TextEditingController ctrl,
    required String hint,
    required bool showText,
    required VoidCallback onToggle,
  }) {
    return Container(
      height: 58,
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cyan.withOpacity(0.22), width: 1),
        boxShadow: [
          BoxShadow(
            color: _cyan.withOpacity(0.08),
            blurRadius: 18,
            spreadRadius: -5,
          ),
        ],
      ),
      child: TextField(
        controller: ctrl,
        obscureText: !showText,
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
            Icons.lock_outline_rounded,
            color: Colors.white.withOpacity(0.55),
            size: 20,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              showText
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.white.withOpacity(0.45),
              size: 20,
            ),
            onPressed: onToggle,
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ResetPasswordBloc, AuthState>(
      listenWhen: (previous, current) =>
          current is ResetPasswordState &&
          current.isSuccess &&
          (previous is! ResetPasswordState || !previous.isSuccess),
      listener: (context, state) {
        if (state is ResetPasswordState && state.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password reset successfully!'),
              backgroundColor: Color(0xFF18E8F2),
              behavior: SnackBarBehavior.floating,
            ),
          );
          Future.delayed(const Duration(seconds: 2), _goToLogin);
        }
      },
      builder: (context, state) {
        final s = state is ResetPasswordState
            ? state
            : const ResetPasswordState();

        if (s.isSuccess) {
          return Scaffold(
            backgroundColor: _dark,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    color: _cyan,
                    size: 72,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Password Reset!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Redirecting to login…',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

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
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Image.asset(
                        'assets/images/scops_white.png',
                        width: 130,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Text(
                          'scops',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Set new password',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose a strong password you don\'t use elsewhere.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.52),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Glass card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF07121C).withOpacity(0.72),
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
                              ],
                            ),
                            child: Column(
                              children: [
                                _passwordField(
                                  ctrl: _passwordCtrl,
                                  hint: 'New password',
                                  showText: _showPassword,
                                  onToggle: () => setState(
                                    () => _showPassword = !_showPassword,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                _passwordField(
                                  ctrl: _confirmCtrl,
                                  hint: 'Confirm new password',
                                  showText: _showConfirm,
                                  onToggle: () => setState(
                                    () => _showConfirm = !_showConfirm,
                                  ),
                                ),
                                if (s.resetError != null) ...[
                                  const SizedBox(height: 14),
                                  Text(
                                    s.resetError!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: _orange,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 22),

                                // Submit button
                                Container(
                                  height: 56,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFF7A1F),
                                        Color(0xFFFF4B09),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _orange.withOpacity(0.40),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: s.isResetting
                                        ? null
                                        : () => _submit(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: s.isResetting
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: Colors.black,
                                            ),
                                          )
                                        : const Text(
                                            'Reset Password',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
