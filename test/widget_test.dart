import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patungankilat/main.dart';

void main() {
  testWidgets('PatunganKilat App renders SplashScreen first', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: PatunganKilatApp(),
      ),
    );

    expect(find.text('PatunganKilat'), findsOneWidget);
    expect(find.text('Visual Bill Splitter Tanpa Drama'), findsOneWidget);

    // Advance timer so pending Future.delayed timer completes cleanly
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pumpAndSettle();
  });

  testWidgets('MainNavigationShell renders clean zero-state Home', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: MainNavigationShell(),
        ),
      ),
    );

    expect(find.text('Total Talangan Aktif'), findsOneWidget);
    expect(find.text('Belum Ada Sesi'), findsOneWidget);
    expect(find.text('+ Buat Patungan Baru'), findsWidgets);
  });
}
