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

  /// Shows a clean, modern minimalist card notification (Linear / Vercel style).
  ///
  /// - Crisp white card with subtle grey border and dual-layer soft elevation.
  /// - High-contrast semantic indicator on the left.
  /// - Structured hierarchy: bold headline (if [title] is provided) + concise body.
  /// - Snappy, non-distracting slide-down animation with dismiss button.
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
        : const Duration(milliseconds: 2200);

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
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  Timer? _timer;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    // Snappy 200ms motion like Linear/Vercel
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.40),
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

  /// High-contrast, accessible semantic colors on white background
  Color get _accentColor {
    switch (widget.type) {
      case NeoToastType.success:
        return const Color(0xFF16A34A); // Emerald Green
      case NeoToastType.warning:
        return const Color(0xFFD97706); // Warm Amber
      case NeoToastType.error:
        return const Color(0xFFDC2626); // Clean Red
      case NeoToastType.info:
        return const Color(0xFF2563EB); // Royal Blue
    }
  }

  IconData get _iconData {
    if (widget.customIcon != null) return widget.customIcon!;
    switch (widget.type) {
      case NeoToastType.success:
        return Icons.check_rounded;
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
      top: topPadding + 12,
      left: 16,
      right: 16,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: SlideTransition(
            position: _slideAnimation,
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
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white, // Clean White Card (Option B2)
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE4E7EC), // Refined neutral grey border
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        spreadRadius: 0,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 3,
                        spreadRadius: 0,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: isExpanded ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                    children: [
                      // Status Icon Badge
                      Container(
                        width: 22,
                        height: 22,
                        margin: EdgeInsets.only(top: isExpanded ? 1.5 : 0),
                        decoration: BoxDecoration(
                          color: _accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Icon(
                            _iconData,
                            size: 13.5,
                            color: _accentColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Text Content (Title & Message)
                      Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.title != null) ...[
                              Text(
                                widget.title!,
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppColors.neoDark,
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
                                color: widget.title != null
                                    ? const Color(0xFF64748B) // Subtle slate for body
                                    : AppColors.neoDark, // Crisp dark for single line
                                fontSize: 12,
                                fontWeight: widget.title != null ? FontWeight.w500 : FontWeight.w700,
                                letterSpacing: -0.1,
                                height: 1.3,
                              ),
                              maxLines: isExpanded ? 3 : 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 10),

                      // Subtle Dismiss Button (✕)
                      InkWell(
                        onTap: _dismiss,
                        borderRadius: BorderRadius.circular(4),
                        child: const Padding(
                          padding: EdgeInsets.all(2),
                          child: Icon(
                            Icons.close_rounded,
                            size: 14,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
