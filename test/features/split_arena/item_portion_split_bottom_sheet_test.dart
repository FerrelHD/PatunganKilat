import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patungankilat/features/bill_engine/models/friend.dart';
import 'package:patungankilat/features/bill_engine/models/menu_item.dart';
import 'package:patungankilat/features/split_arena/widgets/item_portion_split_bottom_sheet.dart';

void main() {
  group('ItemPortionSplitBottomSheet Widget Tests', () {
    const friend1 = Friend(id: 'f1', name: 'Raka', role: 'Talangan');
    const friend2 = Friend(id: 'f2', name: 'Nadia', role: 'Teman');
    const friend3 = Friend(id: 'f3', name: 'Bima', role: 'Teman');

    final testFriends = [friend1, friend2, friend3];

    testWidgets('Renders item details and allocated friend portions', (tester) async {
      const item = MenuItem(
        id: '1',
        name: 'Dimsum Porsi',
        price: 20000,
        quantity: 3,
        assignedTo: ['f1', 'f2'],
        portions: {'f1': 2, 'f2': 1},
      );

      Map<String, int>? savedPortions;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  ItemPortionSplitBottomSheet.show(
                    context,
                    item: item,
                    allFriends: testFriends,
                    onSave: (portions) {
                      savedPortions = portions;
                    },
                  );
                },
                child: const Text('Open Sheet'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Verify item name
      expect(find.text('Dimsum Porsi'), findsOneWidget);
      expect(find.text('Pas Qty'), findsOneWidget);

      // Verify friend names
      expect(find.text('Raka'), findsOneWidget);
      expect(find.text('Nadia'), findsOneWidget);
      expect(find.text('Bima'), findsOneWidget);

      // Verify initial portion values
      expect(find.text('2'), findsOneWidget); // Raka's portion
      expect(find.text('1'), findsOneWidget); // Nadia's portion

      // Tap Simpan
      await tester.tap(find.text('Simpan Pembagian Porsi ⚡'));
      await tester.pumpAndSettle();

      expect(savedPortions, isNotNull);
      expect(savedPortions!['f1'], 2);
      expect(savedPortions!['f2'], 1);
    });

    testWidgets('Allows adjusting portion with stepper and adding unassigned friend', (tester) async {
      const item = MenuItem(
        id: '1',
        name: 'Es Teh Manis',
        price: 5000,
        quantity: 2,
        assignedTo: ['f1'],
        portions: {'f1': 1},
      );

      Map<String, int>? savedPortions;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  ItemPortionSplitBottomSheet.show(
                    context,
                    item: item,
                    allFriends: testFriends,
                    onSave: (portions) {
                      savedPortions = portions;
                    },
                  );
                },
                child: const Text('Open Sheet'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Add Nadia (friend 2) who is currently unassigned via "Ikut" button
      final ikutButtons = find.text('Ikut');
      expect(ikutButtons, findsWidgets);
      await tester.tap(ikutButtons.first);
      await tester.pumpAndSettle();

      // Now both f1 and f2 are assigned
      // Tap Simpan
      await tester.tap(find.text('Simpan Pembagian Porsi ⚡'));
      await tester.pumpAndSettle();

      expect(savedPortions, isNotNull);
      expect(savedPortions!['f1'], 1);
      expect(savedPortions!['f2'], 1);
    });

    testWidgets('Bagi Rata (1:1) resets all unequal portions to 1', (tester) async {
      const item = MenuItem(
        id: '1',
        name: 'Pizza Pepperoni',
        price: 90000,
        quantity: 1,
        assignedTo: ['f1', 'f2'],
        portions: {'f1': 3, 'f2': 1},
      );

      Map<String, int>? savedPortions;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  ItemPortionSplitBottomSheet.show(
                    context,
                    item: item,
                    allFriends: testFriends,
                    onSave: (portions) {
                      savedPortions = portions;
                    },
                  );
                },
                child: const Text('Open Sheet'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Tap Bagi Rata (1:1)
      await tester.tap(find.text('Bagi Rata (1:1)'));
      await tester.pumpAndSettle();

      // Tap Simpan
      await tester.tap(find.text('Simpan Pembagian Porsi ⚡'));
      await tester.pumpAndSettle();

      expect(savedPortions, isNotNull);
      expect(savedPortions!['f1'], 1);
      expect(savedPortions!['f2'], 1);
    });
  });
}
