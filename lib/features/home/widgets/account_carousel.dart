import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/neo_dark_card.dart';
import '../../../core/widgets/neo_lime_card.dart';
import '../../onboarding/providers/user_profile_provider.dart';

class AccountCarousel extends ConsumerWidget {
  const AccountCarousel({super.key});

  String _maskAccount(String raw) {
    if (raw.length <= 4) return raw;
    return '•••• ${raw.substring(raw.length - 4)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);
    final bankName = userProfile.bankName.isNotEmpty ? '${userProfile.bankName}.' : 'BCA.';
    final holderName = userProfile.name.isNotEmpty ? userProfile.name : 'Saya';
    final rawNumber = userProfile.accountNumber.isNotEmpty ? userProfile.accountNumber : '682044918821';
    final masked = _maskAccount(rawNumber);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rekening Talangan',
                style: AppTypography.sectionHeading,
              ),
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Rekening baru dapat disimpan di penyimpanan lokal'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    '+ Tambah',
                    style: AppTypography.cardTitle.copyWith(
                      color: AppColors.neoDark,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              NeoLimeCard(
                bankName: bankName,
                holderName: holderName,
                accountNumber: masked,
                rawAccountNumber: rawNumber,
              ),
              const SizedBox(width: 12),
              const NeoDarkCard(),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ],
    );
  }
}
