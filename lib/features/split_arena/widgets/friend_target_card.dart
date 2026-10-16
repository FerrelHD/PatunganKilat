import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../bill_engine/models/friend.dart';
import '../../bill_engine/models/menu_item.dart';

class FriendTargetCard extends StatelessWidget {
  final Friend friend;
  final int totalAmount;
  final bool isSelected;
  final VoidCallback onTap;
  final void Function(MenuItem item) onDropItem;

  const FriendTargetCard({
    super.key,
    required this.friend,
    required this.totalAmount,
    required this.isSelected,
    required this.onTap,
    required this.onDropItem,
  });

  @override
  Widget build(BuildContext context) {
    Color cardBg = Colors.white;
    Color textColor = AppColors.neoDark;
    Color avatarBg = AppColors.neoDark;
    Color avatarText = Colors.white;

    if (friend.theme == 'lime') {
      cardBg = AppColors.neoLime;
      textColor = AppColors.neoDark;
      avatarBg = AppColors.neoDark;
      avatarText = AppColors.neoLime;
    } else if (friend.theme == 'dark') {
      cardBg = AppColors.neoDark;
      textColor = Colors.white;
      avatarBg = AppColors.neoLime;
      avatarText = AppColors.neoDark;
    }

    return DragTarget<MenuItem>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) => onDropItem(details.data),
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;

        return AnimatedScale(
          scale: isHovered ? 1.06 : (isSelected ? 1.03 : 1.0),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 84,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.neoDark : Colors.black.withValues(alpha: 0.08),
                  width: isSelected ? 2.0 : 1.0,
                ),
                boxShadow: isSelected ? AppColors.softShadow : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: avatarBg,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            friend.avatarInitial,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: avatarText,
                            ),
                          ),
                        ),
                      ),
                      if (isSelected)
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.neoDark,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        friend.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        CurrencyFormatter.formatShortRp(totalAmount),
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: friend.theme == 'dark' ? AppColors.neoLime : textColor.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
