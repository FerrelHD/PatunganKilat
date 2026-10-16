# Top Floating Toast Notifications Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

Build a modern, Dynamic Island style top-floating notification system (`NeoToast`) for PatunganKilat, replacing all standard bottom `SnackBar` calls with contextual (Success, Warning, Error, Info) dark capsule pills that slide down from the top edge.

---

## File Structure

- **Create:** `lib/core/widgets/neo_toast.dart`
  - Defines `NeoToastType` (`success`, `warning`, `error`, `info`).
  - Defines `NeoToast` utility with `show(context, message, {NeoToastType type, Duration duration})`.
  - Defines `_NeoToastWidget` with slide-down/fade-in animation, gesture dismissal, and Neobank styling.
- **Create:** `test/core/widgets/neo_toast_test.dart`
  - Unit & widget tests verifying overlay insertion, appearance, contextual types, dismiss on tap, and timeout.
- **Modify:** All screens and widgets replacing `ScaffoldMessenger.of(context).showSnackBar(...)` with `NeoToast.show(context, ...)`:
  - `lib/core/widgets/neo_dark_card.dart`
  - `lib/core/widgets/neo_lime_card.dart`
  - `lib/features/friends/screens/friends_screen.dart`
  - `lib/features/home/screens/home_screen.dart`
  - `lib/features/home/widgets/create_session_bottom_sheet.dart`
  - `lib/features/home/widgets/edit_account_bottom_sheet.dart`
  - `lib/features/onboarding/screens/onboarding_screen.dart`
  - `lib/features/receipt/screens/receipt_screen.dart`
  - `lib/features/receipt/widgets/thermal_receipt_card.dart`
  - `lib/features/split_arena/screens/split_arena_screen.dart`
  - `lib/features/split_arena/widgets/add_menu_bottom_sheet.dart`

---

## Tasks

### Task 1: Create `NeoToast` Component & Unit/Widget Tests

- [ ] **Step 1: Write widget test for `NeoToast`**
  - Path: `test/core/widgets/neo_toast_test.dart`
  - Test showing a toast on tap, verifying text and icon rendered in the overlay.
  - Test contextual colors and icons for `success`, `warning`, `error`, `info`.
  - Test dismiss on tap or timer expiration.
- [ ] **Step 2: Implement `NeoToast` in `lib/core/widgets/neo_toast.dart`**
  - Implement `OverlayEntry` manager to ensure single active toast.
  - Implement animated pill container with `Curves.easeOutCubic` slide & fade.
  - Implement contextual colors matching Neobank theme (`neoLime` for success, `#FFB800` for warning, `#FF5252` for error, `#5AC8FA` for info).
- [ ] **Step 3: Run tests to verify `NeoToast` passes**
  - Run `E:\flutter\bin\flutter.bat test test/core/widgets/neo_toast_test.dart`.

### Task 2: Replace Bottom SnackBars in Account & Receipt Widgets

- [ ] **Step 1: Update `neo_lime_card.dart` & `neo_dark_card.dart`**
  - Replace `ScaffoldMessenger.of(context).showSnackBar` with `NeoToast.show(context, ..., type: NeoToastType.success)`.
- [ ] **Step 2: Update `thermal_receipt_card.dart` & `receipt_screen.dart`**
  - Replace copy number and save image snackbars with `NeoToast.show`.
- [ ] **Step 3: Update `edit_account_bottom_sheet.dart` & `onboarding_screen.dart`**
  - Use `NeoToastType.warning` for empty name validation.
  - Use `NeoToastType.success` for save confirmations.

### Task 3: Replace Bottom SnackBars in Split Arena, Friends & Home Screens

- [ ] **Step 1: Update `split_arena_screen.dart` & `add_menu_bottom_sheet.dart`**
  - Replace menu validation warnings and action snackbars with `NeoToast`.
- [ ] **Step 2: Update `friends_screen.dart` & `create_session_bottom_sheet.dart` & `home_screen.dart`**
  - Replace friend added/deleted snackbars and session validation with `NeoToast`.

### Task 4: Full Verification & Local Commit

- [ ] **Step 1: Run `E:\flutter\bin\dart.bat analyze`**
  - Ensure 0 errors, 0 warnings.
- [ ] **Step 2: Run `E:\flutter\bin\flutter.bat test`**
  - Ensure all tests pass.
- [ ] **Step 3: Run `E:\flutter\bin\flutter.bat build web --release`**
  - Verify web bundle compiles successfully.
- [ ] **Step 4: Commit locally**
  - Commit message: `feat(ui): replace bottom snackbars with dynamic island top floating neo toast`
  - Do NOT push to remote (per user constraint: user pushes manually).

