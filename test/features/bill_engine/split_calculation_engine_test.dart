import 'package:flutter_test/flutter_test.dart';
import 'package:patungankilat/features/bill_engine/models/friend.dart';
import 'package:patungankilat/features/bill_engine/models/menu_item.dart';
import 'package:patungankilat/features/bill_engine/services/split_calculation_engine.dart';

void main() {
  group('SplitCalculationEngine Unit Tests', () {
    const raka = Friend(id: 'raka', name: 'Raka', role: 'Talangan', theme: 'lime');
    const nadia = Friend(id: 'nadia', name: 'Nadia', role: 'Teman', theme: 'dark');
    const bima = Friend(id: 'bima', name: 'Bima', role: 'Teman', theme: 'white');
    const sinta = Friend(id: 'sinta', name: 'Sinta', role: 'Teman', theme: 'white');

    final sampleFriends = [raka, nadia, bima, sinta];

    test('Computes proportional tax and discounts correctly for demo state', () {
      final items = [
        const MenuItem(id: '1', name: 'Toripaitan Ramen', price: 88000, assignedTo: ['raka']),
        const MenuItem(id: '2', name: 'Spicy Miso Ramen', price: 82000, assignedTo: ['nadia']),
        const MenuItem(id: '3', name: 'Shoyu Ramen', price: 74000, assignedTo: ['bima']),
        const MenuItem(id: '4', name: 'Karaage Sharing', price: 42000, assignedTo: ['raka', 'nadia', 'bima', 'sinta']),
        const MenuItem(id: '5', name: 'Ocha Refill', price: 24000, assignedTo: ['sinta']),
      ];

      final result = SplitCalculationEngine.calculate(
        friends: sampleFriends,
        items: items,
        taxEnabled: true,      // 10%
        serviceEnabled: true,  // 5%
        discountAmount: 30000, // Rp 30.000
      );

      // Subtotal: 88k + 82k + 74k + 42k + 24k = 310.000
      expect(result.subtotalAll, 310000);
      expect(result.totalTaxService.round(), 46500);
      expect(result.totalDiscount, 30000);
      expect(result.grandTotal, 310000 + 46500 - 30000); // 326.500

      // Sum of individual breakdown final amounts must strictly equal grandTotal
      final sumOfFinals = result.breakdowns.fold<int>(0, (sum, b) => sum + b.finalAmount);
      expect(sumOfFinals, result.grandTotal);
    });

    test('Rounding reconciliation handles odd splits (Penny problem)', () {
      final threeFriends = [
        const Friend(id: 'f1', name: 'Alice', role: 'Talangan'),
        const Friend(id: 'f2', name: 'Bob', role: 'Teman'),
        const Friend(id: 'f3', name: 'Charlie', role: 'Teman'),
      ];

      // Rp 100.000 shared by 3 people => 33333.33 each
      final items = [
        const MenuItem(id: '1', name: 'Pizza Party', price: 100000, assignedTo: ['f1', 'f2', 'f3']),
      ];

      final result = SplitCalculationEngine.calculate(
        friends: threeFriends,
        items: items,
        taxEnabled: false,
        serviceEnabled: false,
        discountAmount: 0,
      );

      expect(result.grandTotal, 100000);

      // Sum of all individual final amounts must equal exactly 100.000
      final sumOfFinals = result.breakdowns.fold<int>(0, (sum, b) => sum + b.finalAmount);
      expect(sumOfFinals, 100000);

      // Payer Alice should absorb the +1 difference (33334, while others are 33333)
      final alice = result.breakdowns.firstWhere((b) => b.friend.id == 'f1');
      expect(alice.finalAmount, 33334);
    });
  });
}
