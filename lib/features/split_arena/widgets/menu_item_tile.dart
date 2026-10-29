import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../bill_engine/models/friend.dart';
import '../../bill_engine/models/menu_item.dart';

class MenuItemTile extends StatelessWidget {
  final MenuItem item;
  final String activeFriendId;
  final List<Friend> allFriends;
  final VoidCallback onToggleAssign;
  final void Function(int delta)? onUpdateQuantity;
  final VoidCallback? onDelete;

  const MenuItemTile({
    super.key,
    required this.item,
    required this.activeFriendId,
    required this.allFriends,
    required this.onToggleAssign,
    this.onUpdateQuantity,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isAssignedToActive = item.isAssignedTo(activeFriendId);

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isAssignedToActive ? Colors.white : Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAssignedToActive ? AppColors.neoDark : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: isAssignedToActive ? AppColors.softShadow : null,
      ),
      child: Row(
        children: [
          // Left: Emoji Box
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isAssignedToActive ? AppColors.neoLime : AppColors.neoBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                item.emoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Center: Name, Price, and Assigned Badges
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: AppTypography.menuName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (onDelete != null)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onDelete,
                        child: const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(Icons.close_rounded, size: 14, color: AppColors.neoMuted),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      CurrencyFormatter.formatRp(item.totalPrice),
                      style: AppTypography.monoPrice.copyWith(
                        color: AppColors.neoDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    if (item.quantity > 1) ...[
                      const SizedBox(width: 4),
                      Text(
                        '(${CurrencyFormatter.formatShortRp(item.price)} × ${item.quantity})',
                        style: AppTypography.monoPrice.copyWith(
                          color: AppColors.neoMuted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: item.assignedTo.isEmpty
                      ? [
                          Text(
                            'Belum di-assign',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.redAccent,
                            ),
                          ),
                        ]
                      : item.assignedTo.map((friendId) {
                          final friendObj = allFriends.firstWhere(
                            (f) => f.id == friendId,
                            orElse: () => Friend(id: friendId, name: friendId),
                          );
                          final isCurrent = friendId == activeFriendId;

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: isCurrent ? AppColors.neoLime : AppColors.neoBg,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: isCurrent
                                    ? AppColors.neoDark.withValues(alpha: 0.15)
                                    : Colors.transparent,
                              ),
                            ),
                            child: Text(
                              friendObj.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.neoDark,
                              ),
                            ),
                          );
                        }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Stepper for Quantity (Berapa kali pesannya)
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
                  onTap: () {
                    if (item.quantity > 1) {
                      onUpdateQuantity?.call(-1);
                    } else if (onDelete != null) {
                      onDelete?.call();
                    }
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    child: Icon(
                      item.quantity > 1 ? Icons.remove_rounded : Icons.delete_outline_rounded,
                      size: 13,
                      color: item.quantity > 1 ? AppColors.neoDark : Colors.redAccent,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    '${item.quantity}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: AppColors.neoDark,
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onUpdateQuantity?.call(1),
                  child: Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.add_rounded,
                      size: 13,
                      color: AppColors.neoDark,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Right: Status circle check / plus
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isAssignedToActive ? AppColors.neoDark : AppColors.neoBg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                isAssignedToActive
                    ? Icons.check_rounded
                    : Icons.add_rounded,
                size: 14,
                color: isAssignedToActive ? AppColors.neoLime : AppColors.neoMuted,
              ),
            ),
          ),
        ],
      ),
    );

    return Draggable<MenuItem>(
      data: item,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 280,
          child: Opacity(
            opacity: 0.9,
            child: content,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: content,
      ),
      child: GestureDetector(
        onTap: onToggleAssign,
        child: content,
      ),
    );
  }
}
