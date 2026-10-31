import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

enum NeoToastType {
  success,
  warning,
  error,
  info,
}

class NeoToast {
  NeoToast._();

  static OverlayEntry? _activeEntry;

  /// Shows an adaptive Apple Dynamic Island style notification.
  ///
  /// - **Compact Mode** (brief 1-line messages without title):
  ///   Renders as a sleek, ultra-clean pill for micro-feedback (e.g. copied to clipboard).
  /// - **Expanded Mode** (when [title] is supplied or message is lengthy):
  ///   Renders as a structured squircle card with title and helpful remedy instruction.
  static void show(
    BuildContext context,
    String message, {
    String? title,
    NeoToastType type = NeoToastType.success,
    Duration? duration,
    IconData? customIcon,
  }) {
    // Dismiss any currently visible toast
    _dismissActive();

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    final isExpanded = title != null || message.length > 55;
    final defaultDuration = isExpanded
        ? const Duration(milliseconds: 3200)
        : const Duration(milliseconds: 2000);

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _NeoToastWidget(
        title: title,
        message: message,
        type: type,
        customIcon: customIcon,
        duration: duration ?? defaultDuration,
        onDismiss: () {
          if (_activeEntry == entry) {
            _activeEntry?.remove();
            _activeEntry = null;
          }
        },
      ),
    );

    _activeEntry = entry;
    overlay.insert(entry);
  }

  static void _dismissActive() {
    _activeEntry?.remove();
    _activeEntry = null;
  }
}

class _NeoToastWidget extends StatefulWidget {
  final String? title;
  final String message;
  final NeoToastType type;
  final IconData? customIcon;
  final Duration duration;
  final VoidCallback onDismiss;

  const _NeoToastWidget({
    this.title,
    required this.message,
    required this.type,
    this.customIcon,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_NeoToastWidget> createState() => _NeoToastWidgetState();
}

class _NeoToastWidgetState extends State<_NeoToastWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  Timer? _timer;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    // Spring-out dynamic island physics
    _scaleAnimation = Tween<double>(begin: 0.78, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.65),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    _controller.forward();

    _timer = Timer(widget.duration, () {
      _dismiss();
    });
  }

  Future<void> _dismiss() async {
    if (_isDismissing || !mounted) return;
    _isDismissing = true;
    _timer?.cancel();

    try {
      await _controller.reverse();
    } catch (_) {}

    if (mounted) {
      widget.onDismiss();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Color get _accentColor {
    switch (widget.type) {
      case NeoToastType.success:
        return AppColors.neoLime;
      case NeoToastType.warning:
        return const Color(0xFFFF9F0A); // Apple Amber
      case NeoToastType.error:
        return const Color(0xFFFF453A); // Apple Red
      case NeoToastType.info:
        return const Color(0xFF0A84FF); // Apple Blue
    }
  }

  IconData get _iconData {
    if (widget.customIcon != null) return widget.customIcon!;
    switch (widget.type) {
      case NeoToastType.success:
        return Icons.check_rounded; // Semantic checkmark (no generic AI lightning slop)
      case NeoToastType.warning:
        return Icons.warning_amber_rounded;
      case NeoToastType.error:
        return Icons.error_outline_rounded;
      case NeoToastType.info:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final isExpanded = widget.title != null || widget.message.length > 55;

    return Positioned(
      top: topPadding + 10,
      left: 16,
      right: 16,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              alignment: Alignment.topCenter,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: GestureDetector(
                  onTap: _dismiss,
                  onVerticalDragUpdate: (details) {
                    if (details.primaryDelta != null && details.primaryDelta! < -3) {
                      _dismiss();
                    }
                  },
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: isExpanded ? 400 : 360,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: isExpanded ? 14 : 14,
                      vertical: isExpanded ? 12 : 9,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D0E11), // Neobank Pitch Black
                      borderRadius: BorderRadius.circular(isExpanded ? 18 : 999),
                      border: Border.all(
                        color: isExpanded
                            ? _accentColor.withValues(alpha: 0.28)
                            : Colors.white.withValues(alpha: 0.12),
                        width: 0.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.42),
                          blurRadius: 22,
                          spreadRadius: 1,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isExpanded ? _buildExpandedLayout() : _buildCompactLayout(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Single-line compact pill for quick confirmations
  Widget _buildCompactLayout() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: _accentColor.withValues(alpha: 0.16),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              _iconData,
              size: 13,
              color: _accentColor,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            widget.message,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Multi-line card with bold title and subtle descriptive instructions
  Widget _buildExpandedLayout() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          margin: const EdgeInsets.only(top: 1),
          decoration: BoxDecoration(
            color: _accentColor.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(
              _iconData,
              size: 16,
              color: _accentColor,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.title != null) ...[
                Text(
                  widget.title!,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
              ],
              Text(
                widget.message,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
