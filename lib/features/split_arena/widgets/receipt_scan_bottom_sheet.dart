import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/neo_pill_button.dart';
import '../../../core/widgets/neo_toast.dart';
import '../../bill_engine/models/menu_item.dart';
import '../../bill_engine/providers/bill_session_provider.dart';
import '../services/receipt_ocr_service.dart';

class ReceiptScanBottomSheet extends ConsumerStatefulWidget {
  const ReceiptScanBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const ReceiptScanBottomSheet(),
    );
  }

  @override
  ConsumerState<ReceiptScanBottomSheet> createState() => _ReceiptScanBottomSheetState();
}

class _ReceiptScanBottomSheetState extends ConsumerState<ReceiptScanBottomSheet> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _pasteController = TextEditingController();

  bool _isLoading = false;
  String _loadingMessage = '';
  bool _isPasteMode = false;

  List<ExtractedReceiptItem> _parsedItems = [];
  int? _detectedTax;
  int? _detectedService;

  @override
  void dispose() {
    _pasteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 85,
      );

      if (file == null) return;

      setState(() {
        _isLoading = true;
        _loadingMessage = 'Membaca struk dengan OCR Engine 2... 🔍';
      });

      final bytes = await file.readAsBytes();
      final result = await ReceiptOcrService.extractFromImageBytes(bytes);

      if (result.items.isEmpty) {
        if (mounted) {
          NeoToast.show(
            context,
            'Tidak menemukan daftar menu. Coba cek hasil foto atau tempel teks struk manual.',
            type: NeoToastType.warning,
          );
        }
      }

      setState(() {
        _parsedItems = result.items;
        _detectedTax = result.taxAmount;
        _detectedService = result.serviceAmount;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        NeoToast.show(
          context,
          'Gagal membaca foto struk: ${e.toString().replaceAll("Exception:", "").trim()}. Coba tempel teks struk yaa.',
          type: NeoToastType.error,
        );
        setState(() => _isPasteMode = true);
      }
    }
  }

  void _processPastedText() {
    final text = _pasteController.text.trim();
    if (text.isEmpty) {
      NeoToast.show(context, 'Teks struk belum diisi', type: NeoToastType.warning);
      return;
    }

    final result = ReceiptOcrService.parseReceiptText(text);
    if (result.items.isEmpty) {
      NeoToast.show(
        context,
        'Format teks tidak dikenali. Pastikan ada nama menu & harga (misal: 2x Nasi Goreng 50.000)',
        type: NeoToastType.warning,
      );
      return;
    }

    setState(() {
      _parsedItems = result.items;
      _detectedTax = result.taxAmount;
      _detectedService = result.serviceAmount;
      _isPasteMode = false;
    });

    NeoToast.show(
      context,
      'Berhasil mengekstrak ${_parsedItems.length} menu dari teks! ⚡',
      type: NeoToastType.success,
    );
  }

  void _showEditItemDialog(int index) {
    final item = _parsedItems[index];
    final nameController = TextEditingController(text: item.name);
    final priceController = TextEditingController(text: item.unitPrice.toString());

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Text(item.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text('Edit Menu Struk', style: AppTypography.cardTitle),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nama Menu', style: AppTypography.captionBold),
            const SizedBox(height: 4),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.neoBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text('Harga Satuan (Rp)', style: AppTypography.captionBold),
            const SizedBox(height: 4),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.neoBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.neoMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neoDark,
              foregroundColor: AppColors.neoLime,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final newName = nameController.text.trim();
              final newPrice = int.tryParse(priceController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? item.unitPrice;
              if (newName.isNotEmpty && newPrice > 0) {
                setState(() {
                  _parsedItems[index] = item.copyWith(
                    name: newName,
                    unitPrice: newPrice,
                    emoji: ReceiptOcrService.detectEmoji(newName),
                  );
                });
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final qtyController = TextEditingController(text: '1');

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.add_circle_outline_rounded, color: AppColors.neoDark),
            const SizedBox(width: 8),
            Text('Tambah Menu Struk', style: AppTypography.cardTitle),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nama Menu', style: AppTypography.captionBold),
            const SizedBox(height: 4),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Misal: Nasi Putih',
                hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.neoMuted, fontSize: 12),
                filled: true,
                fillColor: AppColors.neoBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Harga Satuan', style: AppTypography.captionBold),
                      const SizedBox(height: 4),
                      TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '8000',
                          hintStyle: GoogleFonts.jetBrainsMono(color: AppColors.neoMuted, fontSize: 12),
                          filled: true,
                          fillColor: AppColors.neoBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Qty', style: AppTypography.captionBold),
                      const SizedBox(height: 4),
                      TextField(
                        controller: qtyController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.neoBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.neoMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neoDark,
              foregroundColor: AppColors.neoLime,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final name = nameController.text.trim();
              final price = int.tryParse(priceController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
              final qty = int.tryParse(qtyController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;

              if (name.isNotEmpty && price > 0) {
                setState(() {
                  _parsedItems.add(
                    ExtractedReceiptItem(
                      name: name,
                      quantity: qty > 0 ? qty : 1,
                      unitPrice: price,
                      emoji: ReceiptOcrService.detectEmoji(name),
                    ),
                  );
                });
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Tambah', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _importToArena() {
    if (_parsedItems.isEmpty) return;

    final session = ref.read(billSessionProvider);
    final notifier = ref.read(billSessionProvider.notifier);

    final activeId = session.activeFriendId.isNotEmpty
        ? session.activeFriendId
        : (session.friends.isNotEmpty ? session.friends.first.id : '');

    final newMenuItems = _parsedItems.map((item) {
      return MenuItem(
        id: 'ocr_${DateTime.now().microsecondsSinceEpoch}_${item.name.hashCode}',
        name: item.name,
        price: item.unitPrice,
        quantity: item.quantity,
        emoji: item.emoji,
        assignedTo: activeId.isNotEmpty ? [activeId] : [],
        portions: activeId.isNotEmpty ? {activeId: item.quantity} : {},
      );
    }).toList();

    notifier.batchAddItems(newMenuItems);

    if (_detectedTax != null && _detectedTax! > 0 && !session.taxEnabled) {
      notifier.toggleTax();
    }
    if (_detectedService != null && _detectedService! > 0 && !session.serviceEnabled) {
      notifier.toggleService();
    }

    Navigator.of(context).pop();

    NeoToast.show(
      context,
      '${newMenuItems.length} menu dari struk berhasil masuk ke Split Arena! ⚡',
      type: NeoToastType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppColors.neoLime,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.document_scanner_rounded, size: 20, color: AppColors.neoDark),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('Scan / Impor Struk ⚡', style: AppTypography.screenTitle.copyWith(fontSize: 16)),
                ],
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
                    child: Icon(Icons.close_rounded, size: 16, color: AppColors.neoDark),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Action Mode Switchers (Camera / Gallery / Text Paste)
          Row(
            children: [
              Expanded(
                child: _buildActionPill(
                  icon: Icons.camera_alt_rounded,
                  label: 'Kamera',
                  onTap: () => _pickImage(ImageSource.camera),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionPill(
                  icon: Icons.photo_library_rounded,
                  label: 'Galeri',
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionPill(
                  icon: Icons.text_snippet_rounded,
                  label: 'Teks Struk',
                  isSelected: _isPasteMode,
                  onTap: () => setState(() => _isPasteMode = !_isPasteMode),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Loading Indicator
          if (_isLoading)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const CircularProgressIndicator(color: AppColors.neoDark, strokeWidth: 3),
                  const SizedBox(height: 12),
                  Text(_loadingMessage, style: AppTypography.bodyMuted.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            )
          // Paste Text Input Mode
          else if (_isPasteMode) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.neoBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tempel rincian pesanan dari GoFood / GrabFood / Kasir:',
                    style: AppTypography.captionBold.copyWith(fontSize: 11),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _pasteController,
                    maxLines: 4,
                    style: GoogleFonts.jetBrainsMono(fontSize: 11, color: AppColors.neoDark),
                    decoration: InputDecoration(
                      hintText: 'Contoh:\n2x Nasi Goreng Spesial 70.000\n1x Es Teh Manis 8.000',
                      hintStyle: GoogleFonts.jetBrainsMono(fontSize: 11, color: AppColors.neoMuted),
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neoDark,
                        foregroundColor: AppColors.neoLime,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      onPressed: _processPastedText,
                      icon: const Icon(Icons.auto_awesome_rounded, size: 14),
                      label: const Text('Ekstrak Menu', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Parsed Items Section with Quick Edit & Add
          if (_parsedItems.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hasil Scan (${_parsedItems.length} Menu)',
                  style: AppTypography.cardTitle.copyWith(fontSize: 13),
                ),
                InkWell(
                  onTap: _showAddItemDialog,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.neoBg,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.neoDark.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_rounded, size: 12, color: AppColors.neoDark),
                        const SizedBox(width: 4),
                        Text(
                          'Tambah Menu',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.neoDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Detected Tax & Service Badge
            if ((_detectedTax != null && _detectedTax! > 0) || (_detectedService != null && _detectedService! > 0)) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.neoLime.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.neoDark.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long_rounded, size: 13, color: AppColors.neoDark),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${[
                          if (_detectedTax != null && _detectedTax! > 0)
                            'Pajak: ${CurrencyFormatter.formatRp(_detectedTax!)}',
                          if (_detectedService != null && _detectedService! > 0)
                            'Service: ${CurrencyFormatter.formatRp(_detectedService!)}',
                        ].join(' • ')} (otomatis diaktifkan)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.neoDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 8),

            // Parsed Items List
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _parsedItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final item = _parsedItems[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.neoBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Text(item.emoji, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),

                        // Item name & price (tappable to edit)
                        Expanded(
                          child: InkWell(
                            onTap: () => _showEditItemDialog(index),
                            borderRadius: BorderRadius.circular(8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              item.name,
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.neoDark,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(Icons.edit_rounded, size: 11, color: AppColors.neoMuted),
                                        ],
                                      ),
                                      Text(
                                        '${CurrencyFormatter.formatRp(item.totalPrice)} (${CurrencyFormatter.formatShortRp(item.unitPrice)}/porsi)',
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.neoMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Stepper for Quantity
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: AppColors.neoDark.withValues(alpha: 0.12)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () {
                                  if (item.quantity > 1) {
                                    setState(() {
                                      _parsedItems[index] = item.copyWith(quantity: item.quantity - 1);
                                    });
                                  } else {
                                    setState(() => _parsedItems.removeAt(index));
                                  }
                                },
                                borderRadius: BorderRadius.circular(999),
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    item.quantity > 1 ? Icons.remove_rounded : Icons.delete_outline_rounded,
                                    size: 13,
                                    color: item.quantity > 1 ? AppColors.neoDark : Colors.redAccent,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                child: Text(
                                  '${item.quantity}',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.neoDark,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _parsedItems[index] = item.copyWith(quantity: item.quantity + 1);
                                  });
                                },
                                borderRadius: BorderRadius.circular(999),
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.add_rounded, size: 13, color: AppColors.neoDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            NeoPillButton(
              label: 'Impor ${_parsedItems.length} Menu ke Split Arena 🚀',
              variant: NeoPillVariant.dark,
              onPressed: _importToArena,
            ),
          ] else if (!_isLoading && !_isPasteMode) ...[
            Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.neoBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(Icons.receipt_long_rounded, size: 36, color: AppColors.neoMuted),
                  const SizedBox(height: 8),
                  Text(
                    'Pilih foto struk dari galeri atau kamera',
                    style: AppTypography.cardTitle.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Item makanan, jumlah pesanan (qty), dan harga akan otomatis terdeteksi tanpa perlu ngetik manual.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMuted.copyWith(fontSize: 11, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionPill({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return Material(
      color: isSelected ? AppColors.neoDark : AppColors.neoBg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? AppColors.neoLime : AppColors.neoDark,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : AppColors.neoDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
