import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum NeoPillVariant {
  dark,
  lime,
  soft,
}

class NeoPillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final NeoPillVariant variant;
  final bool isFullWidth;
  final EdgeInsetsGeometry padding;

  const NeoPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = NeoPillVariant.dark,
    this.isFullWidth = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textColor;

    switch (variant) {
      case NeoPillVariant.dark:
        bg = AppColors.neoDark;
        textColor = Colors.white;
        break;
      case NeoPillVariant.lime:
        bg = AppColors.neoLime;
        textColor = AppColors.neoDark;
        break;
      case NeoPillVariant.soft:
        bg = AppColors.neoSoft;
        textColor = AppColors.neoDark;
        break;
    }

    final content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          icon!,
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: AppTypography.buttonText.copyWith(color: textColor),
        ),
      ],
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: padding,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
          ),
          child: content,
        ),
      ),
    );
  }
}
