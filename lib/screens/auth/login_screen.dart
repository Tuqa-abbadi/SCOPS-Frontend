import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/user/user_cubit.dart';
import '../admin/admin_dashboard_screen.dart';
import '../dashboard/dashboard_screen.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  static const _cyan = Color(0xFF18E8F2);
  static const _orange = Color(0xFFFF5A14);
  static const _dark = Color(0xFF020812);

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
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
          onPressed: () {},
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
        obscureText: isPassword && !showPassword,
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

  Widget _loginButton(BuildContext context, bool isLoading) {
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
                context.read<LoginBloc>().add(
                      LoginSubmitted(
                        email: emailController.text.trim(),
                        password: passwordController.text,
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
                'Login',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
      ),
    );
  }

  Widget _glassCard({
    required LoginState loginState,
    required bool isLoading,
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
                hint: 'Email or username',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 14),
              _inputField(
                controller: passwordController,
                hint: 'Password',
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                showPassword: loginState.showPassword,
                onTogglePassword: () => context
                    .read<LoginBloc>()
                    .add(const TogglePasswordVisibility()),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: _cyan,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              if (loginState.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    loginState.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _orange,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              _loginButton(context, isLoading),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, AuthState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          context.read<UserCubit>().setUser(state.user);
          final isAdmin = state.user?.isAdmin ?? false;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => isAdmin
                  ? const AdminDashboardScreen()
                  : const DashboardScreen(),
            ),
          );
        }
      },
      builder: (context, state) {
        final loginState = state is LoginState ? state : const LoginState();
        final isLoading = loginState.isLoading;

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
                        'Welcome back',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 46),
                      _glassCard(
                        loginState: loginState,
                        isLoading: isLoading,
                        context: context,
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.42),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignupScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: _orange,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
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
