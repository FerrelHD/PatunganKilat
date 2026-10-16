import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/neo_pill_button.dart';
import '../../onboarding/providers/user_profile_provider.dart';

class EditAccountBottomSheet extends ConsumerStatefulWidget {
  const EditAccountBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EditAccountBottomSheet(),
    );
  }

  @override
  ConsumerState<EditAccountBottomSheet> createState() => _EditAccountBottomSheetState();
}

class _EditAccountBottomSheetState extends ConsumerState<EditAccountBottomSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _accountController;
  late final TextEditingController _walletController;
  late String _selectedBank;
  late String _selectedWallet;

  final List<String> _bankOptions = [
    'BCA',
    'Mandiri',
    'BNI',
    'BRI',
    'SeaBank',
    'CIMB',
    'Jago',
  ];

  final List<String> _walletOptions = [
    'GoPay',
    'OVO',
    'Dana',
    'ShopeePay',
  ];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    _nameController = TextEditingController(text: profile.name);
    _accountController = TextEditingController(text: profile.accountNumber);
    _walletController = TextEditingController(text: profile.walletNumber);

    _selectedBank = _bankOptions.contains(profile.bankName) ? profile.bankName : 'BCA';
    _selectedWallet = _walletOptions.contains(profile.walletName) ? profile.walletName : 'GoPay';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _accountController.dispose();
    _walletController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Nama panggilan tidak boleh kosong'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      return;
    }

    final bankAcc = _accountController.text.trim();
    final walletNum = _walletController.text.trim();

    await ref.read(userProfileProvider.notifier).saveProfile(
      name: name,
      bankName: _selectedBank,
      accountNumber: bankAcc,
      walletName: _selectedWallet,
      walletNumber: walletNum,
    );

    if (!mounted) return;
    Navigator.pop(context);

    final walletMsg = walletNum.isNotEmpty ? ' & $_selectedWallet' : '';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rekening talangan berhasil diperbarui ($_selectedBank$walletMsg)! ⚡'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final maxHeight = MediaQuery.of(context).size.height * 0.88;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomInset),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Atur Rekening Talangan',
                  style: AppTypography.screenTitle.copyWith(fontSize: 17),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.neoSoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.close_rounded, size: 16, color: AppColors.neoDark),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Rekening ini akan dicantumkan di struk dan teks WhatsApp agar teman-teman bisa transfer via Bank atau E-Wallet.',
              style: AppTypography.bodyMuted.copyWith(fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 20),

            // Name field
            Text('Nama Panggilanmu', style: AppTypography.cardTitle.copyWith(fontSize: 12)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.neoSoft,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _nameController,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neoDark,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Contoh: Raka / Alex',
                ),
              ),
            ),
            const SizedBox(height: 20),

            // SECTION 1: BANK
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.neoDark,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'UTAMA',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: AppColors.neoLime,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('Rekening Bank Utama', style: AppTypography.cardTitle.copyWith(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _bankOptions.map((bank) {
                  final isSelected = _selectedBank == bank;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => setState(() => _selectedBank = bank),
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.neoDark : AppColors.neoSoft,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          bank,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? AppColors.neoLime : AppColors.neoDark,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.neoSoft,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _accountController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neoDark,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Nomor Rekening Bank (Contoh: 682044918821)',
                ),
              ),
            ),
            const SizedBox(height: 24),

            // SECTION 2: E-WALLET (OPSIONAL)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.neoLime,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'PILIHAN',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: AppColors.neoDark,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('Akun E-Wallet (Opsional)', style: AppTypography.cardTitle.copyWith(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _walletOptions.map((wallet) {
                  final isSelected = _selectedWallet == wallet;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => setState(() => _selectedWallet = wallet),
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.neoDark : AppColors.neoSoft,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          wallet,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? AppColors.neoLime : AppColors.neoDark,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.neoSoft,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _walletController,
                keyboardType: TextInputType.phone,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neoDark,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Nomor HP E-Wallet (Kosongkan jika tidak ada)',
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Submit Button
            NeoPillButton(
              label: 'Simpan Pengaturan Rekening',
              icon: const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.neoLime),
              onPressed: _handleSave,
            ),
          ],
        ),
      ),
    );
  }
}
