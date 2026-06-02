import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/user/user_cubit.dart';
import '../../models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const _bg = Color(0xFF020812);
  static const _card = Color(0xFF07111C);
  static const _cyan = Color(0xFF18E8F2);
  static const _orange = Color(0xFFFF5A14);
  static const _white = Colors.white;
  static const _muted = Color(0xFF9BA4B0);
  static const _fieldBg = Color(0xFF0D1520);

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  String? _errorText;
  bool _didLoadUser = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadUser) return;
    final user = context.read<UserCubit>().state;
    _nameCtrl.text = user?.fullName ?? '';
    _emailCtrl.text = user?.email ?? '';
    _didLoadUser = true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _submit(UserModel? user) {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();

    if (name.isEmpty) {
      setState(() => _errorText = 'Please enter your name.');
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorText = 'Please enter a valid email address.');
      return;
    }

    final parts = name.split(RegExp(r'\s+'));
    final firstName = parts.first;
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    context.read<UserCubit>().setUser(
          UserModel(
            id: user?.id ?? '',
            firstName: firstName,
            lastName: lastName,
            email: email,
            role: user?.role ?? '',
          ),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated locally'),
        backgroundColor: _cyan,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  Widget _field({
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _fieldBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: _white,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: _muted),
          prefixIcon: Icon(icon, color: _muted, size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
        ),
      ),
    );
  }

  Widget _avatarPreview(UserModel? user) {
    final name = _nameCtrl.text.trim();
    final fallback = user?.firstName.isNotEmpty == true ? user!.firstName : 'U';
    final initial = (name.isNotEmpty ? name[0] : fallback[0]).toUpperCase();

    return Center(
      child: Column(
        children: [
          Container(
            width: 92,
            height: 92,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [_cyan, _orange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: _cyan.withOpacity(0.18),
                  blurRadius: 26,
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: _orange.withOpacity(0.16),
                  blurRadius: 26,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: _card,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: _white,
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Profile initials update from your name',
            style: TextStyle(color: _muted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserModel?>(
      builder: (context, user) {
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
              'Edit Profile',
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
                          'Update your profile',
                          style: TextStyle(
                            color: _white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Change the name and email shown on your account.',
                          style: TextStyle(color: _muted, fontSize: 12),
                        ),
                        const SizedBox(height: 22),
                        AnimatedBuilder(
                          animation: _nameCtrl,
                          builder: (_, __) => _avatarPreview(user),
                        ),
                        const SizedBox(height: 22),
                        _field(
                          ctrl: _nameCtrl,
                          hint: 'Full name',
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 12),
                        _field(
                          ctrl: _emailCtrl,
                          hint: 'Email address',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        if (_errorText != null) ...[
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
                              _errorText!,
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
                            onPressed: () => _submit(user),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _orange,
                              foregroundColor: _white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
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
