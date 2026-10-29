import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ExtractedReceiptItem {
  final String name;
  final int quantity;
  final int unitPrice;
  final String emoji;

  const ExtractedReceiptItem({
    required this.name,
    this.quantity = 1,
    required this.unitPrice,
    this.emoji = '🍽️',
  });

  int get totalPrice => unitPrice * quantity;

  ExtractedReceiptItem copyWith({
    String? name,
    int? quantity,
    int? unitPrice,
    String? emoji,
  }) {
    return ExtractedReceiptItem(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      emoji: emoji ?? this.emoji,
    );
  }
}

class ExtractedReceiptResult {
  final List<ExtractedReceiptItem> items;
  final int? subtotal;
  final int? taxAmount;
  final int? serviceAmount;
  final int? discountAmount;
  final int? grandTotal;
  final String rawText;

  const ExtractedReceiptResult({
    required this.items,
    this.subtotal,
    this.taxAmount,
    this.serviceAmount,
    this.discountAmount,
    this.grandTotal,
    this.rawText = '',
  });
}

class ReceiptOcrService {
  ReceiptOcrService._();

  // Public default free OCR.space key
  static const String _defaultOcrKey = 'K88796839388957';

  static String detectEmoji(String foodName) {
    final lower = foodName.toLowerCase();
    if (lower.contains('ayam') || lower.contains('chicken') || lower.contains('bebek') || lower.contains('chick')) {
      return '🍗';
    }
    if (lower.contains('ramen') || lower.contains('mie') || lower.contains('noodle') || lower.contains('bakmi') || lower.contains('bihun') || lower.contains('kwetiau')) {
      return '🍜';
    }
    if (lower.contains('teh') || lower.contains('tea') || lower.contains('ocha') || lower.contains('kopi') || lower.contains('coffee') || lower.contains('latte') || lower.contains('jus') || lower.contains('juice') || lower.contains('drink') || lower.contains('air')) {
      return '🍵';
    }
    if (lower.contains('nasi') || lower.contains('rice')) {
      return '🍚';
    }
    if (lower.contains('burger')) {
      return '🍔';
    }
    if (lower.contains('pizza')) {
      return '🍕';
    }
    if (lower.contains('dimsum') || lower.contains('siomay') || lower.contains('gyoza') || lower.contains('pangsit')) {
      return '🥟';
    }
    if (lower.contains('es') || lower.contains('ice') || lower.contains('dessert') || lower.contains('cake')) {
      return '🍨';
    }
    if (lower.contains('daging') || lower.contains('beef') || lower.contains('steak')) {
      return '🥩';
    }
    if (lower.contains('sate') || lower.contains('satay')) {
      return '🍢';
    }
    return '🍽️';
  }

  /// Sends image bytes to OCR Space API and extracts text
  static Future<ExtractedReceiptResult> extractFromImageBytes(
    Uint8List bytes, {
    String? customApiKey,
  }) async {
    final apiKey = (customApiKey != null && customApiKey.trim().isNotEmpty)
        ? customApiKey.trim()
        : _defaultOcrKey;

    final uri = Uri.parse('https://api.ocr.space/parse/image');
    final request = http.MultipartRequest('POST', uri)
      ..fields['apikey'] = apiKey
      ..fields['language'] = 'eng'
      ..fields['isOverlayRequired'] = 'false'
      ..fields['detectOrientation'] = 'true'
      ..fields['scale'] = 'true'
      ..files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: 'receipt.jpg'),
      );

    final streamedResponse = await request.send().timeout(const Duration(seconds: 20));
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('OCR service returned status ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['IsErroredOnProcessing'] == true) {
      final err = data['ErrorMessage'] ?? 'OCR processing failed';
      throw Exception(err.toString());
    }

    final parsedResults = data['ParsedResults'] as List<dynamic>?;
    if (parsedResults == null || parsedResults.isEmpty) {
      throw Exception('Tidak ada teks struk yang terdeteksi');
    }

    final parsedText = (parsedResults[0]['ParsedText'] as String?) ?? '';
    return parseReceiptText(parsedText);
  }

  /// Parses raw receipt string into structured items, taxes, and totals
  static ExtractedReceiptResult parseReceiptText(String text) {
    final lines = text.split(RegExp(r'\r?\n'));
    final items = <ExtractedReceiptItem>[];

    int? subtotal;
    int? taxAmount;
    int? serviceAmount;
    int? discountAmount;
    int? grandTotal;

    // Regex patterns for metadata lines
    final subtotalReg = RegExp(r'(subtotal|total\s+harga|total\s+belanja)\s*[:=]?\s*(?:rp\.?)?\s*([0-9.,]+)', caseSensitive: false);
    final taxReg = RegExp(r'(pb1|pajak|tax|ppn)\s*(?:\([^)]*\))?\s*[:=]?\s*(?:rp\.?)?\s*([0-9.,]+)', caseSensitive: false);
    final serviceReg = RegExp(r'(service|layanan|charge)\s*(?:\([^)]*\))?\s*[:=]?\s*(?:rp\.?)?\s*([0-9.,]+)', caseSensitive: false);
    final discountReg = RegExp(r'(diskon|discount|promo|voucher|potongan)\s*[:=]?\s*(?:rp\.?)?\s*-?\s*([0-9.,]+)', caseSensitive: false);
    final grandTotalReg = RegExp(r'(grand\s*total|total\s*bayar|total\s*tagihan|total\s*akhir|total)\s*[:=]?\s*(?:rp\.?)?\s*([0-9.,]+)', caseSensitive: false);

    // Filter ignore lines
    final ignoreReg = RegExp(
      r'^(tanggal|waktu|jam|kasir|meja|table|order|struk|nota|kembali|change|tunai|cash|debit|qris|kartu|card|terima\s+kasih|thank\s+you|resto|welcome|resto|jl\.|jalan|telp|tel:|-+|=+)',
      caseSensitive: false,
    );

    for (var rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      // Check metadata lines first
      final taxMatch = taxReg.firstMatch(line);
      if (taxMatch != null) {
        taxAmount = _cleanNumber(taxMatch.group(2) ?? '');
        continue;
      }

      final serviceMatch = serviceReg.firstMatch(line);
      if (serviceMatch != null) {
        serviceAmount = _cleanNumber(serviceMatch.group(2) ?? '');
        continue;
      }

      final discMatch = discountReg.firstMatch(line);
      if (discMatch != null) {
        discountAmount = _cleanNumber(discMatch.group(2) ?? '');
        continue;
      }

      final subMatch = subtotalReg.firstMatch(line);
      if (subMatch != null) {
        subtotal = _cleanNumber(subMatch.group(2) ?? '');
        continue;
      }

      final grandMatch = grandTotalReg.firstMatch(line);
      if (grandMatch != null && subtotal != null) {
        grandTotal = _cleanNumber(grandMatch.group(2) ?? '');
        continue;
      }

      if (ignoreReg.hasMatch(line)) continue;

      // Try parsing food line
      final parsedItem = _parseItemLine(line);
      if (parsedItem != null) {
        items.add(parsedItem);
      }
    }

    return ExtractedReceiptResult(
      items: items,
      subtotal: subtotal,
      taxAmount: taxAmount,
      serviceAmount: serviceAmount,
      discountAmount: discountAmount,
      grandTotal: grandTotal,
      rawText: text,
    );
  }

  static ExtractedReceiptItem? _parseItemLine(String line) {
    // Clean unwanted characters
    final cleaned = line.replaceAll(RegExp(r'[\r\t]'), ' ').trim();

    // Pattern A: Suffix multiplier format: "Kopi Susu @ Rp 18.000 x 2 = Rp 36.000" or "... x 2 = 36000"
    final patternSuffix = RegExp(
      r'^(.*?)(?:@\s*(?:rp\.?)?\s*([0-9.,]+))?\s*(?:x\s*|\*|\()?\s*([0-9]+)\s*(?:x|\))?\s*=?\s*(?:rp\.?)?\s*([0-9.,]+)$',
      caseSensitive: false,
    );

    final matchSuffix = patternSuffix.firstMatch(cleaned);
    if (matchSuffix != null) {
      final rawName = matchSuffix.group(1)?.trim() ?? '';
      final unitPriceStr = matchSuffix.group(2);
      final qtyStr = matchSuffix.group(3);
      final totalStr = matchSuffix.group(4);

      final qty = int.tryParse(qtyStr ?? '') ?? 1;
      final total = _cleanNumber(totalStr ?? '');
      final unit = (unitPriceStr != null && unitPriceStr.isNotEmpty)
          ? _cleanNumber(unitPriceStr)
          : (qty > 0 && total != null ? (total / qty).round() : total ?? 0);

      if (_isValidItemName(rawName) && unit > 0) {
        return ExtractedReceiptItem(
          name: _formatName(rawName),
          quantity: qty > 0 ? qty : 1,
          unitPrice: unit,
          emoji: detectEmoji(rawName),
        );
      }
    }

    // Pattern B: Prefix multiplier format: "2x Mie Gacoan 24.000" or "2 x Mie Gacoan Rp 24.000"
    final patternPrefix = RegExp(
      r'^(?:([0-9]+)\s*(?:x|\*)\s+)?(.*?)\s+(?:rp\.?)?\s*([0-9.,]{4,})$',
      caseSensitive: false,
    );

    final matchPrefix = patternPrefix.firstMatch(cleaned);
    if (matchPrefix != null) {
      final qtyStr = matchPrefix.group(1);
      final rawName = matchPrefix.group(2)?.trim() ?? '';
      final priceStr = matchPrefix.group(3);

      final qty = int.tryParse(qtyStr ?? '') ?? 1;
      final rawPrice = _cleanNumber(priceStr ?? '') ?? 0;

      // In prefix receipts (e.g. 2x Mie Gacoan 24.000), 24.000 is typically the line total.
      // So unit price is line total / qty.
      final unitPrice = (qty > 1 && rawPrice > 0) ? (rawPrice / qty).round() : rawPrice;

      if (_isValidItemName(rawName) && unitPrice > 0) {
        return ExtractedReceiptItem(
          name: _formatName(rawName),
          quantity: qty > 0 ? qty : 1,
          unitPrice: unitPrice,
          emoji: detectEmoji(rawName),
        );
      }
    }

    return null;
  }

  static bool _isValidItemName(String name) {
    final trimmed = name.replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '').trim();
    if (trimmed.length < 2) return false;
    final lower = trimmed.toLowerCase();
    if (lower == 'total' || lower == 'subtotal' || lower == 'tunai' || lower == 'change') {
      return false;
    }
    return true;
  }

  static String _formatName(String name) {
    return name
        .replaceAll(RegExp(r'^[0-9\s\.\-\*xX]+'), '')
        .replaceAll(RegExp(r'[@:=\-_]+$'), '')
        .trim();
  }

  static int? _cleanNumber(String str) {
    final digits = str.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits);
  }
}
