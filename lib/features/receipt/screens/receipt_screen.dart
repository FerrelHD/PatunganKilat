import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/receipt_share_util.dart';
import '../../../core/widgets/neo_pill_button.dart';
import '../../bill_engine/providers/bill_session_provider.dart';
import '../../home/widgets/create_session_bottom_sheet.dart';
import '../../onboarding/providers/user_profile_provider.dart';
import '../widgets/thermal_receipt_card.dart';

class ReceiptScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;

  const ReceiptScreen({
    super.key,
    required this.onBack,
  });

  @override
  ConsumerState<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends ConsumerState<ReceiptScreen> {
  final GlobalKey _receiptRepaintKey = GlobalKey();
  bool _isSavingImage = false;

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return months[(month - 1).clamp(0, 11)];
  }

  Future<void> _shareToWhatsApp() async {
    final session = ref.read(billSessionProvider);
    final calc = ref.read(splitCalculationProvider);
    final userProfile = ref.read(userProfileProvider);

    final text = ReceiptShareUtil.formatWhatsAppSummary(
      session: session,
      calc: calc,
      bankName: userProfile.bankName.isNotEmpty ? userProfile.bankName : 'BCA',
      accountNumber: userProfile.accountNumber.isNotEmpty ? userProfile.accountNumber : '-',
      accountHolder: userProfile.name.isNotEmpty ? userProfile.name : 'Saya',
    );

    await Clipboard.setData(ClipboardData(text: text));

    final launched = await ReceiptShareUtil.launchWhatsAppShare(text);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Rincian tersalin ke Clipboard! Buka WhatsApp untuk mengirim.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }

  Future<void> _saveReceiptImage() async {
    final session = ref.read(billSessionProvider);
    setState(() => _isSavingImage = true);

    try {
      final success = await ReceiptShareUtil.captureAndSaveReceipt(
        repaintBoundaryKey: _receiptRepaintKey,
        sessionTitle: session.sessionTitle,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Struk siap dibagikan / tersimpan! 🧾⚡'
                  : 'Gagal memproses gambar struk. Coba lagi.',
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingImage = false);
    }
  }

  void _confirmCompleteSession() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Selesaikan Patungan?', style: AppTypography.cardTitle),
        content: Text(
          'Pastikan semua teman sudah mentransfer atau mencatat rinciannya. Sesi patungan ini akan ditutup dan meja patungan akan kembali bersih.',
          style: AppTypography.bodyMuted,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppColors.neoMuted)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.neoDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(billSessionProvider.notifier).completeSession();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Sesi patungan selesai! Meja patungan sudah bersih 🎉'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              );
              widget.onBack();
            },
            child: const Text('Ya, Selesaikan', style: TextStyle(color: AppColors.neoLime, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(billSessionProvider);
    final calc = ref.watch(splitCalculationProvider);

    if (!session.hasActiveSession || session.friends.isEmpty || session.items.isEmpty) {
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
                      onTap: widget.onBack,
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
                      'Struk Patungan',
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
                              child: Text('🧾', style: TextStyle(fontSize: 32)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum Ada Struk Aktif',
                            style: AppTypography.cardTitle.copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Mulai sesi patungan dan masukkan menu pesanan untuk menghasilkan struk digital & rincian per orang.',
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
                    onTap: widget.onBack,
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
                  Text(
                    'Struk Patungan',
                    style: AppTypography.screenTitle,
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // Scrollable Receipt Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  children: [
                    // Profile-Style Header Badge
                    Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: AppColors.softShadow,
                              ),
                              padding: const EdgeInsets.all(5),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: AppColors.neoLime,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Text('🍜', style: TextStyle(fontSize: 34)),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: AppColors.neoDark,
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                  boxShadow: AppColors.softShadow,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.receipt_long_rounded,
                                    size: 15,
                                    color: AppColors.neoLime,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          session.sessionTitle,
                          style: AppTypography.cardTitle.copyWith(fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${DateTime.now().day} ${_getMonthName(DateTime.now().month)} ${DateTime.now().year} • Talangan oleh ${session.friends.firstWhere((f) => f.isPayer, orElse: () => session.friends.first).name}',
                          style: AppTypography.bodyMuted,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Thermal Receipt Card wrapped inside RepaintBoundary for PNG capture
                    RepaintBoundary(
                      key: _receiptRepaintKey,
                      child: ThermalReceiptCard(
                        session: session,
                        calc: calc,
                      ),
                    ),

                    const SizedBox(height: 200),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Action Bar
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 84),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Primary Action: Share ke WhatsApp
            Material(
              color: AppColors.neoDark,
              borderRadius: BorderRadius.circular(999),
              child: InkWell(
                onTap: _shareToWhatsApp,
                borderRadius: BorderRadius.circular(999),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.chat_bubble_rounded,
                        size: 18,
                        color: AppColors.neoLime,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Share Rincian ke WhatsApp',
                        style: AppTypography.buttonText,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Secondary Action: Simpan Gambar Struk PNG
            Material(
              color: AppColors.neoSoft,
              borderRadius: BorderRadius.circular(999),
              child: InkWell(
                onTap: _isSavingImage ? null : _saveReceiptImage,
                borderRadius: BorderRadius.circular(999),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.download_rounded,
                        size: 18,
                        color: _isSavingImage ? AppColors.neoMuted : AppColors.neoDark,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isSavingImage ? 'Menyiapkan Gambar...' : 'Simpan Gambar Struk (PNG)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _isSavingImage ? AppColors.neoMuted : AppColors.neoDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),

            // Tertiary: Selesaikan & Tutup Sesi
            InkWell(
              onTap: _confirmCompleteSession,
              borderRadius: BorderRadius.circular(999),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 16,
                      color: AppColors.neoMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Selesaikan & Tutup Sesi Ini',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neoMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
