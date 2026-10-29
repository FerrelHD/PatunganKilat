import 'package:flutter_test/flutter_test.dart';
import 'package:patungankilat/features/split_arena/services/receipt_ocr_service.dart';

void main() {
  group('ReceiptOcrService Parsing Tests', () {
    test('Parses standard GoFood/GrabFood receipt text', () {
      const rawReceipt = '''
RESTO MIE GACOAN
Tanggal: 29/10/2026
-------------------------------
2x Mie Gacoan Lv 2       24.000
1x Pangsit Goreng        12.000
3x Es Gobak Sodor        36.000
1x Udang Keju            11.000
-------------------------------
Subtotal                 83.000
PB1 (10%)                 8.300
Diskon Promo             15.000
Total Bayar              76.300
''';

      final result = ReceiptOcrService.parseReceiptText(rawReceipt);

      expect(result.items.length, 4);

      expect(result.items[0].name, 'Mie Gacoan Lv 2');
      expect(result.items[0].quantity, 2);
      expect(result.items[0].unitPrice, 12000); // 24.000 total / 2 qty
      expect(result.items[0].totalPrice, 24000);

      expect(result.items[1].name, 'Pangsit Goreng');
      expect(result.items[1].quantity, 1);
      expect(result.items[1].unitPrice, 12000);

      expect(result.items[2].name, 'Es Gobak Sodor');
      expect(result.items[2].quantity, 3);
      expect(result.items[2].unitPrice, 12000); // 36.000 total / 3 qty

      expect(result.items[3].name, 'Udang Keju');
      expect(result.items[3].quantity, 1);
      expect(result.items[3].unitPrice, 11000);

      expect(result.subtotal, 83000);
      expect(result.taxAmount, 8300);
      expect(result.discountAmount, 15000);
    });

    test('Parses receipt with item quantity suffix @ and Rp formatting', () {
      const rawReceipt = '''
WARUNG KOPI NONGKRONG
Kopi Susu Gula Aren @ Rp 18.000 x 2 = Rp 36.000
Roti Bakar Coklat Keju Rp 22.000
Kentang Goreng (1) Rp 15.000
Total Rp 73.000
''';

      final result = ReceiptOcrService.parseReceiptText(rawReceipt);

      expect(result.items.length, 3);
      expect(result.items[0].name, 'Kopi Susu Gula Aren');
      expect(result.items[0].quantity, 2);
      expect(result.items[0].unitPrice, 18000);

      expect(result.items[1].name, 'Roti Bakar Coklat Keju');
      expect(result.items[1].quantity, 1);
      expect(result.items[1].unitPrice, 22000);

      expect(result.items[2].name, 'Kentang Goreng');
      expect(result.items[2].quantity, 1);
      expect(result.items[2].unitPrice, 15000);
    });

    test('Parses multi-line Indonesian thermal receipts (item name on line 1, qty/price on line 2)', () {
      const multiLineReceipt = '''
SOLARIA RESTO
KASIR: 02 - MEJA 14
-------------------------------
Nasi Goreng Spesial
1 x 38.000           38.000
Ayam Mentega
2 x 42.000           84.000
Es Teh Manis
3 x 8.000            24.000
-------------------------------
Subtotal            146.000
PB1 10%              14.600
Total Bayar         160.600
''';

      final result = ReceiptOcrService.parseReceiptText(multiLineReceipt);

      expect(result.items.length, 3);

      expect(result.items[0].name, 'Nasi Goreng Spesial');
      expect(result.items[0].quantity, 1);
      expect(result.items[0].unitPrice, 38000);

      expect(result.items[1].name, 'Ayam Mentega');
      expect(result.items[1].quantity, 2);
      expect(result.items[1].unitPrice, 42000);
      expect(result.items[1].totalPrice, 84000);

      expect(result.items[2].name, 'Es Teh Manis');
      expect(result.items[2].quantity, 3);
      expect(result.items[2].unitPrice, 8000);
      expect(result.items[2].totalPrice, 24000);

      expect(result.subtotal, 146000);
      expect(result.taxAmount, 14600);
      expect(result.grandTotal, 160600);
    });

    test('Handles decimal cents (,00 or .00) accurately without price inflation', () {
      const receiptWithCents = '''
CAFE KOPI SENJA
2x Americano 40.000,00
1x Croissant 25.000,00
Subtotal 65.000,00
''';

      final result = ReceiptOcrService.parseReceiptText(receiptWithCents);

      expect(result.items.length, 2);
      expect(result.items[0].name, 'Americano');
      expect(result.items[0].quantity, 2);
      expect(result.items[0].unitPrice, 20000);
      expect(result.items[0].totalPrice, 40000);

      expect(result.items[1].name, 'Croissant');
      expect(result.items[1].quantity, 1);
      expect(result.items[1].unitPrice, 25000);
    });

    test('Parses middle multiplier format cleanly', () {
      const receipt = '''
Es Teh Manis 3 x 5.000 15.000
Nasi Liwet 2 x 20.000 40.000
''';

      final result = ReceiptOcrService.parseReceiptText(receipt);
      expect(result.items.length, 2);
      expect(result.items[0].name, 'Es Teh Manis');
      expect(result.items[0].quantity, 3);
      expect(result.items[0].unitPrice, 5000);

      expect(result.items[1].name, 'Nasi Liwet');
      expect(result.items[1].quantity, 2);
      expect(result.items[1].unitPrice, 20000);
    });
  });
}
