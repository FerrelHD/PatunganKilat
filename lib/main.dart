import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_colors.dart';
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
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(36),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(36),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.85),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: Row(
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
                      customBadge: (isActive) => Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.neoLime : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isActive ? AppColors.neoDark : Colors.black.withValues(alpha: 0.2),
                            width: 1.2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            userInitial,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 8.5,
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
    Widget Function(bool isActive)? customBadge,
  }) {
    final isActive = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _navigateToTab(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isActive ? AppColors.neoDark : Colors.transparent,
            borderRadius: BorderRadius.circular(28),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.16),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (customBadge != null)
                customBadge(isActive)
              else
                Icon(
                  isActive ? activeIcon : icon,
                  size: 19,
                  color: isActive ? AppColors.neoLime : AppColors.neoDark.withValues(alpha: 0.6),
                ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  color: isActive ? AppColors.neoLime : AppColors.neoDark.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
