import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../bill_engine/providers/bill_session_provider.dart';

class RecentSessionsCard extends ConsumerWidget {
  final VoidCallback onOpenActiveSession;

  const RecentSessionsCard({
    super.key,
    required this.onOpenActiveSession,
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
                'Riwayat Patungan',
                style: AppTypography.sectionHeading,
              ),
              Text(
                'Semua',
                style: AppTypography.captionBold.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

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
                          'Hari ini, 19:30 • ${session.friends.length} Orang',
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

          const Divider(color: AppColors.neoBg, thickness: 1.5, height: 16),

          // Past Session 1
          Padding(
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
                    child: Text('☕', style: TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kopi Tuku Kemang',
                        style: AppTypography.cardTitle,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Kemarin • 3 Orang',
                        style: AppTypography.bodyMuted,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rp 114.000',
                      style: AppTypography.monoPrice,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.neoBg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Lunas 3/3',
                        style: AppTypography.captionBold.copyWith(
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(color: AppColors.neoBg, thickness: 1.5, height: 16),

          // Past Session 2
          Padding(
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
                    child: Text('⚽', style: TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sewa Lapangan Mini Soccer',
                        style: AppTypography.cardTitle,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '12 Okt • 12 Orang',
                        style: AppTypography.bodyMuted,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rp 960.000',
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
                        '+Rp 80rb/org',
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
        ],
      ),
    );
  }
}
