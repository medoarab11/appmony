import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:appmony/features/settings/screens/settings_screen.dart';
import 'package:appmony/services/analytics/analytics_service.dart';
import 'package:appmony/services/subscription/subscription_service.dart';
import 'package:appmony/features/settings/providers/settings_provider.dart';
import 'package:appmony/features/auth/providers/auth_provider.dart';
import 'package:appmony/models/language/language_model.dart';
import 'package:appmony/models/currency/currency_model.dart';
import 'package:appmony/models/user/user_model.dart';

// Mock classes
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
  ThemeMode get themeMode => ThemeMode.light;
  
  @override
  bool get notificationsEnabled => true;
  
  @override
  LanguageModel get language => const LanguageModel(
    code: 'en',
    name: 'English',
    nativeName: 'English',
    flagAsset: 'assets/flags/us.png',
  );
  
  @override
  CurrencyModel get currency => CurrencyModel.usd;
  
  @override
  Future<void> setThemeMode(ThemeMode mode) async {}
  
  @override
  Future<void> setNotificationsEnabled(bool enabled) async {}
}

class MockAuthProvider extends Mock implements AuthProvider {
  @override
  bool get isAuthenticated => true;
  
  @override
  UserModel? get currentUser => UserModel(
    id: 'test-user-id',
    email: 'test@example.com',
    displayName: 'Test User',
    photoURL: null,
  );
  
  @override
  Future<void> signOut() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Mock PackageInfo for app version
  PackageInfo.setMockInitialValues(
    appName: 'AppMony',
    packageName: 'com.example.appmony',
    version: '1.0.0',
    buildNumber: '1',
    buildSignature: '',
  );
  
  group('SettingsScreen', () {
    late MockAnalyticsService mockAnalyticsService;
    late MockSubscriptionService mockSubscriptionService;
    late MockSettingsProvider mockSettingsProvider;
    late MockAuthProvider mockAuthProvider;
    
    setUp(() {
      mockAnalyticsService = MockAnalyticsService();
      mockSubscriptionService = MockSubscriptionService();
      mockSettingsProvider = MockSettingsProvider();
      mockAuthProvider = MockAuthProvider();
    });
    
    testWidgets('renders correctly with authenticated user', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsProvider>.value(value: mockSettingsProvider),
            ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
            Provider<AnalyticsService>.value(value: mockAnalyticsService),
            Provider<SubscriptionService>.value(value: mockSubscriptionService),
          ],
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      
      // Wait for the future to complete
      await tester.pumpAndSettle();
      
      // Verify that the screen renders with the correct title
      expect(find.text('Settings'), findsOneWidget);
      
      // Verify that the user profile is displayed
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('Edit Profile'), findsOneWidget);
      
      // Verify that the app settings section is displayed
      expect(find.text('App Settings'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Currency'), findsOneWidget);
      expect(find.text('Dark Mode'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      
      // Verify that the premium section is displayed
      expect(find.text('Premium'), findsOneWidget);
      expect(find.text('Upgrade to Premium'), findsOneWidget);
      
      // Verify that the about section is displayed
      expect(find.text('About'), findsOneWidget);
      expect(find.text('Rate App'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Terms of Service'), findsOneWidget);
      expect(find.text('App Version'), findsOneWidget);
      
      // Verify that the sign out button is displayed
      expect(find.text('Sign Out'), findsOneWidget);
    });
    
    testWidgets('shows premium status when user is premium', (WidgetTester tester) async {
      when(mockSubscriptionService.isPremium).thenReturn(true);
      
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsProvider>.value(value: mockSettingsProvider),
            ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
            Provider<AnalyticsService>.value(value: mockAnalyticsService),
            Provider<SubscriptionService>.value(value: mockSubscriptionService),
          ],
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      
      // Wait for the future to complete
      await tester.pumpAndSettle();
      
      // Verify that the premium status is displayed
      expect(find.text('Premium Subscription'), findsOneWidget);
      expect(find.text('You have access to all premium features'), findsOneWidget);
    });
    
    testWidgets('toggles dark mode when switch is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsProvider>.value(value: mockSettingsProvider),
            ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
            Provider<AnalyticsService>.value(value: mockAnalyticsService),
            Provider<SubscriptionService>.value(value: mockSubscriptionService),
          ],
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      
      // Wait for the future to complete
      await tester.pumpAndSettle();
      
      // Find the dark mode switch
      final darkModeSwitch = find.byType(Switch).first;
      
      // Tap the switch
      await tester.tap(darkModeSwitch);
      await tester.pumpAndSettle();
      
      // Verify that setThemeMode was called
      verify(mockSettingsProvider.setThemeMode(ThemeMode.dark)).called(1);
    });
    
    testWidgets('shows sign out dialog when sign out is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsProvider>.value(value: mockSettingsProvider),
            ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
            Provider<AnalyticsService>.value(value: mockAnalyticsService),
            Provider<SubscriptionService>.value(value: mockSubscriptionService),
          ],
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      
      // Wait for the future to complete
      await tester.pumpAndSettle();
      
      // Find the sign out button
      final signOutButton = find.text('Sign Out');
      
      // Tap the button
      await tester.tap(signOutButton);
      await tester.pumpAndSettle();
      
      // Verify that the dialog is displayed
      expect(find.text('Are you sure you want to sign out?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Sign Out').last, findsOneWidget);
    });
  });
}