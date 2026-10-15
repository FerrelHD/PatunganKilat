import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../widgets/account_carousel.dart';
import '../widgets/hero_balance_card.dart';
import '../widgets/recent_sessions_card.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onNavigateToSplitArena;
  final VoidCallback onNavigateToReceipt;

  const HomeScreen({
    super.key,
    required this.onNavigateToSplitArena,
    required this.onNavigateToReceipt,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neoBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar Greeting
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Malam, Raka 👋',
                        style: AppTypography.screenTitle.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Siap talangin tongkrongan?',
                        style: AppTypography.bodyMuted,
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Semua teman di grup Kopi Senja sudah lunas! 🎉'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppColors.softShadow,
                      ),
                      child: Stack(
                        children: [
                          const Center(
                            child: Icon(
                              Icons.notifications_none_rounded,
                              size: 20,
                              color: AppColors.neoDark,
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.neoLime,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Active Balance Summary Card
              HeroBalanceCard(onStartSplit: onNavigateToSplitArena),

              const SizedBox(height: 24),

              // Transfer Accounts Carousel
              const AccountCarousel(),

              const SizedBox(height: 24),

              // Recent Sessions History Card
              RecentSessionsCard(onOpenActiveSession: onNavigateToSplitArena),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
