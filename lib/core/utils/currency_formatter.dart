import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _rpFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  /// Format as full Rupiah, e.g., "Rp 331.650"
  static String formatRp(num amount) {
    return _rpFormat.format(amount.round()).trim();
  }

  /// Format as compact Rupiah, e.g., "Rp 86rb" or "Rp 1.2jt"
  static String formatShortRp(num amount) {
    final rounded = amount.round();
    if (rounded >= 1000000) {
      final jt = (rounded / 1000000).toStringAsFixed(1).replaceAll('.0', '');
      return 'Rp ${jt}jt';
    } else if (rounded >= 1000) {
      final rb = (rounded / 1000).round();
      return 'Rp ${rb}rb';
    }
    return 'Rp $rounded';
  }
}
