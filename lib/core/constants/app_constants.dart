class AppConstants {
  // App Info
  static const String appName = 'AppMony';
  static const String appVersion = '1.0.0';
  
  // Database
  static const String databaseName = 'appmony.db';
  static const int databaseVersion = 1;
  
  // AdMob
  static const String adMobAppId = 'ca-app-pub-3940256099942544~3347511713'; // Test ID
  static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111'; // Test ID
  static const String interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712'; // Test ID
  static const String rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917'; // Test ID
  
  // In-App Purchase
  static const String monthlySubscriptionId = 'appmony_premium_monthly';
  static const String yearlySubscriptionId = 'appmony_premium_yearly';
  
  // Free Tier Limits
  static const int maxWalletsInFreeTier = 1;
  static const int maxBudgetsInFreeTier = 2;
  
  // Analytics Events
  static const String eventAppOpen = 'app_open';
  static const String eventTransactionAdded = 'transaction_added';
  static const String eventBudgetCreated = 'budget_created';
  static const String eventLanguageChanged = 'language_changed';
  static const String eventCurrencyChanged = 'currency_changed';
  static const String eventSubscriptionStarted = 'subscription_started';
  static const String eventAdViewed = 'ad_viewed';
  
  // Shared Preferences Keys
  static const String prefLanguageCode = 'language_code';
  static const String prefCurrencyCode = 'currency_code';
  static const String prefThemeMode = 'theme_mode';
  static const String prefIsFirstLaunch = 'is_first_launch';
  static const String prefHasCompletedOnboarding = 'has_completed_onboarding';
  static const String prefUserId = 'user_id';
  static const String prefIsPremium = 'is_premium';
  static const String prefNotificationsEnabled = 'notifications_enabled';
  
  // Time Formats
  static const String dateFormatFull = 'EEEE, MMMM d, yyyy';
  static const String dateFormatShort = 'MMM d, yyyy';
  static const String dateFormatMonthYear = 'MMMM yyyy';
  
  // Interstitial Ad Frequency
  static const int interstitialAdFrequency = 5; // Show ad every 5 actions
  
  // Premium Features
  static const List<String> premiumFeatures = [
    'Unlimited wallets',
    'Unlimited budgets',
    'Recurring transactions',
    'Advanced reports and analytics',
    'Data backup and sync',
    'Export to CSV/Google Sheets',
    'No advertisements',
    'Premium themes',
  ];
  
  // Support
  static const String supportEmail = 'support@appmony.com';
  static const String privacyPolicyUrl = 'https://appmony.com/privacy';
  static const String termsOfServiceUrl = 'https://appmony.com/terms';
}