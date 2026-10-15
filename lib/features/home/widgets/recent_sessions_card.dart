import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../bill_engine/providers/bill_session_provider.dart';

class RecentSessionsCard extends ConsumerWidget {
  final VoidCallback onOpenActiveSession;
  final VoidCallback onStartNewSession;

  const RecentSessionsCard({
    super.key,
    required this.onOpenActiveSession,
    required this.onStartNewSession,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calc = ref.watch(splitCalculationProvider);
    final session = ref.watch(billSessionProvider);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.neoCard,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sesi Patungan',
                style: AppTypography.sectionHeading,
              ),
              if (session.hasActiveSession)
                Text(
                  '1 Sesi',
                  style: AppTypography.captionBold.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          if (!session.hasActiveSession)
            // Empty State
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.neoBg.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('🍽️', style: TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Belum Ada Sesi Patungan',
                    style: AppTypography.cardTitle.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Siap talangin makanan di restoran atau kafe? Buat sesi patungan sekarang dan bagi tagihan tanpa drama.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMuted.copyWith(fontSize: 11, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  Material(
                    color: AppColors.neoDark,
                    borderRadius: BorderRadius.circular(999),
                    child: InkWell(
                      onTap: onStartNewSession,
                      borderRadius: BorderRadius.circular(999),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          '+ Buat Patungan Baru',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.neoLime,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            // Active Session Row
            InkWell(
              onTap: onOpenActiveSession,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.neoBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text('🍜', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.sessionTitle,
                            style: AppTypography.cardTitle,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Hari ini • ${session.friends.length} Orang • ${session.items.length} Menu',
                            style: AppTypography.bodyMuted,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          CurrencyFormatter.formatRp(calc.grandTotal),
                          style: AppTypography.monoPrice,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.neoLime,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Aktif • Edit',
                            style: AppTypography.captionBold.copyWith(
                              color: AppColors.neoDark,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
