import 'dart:math';
import '../models/friend.dart';
import '../models/menu_item.dart';
import '../models/split_breakdown.dart';

/// Pure mathematical calculation engine for PatunganKilat.
/// Incorporates proportional PB1 tax, service charges, discounts, and
/// rounding reconciliation so that individual totals match the grand total 100%.
class SplitCalculationEngine {
  SplitCalculationEngine._();

  static SplitCalculationResult calculate({
    required List<Friend> friends,
    required List<MenuItem> items,
    required bool taxEnabled,
    required bool serviceEnabled,
    required int discountAmount,
    double taxPercent = 0.10,
    double servicePercent = 0.05,
  }) {
    final subtotalAll = items.fold<int>(0, (sum, item) => sum + item.totalPrice);
    final appliedTaxRate = taxEnabled ? taxPercent : 0.0;
    final appliedServiceRate = serviceEnabled ? servicePercent : 0.0;
    final totalTaxRate = appliedTaxRate + appliedServiceRate;

    final totalTaxService = subtotalAll * totalTaxRate;
    final totalDiscount = max(0, discountAmount);
    final grandTotal = max(0, (subtotalAll + totalTaxService - totalDiscount).round());

    // Compute raw subtotals and item shares per friend
    final friendSubtotals = <String, double>{for (final f in friends) f.id: 0.0};
    final friendItemShares = <String, List<FriendItemShare>>{for (final f in friends) f.id: []};

    for (final item in items) {
      final assignees = item.assignedTo;
      if (assignees.isEmpty) continue;

      final splitPrice = item.totalPrice / assignees.length;
      final isShared = assignees.length > 1;

      for (final friendId in assignees) {
        if (friendSubtotals.containsKey(friendId)) {
          friendSubtotals[friendId] = (friendSubtotals[friendId] ?? 0.0) + splitPrice;
          friendItemShares[friendId]?.add(
            FriendItemShare(
              itemName: item.quantity > 1 ? '${item.name} (${item.quantity}x)' : item.name,
              sharePrice: splitPrice,
              isShared: isShared,
              sharedCount: assignees.length,
            ),
          );
        }
      }
    }

    // Build raw breakdowns
    var runningFinalSum = 0;
    final tempBreakdowns = <_MutableFriendBreakdown>[];

    for (final friend in friends) {
      final sub = friendSubtotals[friend.id] ?? 0.0;
      final proportion = subtotalAll > 0 ? (sub / subtotalAll) : 0.0;
      final taxShare = totalTaxService * proportion;
      final discountShare = totalDiscount * proportion;
      final rawFinal = max(0.0, sub + taxShare - discountShare);
      final roundedFinal = rawFinal.round();

      runningFinalSum += roundedFinal;

      tempBreakdowns.add(
        _MutableFriendBreakdown(
          friend: friend,
          subtotal: sub,
          proportion: proportion,
          taxShare: taxShare,
          discountShare: discountShare,
          finalAmount: roundedFinal,
          items: friendItemShares[friend.id] ?? [],
        ),
      );
    }

    // Rounding reconciliation (The Penny / Rupiah Rounding Problem)
    // Settle difference on the payer (talangan) or the first friend
    final diff = grandTotal - runningFinalSum;
    if (diff != 0 && tempBreakdowns.isNotEmpty) {
      final payerIndex = tempBreakdowns.indexWhere((b) => b.friend.isPayer);
      final targetIndex = payerIndex != -1 ? payerIndex : 0;
      final current = tempBreakdowns[targetIndex].finalAmount;
      tempBreakdowns[targetIndex].finalAmount = max(0, current + diff);
    }

    final finalizedBreakdowns = tempBreakdowns.map((b) => b.toImmutable()).toList();

    return SplitCalculationResult(
      subtotalAll: subtotalAll,
      taxRate: appliedTaxRate,
      serviceRate: appliedServiceRate,
      totalTaxService: totalTaxService,
      totalDiscount: totalDiscount,
      grandTotal: grandTotal,
      breakdowns: finalizedBreakdowns,
    );
  }
}

class _MutableFriendBreakdown {
  final Friend friend;
  final double subtotal;
  final double proportion;
  final double taxShare;
  final double discountShare;
  int finalAmount;
  final List<FriendItemShare> items;

  _MutableFriendBreakdown({
    required this.friend,
    required this.subtotal,
    required this.proportion,
    required this.taxShare,
    required this.discountShare,
    required this.finalAmount,
    required this.items,
  });

  FriendBreakdown toImmutable() => FriendBreakdown(
    friend: friend,
    subtotal: subtotal,
    proportion: proportion,
    taxShare: taxShare,
    discountShare: discountShare,
    finalAmount: finalAmount,
    items: items,
  );
}
