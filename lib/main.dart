import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_typography.dart';
import 'features/friends/screens/friends_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/onboarding/providers/user_profile_provider.dart';
import 'features/onboarding/screens/splash_screen.dart';
import 'features/receipt/screens/receipt_screen.dart';
import 'features/split_arena/screens/split_arena_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: PatunganKilatApp(),
    ),
  );
}

class PatunganKilatApp extends StatelessWidget {
  const PatunganKilatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PatunganKilat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.neoBg,
        primaryColor: AppColors.neoDark,
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class MainNavigationShell extends ConsumerStatefulWidget {
  const MainNavigationShell({super.key});

  @override
  ConsumerState<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  int _currentIndex = 0;

  void _navigateToTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider);
    final userInitial = userProfile.name.trim().isNotEmpty
        ? userProfile.name.trim().substring(0, min(2, userProfile.name.trim().length)).toUpperCase()
        : 'PK';

    final screens = [
      HomeScreen(
        onNavigateToSplitArena: () => _navigateToTab(1),
        onNavigateToReceipt: () => _navigateToTab(3),
      ),
      SplitArenaScreen(
        onBack: () => _navigateToTab(0),
        onNavigateToReceipt: () => _navigateToTab(3),
      ),
      const FriendsScreen(),
      ReceiptScreen(
        onBack: () => _navigateToTab(1),
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                label: 'Home',
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
              ),
              _buildNavItem(
                index: 1,
                label: 'Split Bill',
                icon: Icons.calculate_outlined,
                activeIcon: Icons.calculate_rounded,
              ),
              _buildNavItem(
                index: 2,
                label: 'Teman',
                icon: Icons.people_outline_rounded,
                activeIcon: Icons.people_rounded,
              ),
              _buildNavItem(
                index: 3,
                label: 'Struk',
                icon: Icons.receipt_long_outlined,
                activeIcon: Icons.receipt_long_rounded,
                customBadge: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.neoLime,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.neoDark, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      userInitial,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: AppColors.neoDark,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
    Widget? customBadge,
    VoidCallback? onTapOverride,
  }) {
    final isActive = _currentIndex == index;

    return InkWell(
      onTap: onTapOverride ?? () => _navigateToTab(index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (customBadge != null)
              customBadge
            else
              Icon(
                isActive ? activeIcon : icon,
                size: 20,
                color: isActive ? AppColors.neoDark : AppColors.neoMuted,
              ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTypography.captionBold.copyWith(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive ? AppColors.neoDark : AppColors.neoMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
