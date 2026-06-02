import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/profile/change_password_bloc.dart';
import '../../blocs/user/user_cubit.dart';
import '../auth/forgot_password_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  static const _bg = Color(0xFF020812);
  static const _card = Color(0xFF07111C);
  static const _cyan = Color(0xFF18E8F2);
  static const _orange = Color(0xFFFF5A14);
  static const _white = Colors.white;
  static const _muted = Color(0xFF9BA4B0);
  static const _fieldBg = Color(0xFF0D1520);

  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    context.read<ChangePasswordBloc>().add(
      ChangePasswordSubmitted(
        currentPassword: _currentCtrl.text,
        newPassword: _newCtrl.text,
        confirmPassword: _confirmCtrl.text,
      ),
    );
  }

  void _clearFields() {
    _currentCtrl.clear();
    _newCtrl.clear();
    _confirmCtrl.clear();
  }

  Widget _field({
    required TextEditingController ctrl,
    required String hint,
    required bool showText,
    required VoidCallback onToggle,
  }) => Container(
    decoration: BoxDecoration(
      color: _fieldBg,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withOpacity(0.07)),
    ),
    child: TextField(
      controller: ctrl,
      obscureText: !showText,
      style: const TextStyle(
        color: _white,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _muted),
        prefixIcon: const Icon(
          Icons.lock_outline_rounded,
          color: _muted,
          size: 20,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            showText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: _muted,
            size: 20,
          ),
          onPressed: onToggle,
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChangePasswordBloc, ChangePasswordState>(
      listener: (context, state) {
        if (state is ChangePasswordSuccess) {
          _clearFields();
          context.read<ChangePasswordBloc>().add(const ChangePasswordReset());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: _cyan,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        final isLoading = state is ChangePasswordLoading;
        final errorText = state is ChangePasswordFailure ? state.error : null;

        return Scaffold(
          backgroundColor: _bg,
          appBar: AppBar(
            backgroundColor: _bg,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: _white,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Change Password',
              style: TextStyle(
                color: _white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _cyan.withOpacity(0.14)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Update your password',
                          style: TextStyle(
                            color: _white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Use a strong password you don\'t use elsewhere.',
                          style: TextStyle(color: _muted, fontSize: 12),
                        ),
                        const SizedBox(height: 20),
                        _field(
                          ctrl: _currentCtrl,
                          hint: 'Current password',
                          showText: _showCurrent,
                          onToggle: () =>
                              setState(() => _showCurrent = !_showCurrent),
                        ),
                        const SizedBox(height: 12),
                        _field(
                          ctrl: _newCtrl,
                          hint: 'New password',
                          showText: _showNew,
                          onToggle: () => setState(() => _showNew = !_showNew),
                        ),
                        const SizedBox(height: 12),
                        _field(
                          ctrl: _confirmCtrl,
                          hint: 'Confirm new password',
                          showText: _showConfirm,
                          onToggle: () =>
                              setState(() => _showConfirm = !_showConfirm),
                        ),
                        if (errorText != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: _orange.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _orange.withOpacity(0.30),
                              ),
                            ),
                            child: Text(
                              errorText,
                              style: const TextStyle(
                                color: _orange,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () => _submit(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _orange,
                              disabledBackgroundColor: _orange.withOpacity(
                                0.45,
                              ),
                              foregroundColor: _white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    'Update Password',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              final email = context
                                  .read<UserCubit>()
                                  .state
                                  ?.email
                                  .trim();
                              if (email == null || email.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'We could not find your account email.',
                                    ),
                                    backgroundColor: _orange,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ForgotPasswordScreen(
                                    initialEmail: email,
                                    useKnownEmail: true,
                                    autoSubmit: true,
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              'Forgot your password?',
                              style: TextStyle(
                                color: _cyan,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
