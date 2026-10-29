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
  }

  int get _totalAssignedPortions {
    return _portions.values.fold<int>(0, (sum, val) => sum + val);
  }

  bool get _isAllEqualPortions {
    if (_portions.isEmpty) return false;
    final first = _portions.values.first;
    return _portions.values.every((val) => val == first);
  }

  void _toggleFriend(String friendId) {
    setState(() {
      if (_portions.containsKey(friendId)) {
        _portions.remove(friendId);
      } else {
        _portions[friendId] = 1;
      }
    });
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

  void _toggleSelectAll() {
    setState(() {
      if (_portions.length == widget.allFriends.length) {
        _portions.clear();
      } else {
        for (final friend in widget.allFriends) {
          _portions[friend.id] = _portions[friend.id] ?? 1;
        }
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
    final participantCount = _portions.length;
    final isExactQtyMatch = totalPortions == widget.item.quantity;

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
          // Header Bar
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.neoLime,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.neoDark, width: 1.2),
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

          const SizedBox(height: 14),

          // Real-time Summary Card (Clean & Friction-free)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: participantCount > 0 ? AppColors.neoBg : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: participantCount > 0
                    ? AppColors.neoDark.withValues(alpha: 0.15)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  participantCount == 0
                      ? Icons.group_off_rounded
                      : (_isAllEqualPortions
                          ? Icons.balance_rounded
                          : Icons.pie_chart_outline_rounded),
                  size: 18,
                  color: participantCount > 0 ? AppColors.neoDark : AppColors.neoMuted,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    participantCount == 0
                        ? 'Pilih teman yang ikut patungan menu ini'
                        : (_isAllEqualPortions
                            ? 'Bagi rata ke $participantCount orang — ${CurrencyFormatter.formatRp((widget.item.totalPrice / participantCount).round())}/orang'
                            : 'Total $totalPortions porsi terbagi — dihitung proporsional'),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: participantCount > 0 ? AppColors.neoDark : AppColors.neoMuted,
                    ),
                  ),
                ),
                if (isExactQtyMatch && participantCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.neoLime,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.neoDark, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_rounded, size: 11, color: AppColors.neoDark),
                        const SizedBox(width: 2),
                        Text(
                          'Pas Qty',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppColors.neoDark,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Quick Action Presets (Bagi Rata 1:1, Pilih Semua)
          Row(
            children: [
              InkWell(
                onTap: _portions.isNotEmpty ? _resetEqualPortions : null,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _portions.isNotEmpty ? AppColors.neoBg : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.balance_rounded,
                        size: 12,
                        color: _portions.isNotEmpty ? AppColors.neoDark : Colors.grey.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Bagi Rata (1:1)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: _portions.isNotEmpty ? AppColors.neoDark : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _toggleSelectAll,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.neoBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _portions.length == widget.allFriends.length
                            ? Icons.deselect_rounded
                            : Icons.select_all_rounded,
                        size: 12,
                        color: AppColors.neoDark,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _portions.length == widget.allFriends.length ? 'Hapus Semua' : 'Pilih Semua',
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

          const SizedBox(height: 12),
          Text('Daftar Teman:', style: AppTypography.captionBold),
          const SizedBox(height: 8),

          // Friends List with Tap-to-toggle & Inline Stepper
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.allFriends.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final friend = widget.allFriends[index];
                final isAssigned = _portions.containsKey(friend.id);
                final portion = _portions[friend.id] ?? 0;
                final friendCost = totalPortions > 0 && isAssigned
                    ? (widget.item.totalPrice * (portion / totalPortions)).round()
                    : 0;

                return InkWell(
                  onTap: () {
                    // Tap row toggles participation
                    if (!isAssigned) {
                      _incrementPortion(friend.id);
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isAssigned ? Colors.white : AppColors.neoBg.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isAssigned ? AppColors.neoDark : Colors.transparent,
                        width: isAssigned ? 1.4 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Checkbox indicator
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _toggleFriend(friend.id),
                          child: Container(
                            width: 24,
                            height: 24,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: isAssigned ? AppColors.neoDark : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isAssigned ? AppColors.neoDark : Colors.grey.shade400,
                                width: 1.5,
                              ),
                            ),
                            child: isAssigned
                                ? const Center(
                                    child: Icon(Icons.check_rounded, size: 14, color: AppColors.neoLime),
                                  )
                                : null,
                          ),
                        ),

                        // Avatar
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isAssigned ? AppColors.neoLime : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isAssigned ? AppColors.neoDark : Colors.grey.shade300,
                              width: 1,
                            ),
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
                                  color: isAssigned ? AppColors.neoDark : Colors.grey.shade600,
                                ),
                              ),
                              if (isAssigned && totalPortions > 0)
                                Text(
                                  CurrencyFormatter.formatRp(friendCost),
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.neoDark,
                                  ),
                                )
                              else
                                Text(
                                  'Tap untuk ikut',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.neoMuted,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Stepper or Tap button
                        if (isAssigned)
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.neoBg,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppColors.neoDark.withValues(alpha: 0.15)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => _decrementPortion(friend.id),
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    alignment: Alignment.center,
                                    child: Icon(
                                      portion > 1 ? Icons.remove_rounded : Icons.delete_outline_rounded,
                                      size: 15,
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
                                    width: 30,
                                    height: 30,
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.add_rounded,
                                      size: 15,
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
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                                    'Ikut',
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
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

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
