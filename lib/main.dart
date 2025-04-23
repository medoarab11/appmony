import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/settings/providers/settings_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'services/admob/admob_service.dart';
import 'services/analytics/analytics_service.dart';
import 'services/database/database_service.dart';
import 'services/localization/localization_service.dart';
import 'services/subscription/subscription_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize services
  final databaseService = DatabaseService();
  await databaseService.initialize();
  
  final analyticsService = AnalyticsService();
  await analyticsService.initialize();
  
  final adMobService = AdMobService();
  await adMobService.initialize();
  
  final subscriptionService = SubscriptionService();
  await subscriptionService.initialize();
  
  final localizationService = LocalizationService();
  await localizationService.initialize();
  
  runApp(MyApp(
    databaseService: databaseService,
    analyticsService: analyticsService,
    adMobService: adMobService,
    subscriptionService: subscriptionService,
    localizationService: localizationService,
  ));
}

class MyApp extends StatelessWidget {
  final DatabaseService databaseService;
  final AnalyticsService analyticsService;
  final AdMobService adMobService;
  final SubscriptionService subscriptionService;
  final LocalizationService localizationService;

  const MyApp({
    Key? key,
    required this.databaseService,
    required this.analyticsService,
    required this.adMobService,
    required this.subscriptionService,
    required this.localizationService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(
            localizationService: localizationService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            databaseService: databaseService,
            analyticsService: analyticsService,
          ),
        ),
        Provider.value(value: databaseService),
        Provider.value(value: analyticsService),
        Provider.value(value: adMobService),
        Provider.value(value: subscriptionService),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsProvider.themeMode,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: settingsProvider.locale,
            onGenerateRoute: AppRouter.onGenerateRoute,
            initialRoute: AppRouter.initialRoute,
          );
        },
      ),
    );
  }
}