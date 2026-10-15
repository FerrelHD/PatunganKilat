import 'friend.dart';

class FriendItemShare {
  final String itemName;
  final double sharePrice;
  final bool isShared;
  final int sharedCount;

  const FriendItemShare({
    required this.itemName,
    required this.sharePrice,
    required this.isShared,
    required this.sharedCount,
  });
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
