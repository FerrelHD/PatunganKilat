import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patungankilat/main.dart';

void main() {
  testWidgets('PatunganKilat App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: PatunganKilatApp(),
      ),
    );

    expect(find.text('PatunganKilat'), findsNothing); // Title is in MaterialApp
    expect(find.text('Total Talangan Aktif'), findsOneWidget);
  });
}
