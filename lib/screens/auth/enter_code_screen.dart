import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/user/user_cubit.dart';
import '../dashboard/dashboard_screen.dart';
import 'new_password_screen.dart';

class EnterCodeScreen extends StatefulWidget {
  const EnterCodeScreen({
    super.key,
    required this.email,
    this.isEmailVerification = false,
    this.password,
  });

  final String email;
  final bool isEmailVerification;
  final String? password;

  @override
  State<EnterCodeScreen> createState() => _EnterCodeScreenState();
}

class _EnterCodeScreenState extends State<EnterCodeScreen> {
  final _codeCtrl = TextEditingController();
  String? _localError;

  static const _cyan = Color(0xFF18E8F2);
  static const _orange = Color(0xFFFF5A14);
  static const _dark = Color(0xFF020812);

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  void _verify(BuildContext context) {
    final code = _codeCtrl.text.trim();
    if (code.length != 6 || int.tryParse(code) == null) {
      setState(() => _localError = 'Enter the 6-digit code.');
      return;
    }

    setState(() => _localError = null);

    if (widget.isEmailVerification) {
      context.read<EmailVerificationBloc>().add(
            EmailVerificationSubmitted(
              email: widget.email,
              token: code,
              password: widget.password,
            ),
          );
    } else {
      context.read<ResetPasswordBloc>().add(
            VerifyCodeSubmitted(email: widget.email, token: code),
          );
    }
  }

  void _openNewPassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ResetPasswordBloc>(),
          child: NewPasswordScreen(
            email: widget.email,
            code: _codeCtrl.text.trim(),
          ),
        ),
      ),
    );
  }

  Future<void> _finishSignup(BuildContext context, String message) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _cyan,
        behavior: SnackBarBehavior.floating,
      ),
    );
    await context.read<UserCubit>().loadUser();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const DashboardScreen(showAddCardAfterSignup: true),
      ),
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

  Widget _content({
    required BuildContext context,
    required bool isLoading,
    String? errorMessage,
  }) {
    final title =
        widget.isEmailVerification ? 'Verify your email' : 'Check your email';
    final buttonText =
        widget.isEmailVerification ? 'Verify Email' : 'Verify Code';
    final subtitle = widget.isEmailVerification
        ? 'Enter the 6-digit code we sent to\n${widget.email}'
        : 'We sent a 6-digit code to\n${widget.email}';
    final error = _localError ?? errorMessage;

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
                        onPressed:
                            isLoading ? null : () => Navigator.pop(context),
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
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.52),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
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
                            Container(
                              height: 58,
                              padding: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: _cyan.withOpacity(0.22),
                                  width: 1,
                                ),
                              ),
                              child: TextField(
                                controller: _codeCtrl,
                                enabled: !isLoading,
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                                textAlign: TextAlign.center,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: const TextStyle(
                                  color: Color(0xFFE9F3F4),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 10,
                                ),
                                decoration: InputDecoration(
                                  counterText: '',
                                  hintText: '------',
                                  hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.25),
                                    fontSize: 20,
                                    letterSpacing: 10,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFF07121C),
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(17),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                onSubmitted: (_) => _verify(context),
                              ),
                            ),
                            if (error != null) ...[
                              const SizedBox(height: 14),
                              Text(
                                error,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: _orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                            const SizedBox(height: 22),
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
                                onPressed:
                                    isLoading ? null : () => _verify(context),
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
                                    : Text(
                                        buttonText,
                                        style: const TextStyle(
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
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEmailVerification) {
      return BlocConsumer<EmailVerificationBloc, AuthState>(
        listenWhen: (previous, current) =>
            current is EmailVerificationState &&
            current.isVerified &&
            (previous is! EmailVerificationState || !previous.isVerified),
        listener: (context, state) {
          final verificationState = state as EmailVerificationState;
          _finishSignup(
            context,
            verificationState.successMessage ?? 'Email verified successfully.',
          );
        },
        builder: (context, state) {
          final verificationState = state is EmailVerificationState
              ? state
              : const EmailVerificationState();
          return _content(
            context: context,
            isLoading: verificationState.isVerifying,
            errorMessage: verificationState.errorMessage,
          );
        },
      );
    }

    return BlocConsumer<ResetPasswordBloc, AuthState>(
      listenWhen: (previous, current) =>
          current is ResetPasswordState &&
          current.isCodeVerified &&
          (previous is! ResetPasswordState || !previous.isCodeVerified),
      listener: (context, state) => _openNewPassword(context),
      builder: (context, state) {
        final resetState =
            state is ResetPasswordState ? state : const ResetPasswordState();
        return _content(
          context: context,
          isLoading: resetState.isVerifying,
          errorMessage: resetState.verifyError,
        );
      },
    );
  }
}
