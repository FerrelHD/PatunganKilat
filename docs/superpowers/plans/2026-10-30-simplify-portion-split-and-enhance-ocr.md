# Implementation Plan: Simplify Portion Split UX & Enhance Receipt OCR Accuracy

**Status:** Ready to execute  
**Goal:**  
1. Redesign `ItemPortionSplitBottomSheet` to provide a friction-free, intuitive portion splitting experience (tap friend card to toggle participation, inline stepper for custom portions, clean live summary).
2. Enhance `ReceiptOcrService` with OCR.space `OCREngine=2`, multi-line receipt parsing (item name on line 1, qty/price on line 2), and Indonesian receipt heuristics.
3. Enhance `ReceiptScanBottomSheet` with an intuitive review & quick edit UI (stepper, quick name/price edit, item deletion, and manual add item before importing).
4. Verify with comprehensive unit/widget tests and Flutter release build, then commit and push.

---

## Proposed Changes

### 1. Split Arena: Portion Split UX Redesign
- File: `lib/features/split_arena/widgets/item_portion_split_bottom_sheet.dart`
- Updates:
  - Simplify header and live summary calculation.
  - Replace complex warning states with a clean, dynamic status pill:
    - Equal split: `"Bagi rata ke N orang — Rp X / orang"`
    - Custom ratio: `"Total P porsi — dihitung proporsional"`
  - Tappable friend list items:
    - Clicking the friend row toggles their participation directly.
    - When active, shows clean avatar, name, proportional share cost (`Rp X`), and a tactile inline stepper `[-] portion [+]`.
    - Stepper decrementing from 1 removes the friend from the item.
  - Clean bottom bar with single primary action: `"Simpan Pembagian Porsi ⚡"`.
- Unit/Widget Tests:
  - Update `test/features/split_arena/item_portion_split_bottom_sheet_test.dart` to cover tap-to-toggle, stepper increments/decrements, and portion saving.

---

### 2. OCR Engine & Multi-Line Parsing Algorithm
- File: `lib/features/split_arena/services/receipt_ocr_service.dart`
- Updates:
  - In `extractFromImageBytes`: Add `OCREngine: '2'` parameter to OCR.space API request for superior numeric and tabular extraction.
  - In `parseReceiptText`:
    - Add multi-line lookahead: detect food name on line $i$ followed by quantity/price specification on line $i+1$ (e.g., `Ayam Bakar Madu\n2 x 25.000 50.000`).
    - Robust price parsing: handle both Indonesian dot `.` and comma `,` thousand separators, strip currency markers (`Rp`, `IDR`).
    - Expand Indonesian receipt metadata regexes (`PB1`, `PPN`, `Service Charge`, `Diskon Promo`, `Subtotal`, `Total Bayar`).
- Unit Tests:
  - Update `test/features/split_arena/receipt_parser_test.dart` with tests for:
    - Standard single-line receipts
    - Multi-line receipts (name line + qty/price line)
    - Mixed formats and Indonesian restaurant receipts (Mie Gacoan, Solaria, etc.)

---

### 3. Receipt Scan Sheet: Review & Quick Edit UI
- File: `lib/features/split_arena/widgets/receipt_scan_bottom_sheet.dart`
- Updates:
  - Provide inline/dialog quick editing of parsed item names and unit prices.
  - Add "+ Tambah Menu" quick entry button if the receipt missed an item.
  - Display detected Tax & Service indicators with clear feedback.
  - Maintain the existing image picker and paste text options.

---

## Verification Plan
1. **Unit & Widget Tests:**
   - Run `dart test test/features/split_arena/receipt_parser_test.dart`
   - Run `flutter test test/features/split_arena/item_portion_split_bottom_sheet_test.dart`
   - Run full test suite: `flutter test`
2. **Static Analysis:**
   - Run `dart analyze` (0 errors, 0 warnings).
3. **Web Build:**
   - Run `flutter build web --release`
4. **Git:**
   - Commit with clean message: `feat(split_arena): simplify portion split UX and enhance receipt OCR accuracy`
   - Push to `origin main`

