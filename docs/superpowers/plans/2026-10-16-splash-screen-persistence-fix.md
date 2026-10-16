# Splash Screen Persistence & Profile Management Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ensure SplashScreen awaits persistent storage so onboarded users immediately enter HomeScreen without ever re-prompting onboarding, and provide an in-app bottom sheet to edit or switch the talangan bank/account anytime.

**Architecture:**
1. Eliminate the race condition in `SplashScreen` by coordinating `SharedPreferences.getInstance()` resolution with the splash branding animation using `Future.wait`.
2. Ensure `UserProfileNotifier` synchronously or reliably reflects the stored state.
3. Build `EditAccountBottomSheet` and connect it to `AccountCarousel` so the user can update their bank name, account number, or name at any time from HomeScreen.

**Tech Stack:** Flutter 3.47, Dart 3.13, Riverpod 2.6 (`StateNotifierProvider`), `shared_preferences`, Google Fonts (`Plus Jakarta Sans`), Neobank Design Tokens (`AppColors`).

---

## Global Constraints

- Never block or delay splash animation longer than 2000ms unless storage is still being read.
- Keep onboarding data offline-first in `SharedPreferences`.
- All UI components must adhere to Neobank aesthetics: `#141518` (neoDark), `#C5F536` (neoLime), `#F5F6F8` (neoBg), full pill buttons (radius 999), and card radius 28.
- Maintain existing architecture and clean Riverpod separation.

## Review Focus

1. **Slow Storage Read:** If `SharedPreferences.getInstance()` takes longer than 2000ms on low-end devices or slow browsers, splash must wait for storage rather than navigating to Onboarding with stale false state.
2. **Missing/Corrupted Name:** If `user_onboarded` is true but `user_name` is empty or whitespace, it must treat user as not onboarded.
3. **Account Edit Immediate UI Update:** When account details are edited in the new bottom sheet, the home screen cards, receipt screen, and WhatsApp summary text must immediately reflect the updated details without app restart.
4. **Validation in Edit Sheet:** Account edit form must require a non-empty name before saving.
5. **Back Navigation Integrity:** Replacing `SplashScreen` with `MainNavigationShell` must not allow back button to navigate back to splash.

---

### Task 1: Widget Test for Splash Screen Persistence Routing

**Files:**
- Create: `test/features/onboarding/splash_persistence_test.dart`

**Interfaces:**
- Consumes: `SplashScreen`, `userProfileProvider`, `SharedPreferences`
- Produces: Verified automated test suite for onboarding vs home navigation

- [ ] **Step 1: Write widget test verifying onboarding routing logic**

```dart
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

    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.byType(MainNavigationShell), findsNothing);
  });
}
```

- [ ] **Step 2: Run test to see current behavior / failure**

Run: `E:\flutter\bin\flutter.bat test test/features/onboarding/splash_persistence_test.dart`
Expected: Failure or timeout due to race condition between Future.delayed and provider state loading.

---

### Task 2: Eliminate Race Condition in `SplashScreen` & `UserProfileNotifier`

**Files:**
- Modify: `lib/features/onboarding/screens/splash_screen.dart:70-96`
- Modify: `lib/features/onboarding/providers/user_profile_provider.dart:5-49`

**Interfaces:**
- Consumes: `SharedPreferences.getInstance()`
- Produces: Guaranteed synchronous/awaitable user profile loading and deterministic navigation

- [ ] **Step 1: Update `SplashScreen._checkNextScreen()`**

In `lib/features/onboarding/screens/splash_screen.dart`:
Coordinate `SharedPreferences.getInstance()` and minimum splash presentation:
```dart
  Future<void> _checkNextScreen() async {
    final prefsFuture = SharedPreferences.getInstance();
    final delayFuture = Future<void>.delayed(const Duration(milliseconds: 2000));

    final results = await Future.wait([prefsFuture, delayFuture]);
    final prefs = results[0] as SharedPreferences;

    if (!mounted) return;

    final isOnboarded = prefs.getBool('user_onboarded') ?? false;
    final userName = prefs.getString('user_name') ?? '';

    // Warm up Riverpod state with loaded prefs
    ref.read(userProfileProvider.notifier).syncFromPrefs(prefs);

    final targetScreen = (isOnboarded && userName.trim().isNotEmpty)
        ? const MainNavigationShell()
        : const OnboardingScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
```

- [ ] **Step 2: Add `syncFromPrefs(SharedPreferences prefs)` to `UserProfileNotifier`**

In `lib/features/onboarding/providers/user_profile_provider.dart`:
Add helper method so `SplashScreen` can hydrate state instantly without a second asynchronous call:
```dart
  void syncFromPrefs(SharedPreferences prefs) {
    final name = prefs.getString('user_name') ?? '';
    final bankName = prefs.getString('user_bank') ?? 'BCA';
    final accountNumber = prefs.getString('user_account') ?? '';
    final isOnboarded = prefs.getBool('user_onboarded') ?? false;

    state = UserProfile(
      name: name,
      bankName: bankName,
      accountNumber: accountNumber,
      isOnboarded: isOnboarded,
    );
  }
```

- [ ] **Step 3: Run the test to verify it passes**

Run: `E:\flutter\bin\flutter.bat test test/features/onboarding/splash_persistence_test.dart`
Expected: PASS (2/2 tests pass).

---

### Task 3: In-App "Edit Rekening Talangan" Bottom Sheet

**Files:**
- Create: `lib/features/home/widgets/edit_account_bottom_sheet.dart`
- Modify: `lib/features/home/widgets/account_carousel.dart:37-60`

**Interfaces:**
- Consumes: `userProfileProvider`, `AppColors`, `AppTypography`
- Produces: `EditAccountBottomSheet.show(BuildContext context)`

- [ ] **Step 1: Create `EditAccountBottomSheet`**

Create `lib/features/home/widgets/edit_account_bottom_sheet.dart`:
- Clean Neobank modal sheet with:
  - Header: "Atur Rekening Talangan" with close button
  - Text input for "Nama Panggilanmu"
  - Bank/E-Wallet selector chips (BCA, Mandiri, BNI, BRI, SeaBank, GoPay, OVO, Dana)
  - Text input for "Nomor Rekening / No HP"
  - Primary button: "Simpan Rekening" (calls `userProfileProvider.notifier.saveProfile(...)`)
- Validate non-empty name before saving.
- Show SnackBar: "Rekening talangan berhasil diperbarui! ⚡".

- [ ] **Step 2: Hook up `EditAccountBottomSheet` in `AccountCarousel`**

In `lib/features/home/widgets/account_carousel.dart`:
- When clicking `+ Tambah` or `Edit`: open `EditAccountBottomSheet.show(context)`.
- When tapping the `NeoLimeCard` (BCA card) or `NeoDarkCard` (GoPay card): also offer opening the edit sheet.

- [ ] **Step 3: Run Flutter analyzer**

Run: `E:\flutter\bin\dart.bat analyze`
Expected: 0 errors.

---

### Task 4: Full Verification & Sanity Check

- [ ] **Step 1: Run all unit and widget tests**
Run: `E:\flutter\bin\flutter.bat test`
Expected: All tests pass.

- [ ] **Step 2: Run Flutter Web release build test**
Run: `E:\flutter\bin\flutter.bat build web --release`
Expected: Exit code 0 (`√ Built build\web`).

- [ ] **Step 3: Commit changes**
Commit with message: `feat(onboarding): eliminate splash race condition and add edit talangan account bottom sheet`

