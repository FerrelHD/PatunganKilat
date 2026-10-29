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

  /// Shows a clean Apple Dynamic Island style top-floating toast notification
  static void show(
    BuildContext context,
    String message, {
    NeoToastType type = NeoToastType.success,
    Duration duration = const Duration(milliseconds: 2200),
  }) {
    // Dismiss any currently visible toast
    _dismissActive();

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _NeoToastWidget(
        message: message,
        type: type,
        duration: duration,
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
  final String message;
  final NeoToastType type;
  final Duration duration;
  final VoidCallback onDismiss;

  const _NeoToastWidget({
    required this.message,
    required this.type,
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

    // Dynamic Island spring-out physics
    _scaleAnimation = Tween<double>(begin: 0.72, end: 1.0).animate(
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
    switch (widget.type) {
      case NeoToastType.success:
        return Icons.bolt_rounded;
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
                    constraints: const BoxConstraints(maxWidth: 420),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF000000), // Pure Dynamic Island pitch black
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                        width: 0.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.40),
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _accentColor.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              _iconData,
                              size: 14,
                              color: _accentColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            widget.message,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}
