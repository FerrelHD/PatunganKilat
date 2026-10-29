import 'friend.dart';

class FriendItemShare {
  final String itemName;
  final double sharePrice;
  final bool isShared;
  final int sharedCount;
  final int portion;
  final int totalPortions;

  const FriendItemShare({
    required this.itemName,
    required this.sharePrice,
    required this.isShared,
    required this.sharedCount,
    this.portion = 1,
    this.totalPortions = 1,
  });

  /// User-friendly label for display on receipts and messages.
  /// E.g. "2/3 porsi", "1/2", or empty if 100% individual.
  String get shareDetailLabel {
    if (!isShared) return '';
    if (portion == 1 && totalPortions == sharedCount) {
      return '1/$sharedCount';
    }
    return '$portion/$totalPortions porsi';
  }
}

class FriendBreakdown {
  final Friend friend;
  final double subtotal;
  final double proportion; // e.g. 0.35 (35%)
  final double taxShare;
  final double discountShare;
  final int finalAmount;
  final List<FriendItemShare> items;

  const FriendBreakdown({
    required this.friend,
    required this.subtotal,
    required this.proportion,
    required this.taxShare,
    required this.discountShare,
    required this.finalAmount,
    required this.items,
  });
}

class SplitCalculationResult {
  final int subtotalAll;
  final double taxRate;
  final double serviceRate;
  final double totalTaxService;
  final int totalDiscount;
  final int grandTotal;
  final List<FriendBreakdown> breakdowns;

  const SplitCalculationResult({
    required this.subtotalAll,
    required this.taxRate,
    required this.serviceRate,
    required this.totalTaxService,
    required this.totalDiscount,
    required this.grandTotal,
    required this.breakdowns,
  });
}
