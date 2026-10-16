class UserProfile {
  final String name;
  final String bankName;
  final String accountNumber;
  final String walletName;
  final String walletNumber;
  final bool isOnboarded;

  const UserProfile({
    this.name = '',
    this.bankName = 'BCA',
    this.accountNumber = '',
    this.walletName = 'GoPay',
    this.walletNumber = '',
    this.isOnboarded = false,
  });

  bool get hasWallet => walletNumber.trim().isNotEmpty;

  UserProfile copyWith({
    String? name,
    String? bankName,
    String? accountNumber,
    String? walletName,
    String? walletNumber,
    bool? isOnboarded,
  }) {
    return UserProfile(
      name: name ?? this.name,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      walletName: walletName ?? this.walletName,
      walletNumber: walletNumber ?? this.walletNumber,
      isOnboarded: isOnboarded ?? this.isOnboarded,
    );
  }
}
