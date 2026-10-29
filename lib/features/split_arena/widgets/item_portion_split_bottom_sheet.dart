import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/neo_pill_button.dart';
import '../../bill_engine/models/friend.dart';
import '../../bill_engine/models/menu_item.dart';

class ItemPortionSplitBottomSheet extends StatefulWidget {
  final MenuItem item;
  final List<Friend> allFriends;
  final void Function(Map<String, int> updatedPortions) onSave;

  const ItemPortionSplitBottomSheet({
    super.key,
    required this.item,
    required this.allFriends,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    required MenuItem item,
    required List<Friend> allFriends,
    required void Function(Map<String, int> updatedPortions) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ItemPortionSplitBottomSheet(
        item: item,
        allFriends: allFriends,
        onSave: onSave,
      ),
    );
  }

  @override
  State<ItemPortionSplitBottomSheet> createState() => _ItemPortionSplitBottomSheetState();
}

class _ItemPortionSplitBottomSheetState extends State<ItemPortionSplitBottomSheet> {
  late Map<String, int> _portions;

  @override
  void initState() {
    super.initState();
    _portions = <String, int>{};
    for (final friendId in widget.item.assignedTo) {
      _portions[friendId] = widget.item.getPortionFor(friendId);
    }
    // If empty but there are friends, keep empty or let user pick
  }

  int get _totalAssignedPortions {
    return _portions.values.fold<int>(0, (sum, val) => sum + val);
  }

  void _incrementPortion(String friendId) {
    setState(() {
      final current = _portions[friendId] ?? 0;
      _portions[friendId] = current + 1;
    });
  }

  void _decrementPortion(String friendId) {
    setState(() {
      final current = _portions[friendId] ?? 0;
      if (current > 1) {
        _portions[friendId] = current - 1;
      } else {
        _portions.remove(friendId);
      }
    });
  }

  void _resetEqualPortions() {
    setState(() {
      for (final key in _portions.keys.toList()) {
        _portions[key] = 1;
      }
    });
  }

  void _distributeByQuantity() {
    final friendIds = _portions.keys.toList();
    if (friendIds.isEmpty) return;

    final totalQty = widget.item.quantity;
    final basePortion = totalQty ~/ friendIds.length;
    var remainder = totalQty % friendIds.length;

    setState(() {
      for (var i = 0; i < friendIds.length; i++) {
        final fId = friendIds[i];
        final extra = (remainder > 0) ? 1 : 0;
        if (remainder > 0) remainder--;
        _portions[fId] = max(1, basePortion + extra);
      }
    });
  }

  void _save() {
    widget.onSave(_portions);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final totalPortions = _totalAssignedPortions;
    final isExactMatch = totalPortions == widget.item.quantity;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.neoLime,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    widget.item.emoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.name,
                      style: AppTypography.screenTitle.copyWith(fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${CurrencyFormatter.formatRp(widget.item.price)} × ${widget.item.quantity} = ${CurrencyFormatter.formatRp(widget.item.totalPrice)}',
                      style: AppTypography.monoPrice.copyWith(
                        fontSize: 11,
                        color: AppColors.neoMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
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

          // Portion Status Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isExactMatch ? AppColors.neoLime.withValues(alpha: 0.3) : AppColors.neoBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isExactMatch ? AppColors.neoDark : Colors.transparent,
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isExactMatch ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                  size: 16,
                  color: AppColors.neoDark,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isExactMatch
                        ? 'Total $totalPortions porsi terbagi (Pas dengan pesanan)'
                        : '$totalPortions porsi terbagi dari ${widget.item.quantity} pesanan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.neoDark,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Quick Action Presets
          Row(
            children: [
              InkWell(
                onTap: _resetEqualPortions,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.neoBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.balance_rounded, size: 12, color: AppColors.neoDark),
                      const SizedBox(width: 4),
                      Text(
                        'Bagi Rata (1:1)',
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
              if (widget.item.quantity > 1) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: _distributeByQuantity,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.neoBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_fix_high_rounded, size: 12, color: AppColors.neoDark),
                        const SizedBox(width: 4),
                        Text(
                          'Bagi Sesuai Qty (${widget.item.quantity}x)',
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
            ],
          ),

          const SizedBox(height: 14),
          Text('Porsi Teman yang Ikut:', style: AppTypography.captionBold),
          const SizedBox(height: 8),

          // Friends List with Stepper
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.allFriends.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final friend = widget.allFriends[index];
                final isAssigned = _portions.containsKey(friend.id);
                final portion = _portions[friend.id] ?? 0;
                final friendCost = totalPortions > 0
                    ? (widget.item.totalPrice * (portion / totalPortions)).round()
                    : 0;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isAssigned ? Colors.white : AppColors.neoBg.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isAssigned ? AppColors.neoDark.withValues(alpha: 0.15) : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isAssigned ? AppColors.neoLime : AppColors.neoBg,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            friend.avatarInitial,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppColors.neoDark,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Friend Name & Cost
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              friend.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.neoDark,
                              ),
                            ),
                            if (isAssigned && totalPortions > 0)
                              Text(
                                '${CurrencyFormatter.formatRp(friendCost)} (${portion}/$totalPortions porsi)',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.neoMuted,
                                ),
                              )
                            else
                              Text(
                                'Tidak ikut menu ini',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.neoMuted,
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Stepper / Add button
                      if (isAssigned)
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.neoBg,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => _decrementPortion(friend.id),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    portion > 1 ? Icons.remove_rounded : Icons.delete_outline_rounded,
                                    size: 14,
                                    color: portion > 1 ? AppColors.neoDark : Colors.redAccent,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: Text(
                                  '$portion',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.neoDark,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => _incrementPortion(friend.id),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.add_rounded,
                                    size: 14,
                                    color: AppColors.neoDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        InkWell(
                          onTap: () => _incrementPortion(friend.id),
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.neoDark,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.add_rounded, size: 12, color: AppColors.neoLime),
                                const SizedBox(width: 4),
                                Text(
                                  'Tambah',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.neoLime,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 18),

          // Save Button
          NeoPillButton(
            label: 'Simpan Pembagian Porsi ⚡',
            variant: NeoPillVariant.dark,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
