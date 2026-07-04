import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'theme/theme_controller.dart';

class D {
  D._();

  // ── Colors ─────────────────────────────────────────────────────────────────
  static bool get _isDark => ThemeController.currentMode == ThemeMode.dark;
  static Color get bg =>
      _isDark ? const Color(0xFF0A0C0F) : AppColors.lightBackground;
  static const cyan = Color(0xFF1DD8E8);
  static const orange = Color(0xFFFF5A14);
  static Color get white =>
      _isDark ? const Color(0xFFFFFFFF) : AppColors.lightTextPrimary;
  static Color get textSub =>
      _isDark ? const Color(0xFF8A9BA8) : AppColors.lightTextSecondary;
  static Color get cardBg =>
      _isDark ? const Color(0xFF111418) : AppColors.lightSurface;
  static Color get fieldBg =>
      _isDark ? const Color(0xFF1A1E26) : AppColors.lightSecondarySurface;
  static Color get navBg =>
      _isDark ? const Color(0xFF13171E) : AppColors.lightNavBar;
  static Color get iconBtnBg =>
      _isDark ? const Color(0xFF181E26) : AppColors.lightSecondarySurface;
  static Color get tealCardBg =>
      _isDark ? const Color(0xFF091D22) : AppColors.lightSecondarySurface;
  static Color get orangeCardBg =>
      _isDark ? const Color(0xFF1C0D05) : AppColors.lightSecondarySurface;

  // ── Border radii ───────────────────────────────────────────────────────────
  static const r12 = BorderRadius.all(Radius.circular(12));
  static const r16 = BorderRadius.all(Radius.circular(16));
  static const r20 = BorderRadius.all(Radius.circular(20));
  static const r22 = BorderRadius.all(Radius.circular(22));
  static const r24 = BorderRadius.all(Radius.circular(24));
  static const r28 = BorderRadius.all(Radius.circular(28));
  static const r30 = BorderRadius.all(Radius.circular(30));

  // ── Glowing bordered card decoration ──────────────────────────────────────
  static BoxDecoration glowCard({
    required Color accent,
    required Color bg,
    BorderRadius? radius,
    AlignmentGeometry lightFrom = Alignment.topLeft,
  }) => BoxDecoration(
    color: bg,
    borderRadius: radius ?? r24,
    border: Border.all(color: accent.withOpacity(0.30), width: 1.0),
    boxShadow: [
      BoxShadow(
        color: accent.withOpacity(0.22),
        blurRadius: 35,
        spreadRadius: 2,
        offset: lightFrom == Alignment.topLeft
            ? const Offset(-8, -8)
            : const Offset(8, -8),
      ),
    ],
  );

  // ── Plain dark card decoration ─────────────────────────────────────────────
  static BoxDecoration plainCard({BorderRadius? radius}) => BoxDecoration(
    borderRadius: radius ?? r20,
    border: Border.all(
      color: _isDark ? Colors.white.withOpacity(0.08) : AppColors.lightBorder,
      width: 1.0,
    ),
    gradient: LinearGradient(
      colors: _isDark
          ? const [Color(0xFF1E2530), Color(0xFF111418), Color(0xFF0D1014)]
          : const [
              AppColors.lightSurface,
              AppColors.lightSurface,
              AppColors.lightSecondarySurface,
            ],
      stops: [0.0, 0.5, 1.0],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  // ── Text styles ────────────────────────────────────────────────────────────
  static TextStyle get tsPageTitle =>
      TextStyle(color: white, fontSize: 32, fontWeight: FontWeight.w900);
  static TextStyle get tsSection =>
      TextStyle(color: white, fontSize: 20, fontWeight: FontWeight.w800);
  static TextStyle get tsLabel => TextStyle(color: textSub, fontSize: 13);
  static TextStyle get tsBody =>
      TextStyle(color: white, fontSize: 14, fontWeight: FontWeight.w600);
  static TextStyle get tsCaption => TextStyle(color: textSub, fontSize: 12);
}
