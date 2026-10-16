import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patungankilat/core/widgets/neo_toast.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('NeoToast displays success message in overlay at top of screen', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () {
                  NeoToast.show(context, 'Rekening berhasil disalin! ⚡', type: NeoToastType.success);
                },
                child: const Text('Show Toast'),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Rekening berhasil disalin! ⚡'), findsNothing);

    await tester.tap(find.text('Show Toast'));
    await tester.pump(); // Start animation
    await tester.pump(const Duration(milliseconds: 300)); // Finish slide-in

    expect(find.text('Rekening berhasil disalin! ⚡'), findsOneWidget);
    expect(find.byIcon(Icons.bolt_rounded), findsOneWidget);

    // After duration, it disappears
    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Rekening berhasil disalin! ⚡'), findsNothing);
  });

  testWidgets('NeoToast renders warning and error variants with appropriate icons', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      NeoToast.show(context, 'Nama tidak boleh kosong', type: NeoToastType.warning);
                    },
                    child: const Text('Show Warning'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      NeoToast.show(context, 'Gagal memproses struk', type: NeoToastType.error);
                    },
                    child: const Text('Show Error'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Test warning
    await tester.tap(find.text('Show Warning'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Nama tidak boleh kosong'), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);

    // Test error (showing another toast replaces previous)
    await tester.tap(find.text('Show Error'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Gagal memproses struk'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
  });

  testWidgets('NeoToast can be dismissed immediately by tapping on it', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () {
                  NeoToast.show(context, 'Tap to dismiss me', type: NeoToastType.info);
                },
                child: const Text('Show Toast'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Toast'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Tap to dismiss me'), findsOneWidget);

    // Tap on the toast itself to dismiss
    await tester.tap(find.text('Tap to dismiss me'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Tap to dismiss me'), findsNothing);
  });
}

