import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/friend.dart';
import '../models/menu_item.dart';
import '../models/split_breakdown.dart';
import '../services/split_calculation_engine.dart';

class BillSessionState {
  final bool hasActiveSession;
  final String sessionTitle;
  final List<Friend> friends;
  final List<MenuItem> items;
  final String activeFriendId;
  final bool taxEnabled;
  final bool serviceEnabled;
  final int discountAmount;
  final bool hideBalance;

  const BillSessionState({
    this.hasActiveSession = false,
    this.sessionTitle = '',
    this.friends = const [],
    this.items = const [],
    this.activeFriendId = '',
    this.taxEnabled = true,
    this.serviceEnabled = false,
    this.discountAmount = 0,
    this.hideBalance = false,
  });

  BillSessionState copyWith({
    bool? hasActiveSession,
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
      hasActiveSession: hasActiveSession ?? this.hasActiveSession,
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

  Map<String, dynamic> toJson() => {
    'hasActiveSession': hasActiveSession,
    'sessionTitle': sessionTitle,
    'friends': friends.map((f) => f.toJson()).toList(),
    'items': items.map((i) => i.toJson()).toList(),
    'activeFriendId': activeFriendId,
    'taxEnabled': taxEnabled,
    'serviceEnabled': serviceEnabled,
    'discountAmount': discountAmount,
    'hideBalance': hideBalance,
  };

  factory BillSessionState.fromJson(Map<String, dynamic> json) {
    return BillSessionState(
      hasActiveSession: (json['hasActiveSession'] as bool?) ?? false,
      sessionTitle: (json['sessionTitle'] as String?) ?? '',
      friends: ((json['friends'] as List<dynamic>?) ?? [])
          .map((f) => Friend.fromJson(f as Map<String, dynamic>))
          .toList(),
      items: ((json['items'] as List<dynamic>?) ?? [])
          .map((i) => MenuItem.fromJson(i as Map<String, dynamic>))
          .toList(),
      activeFriendId: (json['activeFriendId'] as String?) ?? '',
      taxEnabled: (json['taxEnabled'] as bool?) ?? true,
      serviceEnabled: (json['serviceEnabled'] as bool?) ?? false,
      discountAmount: (json['discountAmount'] as int?) ?? 0,
      hideBalance: (json['hideBalance'] as bool?) ?? false,
    );
  }

  static BillSessionState empty() {
    return const BillSessionState(
      hasActiveSession: false,
      sessionTitle: '',
      friends: [],
      items: [],
      activeFriendId: '',
      taxEnabled: true,
      serviceEnabled: false,
      discountAmount: 0,
      hideBalance: false,
    );
  }

  static BillSessionState demoPreset() {
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
      hasActiveSession: true,
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
  static const _storageKey = 'pk_active_bill_session';

  BillSessionNotifier() : super(BillSessionState.empty()) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        state = BillSessionState.fromJson(decoded);
      }
    } catch (_) {}
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (state.hasActiveSession) {
        await prefs.setString(_storageKey, jsonEncode(state.toJson()));
      } else {
        await prefs.remove(_storageKey);
      }
    } catch (_) {}
  }

  static const List<int> discountOptions = [0, 20000, 30000, 50000];

  void startNewSession({
    required String title,
    required String creatorName,
    required List<String> friendNames,
  }) {
    final creator = Friend(
      id: 'creator_${DateTime.now().millisecondsSinceEpoch}',
      name: creatorName.trim().isEmpty ? 'Saya' : creatorName.trim(),
      role: 'Talangan',
      theme: 'lime',
    );

    final friendsList = <Friend>[creator];
    for (var i = 0; i < friendNames.length; i++) {
      final name = friendNames[i].trim();
      if (name.isNotEmpty) {
        friendsList.add(
          Friend(
            id: 'friend_${DateTime.now().millisecondsSinceEpoch}_$i',
            name: name,
            role: 'Teman',
            theme: i == 0 ? 'dark' : 'white',
          ),
        );
      }
    }

    state = BillSessionState(
      hasActiveSession: true,
      sessionTitle: title.trim().isEmpty ? 'Patungan Baru' : title.trim(),
      friends: friendsList,
      items: const [],
      activeFriendId: creator.id,
      taxEnabled: true,
      serviceEnabled: false,
      discountAmount: 0,
      hideBalance: false,
    );
    _saveToStorage();
  }

  void selectActiveFriend(String friendId) {
    state = state.copyWith(activeFriendId: friendId);
    _saveToStorage();
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
    _saveToStorage();
  }

  void toggleTax() {
    state = state.copyWith(taxEnabled: !state.taxEnabled);
    _saveToStorage();
  }

  void toggleService() {
    state = state.copyWith(serviceEnabled: !state.serviceEnabled);
    _saveToStorage();
  }

  void cycleDiscount() {
    final currentIndex = discountOptions.indexOf(state.discountAmount);
    final nextIndex = (currentIndex + 1) % discountOptions.length;
    state = state.copyWith(discountAmount: discountOptions[nextIndex]);
    _saveToStorage();
  }

  void splitAllEqually() {
    final allFriendIds = state.friends.map((f) => f.id).toList();
    final updatedItems = state.items.map((item) {
      return item.copyWith(assignedTo: List<String>.from(allFriendIds));
    }).toList();

    state = state.copyWith(items: updatedItems);
    _saveToStorage();
  }

  void toggleHideBalance() {
    state = state.copyWith(hideBalance: !state.hideBalance);
    _saveToStorage();
  }

  void addNewMenuItem(String name, int price, String emoji, {int quantity = 1}) {
    final activeId = state.activeFriendId.isNotEmpty
        ? state.activeFriendId
        : (state.friends.isNotEmpty ? state.friends.first.id : '');

    final newItem = MenuItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      price: price,
      quantity: quantity < 1 ? 1 : quantity,
      emoji: emoji,
      assignedTo: activeId.isNotEmpty ? [activeId] : [],
    );

    state = state.copyWith(items: [newItem, ...state.items]);
    _saveToStorage();
  }

  void updateItemQuantity(String itemId, int delta) {
    final updatedItems = state.items.map((item) {
      if (item.id != itemId) return item;
      final newQty = item.quantity + delta;
      return newQty > 0 ? item.copyWith(quantity: newQty) : item;
    }).toList();

    state = state.copyWith(items: updatedItems);
    _saveToStorage();
  }

  void deleteMenuItem(String itemId) {
    final updatedItems = state.items.where((item) => item.id != itemId).toList();
    state = state.copyWith(items: updatedItems);
    _saveToStorage();
  }

  void batchAddItems(List<MenuItem> newItems) {
    state = state.copyWith(items: [...newItems, ...state.items]);
    _saveToStorage();
  }

  void loadDemoData() {
    state = BillSessionState.demoPreset();
    _saveToStorage();
  }

  void resetSession() {
    state = BillSessionState.empty();
    _saveToStorage();
  }

  void completeSession() {
    state = BillSessionState.empty();
    _saveToStorage();
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
