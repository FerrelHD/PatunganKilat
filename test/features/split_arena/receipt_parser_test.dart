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
  });
}
