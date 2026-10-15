import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/neo_pill_button.dart';
import '../../bill_engine/providers/bill_session_provider.dart';
import '../../onboarding/providers/user_profile_provider.dart';

class CreateSessionBottomSheet extends ConsumerStatefulWidget {
  final VoidCallback onSessionCreated;

  const CreateSessionBottomSheet({
    super.key,
    required this.onSessionCreated,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onSessionCreated,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CreateSessionBottomSheet(onSessionCreated: onSessionCreated),
    );
  }

  @override
  ConsumerState<CreateSessionBottomSheet> createState() => _CreateSessionBottomSheetState();
}

class _CreateSessionBottomSheetState extends ConsumerState<CreateSessionBottomSheet> {
  final _titleController = TextEditingController();
  final _friendInputController = TextEditingController();
  final List<String> _friendNames = [];

  @override
  void dispose() {
    _titleController.dispose();
    _friendInputController.dispose();
    super.dispose();
  }

  void _addFriend() {
    final name = _friendInputController.text.trim();
    if (name.isNotEmpty) {
      setState(() {
        _friendNames.add(name);
        _friendInputController.clear();
      });
    }
  }

  void _removeFriend(int index) {
    setState(() {
      _friendNames.removeAt(index);
    });
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Silakan masukkan nama tempat atau acara nongkrong'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      return;
    }

    final userProfile = ref.read(userProfileProvider);
    final creatorName = userProfile.name.isNotEmpty ? userProfile.name : 'Saya';

    ref.read(billSessionProvider.notifier).startNewSession(
      title: title,
      creatorName: creatorName,
      friendNames: _friendNames,
    );

    Navigator.of(context).pop();
    widget.onSessionCreated();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final userProfile = ref.watch(userProfileProvider);
    final myName = userProfile.name.isNotEmpty ? userProfile.name : 'Saya';

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mulai Patungan Baru',
                  style: AppTypography.screenTitle.copyWith(fontSize: 16),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.neoBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: AppColors.neoDark,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Step 1: Session Title
            Text('Tempat / Acara Nongkrong', style: AppTypography.captionBold),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.neoDark,
              ),
              decoration: InputDecoration(
                hintText: 'Contoh: Kopi Tuku, Mie Gacoan, Futsal',
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neoMuted,
                ),
                filled: true,
                fillColor: AppColors.neoBg,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Step 2: Friends
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Siapa Saja yang Ikut?', style: AppTypography.captionBold),
                Text(
                  '${_friendNames.length + 1} Orang',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.neoDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Friend list chips
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                // Me chip (Talangan)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.neoLime,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$myName (Talangan)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.neoDark,
                        ),
                      ),
                    ],
                  ),
                ),

                // Other friends chips
                ..._friendNames.asMap().entries.map((entry) {
                  final index = entry.key;
                  final friendName = entry.value;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.neoBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          friendName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.neoDark,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => _removeFriend(index),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 14,
                            color: AppColors.neoMuted,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),

            const SizedBox(height: 12),

            // Add friend text field
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _friendInputController,
                    onSubmitted: (_) => _addFriend(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neoDark,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ketik nama teman (misal: Budi, Cindy)...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.neoMuted,
                      ),
                      filled: true,
                      fillColor: AppColors.neoBg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: AppColors.neoDark,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: _addFriend,
                    borderRadius: BorderRadius.circular(16),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Text(
                        '+ Tambah',
                        style: TextStyle(
                          color: AppColors.neoLime,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Submit Button
            NeoPillButton(
              label: 'Masuk ke Split Arena ⚡',
              variant: NeoPillVariant.dark,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
