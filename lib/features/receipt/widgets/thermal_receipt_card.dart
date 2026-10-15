import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/jagged_receipt_clipper.dart';
import '../../bill_engine/models/split_breakdown.dart';
import '../../bill_engine/providers/bill_session_provider.dart';
import '../../onboarding/providers/user_profile_provider.dart';

class ThermalReceiptCard extends ConsumerWidget {
  final BillSessionState session;
  final SplitCalculationResult calc;

  const ThermalReceiptCard({
    super.key,
    required this.session,
    required this.calc,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);
    final bankName = userProfile.bankName.isNotEmpty ? userProfile.bankName : 'BCA';
    final accountNumber = userProfile.accountNumber.isNotEmpty ? userProfile.accountNumber : '-';
    final accountHolder = userProfile.name.isNotEmpty ? userProfile.name : 'Talangan';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main White Receipt Container
        Container(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rincian Per Orang',
                    style: AppTypography.cardTitle.copyWith(fontSize: 13),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.neoBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Proporsional',
                      style: AppTypography.captionBold.copyWith(fontSize: 10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildDashedLine(),
              const SizedBox(height: 12),

              // Breakdown rows for each friend
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: calc.breakdowns.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final person = calc.breakdowns[index];
                  final itemsStr = person.items.isEmpty
                      ? 'Belum pesan menu'
                      : person.items
                          .map((i) => i.isShared ? '${i.itemName} (1/${i.sharedCount})' : i.itemName)
                          .join(', ');

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.neoBg.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: const BoxDecoration(
                                    color: AppColors.neoDark,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      person.friend.avatarInitial,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.neoLime,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  person.friend.name,
                                  style: AppTypography.cardTitle.copyWith(fontSize: 12),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '(${(person.proportion * 100).round()}%)',
                                  style: AppTypography.bodyMuted.copyWith(fontSize: 10),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.neoLime,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                CurrencyFormatter.formatRp(person.finalAmount),
                                style: AppTypography.monoPrice.copyWith(fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.only(left: 30),
                          child: Text(
                            itemsStr,
                            style: AppTypography.bodyMuted.copyWith(
                              fontSize: 10,
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.only(left: 30),
                          child: Wrap(
                            spacing: 8,
                            children: [
                              Text(
                                'Menu: ${CurrencyFormatter.formatShortRp(person.subtotal)}',
                                style: AppTypography.monoPriceSmall.copyWith(color: AppColors.neoMuted),
                              ),
                              Text(
                                '+Pajak: ${CurrencyFormatter.formatShortRp(person.taxShare)}',
                                style: AppTypography.monoPriceSmall.copyWith(color: AppColors.neoMuted),
                              ),
                              if (person.discountShare > 0)
                                Text(
                                  '-Diskon: ${CurrencyFormatter.formatShortRp(person.discountShare)}',
                                  style: AppTypography.monoPriceSmall.copyWith(
                                    color: AppColors.neoLimeDark,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 14),
              _buildDashedLine(),
              const SizedBox(height: 12),

              // Summary Calculations
              _buildSummaryRow('Subtotal Menu', CurrencyFormatter.formatRp(calc.subtotalAll)),
              const SizedBox(height: 4),
              _buildSummaryRow(
                'Pajak PB1 (${(calc.taxRate * 100).round()}%) + Service (${(calc.serviceRate * 100).round()}%)',
                '+${CurrencyFormatter.formatRp(calc.totalTaxService)}',
              ),
              const SizedBox(height: 4),
              _buildSummaryRow(
                'Diskon Promo Proporsional',
                '-${CurrencyFormatter.formatRp(calc.totalDiscount)}',
                valueColor: AppColors.neoLimeDark,
                isBold: true,
              ),
              const SizedBox(height: 8),
              const Divider(color: AppColors.neoBg, thickness: 1.5),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('TOTAL TAGIHAN', style: AppTypography.cardTitle.copyWith(fontSize: 13)),
                  Text(
                    CurrencyFormatter.formatRp(calc.grandTotal),
                    style: AppTypography.monoPrice.copyWith(fontSize: 16),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Payment Info Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.neoBg,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.neoDark,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              'QR',
                              style: TextStyle(
                                color: AppColors.neoLime,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TRANSFER KE ${bankName.toUpperCase()}',
                              style: AppTypography.captionBold.copyWith(fontSize: 9),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              accountNumber,
                              style: AppTypography.monoAccountNumber.copyWith(fontSize: 12),
                            ),
                            Text(
                              'a.n. $accountHolder',
                              style: AppTypography.bodyMuted.copyWith(fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: accountNumber));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Nomor rekening $bankName ($accountNumber) disalin!'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Text(
                            'Salin',
                            style: AppTypography.cardTitle.copyWith(fontSize: 11),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Jagged Receipt Bottom
        ClipPath(
          clipper: const JaggedReceiptClipper(toothWidth: 16, toothHeight: 10),
          child: Container(
            height: 10,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMuted.copyWith(
            fontSize: 11,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: valueColor ?? AppColors.neoMuted,
          ),
        ),
        Text(
          value,
          style: AppTypography.monoPriceSmall.copyWith(
            color: valueColor ?? AppColors.neoDark,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDashedLine() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.black12),
              ),
            );
          }),
        );
      },
    );
  }
}
