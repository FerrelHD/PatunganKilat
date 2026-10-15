import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class NeoLimeCard extends StatelessWidget {
  final String bankName;
  final String holderName;
  final String accountNumber;
  final String rawAccountNumber;
  final VoidCallback? onCopy;

  const NeoLimeCard({
    super.key,
    this.bankName = 'BCA.',
    this.holderName = 'Raka Pratama',
    this.accountNumber = '•••• 8821',
    this.rawAccountNumber = '682044918821',
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: 148,
      decoration: BoxDecoration(
        color: AppColors.neoLime,
        borderRadius: BorderRadius.circular(26),
        boxShadow: AppColors.softShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            // Repetitive watermark pattern
            Positioned(
              left: -16,
              top: -16,
              right: -16,
              bottom: -16,
              child: Opacity(
                opacity: 0.38,
                child: Text(
                  'PATUNGAN.KILAT.PATUNGAN.KILAT.PATUNGAN.KILAT.PATUNGAN.KILAT.PATUNGAN.KILAT.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            // Card Foreground Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        bankName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          color: AppColors.neoDark,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.neoDark,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'QRIS Ready',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.neoLime,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Bottom Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              holderName,
                              style: AppTypography.bodyMuted.copyWith(
                                color: AppColors.neoDark.withValues(alpha: 0.75),
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              accountNumber,
                              style: AppTypography.monoAccountNumber,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: onCopy ?? () {
                            Clipboard.setData(ClipboardData(text: rawAccountNumber));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Nomor rekening $bankName ($rawAccountNumber) disalin!'),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.copy_rounded,
                                  size: 13,
                                  color: AppColors.neoDark,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Salin',
                                  style: AppTypography.buttonText.copyWith(
                                    fontSize: 11,
                                    color: AppColors.neoDark,
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
            ),
          ],
        ),
      ),
    );
  }
}
