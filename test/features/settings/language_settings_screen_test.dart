import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';

import 'package:appmony/features/settings/screens/language_settings_screen.dart';
import 'package:appmony/services/analytics/analytics_service.dart';
import 'package:appmony/services/localization/localization_service.dart';
import 'package:appmony/features/settings/providers/settings_provider.dart';
import 'package:appmony/models/language/language_model.dart';

// Mock classes
class MockAnalyticsService extends Mock implements AnalyticsService {
  @override
  Future<void> logScreenView({
    required String screenName,
    required String screenClass,
  }) async {}
}

class MockLocalizationService extends Mock implements LocalizationService {
  @override
  List<LanguageModel> get supportedLanguages => LanguageModel.supportedLanguages;
}

class MockSettingsProvider extends Mock implements SettingsProvider {
  @override
  LanguageModel get language => const LanguageModel(
    code: 'en',
    name: 'English',
    nativeName: 'English',
    flagAsset: 'assets/flags/us.png',
  );
  
  @override
  Future<void> setLanguage(LanguageModel language) async {}
}

void main() {
  group('LanguageSettingsScreen', () {
    late MockAnalyticsService mockAnalyticsService;
    late MockLocalizationService mockLocalizationService;
    late MockSettingsProvider mockSettingsProvider;
    
    setUp(() {
      mockAnalyticsService = MockAnalyticsService();
      mockLocalizationService = MockLocalizationService();
      mockSettingsProvider = MockSettingsProvider();
    });
    
    testWidgets('renders correctly with language list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsProvider>.value(value: mockSettingsProvider),
            Provider<AnalyticsService>.value(value: mockAnalyticsService),
            Provider<LocalizationService>.value(value: mockLocalizationService),
          ],
          child: const MaterialApp(
            home: LanguageSettingsScreen(),
          ),
        ),
      );
      
      // Wait for the future to complete
      await tester.pumpAndSettle();
      
      // Verify that the screen renders with the correct title
      expect(find.text('Language'), findsOneWidget);
      
      // Verify that the language list is displayed
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Spanish'), findsOneWidget);
      expect(find.text('French'), findsOneWidget);
      expect(find.text('German'), findsOneWidget);
      
      // Verify that the current language has a check mark
      final checkIcon = find.byIcon(Icons.check_circle);
      expect(checkIcon, findsOneWidget);
    });
    
    testWidgets('changes language when a language is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsProvider>.value(value: mockSettingsProvider),
            Provider<AnalyticsService>.value(value: mockAnalyticsService),
            Provider<LocalizationService>.value(value: mockLocalizationService),
          ],
          child: const MaterialApp(
            home: LanguageSettingsScreen(),
          ),
        ),
      );
      
      // Wait for the future to complete
      await tester.pumpAndSettle();
      
      // Find the Spanish language item
      final spanishItem = find.text('Spanish');
      
      // Tap the Spanish language item
      await tester.tap(spanishItem);
      await tester.pumpAndSettle();
      
      // Verify that setLanguage was called with Spanish
      verify(mockSettingsProvider.setLanguage(any)).called(1);
      
      // Verify that a snackbar is shown
      expect(find.text('Language changed to Spanish'), findsOneWidget);
    });
  });
}