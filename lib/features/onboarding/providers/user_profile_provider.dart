import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier() : super(const UserProfile()) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? '';
    final bankName = prefs.getString('user_bank') ?? 'BCA';
    final accountNumber = prefs.getString('user_account') ?? '';
    final isOnboarded = prefs.getBool('user_onboarded') ?? false;

    state = UserProfile(
      name: name,
      bankName: bankName,
      accountNumber: accountNumber,
      isOnboarded: isOnboarded,
    );
  }

  void syncFromPrefs(SharedPreferences prefs) {
    final name = prefs.getString('user_name') ?? '';
    final bankName = prefs.getString('user_bank') ?? 'BCA';
    final accountNumber = prefs.getString('user_account') ?? '';
    final isOnboarded = prefs.getBool('user_onboarded') ?? false;

    state = UserProfile(
      name: name,
      bankName: bankName,
      accountNumber: accountNumber,
      isOnboarded: isOnboarded,
    );
  }

  Future<void> saveProfile({
    required String name,
    required String bankName,
    required String accountNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('user_bank', bankName);
    await prefs.setString('user_account', accountNumber);
    await prefs.setBool('user_onboarded', true);

    state = UserProfile(
      name: name,
      bankName: bankName,
      accountNumber: accountNumber,
      isOnboarded: true,
    );
  }

  Future<void> resetProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    state = const UserProfile();
  }
}

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  return UserProfileNotifier();
});
