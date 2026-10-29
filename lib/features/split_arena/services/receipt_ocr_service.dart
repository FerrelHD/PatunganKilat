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
    if (lower.contains('ayam') ||
        lower.contains('chicken') ||
        lower.contains('bebek') ||
        lower.contains('chick')) {
      return '🍗';
    }
    if (lower.contains('ramen') ||
        lower.contains('mie') ||
        lower.contains('noodle') ||
        lower.contains('bakmi') ||
        lower.contains('bihun') ||
        lower.contains('kwetiau')) {
      return '🍜';
    }
    if (lower.contains('teh') ||
        lower.contains('tea') ||
        lower.contains('ocha') ||
        lower.contains('kopi') ||
        lower.contains('coffee') ||
        lower.contains('latte') ||
        lower.contains('jus') ||
        lower.contains('juice') ||
        lower.contains('drink') ||
        lower.contains('air') ||
        lower.contains('mineral')) {
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
    if (lower.contains('dimsum') ||
        lower.contains('siomay') ||
        lower.contains('gyoza') ||
        lower.contains('pangsit')) {
      return '🥟';
    }
    if (lower.contains('es') ||
        lower.contains('ice') ||
        lower.contains('dessert') ||
        lower.contains('cake') ||
        lower.contains('roti') ||
        lower.contains('toast')) {
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

  /// Sends image bytes to OCR Space API using OCREngine 2 and extracts text
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
      ..fields['OCREngine'] = '2' // Engine 2 is optimized for numbers, receipts and tables
      ..fields['isTable'] = 'true'
      ..fields['isOverlayRequired'] = 'false'
      ..fields['detectOrientation'] = 'true'
      ..fields['scale'] = 'true'
      ..files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: 'receipt.jpg'),
      );

    final streamedResponse = await request.send().timeout(const Duration(seconds: 25));
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
    final rawLines = text.split(RegExp(r'\r?\n'));
    final items = <ExtractedReceiptItem>[];

    int? subtotal;
    int? taxAmount;
    int? serviceAmount;
    int? discountAmount;
    int? grandTotal;

    // Regex patterns for metadata lines
    final subtotalReg = RegExp(
      r'(?:subtotal|total\s+harga|total\s+belanja|sub\s*total)\s*[:=]?\s*(?:rp\.?)?\s*([0-9.,]+)',
      caseSensitive: false,
    );
    final taxReg = RegExp(
      r'(?:pb\s*1|pajak|tax|ppn)\s*(?:\([^)]*\)|[0-9]+%?)?\s*[:=]?\s*(?:rp\.?)?\s*([0-9.,]+)',
      caseSensitive: false,
    );
    final serviceReg = RegExp(
      r'(?:service|layanan|charge|sc)\s*(?:\([^)]*\)|[0-9]+%?)?\s*[:=]?\s*(?:rp\.?)?\s*([0-9.,]+)',
      caseSensitive: false,
    );
    final discountReg = RegExp(
      r'(?:diskon|discount|promo|voucher|potongan|hemat)\s*[:=]?\s*(?:rp\.?)?\s*-?\s*([0-9.,]+)',
      caseSensitive: false,
    );
    final grandTotalReg = RegExp(
      r'(?:grand\s*total|total\s*bayar|total\s*tagihan|total\s*akhir|amount\s*due|total)\s*[:=]?\s*(?:rp\.?)?\s*([0-9.,]+)',
      caseSensitive: false,
    );

    // Filter ignore lines
    final ignoreReg = RegExp(
      r'^(tanggal|date|waktu|time|jam|kasir|cashier|meja|table|order|struk|nota|kembali|change|tunai|cash|debit|qris|kartu|card|bca|mandiri|bri|bni|gopay|ovo|dana|shopeepay|terima\s+kasih|thank\s+you|resto|welcome|jl\.|jalan|telp|tel:|npwp|-+|=+|\*+)',
      caseSensitive: false,
    );

    var i = 0;
    while (i < rawLines.length) {
      final line = rawLines[i].trim();
      if (line.isEmpty) {
        i++;
        continue;
      }

      // Check metadata lines
      final taxMatch = taxReg.firstMatch(line);
      if (taxMatch != null) {
        taxAmount = _cleanNumber(taxMatch.group(1) ?? '');
        i++;
        continue;
      }

      final serviceMatch = serviceReg.firstMatch(line);
      if (serviceMatch != null) {
        serviceAmount = _cleanNumber(serviceMatch.group(1) ?? '');
        i++;
        continue;
      }

      final discMatch = discountReg.firstMatch(line);
      if (discMatch != null) {
        discountAmount = _cleanNumber(discMatch.group(1) ?? '');
        i++;
        continue;
      }

      final subMatch = subtotalReg.firstMatch(line);
      if (subMatch != null) {
        subtotal = _cleanNumber(subMatch.group(1) ?? '');
        i++;
        continue;
      }

      final grandMatch = grandTotalReg.firstMatch(line);
      if (grandMatch != null) {
        grandTotal = _cleanNumber(grandMatch.group(1) ?? '');
        i++;
        continue;
      }

      if (ignoreReg.hasMatch(line)) {
        i++;
        continue;
      }

      // 1. Try single-line parse
      final singleItem = _parseItemLine(line);
      if (singleItem != null) {
        items.add(singleItem);
        i++;
        continue;
      }

      // 2. Try multi-line lookahead:
      // If line i has a valid food name candidate, and line i+1 is a quantity/price specification line
      if (i + 1 < rawLines.length) {
        final nextLine = rawLines[i + 1].trim();
        if (_isPotentialItemName(line) && _isQtyPriceLine(nextLine)) {
          final multiItem = _parseMultiLineItem(line, nextLine);
          if (multiItem != null) {
            items.add(multiItem);
            i += 2;
            continue;
          }
        }
      }

      i++;
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

  /// Tests whether a line is likely just quantity and/or price without an item name
  static bool _isQtyPriceLine(String line) {
    if (line.isEmpty) return false;
    // Strip digits, spaces, separators, multiplier and currency symbols
    final withoutNumsOrSymbols = line
        .replaceAll(RegExp(r'(?:rp\.?|idr)\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'[0-9\s.,xX*=@:\-\(\)\[\]]'), '')
        .trim();
    // A qty/price line should have virtually no word characters remaining
    return withoutNumsOrSymbols.isEmpty;
  }

  /// Tests whether a line looks like an item name (contains letters, no trailing price)
  static bool _isPotentialItemName(String line) {
    final trimmed = line.trim();
    if (trimmed.length < 2) return false;
    final letters = trimmed.replaceAll(RegExp(r'[^a-zA-Z]'), '');
    return letters.length >= 2;
  }

  /// Parses a 2-line item structure (Line 1: Name, Line 2: Qty / Unit / Total)
  static ExtractedReceiptItem? _parseMultiLineItem(String nameLine, String qtyPriceLine) {
    final rawName = _formatName(nameLine);
    if (!_isValidItemName(rawName)) return null;

    // Pattern 1: Multiplier with unit & total: "2 x 25.000 50.000" or "2 x 25.000"
    final pattern1 = RegExp(
      r'^(?:([0-9]+)\s*(?:x|\*)\s+)?(?:@\s*)?(?:rp\.?)?\s*([0-9.,]+)(?:\s*(?:rp\.?)?\s*([0-9.,]+))?$',
      caseSensitive: false,
    );

    final match1 = pattern1.firstMatch(qtyPriceLine);
    if (match1 != null) {
      final qtyStr = match1.group(1);
      final p1Str = match1.group(2);
      final p2Str = match1.group(3);

      final qty = int.tryParse(qtyStr ?? '') ?? 1;
      final p1 = _cleanNumber(p1Str ?? '') ?? 0;
      final p2 = _cleanNumber(p2Str ?? '') ?? 0;

      int unitPrice = 0;
      if (p2 > 0) {
        // e.g. "2 x 25.000 50.000" -> unit is 25000, total is 50000
        unitPrice = p1;
      } else if (p1 > 0) {
        // e.g. "2 x 25.000" -> unit is 25000
        unitPrice = p1;
      }

      if (unitPrice > 0) {
        return ExtractedReceiptItem(
          name: rawName,
          quantity: qty > 0 ? qty : 1,
          unitPrice: unitPrice,
          emoji: detectEmoji(rawName),
        );
      }
    }

    // Pattern 2: Unit price first, then quantity: "@ 15.000 x 2 = 30.000" or "18.000 x 2"
    final pattern2 = RegExp(
      r'^(?:@\s*)?(?:rp\.?)?\s*([0-9.,]+)\s*(?:x|\*)\s*([0-9]+)(?:\s*=?\s*(?:rp\.?)?\s*([0-9.,]+))?$',
      caseSensitive: false,
    );

    final match2 = pattern2.firstMatch(qtyPriceLine);
    if (match2 != null) {
      final unitStr = match2.group(1);
      final qtyStr = match2.group(2);
      final unitPrice = _cleanNumber(unitStr ?? '') ?? 0;
      final qty = int.tryParse(qtyStr ?? '') ?? 1;

      if (unitPrice > 0) {
        return ExtractedReceiptItem(
          name: rawName,
          quantity: qty > 0 ? qty : 1,
          unitPrice: unitPrice,
          emoji: detectEmoji(rawName),
        );
      }
    }

    // Pattern 3: Simple Qty and Total: "2 50.000" or "1 25.000"
    final pattern3 = RegExp(r'^([0-9]+)\s+(?:rp\.?)?\s*([0-9.,]{4,})$', caseSensitive: false);
    final match3 = pattern3.firstMatch(qtyPriceLine);
    if (match3 != null) {
      final qty = int.tryParse(match3.group(1) ?? '') ?? 1;
      final total = _cleanNumber(match3.group(2) ?? '') ?? 0;
      final unitPrice = (qty > 1 && total > 0) ? (total / qty).round() : total;

      if (unitPrice > 0) {
        return ExtractedReceiptItem(
          name: rawName,
          quantity: qty > 0 ? qty : 1,
          unitPrice: unitPrice,
          emoji: detectEmoji(rawName),
        );
      }
    }

    // Pattern 4: Just price line: "25.000" or "Rp 25.000"
    final priceOnly = _cleanNumber(qtyPriceLine);
    if (priceOnly != null && priceOnly > 0) {
      return ExtractedReceiptItem(
        name: rawName,
        quantity: 1,
        unitPrice: priceOnly,
        emoji: detectEmoji(rawName),
      );
    }

    return null;
  }

  /// Parses a single-line item structure
  static ExtractedReceiptItem? _parseItemLine(String line) {
    final cleaned = line.replaceAll(RegExp(r'[\r\t]'), ' ').trim();
    final startsWithPrefixQty = RegExp(r'^[0-9]+\s*(?:x|\*)\s+', caseSensitive: false);

    // Pattern Prefix Multiplier: "2x Mie Gacoan Lv 2 24.000"
    final patternPrefix = RegExp(
      r'^(?:([0-9]+)\s*(?:x|\*)\s+)?(.*?)\s+(?:rp\.?)?\s*([0-9.,]{4,})$',
      caseSensitive: false,
    );

    if (startsWithPrefixQty.hasMatch(cleaned)) {
      final matchPrefix = patternPrefix.firstMatch(cleaned);
      if (matchPrefix != null) {
        final qtyStr = matchPrefix.group(1);
        final rawName = matchPrefix.group(2)?.trim() ?? '';
        final priceStr = matchPrefix.group(3);

        final qty = int.tryParse(qtyStr ?? '') ?? 1;
        final rawPrice = _cleanNumber(priceStr ?? '') ?? 0;
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
    }

    // Pattern Middle Multiplier: "Es Teh Manis 3 x 5.000 15.000" or "Es Teh Manis 3x 5.000"
    final patternMiddle = RegExp(
      r'^(.*?)\s+([0-9]+)\s*(?:x|\*)\s*(?:rp\.?)?\s*([0-9.,]+)(?:\s*(?:rp\.?)?\s*([0-9.,]+))?$',
      caseSensitive: false,
    );
    final matchMiddle = patternMiddle.firstMatch(cleaned);
    if (matchMiddle != null) {
      final rawName = matchMiddle.group(1)?.trim() ?? '';
      final qtyStr = matchMiddle.group(2);
      final p1Str = matchMiddle.group(3);
      final p2Str = matchMiddle.group(4);

      final qty = int.tryParse(qtyStr ?? '') ?? 1;
      final p1 = _cleanNumber(p1Str ?? '') ?? 0;
      final p2 = _cleanNumber(p2Str ?? '') ?? 0;

      final unitPrice = (p2 > 0) ? p1 : ((qty > 1 && p1 > 0) ? (p1 / qty).round() : p1);

      if (_isValidItemName(rawName) && unitPrice > 0) {
        return ExtractedReceiptItem(
          name: _formatName(rawName),
          quantity: qty > 0 ? qty : 1,
          unitPrice: unitPrice,
          emoji: detectEmoji(rawName),
        );
      }
    }

    // Pattern Suffix Multiplier: "Kopi Susu @ Rp 18.000 x 2 = Rp 36.000"
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
      final total = _cleanNumber(totalStr ?? '') ?? 0;
      final int unit = (unitPriceStr != null && unitPriceStr.isNotEmpty)
          ? (_cleanNumber(unitPriceStr) ?? 0)
          : (qty > 0 && total > 0 ? (total / qty).round() : total);

      if (_isValidItemName(rawName) && unit > 0) {
        return ExtractedReceiptItem(
          name: _formatName(rawName),
          quantity: qty > 0 ? qty : 1,
          unitPrice: unit,
          emoji: detectEmoji(rawName),
        );
      }
    }

    // Pattern Default Simple Line: "Roti Bakar Coklat Keju Rp 22.000"
    final matchPrefix = patternPrefix.firstMatch(cleaned);
    if (matchPrefix != null) {
      final qtyStr = matchPrefix.group(1);
      final rawName = matchPrefix.group(2)?.trim() ?? '';
      final priceStr = matchPrefix.group(3);

      final qty = int.tryParse(qtyStr ?? '') ?? 1;
      final rawPrice = _cleanNumber(priceStr ?? '') ?? 0;
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
    if (lower == 'total' ||
        lower == 'subtotal' ||
        lower == 'tunai' ||
        lower == 'change' ||
        lower == 'pajak' ||
        lower == 'ppn' ||
        lower == 'service') {
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
    var s = str.trim();
    // Remove currency prefixes
    s = s.replaceAll(RegExp(r'(?:rp\.?|idr)\s*', caseSensitive: false), '');
    // Strip trailing cents (,00 or .00)
    s = s.replaceAll(RegExp(r'[,.]00$'), '');
    final digits = s.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits);
  }
}
