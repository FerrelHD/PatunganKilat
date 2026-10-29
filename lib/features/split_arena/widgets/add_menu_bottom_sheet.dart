import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/neo_pill_button.dart';
import '../../../core/widgets/neo_toast.dart';

class AddMenuBottomSheet extends StatefulWidget {
  final void Function(String name, int price, String emoji, int quantity) onSave;

  const AddMenuBottomSheet({
    super.key,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    required void Function(String name, int price, String emoji, int quantity) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddMenuBottomSheet(onSave: onSave),
    );
  }

  @override
  State<AddMenuBottomSheet> createState() => _AddMenuBottomSheetState();
}

class _AddMenuBottomSheetState extends State<AddMenuBottomSheet> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  String _selectedEmoji = '🥟';
  int _quantity = 1;

  final List<String> _emojiOptions = ['🥟', '🍜', '🍗', '🍵', '🍨', '🍕', '🍔', '☕'];

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final price = int.tryParse(_priceController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    if (name.isEmpty || price <= 0) {
      NeoToast.show(
        context,
        'Silakan masukkan nama menu dan nominal harga yang valid',
        type: NeoToastType.warning,
      );
      return;
    }

    widget.onSave(name, price, _selectedEmoji, _quantity);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tambah Menu Baru',
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
          const SizedBox(height: 16),

          // Menu Name Field
          Text('Nama Makanan / Minuman', style: AppTypography.captionBold),
          const SizedBox(height: 6),
          TextField(
            controller: _nameController,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.neoDark,
            ),
            decoration: InputDecoration(
              hintText: 'Contoh: Gyoza Ayam Crispy',
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
          const SizedBox(height: 14),

          // Price Field
          Text('Harga Satuan (Rp)', style: AppTypography.captionBold),
          const SizedBox(height: 6),
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.neoDark,
            ),
            decoration: InputDecoration(
              hintText: '38000',
              hintStyle: GoogleFonts.jetBrainsMono(
                fontSize: 13,
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
          const SizedBox(height: 14),

          // Quantity Stepper (Berapa kali pesan)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Jumlah Pesanan (Porsi)', style: AppTypography.captionBold),
                  Text('Berapa kali menu ini dipesan', style: AppTypography.bodyMuted.copyWith(fontSize: 11)),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.neoBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        if (_quantity > 1) {
                          setState(() => _quantity--);
                        }
                      },
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        child: const Icon(Icons.remove_rounded, size: 16, color: AppColors.neoDark),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '$_quantity',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.neoDark,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => setState(() => _quantity++),
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        child: const Icon(Icons.add_rounded, size: 16, color: AppColors.neoDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Emoji Selector
          Text('Pilih Ikon Emoji', style: AppTypography.captionBold),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _emojiOptions.map((emoji) {
                final isSelected = emoji == _selectedEmoji;
                return GestureDetector(
                  onTap: () => setState(() => _selectedEmoji = emoji),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.neoLime : AppColors.neoBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppColors.neoDark : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 22),

          // Submit Button
          NeoPillButton(
            label: 'Simpan & Assign ke Teman Aktif',
            variant: NeoPillVariant.dark,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
