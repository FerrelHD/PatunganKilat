import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patungankilat/core/utils/receipt_share_util.dart';
import 'package:patungankilat/features/bill_engine/models/friend.dart';
import 'package:patungankilat/features/bill_engine/models/menu_item.dart';
import 'package:patungankilat/features/bill_engine/models/split_breakdown.dart';
import 'package:patungankilat/features/bill_engine/providers/bill_session_provider.dart';
import 'package:patungankilat/features/home/widgets/account_carousel.dart';
import 'package:patungankilat/features/onboarding/models/user_profile.dart';
import 'package:patungankilat/features/onboarding/providers/user_profile_provider.dart';
import 'package:patungankilat/features/receipt/widgets/thermal_receipt_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UserProfile Model & Notifier Dual Account Tests', () {
    test('UserProfile defaults and hasWallet getter', () {
      const emptyProfile = UserProfile();
      expect(emptyProfile.hasWallet, isFalse);
      expect(emptyProfile.walletName, equals('GoPay'));
      expect(emptyProfile.walletNumber, isEmpty);

      final withWallet = emptyProfile.copyWith(
        walletName: 'OVO',
        walletNumber: '081298765432',
      );
      expect(withWallet.hasWallet, isTrue);
      expect(withWallet.walletName, equals('OVO'));
      expect(withWallet.walletNumber, equals('081298765432'));
    });

    test('UserProfileNotifier saves and syncs wallet from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = UserProfileNotifier();

      await notifier.saveProfile(
        name: 'Raka',
        bankName: 'BCA',
        accountNumber: '682044918821',
        walletName: 'Dana',
        walletNumber: '081234567890',
      );

      expect(notifier.state.name, equals('Raka'));
      expect(notifier.state.bankName, equals('BCA'));
      expect(notifier.state.accountNumber, equals('682044918821'));
      expect(notifier.state.walletName, equals('Dana'));
      expect(notifier.state.walletNumber, equals('081234567890'));
      expect(notifier.state.hasWallet, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('user_wallet_name'), equals('Dana'));
      expect(prefs.getString('user_wallet_number'), equals('081234567890'));

      // New notifier instance syncs persisted values
      final freshNotifier = UserProfileNotifier();
      freshNotifier.syncFromPrefs(prefs);
      expect(freshNotifier.state.hasWallet, isTrue);
      expect(freshNotifier.state.walletName, equals('Dana'));
      expect(freshNotifier.state.walletNumber, equals('081234567890'));
    });
  });

  group('ReceiptShareUtil WhatsApp Summary with E-Wallet', () {
    final session = BillSessionState(
      sessionTitle: 'Kopi Kenangan',
      friends: const [
        Friend(id: '1', name: 'Raka', role: 'Talangan'),
        Friend(id: '2', name: 'Budi', role: 'Teman'),
      ],
      items: const [
        MenuItem(id: 'i1', name: 'Kopi Susu', price: 20000, assignedTo: ['1']),
        MenuItem(id: 'i2', name: 'Americano', price: 20000, assignedTo: ['2']),
      ],
    );

    final calc = const SplitCalculationResult(
      subtotalAll: 40000,
      totalTaxService: 4000,
      totalDiscount: 0,
      grandTotal: 44000,
      taxRate: 0.1,
      serviceRate: 0.0,
      breakdowns: [
        FriendBreakdown(
          friend: Friend(id: '1', name: 'Raka', role: 'Talangan'),
          subtotal: 20000,
          taxShare: 2000,
          discountShare: 0,
          finalAmount: 22000,
          proportion: 0.5,
          items: [FriendItemShare(itemName: 'Kopi Susu', sharePrice: 20000, isShared: false, sharedCount: 1)],
        ),
        FriendBreakdown(
          friend: Friend(id: '2', name: 'Budi', role: 'Teman'),
          subtotal: 20000,
          taxShare: 2000,
          discountShare: 0,
          finalAmount: 22000,
          proportion: 0.5,
          items: [FriendItemShare(itemName: 'Americano', sharePrice: 20000, isShared: false, sharedCount: 1)],
        ),
      ],
    );

    test('Includes E-Wallet line when walletNumber is provided', () {
      final summaryWithWallet = ReceiptShareUtil.formatWhatsAppSummary(
        session: session,
        calc: calc,
        bankName: 'BCA',
        accountNumber: '682044918821',
        accountHolder: 'Raka',
        walletName: 'GoPay',
        walletNumber: '081234567890',
      );

      expect(summaryWithWallet, contains('Transfer BCA: *682044918821* a.n Raka'));
      expect(summaryWithWallet, contains('Atau GoPay: *081234567890* a.n Raka'));
    });

    test('Excludes E-Wallet line when walletNumber is empty', () {
      final summaryWithoutWallet = ReceiptShareUtil.formatWhatsAppSummary(
        session: session,
        calc: calc,
        bankName: 'BCA',
        accountNumber: '682044918821',
        accountHolder: 'Raka',
        walletName: 'GoPay',
        walletNumber: '',
      );

      expect(summaryWithoutWallet, contains('Transfer BCA: *682044918821* a.n Raka'));
      expect(summaryWithoutWallet, isNot(contains('Atau GoPay')));
    });
  });

  group('UI Rendering: AccountCarousel and ThermalReceiptCard', () {
    testWidgets('AccountCarousel displays placeholder when no wallet', (tester) async {
      SharedPreferences.setMockInitialValues({
        'user_name': 'Raka',
        'user_bank': 'BCA',
        'user_account': '682044918821',
        'user_wallet_name': 'GoPay',
        'user_wallet_number': '',
        'user_onboarded': true,
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: AccountCarousel()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Placeholder is shown
      expect(find.text('+ E-Wallet'), findsOneWidget);
      expect(find.text('GoPay / OVO / Dana'), findsOneWidget);
    });

    testWidgets('AccountCarousel displays configured wallet and formatted phone', (tester) async {
      SharedPreferences.setMockInitialValues({
        'user_name': 'Raka',
        'user_bank': 'BCA',
        'user_account': '682044918821',
        'user_wallet_name': 'OVO',
        'user_wallet_number': '081234567890',
        'user_onboarded': true,
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: AccountCarousel()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('OVO'), findsOneWidget);
      expect(find.text('0812 •••• 7890'), findsOneWidget);
    });

    testWidgets('ThermalReceiptCard displays Bank and optional E-Wallet box', (tester) async {
      const session = BillSessionState(
        sessionTitle: 'Dinner',
        friends: [Friend(id: '1', name: 'Raka', role: 'Talangan')],
        items: [MenuItem(id: 'i1', name: 'Steak', price: 100000, assignedTo: ['1'])],
      );

      const calc = SplitCalculationResult(
        subtotalAll: 100000,
        totalTaxService: 1000,
        totalDiscount: 0,
        grandTotal: 101000,
        taxRate: 0.01,
        serviceRate: 0.0,
        breakdowns: [
          FriendBreakdown(
            friend: Friend(id: '1', name: 'Raka', role: 'Talangan'),
            subtotal: 100000,
            taxShare: 1000,
            discountShare: 0,
            finalAmount: 101000,
            proportion: 1.0,
            items: [FriendItemShare(itemName: 'Steak', sharePrice: 100000, isShared: false, sharedCount: 1)],
          ),
        ],
      );

      SharedPreferences.setMockInitialValues({
        'user_name': 'Raka',
        'user_bank': 'Mandiri',
        'user_account': '140001234567',
        'user_wallet_name': 'Dana',
        'user_wallet_number': '08987654321',
        'user_onboarded': true,
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ThermalReceiptCard(session: session, calc: calc),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('TRANSFER KE MANDIRI'), findsOneWidget);
      expect(find.text('140001234567'), findsOneWidget);

      expect(find.text('OPSI E-WALLET: DANA'), findsOneWidget);
      expect(find.text('08987654321'), findsOneWidget);
    });
  });
}
