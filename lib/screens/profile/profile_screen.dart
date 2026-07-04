import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/admin/admin_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/profile/change_password_bloc.dart';
import '../../blocs/reviews/reviews_bloc.dart';
import '../../blocs/subscription/subscription_bloc.dart';
import '../../blocs/user/user_cubit.dart';
import '../../blocs/wallet/wallet_bloc.dart';
import '../../models/user_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_controller.dart';
import '../admin/admin_dashboard_screen.dart';
import '../auth/auth_choice_screen.dart';
import '../feedback/feedback_screen.dart';
import '../reviews/write_review_sheet.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _darkBg = Color(0xFF070B12);
  static const _darkCard = Color(0xFF101722);
  static const _darkCard2 = Color(0xFF0B111A);
  static const _darkCyan = Color(0xFF00D9E8);
  static const _darkOrange = Color(0xFFFF7A1A);
  static const _darkText = Color(0xFFF5F7FA);
  static const _darkMuted = Color(0xFF8B98A8);

  static const _lightBg = AppColors.lightBackground;
  static const _lightCard = AppColors.lightSurface;
  static const _lightCard2 = AppColors.lightSecondarySurface;
  static const _lightCyan = AppColors.primary;
  static const _lightText = AppColors.lightTextPrimary;
  static const _lightMuted = AppColors.lightTextSecondary;
  static const _gold = Color(0xFFFFB020);

  bool _renewalReminders = true;
  bool _monthlySummary = true;
  bool _offersAndTips = false;
  bool _dataPermissions = true;
  bool _appLock = false;
  int _rating = 0;
  String _currency = 'USD - US Dollar';

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _bg => _isDark ? _darkBg : _lightBg;
  Color get _card => _isDark ? _darkCard : _lightCard;
  Color get _card2 => _isDark ? _darkCard2 : _lightCard2;
  Color get _cyan => _isDark ? _darkCyan : _lightCyan;
  Color get _orange => _darkOrange;
  Color get _text => _isDark ? _darkText : _lightText;
  Color get _muted => _isDark ? _darkMuted : _lightMuted;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkPending());
  }

  void _checkPending() {
    if (!mounted) return;
    final subState = context.read<SubscriptionBloc>().state;
    if (subState is SubscriptionData) {
      context.read<ReviewsBloc>().add(
        PendingReviewsRequested(subState.subscriptions),
      );
    }
  }

  TextStyle get _titleStyle =>
      TextStyle(color: _text, fontSize: 15, fontWeight: FontWeight.w800);

  TextStyle get _subtitleStyle =>
      TextStyle(color: _muted, fontSize: 12, height: 1.35);

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: _muted),
      filled: true,
      fillColor: _card2,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _cyan.withValues(alpha: 0.14)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _cyan.withValues(alpha: 0.70)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _orange.withValues(alpha: 0.70)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _orange),
      ),
    );
  }

  Widget _primaryButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _cyan,
          foregroundColor: _darkBg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
    );
  }

  Widget _section(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 10),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: _muted.withValues(alpha: 0.82),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _sheetHandle() {
    return Center(
      child: Container(
        width: 42,
        height: 4,
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: _muted.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );
  }

  Future<void> _showThemedBottomSheet({
    required String title,
    required Widget child,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetContext).size.height * 0.82,
            ),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              border: Border.all(color: _cyan.withValues(alpha: 0.18)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _sheetHandle(),
                  Text(
                    title,
                    style: TextStyle(
                      color: _text,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  child,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _optionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    bool selected = false,
  }) {
    final color = iconColor ?? _cyan;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : _card2,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? color.withValues(alpha: 0.55)
                : _cyan.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: _titleStyle),
                  const SizedBox(height: 2),
                  Text(subtitle, style: _subtitleStyle),
                ],
              ),
            ),
            if (selected) Icon(Icons.check_circle_rounded, color: color),
          ],
        ),
      ),
    );
  }

  Widget _avatar(UserModel? user) {
    final initial = user?.firstName.isNotEmpty == true
        ? user!.firstName[0].toUpperCase()
        : 'U';

    return Center(
      child: Column(
        children: [
          Container(
            width: 112,
            height: 112,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [_cyan, _orange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: _cyan.withValues(alpha: 0.22),
                  blurRadius: 30,
                  spreadRadius: -8,
                ),
                BoxShadow(
                  color: _orange.withValues(alpha: 0.16),
                  blurRadius: 30,
                  spreadRadius: -8,
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(shape: BoxShape.circle, color: _card),
              child: Center(
                child: Text(
                  initial,
                  style: TextStyle(
                    color: _text,
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            user?.fullName.isNotEmpty == true ? user!.fullName : 'User',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _text,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            user?.email.isNotEmpty == true ? user!.email : 'No email added',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _statsCard() {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, subState) {
        final subs = subState is SubscriptionData ? subState.subscriptions : [];
        final total = subs.fold(0.0, (sum, item) => sum + item.amount);

        return BlocBuilder<WalletBloc, WalletState>(
          builder: (context, walletState) {
            final cardCount = walletState is WalletData
                ? walletState.cards.length
                : 0;
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _cyan.withValues(alpha: 0.30)),
                boxShadow: [
                  BoxShadow(
                    color: _cyan.withValues(alpha: _isDark ? 0.10 : 0.06),
                    blurRadius: 24,
                    spreadRadius: -10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  ProfileStatCard(
                    icon: Icons.subscriptions_rounded,
                    value: '${subs.length}',
                    label: 'Subscriptions',
                    color: _cyan,
                    textColor: _text,
                    mutedColor: _muted,
                  ),
                  _divider(),
                  ProfileStatCard(
                    icon: Icons.payments_rounded,
                    value: '\$${total.toStringAsFixed(0)}',
                    label: 'Monthly Spend',
                    color: _orange,
                    textColor: _text,
                    mutedColor: _muted,
                  ),
                  _divider(),
                  ProfileStatCard(
                    icon: Icons.credit_card_rounded,
                    value: '$cardCount',
                    label: 'Cards',
                    color: _cyan,
                    textColor: _text,
                    mutedColor: _muted,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 46,
      color: _muted.withValues(alpha: 0.14),
    );
  }

  List<SubscriptionModel> _pendingSubs(
    SubscriptionData subData,
    ReviewsData reviewData,
  ) {
    return subData.subscriptions.where((sub) {
      if (!sub.isActive) return false;
      final startDate = sub.startDate;
      if (startDate == null) return false;
      final days = DateTime.now().difference(startDate).inDays;
      final hasRenewed = sub.nextRenewal.isBefore(DateTime.now());
      if (days < 7 && !hasRenewed) return false;
      return !reviewData.hasReviewForSubscription(sub.apiId);
    }).toList();
  }

  Widget _reviewsSection() {
    return BlocBuilder<ReviewsBloc, ReviewsState>(
      builder: (context, reviewState) {
        return BlocBuilder<SubscriptionBloc, SubscriptionState>(
          builder: (context, subState) {
            final reviewData = reviewState is ReviewsData ? reviewState : null;
            final subData = subState is SubscriptionData ? subState : null;
            if (reviewData == null) return const SizedBox.shrink();

            final myReviewCount = reviewData.myReviews.length;
            final pendingSubs = subData != null
                ? _pendingSubs(subData, reviewData)
                : <SubscriptionModel>[];

            if (myReviewCount == 0 && pendingSubs.isEmpty) {
              return const SizedBox.shrink();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _section('Reviews'),
                if (myReviewCount > 0)
                  ProfileMenuItem(
                    icon: Icons.rate_review_rounded,
                    title: 'My Reviews',
                    subtitle:
                        '$myReviewCount review${myReviewCount == 1 ? '' : 's'} written',
                    iconColor: _gold,
                    cardColor: _card,
                    borderColor: _cyan.withValues(alpha: 0.14),
                    textColor: _text,
                    mutedColor: _muted,
                    trailing: _countBadge(myReviewCount),
                  ),
                if (pendingSubs.isNotEmpty) ...[
                  _section('Pending Reviews'),
                  if (reviewData.pendingLoading)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: _cyan,
                          strokeWidth: 2.5,
                        ),
                      ),
                    )
                  else
                    ...pendingSubs.map((sub) => _pendingReviewCard(sub)),
                ],
              ],
            );
          },
        );
      },
    );
  }

  Widget _countBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: const TextStyle(color: _gold, fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _pendingReviewCard(SubscriptionModel sub) {
    return ProfileMenuItem(
      icon: Icons.star_outline_rounded,
      title: sub.serviceName,
      subtitle: 'Share your experience',
      iconColor: _gold,
      cardColor: _card,
      borderColor: _gold.withValues(alpha: 0.30),
      textColor: _text,
      mutedColor: _muted,
      onTap: () => _showWriteReviewSheet(sub),
    );
  }

  void _showWriteReviewSheet(SubscriptionModel sub) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<ReviewsBloc>(),
        child: WriteReviewSheet(subscription: sub, serviceId: sub.serviceId),
      ),
    );
  }

  Future<void> _showEditProfileSheet(UserModel? user) {
    final nameController = TextEditingController(text: user?.fullName ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');

    return _showThemedBottomSheet(
      title: 'Edit Profile',
      child: Column(
        children: [
          TextField(
            controller: nameController,
            textInputAction: TextInputAction.next,
            style: TextStyle(color: _text),
            decoration: _inputDecoration('Full name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: _text),
            decoration: _inputDecoration('Email'),
          ),
          const SizedBox(height: 18),
          _primaryButton('Save Changes', () {
            final parts = nameController.text.trim().split(RegExp(r'\s+'));
            final firstName = parts.isNotEmpty && parts.first.isNotEmpty
                ? parts.first
                : 'User';
            final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
            final updated = UserModel(
              id: user?.id ?? '',
              firstName: firstName,
              lastName: lastName,
              email: emailController.text.trim(),
              role: user?.role ?? '',
            );
            context.read<UserCubit>().setUser(updated);
            Navigator.pop(context);
            _showSnack('Profile updated locally');
          }),
        ],
      ),
    );
  }

  Future<void> _showChangePasswordDialog() {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    String? errorText;

    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: _card,
              title: Text('Change Password', style: TextStyle(color: _text)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: currentController,
                      obscureText: true,
                      style: TextStyle(color: _text),
                      decoration: _inputDecoration('Current Password'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: newController,
                      obscureText: true,
                      style: TextStyle(color: _text),
                      decoration: _inputDecoration('New Password'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: confirmController,
                      obscureText: true,
                      style: TextStyle(color: _text),
                      decoration: _inputDecoration('Confirm Password'),
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: 10),
                      Text(errorText!, style: TextStyle(color: _orange)),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('Cancel', style: TextStyle(color: _muted)),
                ),
                TextButton(
                  onPressed: () {
                    if (newController.text != confirmController.text) {
                      setDialogState(
                        () => errorText =
                            'New password and confirmation do not match.',
                      );
                      return;
                    }
                    Navigator.pop(dialogContext);
                    _showSnack('Password validation passed');
                  },
                  child: Text(
                    'Save',
                    style: TextStyle(color: _cyan, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showNotificationsSheet() {
    return _showThemedBottomSheet(
      title: 'Notifications',
      child: StatefulBuilder(
        builder: (context, setSheetState) {
          return Column(
            children: [
              _switchTile(
                title: 'Renewal reminders',
                subtitle: 'Get alerts before subscriptions renew',
                value: _renewalReminders,
                onChanged: (value) =>
                    setSheetState(() => _renewalReminders = value),
              ),
              _switchTile(
                title: 'Monthly summary',
                subtitle: 'Receive spending reports every month',
                value: _monthlySummary,
                onChanged: (value) =>
                    setSheetState(() => _monthlySummary = value),
              ),
              _switchTile(
                title: 'Offers and tips',
                subtitle: 'Product updates and saving ideas',
                value: _offersAndTips,
                onChanged: (value) =>
                    setSheetState(() => _offersAndTips = value),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _card2,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cyan.withValues(alpha: 0.12)),
      ),
      child: SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        value: value,
        onChanged: onChanged,
        activeColor: _cyan,
        title: Text(title, style: _titleStyle),
        subtitle: Text(subtitle, style: _subtitleStyle),
      ),
    );
  }

  Future<void> _showRateDialog() {
    _rating = 0;
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: _card,
              title: Text('Rate the App', style: TextStyle(color: _text)),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final star = index + 1;
                  return IconButton(
                    onPressed: () => setDialogState(() => _rating = star),
                    icon: Icon(
                      star <= _rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: _gold,
                      size: 34,
                    ),
                  );
                }),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('Cancel', style: TextStyle(color: _muted)),
                ),
                TextButton(
                  onPressed: _rating == 0
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                          _showSnack('Thanks for rating SCOPS $_rating stars');
                        },
                  child: Text(
                    'Submit',
                    style: TextStyle(color: _cyan, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showPreferencesSheet() {
    return _showThemedBottomSheet(
      title: 'Preferences',
      child: Column(
        children: [
          _optionTile(
            icon: Icons.language_rounded,
            title: 'Currency',
            subtitle: _currency,
            onTap: () {
              Navigator.pop(context);
              _showCurrencySheet();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showCurrencySheet() {
    final currencies = [
      'USD - US Dollar',
      'JOD - Jordanian Dinar',
      'EUR - Euro',
      'SAR - Saudi Riyal',
    ];

    return _showThemedBottomSheet(
      title: 'Currency',
      child: StatefulBuilder(
        builder: (context, setSheetState) {
          return Column(
            children: currencies.map((currency) {
              return _optionTile(
                icon: Icons.attach_money_rounded,
                title: currency.split(' - ').first,
                subtitle: currency.split(' - ').last,
                selected: _currency == currency,
                onTap: () {
                  setState(() => _currency = currency);
                  setSheetState(() {});
                  _showSnack('Currency set to ${currency.split(' - ').first}');
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Future<void> _showPrivacySheet() {
    return _showThemedBottomSheet(
      title: 'Privacy & Security',
      child: StatefulBuilder(
        builder: (context, setSheetState) {
          return Column(
            children: [
              _switchTile(
                title: 'Data permissions',
                subtitle: 'Allow SCOPS to personalize insights',
                value: _dataPermissions,
                onChanged: (value) =>
                    setSheetState(() => _dataPermissions = value),
              ),
              _switchTile(
                title: 'App lock',
                subtitle: 'Require device authentication on open',
                value: _appLock,
                onChanged: (value) => setSheetState(() => _appLock = value),
              ),
              _optionTile(
                icon: Icons.file_download_outlined,
                title: 'Export data',
                subtitle: 'Prepare a local account export',
                onTap: () => _showSnack('Export request prepared'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showHelpCenterSheet() {
    return _showThemedBottomSheet(
      title: 'Help Center',
      child: Column(
        children: [
          _optionTile(
            icon: Icons.question_answer_outlined,
            title: 'FAQs',
            subtitle: 'Subscription tracking, payments, and wallet help',
            onTap: () => _showSnack('FAQs opened'),
          ),
          _optionTile(
            icon: Icons.support_agent_rounded,
            title: 'Contact support',
            subtitle: 'support@scops.app',
            onTap: () => _showSnack('Support contact copied'),
          ),
          _optionTile(
            icon: Icons.bug_report_outlined,
            title: 'Report a problem',
            subtitle: 'Send an issue to the SCOPS team',
            onTap: () => _showSnack('Problem report started'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'SCOPS',
      applicationVersion: 'Version 1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: [_cyan, _orange]),
        ),
        child: const Icon(Icons.visibility_rounded, color: Colors.white),
      ),
      children: [
        Text('Smart Control of Paid System', style: TextStyle(color: _muted)),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _card,
        title: Text(
          'Log Out',
          style: TextStyle(color: _text, fontWeight: FontWeight.w900),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: _muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: TextStyle(color: _muted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<LogoutBloc>().add(const LogoutRequested());
            },
            child: Text(
              'Log Out',
              style: TextStyle(color: _orange, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _isDark ? _card : _lightText,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  ProfileMenuItem _menuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Color? iconColor,
    Widget? trailing,
  }) {
    final color = iconColor ?? _cyan;
    return ProfileMenuItem(
      icon: icon,
      title: title,
      subtitle: subtitle,
      iconColor: color,
      cardColor: _card,
      borderColor: color.withValues(alpha: title == 'Log Out' ? 0.32 : 0.16),
      textColor: _text,
      mutedColor: _muted,
      onTap: onTap,
      trailing: trailing,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeController = ThemeControllerScope.of(context);

    return BlocListener<LogoutBloc, AuthState>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
          context.read<UserCubit>().clearUser();
          context.read<SubscriptionBloc>().add(const SubscriptionReset());
          context.read<WalletBloc>().add(const WalletReset());
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AuthChoiceScreen()),
            (route) => false,
          );
        }
      },
      child: BlocListener<SubscriptionBloc, SubscriptionState>(
        listenWhen: (prev, curr) =>
            curr is SubscriptionData && prev is! SubscriptionData,
        listener: (context, state) {
          if (state is SubscriptionData) {
            context.read<ReviewsBloc>().add(
              PendingReviewsRequested(state.subscriptions),
            );
          }
        },
        child: Container(
          color: _bg,
          child: SafeArea(
            top: false,
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: BlocBuilder<UserCubit, UserModel?>(
                builder: (context, user) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Profile',
                              style: TextStyle(
                                color: _text,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          IconButton.filled(
                            style: IconButton.styleFrom(
                              backgroundColor: _card,
                              foregroundColor: _muted,
                              side: BorderSide(
                                color: _cyan.withValues(alpha: 0.18),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _showPreferencesSheet,
                            icon: const Icon(Icons.settings_outlined),
                            tooltip: 'Settings',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _avatar(user),
                      const SizedBox(height: 24),
                      _statsCard(),
                      const SizedBox(height: 18),
                      _section('Account'),
                      _menuItem(
                        icon: Icons.person_outline_rounded,
                        title: 'Edit Profile',
                        subtitle: 'Update your name and email',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfileScreen(),
                          ),
                        ),
                      ),
                      _menuItem(
                        icon: Icons.lock_outline_rounded,
                        title: 'Change Password',
                        subtitle: 'Update your password',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<ChangePasswordBloc>(),
                              child: const ChangePasswordScreen(),
                            ),
                          ),
                        ),
                      ),
                      _menuItem(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        subtitle: 'Manage renewal alerts and preferences',
                        onTap: _showNotificationsSheet,
                      ),
                      _reviewsSection(),
                      _section('Insights'),
                      _menuItem(
                        icon: Icons.star_outline_rounded,
                        title: 'Rate the App',
                        subtitle: 'Share your feedback to help us improve',
                        iconColor: _gold,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FeedbackScreen(),
                          ),
                        ),
                      ),
                      _section('Preferences'),
                      _menuItem(
                        icon: _isDark
                            ? Icons.dark_mode_outlined
                            : Icons.light_mode_outlined,
                        title: 'Dark Mode',
                        subtitle: _isDark
                            ? 'Using the original SCOPS theme'
                            : 'Using the SCOPS light theme',
                        onTap: () => themeController.setDarkMode(!_isDark),
                        trailing: Switch.adaptive(
                          value: _isDark,
                          activeColor: _cyan,
                          onChanged: themeController.setDarkMode,
                        ),
                      ),
                      _menuItem(
                        icon: Icons.tune_rounded,
                        title: 'Preferences',
                        subtitle: 'Manage account defaults',
                        onTap: _showPreferencesSheet,
                      ),
                      _menuItem(
                        icon: Icons.language_rounded,
                        title: 'Currency',
                        subtitle: _currency,
                        onTap: _showCurrencySheet,
                      ),
                      _menuItem(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy & Security',
                        subtitle: 'Data permissions, app lock, export data',
                        onTap: _showPrivacySheet,
                      ),
                      _section('Support'),
                      _menuItem(
                        icon: Icons.help_outline_rounded,
                        title: 'Help Center',
                        subtitle: 'FAQs and support',
                        onTap: _showHelpCenterSheet,
                      ),
                      _menuItem(
                        icon: Icons.info_outline_rounded,
                        title: 'About SCOPS',
                        subtitle: 'Version 1.0.0',
                        onTap: _showAboutDialog,
                      ),
                      if (user?.isAdmin == true) ...[
                        _section('Admin'),
                        _menuItem(
                          icon: Icons.shield_rounded,
                          iconColor: _orange,
                          title: 'Admin Panel',
                          subtitle: 'Manage users, services and statistics',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<AdminBloc>(),
                                child: const AdminDashboardScreen(),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      _menuItem(
                        icon: Icons.logout_rounded,
                        title: 'Log Out',
                        subtitle: 'Sign out of your account',
                        iconColor: _orange,
                        onTap: _showLogoutDialog,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileMenuItem extends StatelessWidget {
  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.cardColor,
    required this.borderColor,
    required this.textColor,
    required this.mutedColor,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color cardColor;
  final Color borderColor;
  final Color textColor;
  final Color mutedColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 21),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  color: mutedColor.withValues(alpha: 0.65),
                  size: 23,
                ),
          ],
        ),
      ),
    );
  }
}

class ProfileStatCard extends StatelessWidget {
  const ProfileStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.textColor,
    required this.mutedColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: mutedColor,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
