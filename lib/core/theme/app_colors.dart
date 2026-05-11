import 'package:flutter/material.dart';

class AppColors {
  // Main SCOPS dark style
  static const background = Color(0xFF031014);
  static const background2 = Color(0xFF061A1F);
  static const background3 = Color(0xFF0B252B);

  // Cards
  static const surface = Color(0xFF0B252B);
  static const card = Color(0xCC0B252B);

  // Accent colors
  static const primary = Color(0xFF1DD8E8); // cyan
  static const secondary = Color(0xFFFF5A14); // orange
  static const orangeLight = Color(0xFFFF7A1A);

  // Text
  static const textPrimary = Color(0xFFE9F3F4);
  static const textSecondary = Color(0xFF9AB0B4);
  static const textMuted = Color(0xFF7E969A);

  // Borders
  static const borderCyan = Color(0x331DD8E8);
  static const borderOrange = Color(0x33FF5A14);

  // Status
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFFFB020);
  static const danger = Color(0xFFFF4D4D);

  // Old aliases, keep them so code does not break
  static const bgDeep = background;
  static const bgDark = background2;
  static const bgBlue = background3;
  static const cyan = primary;
  static const orange = secondary;
  static const cardDark = surface;
  static const iconMuted = textSecondary;
}