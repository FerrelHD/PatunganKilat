class UserProfile {
  final String name;
  final String bankName;
  final String accountNumber;
  final bool isOnboarded;

  const UserProfile({
    this.name = '',
    this.bankName = 'BCA',
    this.accountNumber = '',
    this.isOnboarded = false,
  });

  UserProfile copyWith({
    String? name,
    String? bankName,
    String? accountNumber,
    bool? isOnboarded,
  }) {
    return UserProfile(
      name: name ?? this.name,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      isOnboarded: isOnboarded ?? this.isOnboarded,
    );
  }
}
