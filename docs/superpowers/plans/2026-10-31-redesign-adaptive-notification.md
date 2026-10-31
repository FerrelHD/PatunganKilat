# Redesign Adaptive Notification (Anti-Slop) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign the notification system (`NeoToast`) into an Adaptive Dynamic Island component that eliminates AI slop (swollen pill capsules, generic `⚡` spam, rambling error messages) and provides crisp, two-tiered feedback (Compact Pill vs. Expanded Card) with clear, human microcopy.

**Architecture:** 
- The toast widget inspects whether a `title` is provided or if the content exceeds a single brief confirmation.
- **Compact Tier**: A sleek single-line pill (`borderRadius: 999`) for micro-actions (copy, toggle, delete).
- **Expanded Tier**: A structured squircle card (`borderRadius: 18`) with bold title + concise instructional remedy for errors, warnings, and multi-line guidance.
- Microcopy across all call sites is cleaned up to remove emoji/lightning spam and provide clear, reassuring feedback.

**Tech Stack:** Flutter 3.x, Dart 3.x, Google Fonts (Plus Jakarta Sans), Riverpod.

---

## Global Constraints
- Preserve PatunganKilat Neobank aesthetic: midnight black `#000000`/`#0D0E11`, subtle glass border `0.8px` white alpha 0.12, Neobank Lime `#C5F536` for success, Apple Amber `#FF9F0A` for warning, Apple Red `#FF453A` for error.
- Zero AI slop: Remove generic lightning bolts (`⚡`) and excessive exclamation marks (`!`) from toast messages.
- Backward compatibility: Existing `NeoToast.show(context, message)` calls work seamlessly, with an optional `title` parameter for structured alerts.

---

## Tasks

### Task 1: Redesign `NeoToast` Component to Support Adaptive Tiers

**Files:**
- Modify: `lib/core/widgets/neo_toast.dart`
- Test: `test/core/widgets/neo_toast_test.dart`

- [ ] **Step 1: Write widget tests for Compact and Expanded modes**
  - Add test: `NeoToast renders compact pill for brief messages without title`
  - Add test: `NeoToast renders expanded card with title and message when title is provided`
  - Add test: `NeoToast uses semantic icons without generic lightning slop`

- [ ] **Step 2: Run test to observe failure**
  ```powershell
  E:\flutter\bin\flutter.bat test test/core/widgets/neo_toast_test.dart
  ```

- [ ] **Step 3: Implement Adaptive Dynamic Island in `neo_toast.dart`**
  - Add optional `String? title` parameter to `NeoToast.show`.
  - Check whether `title != null` or `message.length > 50` to determine `isExpanded`.
  - In Compact Mode:
    - Shape: `BorderRadius.circular(999)`, slim padding (`h: 14, v: 8`).
    - Semantic icon: Checkmark (`Icons.check_rounded`), copy, etc., with subtle tinted background circle.
    - Typography: 1-line `Plus Jakarta Sans`, 12px, font weight 700.
  - In Expanded Mode:
    - Shape: `BorderRadius.circular(18)`, structured padding (`h: 16, v: 12`).
    - Status icon in rounded container at top-left.
    - Column with Title (`fontWeight: 800`, 13px) and Body (`fontWeight: 500`, 11.5px, subtle contrast).
  - Smooth spring animation physics and swipe-up to dismiss.

- [ ] **Step 4: Run tests and verify they pass**
  ```powershell
  E:\flutter\bin\flutter.bat test test/core/widgets/neo_toast_test.dart
  ```

---

### Task 2: Refactor Toast Call Sites & Microcopy (Anti-Slop Clean-up)

**Files:**
- Modify: `lib/core/widgets/neo_dark_card.dart`
- Modify: `lib/core/widgets/neo_lime_card.dart`
- Modify: `lib/features/receipt/screens/receipt_screen.dart`
- Modify: `lib/features/receipt/widgets/thermal_receipt_card.dart`
- Modify: `lib/features/split_arena/screens/split_arena_screen.dart`
- Modify: `lib/features/split_arena/widgets/receipt_scan_bottom_sheet.dart`
- Modify: `lib/features/split_arena/widgets/add_menu_bottom_sheet.dart`
- Modify: `lib/features/home/screens/home_screen.dart`
- Modify: `lib/features/home/widgets/edit_account_bottom_sheet.dart`
- Modify: `lib/features/friends/screens/friends_screen.dart`

- [ ] **Step 1: Clean copy in core cards & receipt sharing**
  - Change `"Nomor rekening $bankName ($rawAccountNumber) disalin! ⚡"` -> `"No. Rekening $bankName disalin"`.
  - Change `"Nomor $walletName ($textToCopy) disalin! ⚡"` -> `"No. E-Wallet $walletName disalin"`.
  - Change `"Rincian tersalin! Buka WhatsApp untuk mengirim. ⚡"` -> `"Rincian patungan disalin untuk WhatsApp"`.
  - Change `"Sesi patungan selesai! Meja patungan sudah bersih ✨"` -> `"Sesi patungan selesai"`.

- [ ] **Step 2: Clean copy & add titles in Split Arena & Scanner**
  - In `receipt_scan_bottom_sheet.dart`:
    - OCR error: use `title: 'Struk Tidak Terbaca'`, `message: 'Foto buram atau kurang terang. Coba gunakan foto yang lebih jelas atau tempel teks.'`.
    - OCR empty: use `title: 'Menu Tidak Terdeteksi'`, `message: 'Pastikan nama makanan dan harga terlihat jelas pada struk.'`.
    - Format teks tidak dikenal: use `title: 'Format Teks Kurang Pas'`, `message: 'Gunakan format contoh: 2x Nasi Goreng 50.000'`.
    - Success import: `"N menu dari struk berhasil diimpor"`.
  - In `split_arena_screen.dart`:
    - Menu added: `'"$name" ditambahkan'`.
    - Split equally: `'Tagihan dibagi rata ke semua teman'`.
    - Item deleted: `'"$name" dihapus dari tagihan'`.
    - Porsi diatur: `'Porsi "$name" diperbarui'`.

---

### Task 3: Quality Verification & Delivery Gate

- [ ] **Step 1: Run static analysis**
  ```powershell
  E:\flutter\bin\dart.bat analyze
  ```
  *Expected result:* 0 issues found.

- [ ] **Step 2: Run full unit & widget test suite**
  ```powershell
  E:\flutter\bin\flutter.bat test
  ```
  *Expected result:* All 27+ tests pass.

- [ ] **Step 3: Run web production build**
  ```powershell
  E:\flutter\bin\flutter.bat build web --release
  ```
  *Expected result:* Successful build without warnings or runtime errors.

- [ ] **Step 4: Commit and push**
  - Commit message: `feat(ui): redesign adaptive toast notification and clean microcopy`
  - Push to `origin main`.

