import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier() : super(const UserProfile()) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    syncFromPrefs(prefs);
  }

  void syncFromPrefs(SharedPreferences prefs) {
    final name = prefs.getString('user_name') ?? '';
    final bankName = prefs.getString('user_bank') ?? 'BCA';
    final accountNumber = prefs.getString('user_account') ?? '';
    final walletName = prefs.getString('user_wallet_name') ?? 'GoPay';
    final walletNumber = prefs.getString('user_wallet_number') ?? '';
    final isOnboarded = prefs.getBool('user_onboarded') ?? false;

    state = UserProfile(
      name: name,
      bankName: bankName,
      accountNumber: accountNumber,
      walletName: walletName,
      walletNumber: walletNumber,
      isOnboarded: isOnboarded,
    );
  }

  Future<void> saveProfile({
    required String name,
    required String bankName,
    required String accountNumber,
    String walletName = 'GoPay',
    String walletNumber = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('user_bank', bankName);
    await prefs.setString('user_account', accountNumber);
    await prefs.setString('user_wallet_name', walletName);
    await prefs.setString('user_wallet_number', walletNumber);
    await prefs.setBool('user_onboarded', true);

    state = UserProfile(
      name: name,
      bankName: bankName,
      accountNumber: accountNumber,
      walletName: walletName,
      walletNumber: walletNumber,
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
