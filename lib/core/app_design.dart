import 'package:flutter/material.dart';

class D {
  D._();

  // ── Colors ─────────────────────────────────────────────────────────────────
  static const bg           = Color(0xFF0A0C0F);
  static const cyan         = Color(0xFF1DD8E8);
  static const orange       = Color(0xFFFF5A14);
  static const white        = Color(0xFFFFFFFF);
  static const textSub      = Color(0xFF8A9BA8);
  static const cardBg       = Color(0xFF111418);
  static const fieldBg      = Color(0xFF1A1E26);
  static const navBg        = Color(0xFF13171E);
  static const iconBtnBg    = Color(0xFF181E26);
  static const tealCardBg   = Color(0xFF091D22);
  static const orangeCardBg = Color(0xFF1C0D05);

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
}) =>
    BoxDecoration(
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
      border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.0),
      gradient: const LinearGradient(
        colors: [
          Color(0xFF1E2530),
          Color(0xFF111418),
          Color(0xFF0D1014),
        ],
        stops: [0.0, 0.5, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );

  // ── Text styles ────────────────────────────────────────────────────────────
  static const tsPageTitle = TextStyle(color: white,   fontSize: 32, fontWeight: FontWeight.w900);
  static const tsSection   = TextStyle(color: white,   fontSize: 20, fontWeight: FontWeight.w800);
  static const tsLabel     = TextStyle(color: textSub, fontSize: 13);
  static const tsBody      = TextStyle(color: white,   fontSize: 14, fontWeight: FontWeight.w600);
  static const tsCaption   = TextStyle(color: textSub, fontSize: 12);
}