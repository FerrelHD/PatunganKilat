import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../features/bill_engine/models/split_breakdown.dart';
import '../../features/bill_engine/providers/bill_session_provider.dart';
import 'currency_formatter.dart';

class ReceiptShareUtil {
  ReceiptShareUtil._();

  /// Formats clean monospace and bold summary for WhatsApp chat
  static String formatWhatsAppSummary({
    required BillSessionState session,
    required SplitCalculationResult calc,
    String bankName = 'BCA',
    String accountNumber = '682044918821',
    String accountHolder = 'Raka Pratama',
  }) {
    final buffer = StringBuffer();
    buffer.writeln('*🧾 PATUNGANKILAT — ${session.sessionTitle.toUpperCase()}*');
    final payerName = session.friends.isNotEmpty
        ? session.friends.firstWhere((f) => f.isPayer, orElse: () => session.friends.first).name
        : accountHolder;
    buffer.writeln('Talangan: $payerName');
    buffer.writeln('--------------------------------');

    for (final person in calc.breakdowns) {
      final percent = (person.proportion * 100).round();
      final finalStr = CurrencyFormatter.formatRp(person.finalAmount);
      buffer.writeln('• *${person.friend.name}*: *$finalStr* ($percent%)');
      if (person.items.isNotEmpty) {
        final itemDetails = person.items
            .map((i) => i.isShared ? '${i.itemName} (1/${i.sharedCount})' : i.itemName)
            .join(', ');
        buffer.writeln('   _${itemDetails}_');
      }
    }

    buffer.writeln('--------------------------------');
    buffer.writeln('Total Tagihan: *${CurrencyFormatter.formatRp(calc.grandTotal)}*');
    buffer.writeln('Transfer $bankName: *$accountNumber* a.n $accountHolder');
    buffer.writeln('\n_Dihitung otomatis via PatunganKilat ⚡_');

    return buffer.toString();
  }

  /// Captures a RepaintBoundary widget as high-res PNG image and shares via share_plus
  static Future<void> captureAndShareReceipt({
    required GlobalKey repaintBoundaryKey,
    required String sessionTitle,
  }) async {
    try {
      final boundary = repaintBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final fileName = 'PatunganKilat_${sessionTitle.replaceAll(' ', '_')}_Struk.png';
      final file = await File('${tempDir.path}/$fileName').create();
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Struk Patungan Kilat — $sessionTitle 🧾⚡',
      );
    } catch (e) {
      debugPrint('Error sharing receipt image: $e');
    }
  }
}
