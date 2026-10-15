import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/neo_pill_button.dart';
import '../../../main.dart';
import '../providers/user_profile_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameController = TextEditingController();
  final _accountController = TextEditingController();
  String _selectedBank = 'BCA';

  final List<String> _bankOptions = [
    'BCA',
    'Mandiri',
    'BNI',
    'BRI',
    'SeaBank',
    'GoPay',
    'OVO',
    'Dana',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  Future<void> _submitProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Silakan masukkan nama panggilanmu'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      return;
    }

    await ref.read(userProfileProvider.notifier).saveProfile(
      name: name,
      bankName: _selectedBank,
      accountNumber: _accountController.text.trim(),
    );

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => const MainNavigationShell(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neoBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Small Top Logo Badge
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.neoDark,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    'PK.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.neoLime,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Headings
              Text(
                'Selamat Datang di\nPatunganKilat ⚡',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                  letterSpacing: -0.5,
                  color: AppColors.neoDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Siapkan nama dan rekening kamu sekali saja agar langsung tercetak rapi di struk penagihan.',
                style: AppTypography.bodyMuted.copyWith(fontSize: 13, height: 1.4),
              ),

              const SizedBox(height: 32),

              // Card Form
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: AppColors.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Field 1: Name
                    Text('Nama Panggilanmu', style: AppTypography.cardTitle.copyWith(fontSize: 12)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nameController,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neoDark,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Contoh: Raka / Ferrel',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.neoMuted,
                        ),
                        filled: true,
                        fillColor: AppColors.neoBg,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Field 2: Bank Selection
                    Text('Bank / E-Wallet Transfer', style: AppTypography.cardTitle.copyWith(fontSize: 12)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _bankOptions.map((bank) {
                        final isSelected = bank == _selectedBank;
                        return ChoiceChip(
                          label: Text(bank),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedBank = bank);
                          },
                          labelStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? AppColors.neoDark : AppColors.neoMuted,
                          ),
                          selectedColor: AppColors.neoLime,
                          backgroundColor: AppColors.neoBg,
                          side: BorderSide(
                            color: isSelected ? AppColors.neoDark.withValues(alpha: 0.2) : Colors.transparent,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // Field 3: Account Number
                    Text('Nomor Rekening / No HP', style: AppTypography.cardTitle.copyWith(fontSize: 12)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _accountController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neoDark,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Contoh: 682044918821',
                        hintStyle: GoogleFonts.jetBrainsMono(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.neoMuted,
                        ),
                        filled: true,
                        fillColor: AppColors.neoBg,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // Submit Button
              NeoPillButton(
                label: 'Mulai Pakai PatunganKilat →',
                variant: NeoPillVariant.dark,
                onPressed: _submitProfile,
              ),

              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Data tersimpan 100% di HP kamu secara offline',
                  style: AppTypography.captionBold.copyWith(fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
