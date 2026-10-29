import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../features/bill_engine/models/split_breakdown.dart';
import '../../features/bill_engine/providers/bill_session_provider.dart';
import 'currency_formatter.dart';
import 'platform_file_saver.dart';

class ReceiptShareUtil {
  ReceiptShareUtil._();

  /// Formats clean monospace and bold summary for WhatsApp chat
  static String formatWhatsAppSummary({
    required BillSessionState session,
    required SplitCalculationResult calc,
    String bankName = 'BCA',
    String accountNumber = '682044918821',
    String accountHolder = 'Raka Pratama',
    String walletName = '',
    String walletNumber = '',
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
            .map((i) => i.isShared ? '${i.itemName} (${i.shareDetailLabel})' : i.itemName)
            .join(', ');
        buffer.writeln('   _${itemDetails}_');
      }
    }

    buffer.writeln('--------------------------------');
    buffer.writeln('Total Tagihan: *${CurrencyFormatter.formatRp(calc.grandTotal)}*');
    buffer.writeln('Transfer $bankName: *$accountNumber* a.n $accountHolder');
    if (walletNumber.trim().isNotEmpty) {
      final wName = walletName.trim().isNotEmpty ? walletName.trim() : 'E-Wallet';
      buffer.writeln('Atau $wName: *$walletNumber* a.n $accountHolder');
    }
    buffer.writeln('\n_Dihitung otomatis via PatunganKilat ⚡_');

    return buffer.toString();
  }

  /// Directly launches WhatsApp with pre-filled formatted summary
  static Future<bool> launchWhatsAppShare(String text) async {
    final encoded = Uri.encodeComponent(text);
    final waUri = Uri.parse('https://wa.me/?text=$encoded');
    try {
      if (await canLaunchUrl(waUri)) {
        return await launchUrl(waUri, mode: LaunchMode.externalApplication);
      } else {
        return await launchUrl(waUri);
      }
    } catch (e) {
      debugPrint('Error launching WhatsApp: $e');
      return false;
    }
  }

  /// Captures a RepaintBoundary widget as high-res PNG image and saves/shares cross-platform
  static Future<bool> captureAndSaveReceipt({
    required GlobalKey repaintBoundaryKey,
    required String sessionTitle,
  }) async {
    try {
      final boundary = repaintBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return false;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return false;

      final pngBytes = byteData.buffer.asUint8List();
      final cleanTitle = sessionTitle.replaceAll(RegExp(r'\s+'), '_');
      final fileName = 'PatunganKilat_${cleanTitle}_Struk.png';

      return await saveOrShareReceiptImage(
        bytes: pngBytes,
        fileName: fileName,
        text: 'Struk Patungan Kilat — $sessionTitle 🧾⚡',
      );
    } catch (e) {
      debugPrint('Error saving receipt image: $e');
      return false;
    }
  }
}
