# Apple-Style Dynamic Island Notification & PWA Top Blur Fix Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

This plan details the steps to:
1. Fix the frosted/blurry top status-bar band when the application is added to the iOS Home Screen (PWA Standalone).
2. Upgrade the `NeoToast` notification into a clean, Apple-authentic Dynamic Island capsule (pitch black, hairline glass border, clean icon accents, spring bounce animation).

---

## File Structure

- **Modify:** `web/index.html`
  - Add explicit `#F5F6F8` background CSS to `html` and `body` to eliminate compositing artifacts.
  - Refine iOS meta tags (`apple-mobile-web-app-status-bar-style`, `theme-color`) to ensure seamless top integration on iOS Safari.
- **Modify:** `lib/main.dart`
  - Set `SystemChrome.setSystemUIOverlayStyle` to enforce dark status bar icons (black time/battery) on the light `#F5F6F8` background.
- **Modify:** `lib/core/widgets/neo_toast.dart`
  - Redesign capsule: pure black `#000000`, remove colored neon border/glow, use subtle `0.8px` hairline white rim (`rgba(255,255,255,0.12)`).
  - Add spring/scale expansion animation (`Curves.easeOutBack` / `Curves.easeOutCubic`) mimicking Apple's Dynamic Island expand-and-collapse physics.
  - Clean Apple-accurate contextual colors (`#34C759` / `#C5F536` success, `#FF9F0A` warning, `#FF453A` error, `#0A84FF` info).
- **Modify / Verify:** `test/core/widgets/neo_toast_test.dart`
  - Update any icon or layout assertions if needed and ensure all 16 tests pass.

---

## Tasks

### Task 1: Fix Top Status Bar Blur on iOS PWA ("Add to Home Screen")

- [ ] **Step 1: Update `web/index.html` styling and meta tags**
  - Add CSS in `<head>`:
    ```html
    <style>
      html, body {
        background-color: #F5F6F8;
        margin: 0;
        padding: 0;
        width: 100%;
        height: 100%;
        overflow: hidden;
      }
    </style>
    ```
  - Refine `<meta name="theme-color" content="#F5F6F8">` and `<meta name="apple-mobile-web-app-status-bar-style" content="default">` so iOS Safari blends the status bar seamlessly with the app's `#F5F6F8` canvas.
- [ ] **Step 2: Add `SystemUiOverlayStyle` in `lib/main.dart`**
  - Call `SystemChrome.setSystemUIOverlayStyle` in `main()` with `statusBarColor: Colors.transparent`, `statusBarIconBrightness: Brightness.dark`, `statusBarBrightness: Brightness.light`.
- [ ] **Step 3: Verify web compilation**
  - Run `dart analyze` to ensure 0 errors.

### Task 2: Redesign `NeoToast` to Apple Dynamic Island Aesthetic

- [ ] **Step 1: Update `lib/core/widgets/neo_toast.dart` visual styling**
  - Container color: Pure pitch black (`#000000`) or ultra-dark glass.
  - Border: Subtle white hairline rim `Border.all(color: Colors.white.withValues(alpha: 0.12), width: 0.8)`.
  - Shadows: Clean deep ambient black shadow (`Colors.black.withValues(alpha: 0.35)`, blur 20px, offset `0, 8`) without colored neon glow.
  - Icon accent colors:
    - Success: `AppColors.neoLime` / `#34C759`
    - Warning: `#FF9F0A` (Apple Amber)
    - Error: `#FF453A` (Apple Coral Red)
    - Info: `#0A84FF` (Apple Blue)
  - Typography: `GoogleFonts.plusJakartaSans` `fontSize: 12.5`, `fontWeight: FontWeight.w600`, `letterSpacing: -0.2`.
- [ ] **Step 2: Implement Apple-like Spring Scale & Slide Animation**
  - Combine `SlideTransition` (slide down from island) and `ScaleTransition` (scale from `0.75` to `1.0` with `Curves.easeOutBack` or `Curves.easeOutCubic`).
  - Smooth collapse on dismiss (`Curves.easeInCubic`).
- [ ] **Step 3: Verify and update `test/core/widgets/neo_toast_test.dart`**
  - Run `flutter test test/core/widgets/neo_toast_test.dart` and confirm all toast tests pass.

### Task 3: Comprehensive Verification & Local Commit

- [ ] **Step 1: Run `dart analyze`**
  - Ensure 0 errors, 0 warnings.
- [ ] **Step 2: Run all Flutter tests (`flutter test`)**
  - Ensure all 16/16 tests pass.
- [ ] **Step 3: Run `flutter build web --release`**
  - Verify production web bundle builds cleanly.
- [ ] **Step 4: Commit locally**
  - Commit message: `feat(ui): refine apple-style dynamic island notifications and fix pwa top blur`
  - Per user constraint: Do NOT push to remote; provide git push command for user.

