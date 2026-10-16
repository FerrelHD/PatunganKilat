import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class NeoDarkCard extends StatelessWidget {
  final String walletName;
  final String phoneNumber;
  final String rawPhoneNumber;
  final String category;
  final bool hasWallet;
  final VoidCallback? onCopy;
  final VoidCallback? onAdd;

  const NeoDarkCard({
    super.key,
    this.walletName = 'GoPay',
    this.phoneNumber = '',
    this.rawPhoneNumber = '',
    this.category = 'E-Wallet',
    this.hasWallet = false,
    this.onCopy,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasWallet && rawPhoneNumber.isEmpty && phoneNumber.isEmpty) {
      return Container(
        width: 185,
        height: 148,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.neoDark,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Colors.white12, width: 1.5),
          boxShadow: AppColors.softShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'OPSIONAL',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: Colors.white70,
                    ),
                  ),
                ),
                const Icon(
                  Icons.add_circle_outline_rounded,
                  size: 18,
                  color: AppColors.neoLime,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '+ E-Wallet',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'GoPay / OVO / Dana',
                  style: AppTypography.bodyMuted.copyWith(
                    color: Colors.white60,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final displayPhone = phoneNumber.isNotEmpty ? phoneNumber : rawPhoneNumber;

    return Container(
      width: 195,
      height: 148,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category,
                      style: AppTypography.captionBold.copyWith(
                        color: Colors.white60,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayPhone,
                      style: AppTypography.monoAccountNumber.copyWith(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Material(
                color: AppColors.neoLime,
                borderRadius: BorderRadius.circular(999),
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: onCopy ?? () {
                    final textToCopy = rawPhoneNumber.isNotEmpty ? rawPhoneNumber : phoneNumber;
                    Clipboard.setData(ClipboardData(text: textToCopy));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Nomor $walletName ($textToCopy) disalin!'),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.copy_rounded,
                          size: 11,
                          color: AppColors.neoDark,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'Salin',
                          style: AppTypography.buttonText.copyWith(
                            fontSize: 10,
                            color: AppColors.neoDark,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

