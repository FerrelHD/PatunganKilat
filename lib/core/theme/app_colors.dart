import 'package:flutter/material.dart';

/// Design tokens for PatunganKilat Neobank Aesthetics.
class AppColors {
  AppColors._();

  static const Color neoBg = Color(0xFFF5F6F8);
  static const Color neoCard = Color(0xFFFFFFFF);
  static const Color neoDark = Color(0xFF141518);
  static const Color neoLime = Color(0xFFC5F536);
  static const Color neoLimeDark = Color(0xFF9ED115);
  static const Color neoMuted = Color(0xFF8A8F9E);
  static const Color neoSoft = Color(0xFFEEF0F4);
  static const Color neoBorder = Color(0x0D141518);

  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color(0x0A141518),
      blurRadius: 24,
      offset: Offset(0, 8),
      spreadRadius: -4,
    ),
  ];

  static const List<BoxShadow> floatShadow = [
    BoxShadow(
      color: Color(0x24141518),
      blurRadius: 30,
      offset: Offset(0, 14),
      spreadRadius: -6,
    ),
  ];
}
