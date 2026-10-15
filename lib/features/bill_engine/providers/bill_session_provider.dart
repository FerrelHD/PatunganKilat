import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/friend.dart';
import '../models/menu_item.dart';
import '../models/split_breakdown.dart';
import '../services/split_calculation_engine.dart';

class BillSessionState {
  final String sessionTitle;
  final List<Friend> friends;
  final List<MenuItem> items;
  final String activeFriendId;
  final bool taxEnabled;
  final bool serviceEnabled;
  final int discountAmount;
  final bool hideBalance;

  const BillSessionState({
    required this.sessionTitle,
    required this.friends,
    required this.items,
    required this.activeFriendId,
    this.taxEnabled = true,
    this.serviceEnabled = true,
    this.discountAmount = 30000,
    this.hideBalance = false,
  });

  BillSessionState copyWith({
    String? sessionTitle,
    List<Friend>? friends,
    List<MenuItem>? items,
    String? activeFriendId,
    bool? taxEnabled,
    bool? serviceEnabled,
    int? discountAmount,
    bool? hideBalance,
  }) {
    return BillSessionState(
      sessionTitle: sessionTitle ?? this.sessionTitle,
      friends: friends ?? this.friends,
      items: items ?? this.items,
      activeFriendId: activeFriendId ?? this.activeFriendId,
      taxEnabled: taxEnabled ?? this.taxEnabled,
      serviceEnabled: serviceEnabled ?? this.serviceEnabled,
      discountAmount: discountAmount ?? this.discountAmount,
      hideBalance: hideBalance ?? this.hideBalance,
    );
  }

  static BillSessionState initialDemo() {
    const friends = [
      Friend(id: 'raka', name: 'Raka', role: 'Talangan', theme: 'lime'),
      Friend(id: 'nadia', name: 'Nadia', role: 'Teman', theme: 'dark'),
      Friend(id: 'bima', name: 'Bima', role: 'Teman', theme: 'white'),
      Friend(id: 'sinta', name: 'Sinta', role: 'Teman', theme: 'white'),
    ];

    const items = [
      MenuItem(id: '1', name: 'Toripaitan Ramen Spesial', price: 88000, emoji: '🍜', assignedTo: ['raka']),
      MenuItem(id: '2', name: 'Spicy Miso Ramen', price: 82000, emoji: '🌶️', assignedTo: ['nadia']),
      MenuItem(id: '3', name: 'Shoyu Ramen Original', price: 74000, emoji: '🍥', assignedTo: ['bima']),
      MenuItem(id: '4', name: 'Chicken Karaage Sharing', price: 42000, emoji: '🍗', assignedTo: ['raka', 'nadia', 'bima', 'sinta']),
      MenuItem(id: '5', name: 'Cold Ocha Refill (4 Gelas)', price: 24000, emoji: '🍵', assignedTo: ['sinta']),
    ];

    return const BillSessionState(
      sessionTitle: 'Ramen Seirock-Ya',
      friends: friends,
      items: items,
      activeFriendId: 'raka',
      taxEnabled: true,
      serviceEnabled: true,
      discountAmount: 30000,
      hideBalance: false,
    );
  }
}

class BillSessionNotifier extends StateNotifier<BillSessionState> {
  BillSessionNotifier() : super(BillSessionState.initialDemo());

  static const List<int> discountOptions = [0, 30000, 50000];

  void selectActiveFriend(String friendId) {
    state = state.copyWith(activeFriendId: friendId);
  }

  void toggleItemAssignment(String itemId, String friendId) {
    final updatedItems = state.items.map((item) {
      if (item.id != itemId) return item;

      final assignees = List<String>.from(item.assignedTo);
      if (assignees.contains(friendId)) {
        assignees.remove(friendId);
      } else {
        assignees.add(friendId);
      }
      return item.copyWith(assignedTo: assignees);
    }).toList();

    state = state.copyWith(items: updatedItems);
  }

  void toggleTax() {
    state = state.copyWith(taxEnabled: !state.taxEnabled);
  }

  void toggleService() {
    state = state.copyWith(serviceEnabled: !state.serviceEnabled);
  }

  void cycleDiscount() {
    final currentIndex = discountOptions.indexOf(state.discountAmount);
    final nextIndex = (currentIndex + 1) % discountOptions.length;
    state = state.copyWith(discountAmount: discountOptions[nextIndex]);
  }

  void splitAllEqually() {
    final allFriendIds = state.friends.map((f) => f.id).toList();
    final updatedItems = state.items.map((item) {
      return item.copyWith(assignedTo: List<String>.from(allFriendIds));
    }).toList();

    state = state.copyWith(items: updatedItems);
  }

  void toggleHideBalance() {
    state = state.copyWith(hideBalance: !state.hideBalance);
  }

  void addNewMenuItem(String name, int price, String emoji) {
    final newItem = MenuItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      price: price,
      emoji: emoji,
      assignedTo: [state.activeFriendId],
    );

    state = state.copyWith(items: [newItem, ...state.items]);
  }

  void resetToDefaultDemo() {
    state = BillSessionState.initialDemo();
  }
}

final billSessionProvider = StateNotifierProvider<BillSessionNotifier, BillSessionState>((ref) {
  return BillSessionNotifier();
});

final splitCalculationProvider = Provider<SplitCalculationResult>((ref) {
  final session = ref.watch(billSessionProvider);
  return SplitCalculationEngine.calculate(
    friends: session.friends,
    items: session.items,
    taxEnabled: session.taxEnabled,
    serviceEnabled: session.serviceEnabled,
    discountAmount: session.discountAmount,
  );
});
