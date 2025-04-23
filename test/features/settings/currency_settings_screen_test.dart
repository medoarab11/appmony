import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';

import 'package:appmony/features/settings/screens/currency_settings_screen.dart';
import 'package:appmony/services/analytics/analytics_service.dart';
import 'package:appmony/features/settings/providers/settings_provider.dart';
import 'package:appmony/models/currency/currency_model.dart';

// Mock classes
class MockAnalyticsService extends Mock implements AnalyticsService {
  @override
  Future<void> logScreenView({
    required String screenName,
    required String screenClass,
  }) async {}
}

class MockSettingsProvider extends Mock implements SettingsProvider {
  @override
  CurrencyModel get currency => CurrencyModel.usd;
  
  @override
  Future<void> setCurrency(CurrencyModel currency) async {}
}

void main() {
  group('CurrencySettingsScreen', () {
    late MockAnalyticsService mockAnalyticsService;
    late MockSettingsProvider mockSettingsProvider;
    
    setUp(() {
      mockAnalyticsService = MockAnalyticsService();
      mockSettingsProvider = MockSettingsProvider();
    });
    
    testWidgets('renders correctly with currency list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsProvider>.value(value: mockSettingsProvider),
            Provider<AnalyticsService>.value(value: mockAnalyticsService),
          ],
          child: const MaterialApp(
            home: CurrencySettingsScreen(),
          ),
        ),
      );
      
      // Wait for the future to complete
      await tester.pumpAndSettle();
      
      // Verify that the screen renders with the correct title
      expect(find.text('Currency'), findsOneWidget);
      
      // Verify that the search bar is displayed
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      
      // Verify that some common currencies are displayed
      expect(find.text('US Dollar'), findsAtLeastNWidgets(1));
      expect(find.text('Euro'), findsAtLeastNWidgets(1));
      expect(find.text('British Pound'), findsAtLeastNWidgets(1));
      
      // Verify that the current currency has a check mark
      final checkIcon = find.byIcon(Icons.check_circle);
      expect(checkIcon, findsOneWidget);
    });
    
    testWidgets('filters currencies when search text is entered', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsProvider>.value(value: mockSettingsProvider),
            Provider<AnalyticsService>.value(value: mockAnalyticsService),
          ],
          child: const MaterialApp(
            home: CurrencySettingsScreen(),
          ),
        ),
      );
      
      // Wait for the future to complete
      await tester.pumpAndSettle();
      
      // Find the search field
      final searchField = find.byType(TextField);
      
      // Enter search text
      await tester.enterText(searchField, 'euro');
      await tester.pumpAndSettle();
      
      // Verify that only Euro is displayed
      expect(find.text('Euro'), findsOneWidget);
      expect(find.text('US Dollar'), findsNothing);
    });
    
    testWidgets('changes currency when a currency is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsProvider>.value(value: mockSettingsProvider),
            Provider<AnalyticsService>.value(value: mockAnalyticsService),
          ],
          child: const MaterialApp(
            home: CurrencySettingsScreen(),
          ),
        ),
      );
      
      // Wait for the future to complete
      await tester.pumpAndSettle();
      
      // Find the Euro currency item
      final euroItem = find.text('Euro').first;
      
      // Tap the Euro currency item
      await tester.tap(euroItem);
      await tester.pumpAndSettle();
      
      // Verify that setCurrency was called
      verify(mockSettingsProvider.setCurrency(any)).called(1);
      
      // Verify that a snackbar is shown
      expect(find.text('Currency changed to EUR'), findsOneWidget);
    });
  });
}