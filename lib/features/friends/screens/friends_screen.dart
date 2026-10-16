import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/neo_pill_button.dart';
import '../providers/saved_friends_provider.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  String _selectedGroup = 'Semua';

  static const List<String> _groupOptions = [
    'Tongkrongan Kampus',
    'Futsal Jumat',
    'Tim Kantor',
    'Teman Lainnya',
  ];

  void _showAddFriendDialog(BuildContext context) {
    final nameController = TextEditingController();
    String chosenGroup = _groupOptions.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
            return Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tambah Teman Baru',
                    style: AppTypography.screenTitle.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Simpan nama teman agar cepat dipilih saat split bill.',
                    style: AppTypography.bodyMuted,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: 'Nama Teman',
                      hintText: 'Contoh: Bagas',
                      prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.neoDark),
                      filled: true,
                      fillColor: AppColors.neoBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Pilih Grup Tongkrongan:',
                    style: AppTypography.captionBold.copyWith(color: AppColors.neoDark),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _groupOptions.map((grp) {
                      final isSelected = chosenGroup == grp;
                      return ChoiceChip(
                        label: Text(grp),
                        selected: isSelected,
                        labelStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? AppColors.neoDark : AppColors.neoMuted,
                        ),
                        backgroundColor: AppColors.neoBg,
                        selectedColor: AppColors.neoLime,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        onSelected: (val) {
                          if (val) setModalState(() => chosenGroup = grp);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  NeoPillButton(
                    label: 'Simpan Teman',
                    onPressed: () {
                      final name = nameController.text.trim();
                      if (name.isNotEmpty) {
                        ref.read(savedFriendsProvider.notifier).addFriend(name, group: chosenGroup);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$name berhasil ditambahkan ke $chosenGroup! 🎉'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteFriend(BuildContext context, SavedFriend friend) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus Teman?', style: AppTypography.cardTitle),
        content: Text('Hapus "${friend.name}" dari daftar teman tersimpan?', style: AppTypography.bodyMuted),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppColors.neoMuted)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(savedFriendsProvider.notifier).removeFriend(friend.id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final friends = ref.watch(savedFriendsProvider);
    final filteredFriends = _selectedGroup == 'Semua'
        ? friends
        : friends.where((f) => f.group == _selectedGroup).toList();

    final allGroups = ['Semua', ..._groupOptions];

    return Scaffold(
      backgroundColor: AppColors.neoBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Teman & Grup 👥',
                        style: AppTypography.screenTitle.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Kelola lingkaran tongkronganmu',
                        style: AppTypography.bodyMuted,
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => _showAddFriendDialog(context),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.neoDark,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppColors.softShadow,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.person_add_rounded, size: 16, color: AppColors.neoLime),
                          const SizedBox(width: 6),
                          Text(
                            '+ Teman',
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
                ],
              ),

              const SizedBox(height: 18),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: allGroups.map((grp) {
                    final isSelected = _selectedGroup == grp;
                    final count = grp == 'Semua'
                        ? friends.length
                        : friends.where((f) => f.group == grp).length;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text('$grp ($count)'),
                        selected: isSelected,
                        labelStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? AppColors.neoDark : AppColors.neoMuted,
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: AppColors.neoLime,
                        side: BorderSide(
                          color: isSelected ? Colors.transparent : Colors.black.withValues(alpha: 0.05),
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        onSelected: (val) {
                          setState(() => _selectedGroup = grp);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 18),

              // Friends List Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.neoCard,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: AppColors.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Daftar Teman Tersimpan',
                          style: AppTypography.sectionHeading,
                        ),
                        Text(
                          '${filteredFriends.length} Kontak',
                          style: AppTypography.captionBold.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    if (filteredFriends.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.neoBg.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            const Text('👥', style: TextStyle(fontSize: 28)),
                            const SizedBox(height: 8),
                            Text(
                              'Belum ada teman di kategori ini',
                              style: AppTypography.cardTitle.copyWith(fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tekan tombol "+ Teman" di atas untuk menambahkan.',
                              style: AppTypography.bodyMuted.copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredFriends.length,
                        separatorBuilder: (ctx, i) => Divider(
                          color: Colors.black.withValues(alpha: 0.04),
                          height: 16,
                        ),
                        itemBuilder: (ctx, i) {
                          final friend = filteredFriends[i];
                          final initial = friend.name.isNotEmpty ? friend.name[0].toUpperCase() : '?';
                          final isEven = i % 2 == 0;

                          return Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isEven ? AppColors.neoLime : AppColors.neoDark,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    initial,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: isEven ? AppColors.neoDark : Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(friend.name, style: AppTypography.cardTitle.copyWith(fontSize: 14)),
                                    const SizedBox(height: 2),
                                    Text(friend.group, style: AppTypography.bodyMuted.copyWith(fontSize: 11)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.neoMuted),
                                onPressed: () => _confirmDeleteFriend(context, friend),
                              ),
                            ],
                          );
                        },
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
