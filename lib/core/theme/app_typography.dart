import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography configuration using Plus Jakarta Sans & JetBrains Mono.
class AppTypography {
  AppTypography._();

  static TextStyle heroBalance = GoogleFonts.plusJakartaSans(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: AppColors.neoDark,
  );

  static TextStyle screenTitle = GoogleFonts.plusJakartaSans(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: AppColors.neoDark,
  );

  static TextStyle sectionHeading = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: AppColors.neoDark,
  );

  static TextStyle cardTitle = GoogleFonts.plusJakartaSans(
    fontSize: 13,
    fontWeight: FontWeight.w800,
    color: AppColors.neoDark,
  );

  static TextStyle menuName = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    color: AppColors.neoDark,
  );

  static TextStyle bodyMuted = GoogleFonts.plusJakartaSans(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.neoMuted,
  );

  static TextStyle captionBold = GoogleFonts.plusJakartaSans(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.neoMuted,
  );

  static TextStyle buttonText = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  // JetBrains Mono Monospace Styles
  static TextStyle monoPrice = GoogleFonts.jetBrainsMono(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.neoDark,
  );

  static TextStyle monoPriceSmall = GoogleFonts.jetBrainsMono(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.neoDark,
  );

  static TextStyle monoAccountNumber = GoogleFonts.jetBrainsMono(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: AppColors.neoDark,
  );
}
