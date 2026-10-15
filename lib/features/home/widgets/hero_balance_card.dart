import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/neo_pill_button.dart';
import '../../bill_engine/providers/bill_session_provider.dart';

class HeroBalanceCard extends ConsumerWidget {
  final VoidCallback onStartSplit;

  const HeroBalanceCard({
    super.key,
    required this.onStartSplit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(billSessionProvider);
    final calc = ref.watch(splitCalculationProvider);
    final notifier = ref.read(billSessionProvider.notifier);

    final displayBalance = session.hideBalance
        ? 'Rp •••••••'
        : CurrencyFormatter.formatRp(calc.grandTotal);

    return Container(
      padding: const EdgeInsets.all(20),
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
                'Total Talangan Aktif',
                style: AppTypography.captionBold.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.neoLime.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Sesi: ${session.sessionTitle}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.neoDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  displayBalance,
                  style: AppTypography.heroBalance,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              InkWell(
                onTap: notifier.toggleHideBalance,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.neoBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      session.hideBalance
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      size: 18,
                      color: AppColors.neoMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          NeoPillButton(
            label: 'Buat Patungan Kilat',
            icon: const Icon(
              Icons.add_circle_outline_rounded,
              size: 18,
              color: AppColors.neoLime,
            ),
            onPressed: onStartSplit,
          ),
        ],
      ),
    );
  }
}
