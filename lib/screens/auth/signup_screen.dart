import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import '../../blocs/auth/auth_bloc.dart';
import 'enter_code_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final PageController _pageController = PageController();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  static const _cyan = Color(0xFF18E8F2);
  static const _orange = Color(0xFFFF5A14);
  static const _dark = Color(0xFF020812);

  final List<String> titles = [
    'Your name',
    'Your email',
    'Your phone',
    'Secure password',
  ];

  final List<String> subtitles = [
    'Enter your first and last name.',
    'Use an email you can access.',
    'Add your phone for account verification.',
    'Protect your subscription data.',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _onNext(BuildContext context, SignupState state) {
    if (state.currentStep < 3) {
      context.read<SignupBloc>().add(const SignupNextStep());
    } else {
      context.read<SignupBloc>().add(
            SignupSubmitted(
              firstName: firstNameController.text.trim(),
              lastName: lastNameController.text.trim(),
              email: emailController.text.trim(),
              phone: phoneController.text.trim(),
              password: passwordController.text,
            ),
          );
    }
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
          onPressed: () =>
              context.read<SignupBloc>().add(const SignupPreviousStep()),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
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
    bool isPassword = false,
    bool showPassword = false,
    VoidCallback? onTogglePassword,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? prefixText,
  }) {
    return Container(
      height: 58,
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _cyan.withOpacity(0.24),
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
        obscureText: isPassword && !showPassword,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
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
          prefixText: prefixText,
          prefixStyle: const TextStyle(
            color: Color(0xFFE9F3F4),
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    showPassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: Colors.white.withOpacity(0.55),
                    size: 20,
                  ),
                  onPressed: onTogglePassword,
                )
              : null,
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

  Widget _phoneInputField() {
    return Row(
      children: [
        Container(
          height: 58,
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _cyan.withOpacity(0.24),
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
          child: Container(
            width: 82,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF07121C),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Text(
              '+962',
              style: TextStyle(
                color: Color(0xFFE9F3F4),
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _inputField(
            controller: phoneController,
            hint: '10 digits',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
          ),
        ),
      ],
    );
  }

  Widget _inputForStep(
    int index,
    SignupState state,
    BuildContext context,
  ) {
    switch (index) {
      case 0:
        return Column(
          children: [
            _inputField(
              controller: firstNameController,
              hint: 'First name',
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 12),
            _inputField(
              controller: lastNameController,
              hint: 'Last name',
              icon: Icons.person_outline_rounded,
            ),
          ],
        );
      case 1:
        return _inputField(
          controller: emailController,
          hint: 'Email address',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        );
      case 2:
        return _phoneInputField();
      default:
        return _inputField(
          controller: passwordController,
          hint: 'Password',
          icon: Icons.lock_outline_rounded,
          isPassword: true,
          showPassword: state.showPassword,
          onTogglePassword: () => context
              .read<SignupBloc>()
              .add(const TogglePasswordVisibility()),
        );
    }
  }

  Widget _progressBar(int currentStep) {
    return Row(
      children: List.generate(4, (index) {
        final isCompleted = index < currentStep;
        final isCurrent = index == currentStep;

        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isCurrent
                  ? _orange
                  : isCompleted
                      ? _cyan
                      : Colors.white.withOpacity(0.16),
              boxShadow: isCurrent || isCompleted
                  ? [
                      BoxShadow(
                        color: (isCurrent ? _orange : _cyan).withOpacity(0.45),
                        blurRadius: 10,
                      ),
                    ]
                  : [],
            ),
          ),
        );
      }),
    );
  }

  Widget _signupCard(
    int index,
    SignupState state,
    BuildContext context,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
          decoration: BoxDecoration(
            color: const Color(0xFF07121C).withOpacity(0.74),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: _cyan.withOpacity(0.25),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.38),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: _cyan.withOpacity(0.07),
                blurRadius: 24,
                spreadRadius: -8,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Step ${index + 1} of 4',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.42),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                titles[index],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitles[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.46),
                  fontSize: 12,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 26),
              _inputForStep(index, state, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardSlider(SignupState state, BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      height: state.currentStep == 0 ? 315 : 245,
      child: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        onPageChanged: (index) =>
            context.read<SignupBloc>().add(SignupPageChanged(index)),
        itemBuilder: (ctx, index) {
          return AnimatedBuilder(
            animation: _pageController,
            builder: (ctx, child) {
              double value = 0;

              if (_pageController.position.haveDimensions) {
                value =
                    (_pageController.page ?? state.currentStep.toDouble()) -
                        index;
              } else {
                value = state.currentStep.toDouble() - index;
              }

              value = value.clamp(-1.0, 1.0);

              return Transform.translate(
                offset: Offset(value * -36, 0),
                child: Transform.scale(
                  scale: 1 - (value.abs() * 0.07),
                  child: Opacity(
                    opacity: 1 - (value.abs() * 0.28),
                    child: child,
                  ),
                ),
              );
            },
            child: _signupCard(index, state, context),
          );
        },
      ),
    );
  }

  Widget _mainButton(BuildContext context, SignupState state) {
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
        onPressed: state.isLoading ? null : () => _onNext(context, state),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: state.isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.black,
                ),
              )
            : Text(
                state.currentStep == 3 ? 'Create Account' : 'Continue',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignupBloc, AuthState>(
      listener: (context, state) {
        if (state is SignupSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: _cyan,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<EmailVerificationBloc>(),
                child: EnterCodeScreen(
                  email: state.email,
                  isEmailVerification: true,
                  password: passwordController.text,
                ),
              ),
            ),
          );
        } else if (state is SignupGoBack) {
          Navigator.pop(context);
        } else if (state is SignupState) {
          _pageController.animateToPage(
            state.currentStep,
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutCubic,
          );
        }
      },
      builder: (context, state) {
        final signupState =
            state is SignupState ? state : const SignupState();

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
                alignment: const Alignment(-0.55, -0.28),
                color: _cyan,
                size: 290,
                opacity: 0.16,
              ),
              _glow(
                alignment: const Alignment(0.70, 0.78),
                color: _orange,
                size: 310,
                opacity: 0.14,
              ),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
                  child: Column(
                    children: [
                      _topBar(context),
                      const SizedBox(height: 26),
                      Image.asset(
                        'assets/images/scops_white.png',
                        width: 120,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Text(
                          'scops',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Create your account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 34),
                      _progressBar(signupState.currentStep),
                      const SizedBox(height: 34),
                      _cardSlider(signupState, context),
                      if (signupState.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: Text(
                            signupState.errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: _orange,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      _mainButton(context, signupState),
                      const SizedBox(height: 28),
                      
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
