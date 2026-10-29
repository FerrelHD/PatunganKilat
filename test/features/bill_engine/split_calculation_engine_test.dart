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

    test('Correctly calculates subtotal and item shares when items have quantity > 1', () {
      final items = [
        const MenuItem(id: '1', name: 'Es Teh Manis', price: 5000, quantity: 3, assignedTo: ['raka']),
        const MenuItem(id: '2', name: 'Dimsum Porsi', price: 20000, quantity: 2, assignedTo: ['raka', 'nadia']),
      ];

      final result = SplitCalculationEngine.calculate(
        friends: [raka, nadia],
        items: items,
        taxEnabled: false,
        serviceEnabled: false,
        discountAmount: 0,
      );

      // Es Teh Manis: 5.000 x 3 = 15.000 (Raka)
      // Dimsum: 20.000 x 2 = 40.000 (Raka: 20.000, Nadia: 20.000)
      // Subtotal: 55.000
      expect(result.subtotalAll, 55000);
      expect(result.grandTotal, 55000);

      final rakaBreakdown = result.breakdowns.firstWhere((b) => b.friend.id == 'raka');
      final nadiaBreakdown = result.breakdowns.firstWhere((b) => b.friend.id == 'nadia');

      expect(rakaBreakdown.finalAmount, 35000);
      expect(nadiaBreakdown.finalAmount, 20000);
      expect(rakaBreakdown.items.first.itemName, 'Es Teh Manis (3x)');
      expect(rakaBreakdown.items.last.itemName, 'Dimsum Porsi (2x)');
    });

    test('Calculates custom portions split correctly when items are split unevenly', () {
      // 3 porsi Es Teh Manis (@ Rp 10.000 = Rp 30.000)
      // Raka took 2 portions, Nadia took 1 portion
      final items = [
        const MenuItem(
          id: '1',
          name: 'Es Teh Manis',
          price: 10000,
          quantity: 3,
          assignedTo: ['raka', 'nadia'],
          portions: {'raka': 2, 'nadia': 1},
        ),
      ];

      final result = SplitCalculationEngine.calculate(
        friends: [raka, nadia],
        items: items,
        taxEnabled: false,
        serviceEnabled: false,
        discountAmount: 0,
      );

      expect(result.subtotalAll, 30000);
      expect(result.grandTotal, 30000);

      final rakaBreakdown = result.breakdowns.firstWhere((b) => b.friend.id == 'raka');
      final nadiaBreakdown = result.breakdowns.firstWhere((b) => b.friend.id == 'nadia');

      // Raka should pay 2/3 * 30.000 = 20.000
      expect(rakaBreakdown.finalAmount, 20000);
      expect(rakaBreakdown.items.first.sharePrice, 20000.0);
      expect(rakaBreakdown.items.first.portion, 2);
      expect(rakaBreakdown.items.first.totalPortions, 3);
      expect(rakaBreakdown.items.first.shareDetailLabel, '2/3 porsi');

      // Nadia should pay 1/3 * 30.000 = 10.000
      expect(nadiaBreakdown.finalAmount, 10000);
      expect(nadiaBreakdown.items.first.sharePrice, 10000.0);
      expect(nadiaBreakdown.items.first.portion, 1);
      expect(nadiaBreakdown.items.first.totalPortions, 3);
      expect(nadiaBreakdown.items.first.shareDetailLabel, '1/3 porsi');
    });

    test('Calculates custom portions split for single item sharing ratio', () {
      // 1 Pizza Large Rp 80.000
      // Raka ate 3 slices, Nadia ate 1 slice (ratio 3:1)
      final items = [
        const MenuItem(
          id: 'pizza',
          name: 'Pizza Meat Lovers',
          price: 80000,
          quantity: 1,
          assignedTo: ['raka', 'nadia'],
          portions: {'raka': 3, 'nadia': 1},
        ),
      ];

      final result = SplitCalculationEngine.calculate(
        friends: [raka, nadia],
        items: items,
        taxEnabled: false,
        serviceEnabled: false,
        discountAmount: 0,
      );

      expect(result.grandTotal, 80000);

      final rakaBreakdown = result.breakdowns.firstWhere((b) => b.friend.id == 'raka');
      final nadiaBreakdown = result.breakdowns.firstWhere((b) => b.friend.id == 'nadia');

      // Raka 3/4 * 80.000 = 60.000
      expect(rakaBreakdown.finalAmount, 60000);
      // Nadia 1/4 * 80.000 = 20.000
      expect(nadiaBreakdown.finalAmount, 20000);
      expect(rakaBreakdown.items.first.shareDetailLabel, '3/4 porsi');
      expect(nadiaBreakdown.items.first.shareDetailLabel, '1/4 porsi');
    });
  });
}
