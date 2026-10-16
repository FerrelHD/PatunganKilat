import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../bill_engine/providers/bill_session_provider.dart';
import '../../onboarding/providers/user_profile_provider.dart';
import '../widgets/account_carousel.dart';
import '../widgets/create_session_bottom_sheet.dart';
import '../widgets/hero_balance_card.dart';
import '../widgets/recent_sessions_card.dart';

class HomeScreen extends ConsumerWidget {
  final VoidCallback onNavigateToSplitArena;
  final VoidCallback onNavigateToReceipt;

  const HomeScreen({
    super.key,
    required this.onNavigateToSplitArena,
    required this.onNavigateToReceipt,
  });

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) return 'Pagi';
    if (hour >= 11 && hour < 15) return 'Siang';
    if (hour >= 15 && hour < 18) return 'Sore';
    return 'Malam';
  }

  void _openCreateSession(BuildContext context) {
    CreateSessionBottomSheet.show(
      context,
      onSessionCreated: onNavigateToSplitArena,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);
    final session = ref.watch(billSessionProvider);
    final greeting = _getTimeGreeting();
    final displayName = userProfile.name.trim().isNotEmpty ? userProfile.name.trim() : 'Teman';

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
                        '$greeting, $displayName 👋',
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
                          content: const Text('Notifikasi: Aplikasi siap digunakan untuk bagi tagihan! 🎉'),
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
              HeroBalanceCard(
                onStartSplit: () {
                  if (session.hasActiveSession) {
                    onNavigateToSplitArena();
                  } else {
                    _openCreateSession(context);
                  }
                },
              ),

              const SizedBox(height: 24),

              // Transfer Accounts Carousel
              const AccountCarousel(),

              const SizedBox(height: 24),

              // Recent Sessions History Card
              RecentSessionsCard(
                onOpenActiveSession: onNavigateToSplitArena,
                onStartNewSession: () => _openCreateSession(context),
              ),

              const SizedBox(height: 96),
            ],
          ),
        ),
      ),
    );
  }
}
