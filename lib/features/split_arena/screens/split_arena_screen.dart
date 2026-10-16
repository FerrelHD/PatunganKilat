import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/neo_pill_button.dart';
import '../../bill_engine/providers/bill_session_provider.dart';
import '../../home/widgets/create_session_bottom_sheet.dart';
import '../widgets/add_menu_bottom_sheet.dart';
import '../widgets/friend_target_card.dart';
import '../widgets/menu_item_tile.dart';
import '../widgets/tax_service_promo_bar.dart';

class SplitArenaScreen extends ConsumerWidget {
  final VoidCallback onBack;
  final VoidCallback onNavigateToReceipt;

  const SplitArenaScreen({
    super.key,
    required this.onBack,
    required this.onNavigateToReceipt,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(billSessionProvider);
    final calc = ref.watch(splitCalculationProvider);
    final notifier = ref.read(billSessionProvider.notifier);

    if (!session.hasActiveSession || session.friends.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.neoBg,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    InkWell(
                      onTap: onBack,
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: AppColors.softShadow,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 16,
                            color: AppColors.neoDark,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'Split Arena',
                      style: AppTypography.screenTitle,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: AppColors.softShadow,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              color: AppColors.neoBg,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text('🍽️', style: TextStyle(fontSize: 32)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum Ada Sesi Patungan',
                            style: AppTypography.cardTitle.copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Mulai buat sesi patungan baru untuk menentukan teman-teman yang ikut dan membagi tagihan.',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyMuted.copyWith(fontSize: 12, height: 1.4),
                          ),
                          const SizedBox(height: 24),
                          NeoPillButton(
                            label: '+ Buat Patungan Baru',
                            onPressed: () {
                              CreateSessionBottomSheet.show(
                                context,
                                onSessionCreated: () {},
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final activeFriend = session.friends.firstWhere(
      (f) => f.id == session.activeFriendId,
      orElse: () => session.friends.first,
    );

    return Scaffold(
      backgroundColor: AppColors.neoBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: onBack,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: AppColors.softShadow,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: AppColors.neoDark,
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        session.sessionTitle,
                        style: AppTypography.screenTitle,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Pilih teman lalu tap menu untuk assign',
                        style: AppTypography.captionBold.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      AddMenuBottomSheet.show(
                        context,
                        onSave: (name, price, emoji) {
                          notifier.addNewMenuItem(name, price, emoji);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('"$name" ditambahkan ke tagihan!'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          );
                        },
                      );
                    },
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.neoDark,
                        shape: BoxShape.circle,
                        boxShadow: AppColors.softShadow,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add_rounded,
                          size: 20,
                          color: AppColors.neoLime,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Arena Body
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Friend Selectors / Drop Targets
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('1. Pilih / Drop ke Teman', style: AppTypography.cardTitle),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.neoLime,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Target: ${activeFriend.name}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.neoDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: session.friends.map((friend) {
                        final breakdown = calc.breakdowns.firstWhere(
                          (b) => b.friend.id == friend.id,
                          orElse: () => calc.breakdowns.first,
                        );

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: FriendTargetCard(
                              friend: friend,
                              totalAmount: breakdown.finalAmount,
                              isSelected: friend.id == session.activeFriendId,
                              onTap: () => notifier.selectActiveFriend(friend.id),
                              onDropItem: (item) {
                                notifier.toggleItemAssignment(item.id, friend.id);
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 18),

                    // Section 2: Proportional Components (PB1, Service, Discount)
                    const TaxServicePromoBar(),

                    const SizedBox(height: 18),

                    // Section 3: Menu Items List
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('2. Daftar Menu (Tap / Drag)', style: AppTypography.cardTitle),
                        InkWell(
                          onTap: () {
                            notifier.splitAllEqually();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Semua menu dibagi rata ke seluruh teman!'),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            );
                          },
                          child: Text(
                            'Bagi Rata Semua',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.neoDark,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (session.items.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppColors.softShadow,
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(
                                color: AppColors.neoBg,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text('🍜', style: TextStyle(fontSize: 22)),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Belum Ada Menu Dicatat',
                              style: AppTypography.cardTitle.copyWith(fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tambahkan menu makanan atau minuman pertama untuk mulai membagikan porsi ke teman.',
                              textAlign: TextAlign.center,
                              style: AppTypography.bodyMuted.copyWith(fontSize: 11, height: 1.4),
                            ),
                            const SizedBox(height: 16),
                            Material(
                              color: AppColors.neoDark,
                              borderRadius: BorderRadius.circular(999),
                              child: InkWell(
                                onTap: () {
                                  AddMenuBottomSheet.show(
                                    context,
                                    onSave: (name, price, emoji) {
                                      notifier.addNewMenuItem(name, price, emoji);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('"$name" ditambahkan ke tagihan!'),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        ),
                                      );
                                    },
                                  );
                                },
                                borderRadius: BorderRadius.circular(999),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.add_rounded, size: 16, color: AppColors.neoLime),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Tambah Menu Pertama',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.neoLime,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: session.items.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = session.items[index];
                          return MenuItemTile(
                            item: item,
                            activeFriendId: session.activeFriendId,
                            allFriends: session.friends,
                            onToggleAssign: () {
                              notifier.toggleItemAssignment(item.id, session.activeFriendId);
                            },
                          );
                        },
                      ),

                    const SizedBox(height: 180), // Space for sticky bottom bar & floating dock
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Sticky Bottom Bar
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 84),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Bersih (+Pajak -Diskon)',
                  style: AppTypography.bodyMuted.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  CurrencyFormatter.formatRp(calc.grandTotal),
                  style: AppTypography.monoPrice.copyWith(fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Material(
              color: AppColors.neoDark,
              borderRadius: BorderRadius.circular(999),
              child: InkWell(
                onTap: () {
                  if (session.items.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Tambahkan minimal 1 menu makanan terlebih dahulu untuk melihat struk'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    );
                    return;
                  }
                  onNavigateToReceipt();
                },
                borderRadius: BorderRadius.circular(999),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Lihat Struk & QRIS',
                        style: AppTypography.buttonText,
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: AppColors.neoLime,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
