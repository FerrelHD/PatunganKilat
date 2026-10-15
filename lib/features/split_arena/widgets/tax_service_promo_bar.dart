import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../bill_engine/providers/bill_session_provider.dart';

class TaxServicePromoBar extends ConsumerWidget {
  const TaxServicePromoBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(billSessionProvider);
    final notifier = ref.read(billSessionProvider.notifier);

    final discountLabel = session.discountAmount > 0
        ? '-${CurrencyFormatter.formatShortRp(session.discountAmount)}'
        : 'Rp 0';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.neoCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.percent_rounded,
                    size: 14,
                    color: AppColors.neoLimeDark,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Komponen Proporsional Otomatis',
                    style: AppTypography.cardTitle.copyWith(fontSize: 11),
                  ),
                ],
              ),
              Text(
                'Real-time',
                style: AppTypography.captionBold.copyWith(fontSize: 9),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // PB1 Toggle
              Expanded(
                child: _ToggleButton(
                  title: 'Pajak PB1',
                  status: session.taxEnabled ? '10% ON' : 'OFF',
                  isActive: session.taxEnabled,
                  onTap: notifier.toggleTax,
                ),
              ),
              const SizedBox(width: 8),

              // Service Toggle
              Expanded(
                child: _ToggleButton(
                  title: 'Service',
                  status: session.serviceEnabled ? '5% ON' : 'OFF',
                  isActive: session.serviceEnabled,
                  onTap: notifier.toggleService,
                ),
              ),
              const SizedBox(width: 8),

              // Promo Discount Cycle
              Expanded(
                child: _ToggleButton(
                  title: 'Diskon Ojol',
                  status: discountLabel,
                  isActive: session.discountAmount > 0,
                  isPromo: true,
                  onTap: notifier.cycleDiscount,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String title;
  final String status;
  final bool isActive;
  final bool isPromo;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.title,
    required this.status,
    required this.isActive,
    this.isPromo = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.neoBg;
    Color textColor = AppColors.neoMuted;
    Color statusColor = AppColors.neoMuted;

    if (isActive) {
      if (isPromo) {
        bg = AppColors.neoLime.withValues(alpha: 0.25);
        textColor = AppColors.neoDark.withValues(alpha: 0.7);
        statusColor = AppColors.neoDark;
      } else {
        bg = AppColors.neoDark;
        textColor = Colors.white70;
        statusColor = AppColors.neoLime;
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPromo && isActive
                  ? AppColors.neoLimeDark.withValues(alpha: 0.4)
                  : Colors.transparent,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                status,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: statusColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
