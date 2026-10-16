import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patungankilat/features/onboarding/screens/onboarding_screen.dart';
import 'package:patungankilat/features/onboarding/screens/splash_screen.dart';
import 'package:patungankilat/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SplashScreen navigates to MainNavigationShell when onboarded', (tester) async {
    SharedPreferences.setMockInitialValues({
      'user_name': 'Raka',
      'user_bank': 'BCA',
      'user_account': '1234567890',
      'user_onboarded': true,
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: SplashScreen()),
      ),
    );

    // Initial splash state
    expect(find.byType(SplashScreen), findsOneWidget);

    // Advance timer past splash duration (2000ms) + transition (600ms)
    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.byType(MainNavigationShell), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);
  });

  testWidgets('SplashScreen navigates to OnboardingScreen when not onboarded', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: SplashScreen()),
      ),
    );

    // Initial splash state
    expect(find.byType(SplashScreen), findsOneWidget);

    // Advance timer past splash duration (2000ms) + transition (600ms)
    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.byType(MainNavigationShell), findsNothing);
  });
}

