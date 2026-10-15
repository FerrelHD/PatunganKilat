import 'package:flutter/material.dart';

/// Cuts the bottom of a container with repetitive jagged triangular teeth
/// resembling an authentic thermal cashier receipt.
class JaggedReceiptClipper extends CustomClipper<Path> {
  final double toothWidth;
  final double toothHeight;

  const JaggedReceiptClipper({
    this.toothWidth = 14.0,
    this.toothHeight = 8.0,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - toothHeight);

    final toothCount = (size.width / toothWidth).floor();
    final remainingWidth = size.width - (toothCount * toothWidth);
    final adjustedToothWidth = toothWidth + (remainingWidth / toothCount);

    var currentX = 0.0;
    for (var i = 0; i < toothCount; i++) {
      final midX = currentX + (adjustedToothWidth / 2);
      final nextX = currentX + adjustedToothWidth;
      path.lineTo(midX, size.height);
      path.lineTo(nextX, size.height - toothHeight);
      currentX = nextX;
    }

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant JaggedReceiptClipper oldClipper) {
    return oldClipper.toothWidth != toothWidth || oldClipper.toothHeight != toothHeight;
  }
}
