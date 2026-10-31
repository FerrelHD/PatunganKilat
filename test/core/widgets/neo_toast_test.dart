import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patungankilat/core/widgets/neo_toast.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('NeoToast renders compact pill with semantic checkmark for brief messages', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () {
                  NeoToast.show(context, 'No. Rekening BCA disalin', type: NeoToastType.success);
                },
                child: const Text('Show Compact'),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('No. Rekening BCA disalin'), findsNothing);

    await tester.tap(find.text('Show Compact'));
    await tester.pump(); // Start animation
    await tester.pump(const Duration(milliseconds: 300)); // Finish slide-in

    expect(find.text('No. Rekening BCA disalin'), findsOneWidget);
    // Uses clean semantic checkmark, not generic lightning slop
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    // After duration, it disappears
    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('No. Rekening BCA disalin'), findsNothing);
  });

  testWidgets('NeoToast renders expanded card with title and instruction when title is provided', (tester) async {
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
    await tester.pump(const Duration(milliseconds: 300));

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
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Gagal Ekstrak'), findsOneWidget);
    expect(find.text('Format teks tidak dikenali'), findsOneWidget);
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
