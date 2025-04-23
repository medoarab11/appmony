import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';

import 'package:appmony/features/reports/screens/reports_screen.dart';
import 'package:appmony/services/database/database_service.dart';
import 'package:appmony/services/admob/admob_service.dart';
import 'package:appmony/services/analytics/analytics_service.dart';
import 'package:appmony/services/subscription/subscription_service.dart';
import 'package:appmony/features/settings/providers/settings_provider.dart';
import 'package:appmony/features/auth/providers/auth_provider.dart';
import 'package:appmony/models/transaction/transaction_model.dart';

// Mock classes
class MockDatabaseService extends Mock implements DatabaseService {
  @override
  Future<List<TransactionModel>> getTransactionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? walletId,
    String? categoryId,
    String? type,
  }) async {
    return [];
  }
}

class MockAdMobService extends Mock implements AdMobService {
  @override
  Widget getBannerAd() {
    return Container(height: 50, color: Colors.grey[200]);
  }
}

class MockAnalyticsService extends Mock implements AnalyticsService {
  @override
  Future<void> logScreenView({
    required String screenName,
    required String screenClass,
  }) async {}
}

class MockSubscriptionService extends Mock implements SubscriptionService {
  @override
  bool get isPremium => false;
}

class MockSettingsProvider extends Mock implements SettingsProvider {
  @override
  String formatAmount(double amount, {bool showSymbol = true}) {
    return '\$${amount.toStringAsFixed(2)}';
  }
}

class MockAuthProvider extends Mock implements AuthProvider {
  @override
  bool get isAuthenticated => true;
}

void main() {
  group('ReportsScreen', () {
    late MockDatabaseService mockDatabaseService;
    late MockAdMobService mockAdMobService;
    late MockAnalyticsService mockAnalyticsService;
    late MockSubscriptionService mockSubscriptionService;
    late MockSettingsProvider mockSettingsProvider;
    late MockAuthProvider mockAuthProvider;

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      mockAdMobService = MockAdMobService();
      mockAnalyticsService = MockAnalyticsService();
      mockSubscriptionService = MockSubscriptionService();
      mockSettingsProvider = MockSettingsProvider();
      mockAuthProvider = MockAuthProvider();
    });

    testWidgets('renders correctly with no transactions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsProvider>.value(value: mockSettingsProvider),
            ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
            Provider<DatabaseService>.value(value: mockDatabaseService),
            Provider<AdMobService>.value(value: mockAdMobService),
            Provider<AnalyticsService>.value(value: mockAnalyticsService),
            Provider<SubscriptionService>.value(value: mockSubscriptionService),
          ],
          child: const MaterialApp(
            home: ReportsScreen(),
          ),
        ),
      );

      // Wait for the future to complete
      await tester.pumpAndSettle();

      // Verify that the screen renders with the correct title
      expect(find.text('Reports & Analytics'), findsOneWidget);

      // Verify that the filter options are displayed
      expect(find.text('Week'), findsOneWidget);
      expect(find.text('Month'), findsOneWidget);
      expect(find.text('Quarter'), findsOneWidget);
      expect(find.text('Year'), findsOneWidget);
      expect(find.text('Custom'), findsOneWidget);

      // Verify that the empty state message is displayed
      expect(find.text('No transactions found'), findsOneWidget);
      expect(find.text('Add some transactions to see your reports'), findsOneWidget);
    });
  });
}