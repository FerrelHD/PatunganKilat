import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patungankilat/core/widgets/neo_toast.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('NeoToast renders clean white card with semantic checkmark and dismiss icon', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () {
                  NeoToast.show(context, 'No. Rekening BCA disalin', type: NeoToastType.success);
                },
                child: const Text('Show Toast'),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('No. Rekening BCA disalin'), findsNothing);

    await tester.tap(find.text('Show Toast'));
    await tester.pump(); // Start animation
    await tester.pump(const Duration(milliseconds: 250)); // Finish slide-in

    expect(find.text('No. Rekening BCA disalin'), findsOneWidget);
    // Semantic checkmark
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    // Linear style close icon
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);

    // After duration, it disappears
    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('No. Rekening BCA disalin'), findsNothing);
  });

  testWidgets('NeoToast renders structured card with title and instruction when title is provided', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () {
                  NeoToast.show(
                    context,
                    'Foto buram atau kurang terang. Coba gunakan foto yang lebih jelas atau tempel teks.',
                    title: 'Struk Tidak Terbaca',
                    type: NeoToastType.warning,
                  );
                },
                child: const Text('Show Expanded'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Expanded'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Struk Tidak Terbaca'), findsOneWidget);
    expect(
      find.text('Foto buram atau kurang terang. Coba gunakan foto yang lebih jelas atau tempel teks.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
  });

  testWidgets('NeoToast renders error variant with appropriate error icon', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () {
                  NeoToast.show(
                    context,
                    'Format teks tidak dikenali',
                    title: 'Gagal Ekstrak',
                    type: NeoToastType.error,
                  );
                },
                child: const Text('Show Error'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Error'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Gagal Ekstrak'), findsOneWidget);
    expect(find.text('Format teks tidak dikenali'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
  });

  testWidgets('NeoToast can be dismissed immediately by tapping on close icon or toast', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () {
                  NeoToast.show(context, 'Tap close to dismiss', type: NeoToastType.info);
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
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Tap close to dismiss'), findsOneWidget);

    // Tap on close button to dismiss
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Tap close to dismiss'), findsNothing);
  });
}
