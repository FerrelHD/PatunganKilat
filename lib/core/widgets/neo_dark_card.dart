import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class NeoDarkCard extends StatelessWidget {
  final String walletName;
  final String phoneNumber;
  final String category;

  const NeoDarkCard({
    super.key,
    this.walletName = 'GoPay',
    this.phoneNumber = '0812 •••• 901',
    this.category = 'E-Wallet',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 175,
      height: 148,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neoDark,
        borderRadius: BorderRadius.circular(26),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                walletName,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: AppColors.neoLime,
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.neoLime,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: AppTypography.captionBold.copyWith(
                  color: Colors.white60,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                phoneNumber,
                style: AppTypography.monoAccountNumber.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
