import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedFriend {
  final String id;
  final String name;
  final String group;

  const SavedFriend({
    required this.id,
    required this.name,
    this.group = 'Teman',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'group': group,
  };

  factory SavedFriend.fromJson(Map<String, dynamic> json) => SavedFriend(
    id: json['id'] as String,
    name: json['name'] as String,
    group: (json['group'] as String?) ?? 'Teman',
  );
}

class SavedFriendsNotifier extends StateNotifier<List<SavedFriend>> {
  static const _key = 'pk_saved_friends';

  static const List<SavedFriend> _defaultFriends = [
    SavedFriend(id: '1', name: 'Raka', group: 'Tongkrongan Kampus'),
    SavedFriend(id: '2', name: 'Nadia', group: 'Tongkrongan Kampus'),
    SavedFriend(id: '3', name: 'Bima', group: 'Futsal Jumat'),
    SavedFriend(id: '4', name: 'Sinta', group: 'Tim Kantor'),
    SavedFriend(id: '5', name: 'Dion', group: 'Futsal Jumat'),
    SavedFriend(id: '6', name: 'Alya', group: 'Tim Kantor'),
  ];

  SavedFriendsNotifier() : super(_defaultFriends) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> list = jsonDecode(raw);
        state = list.map((e) => SavedFriend.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(state.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }

  void addFriend(String name, {String group = 'Tongkrongan Kampus'}) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final newFriend = SavedFriend(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: trimmed,
      group: group,
    );
    state = [...state, newFriend];
    _saveToStorage();
  }

  void removeFriend(String id) {
    state = state.where((f) => f.id != id).toList();
    _saveToStorage();
  }
}

final savedFriendsProvider = StateNotifierProvider<SavedFriendsNotifier, List<SavedFriend>>((ref) {
  return SavedFriendsNotifier();
});
