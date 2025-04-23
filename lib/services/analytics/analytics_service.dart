import 'package:firebase_analytics/firebase_analytics.dart';

import '../../core/constants/app_constants.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  FirebaseAnalytics? _analytics;
  bool _isInitialized = false;
  
  Future<void> initialize() async {
    try {
      _analytics = FirebaseAnalytics.instance;
      _isInitialized = true;
    } catch (e) {
      print('Error initializing analytics: $e');
      _isInitialized = false;
    }
  }
  
  // Log app open event
  Future<void> logAppOpen() async {
    if (!_isInitialized) return;
    
    try {
      await _analytics?.logAppOpen();
    } catch (e) {
      print('Error logging app open: $e');
    }
  }
  
  // Log screen view event
  Future<void> logScreenView({
    required String screenName,
    required String screenClass,
  }) async {
    if (!_isInitialized) return;
    
    try {
      await _analytics?.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
    } catch (e) {
      print('Error logging screen view: $e');
    }
  }
  
  // Log transaction added event
  Future<void> logTransactionAdded({
    required String type,
    required double amount,
    required String currencyCode,
    String? categoryId,
  }) async {
    if (!_isInitialized) return;
    
    try {
      await _analytics?.logEvent(
        name: AppConstants.eventTransactionAdded,
        parameters: {
          'type': type,
          'amount': amount,
          'currency_code': currencyCode,
          'category_id': categoryId,
        },
      );
    } catch (e) {
      print('Error logging transaction added: $e');
    }
  }
  
  // Log budget created event
  Future<void> logBudgetCreated({
    required String name,
    required double amount,
    required String currencyCode,
    String? categoryId,
  }) async {
    if (!_isInitialized) return;
    
    try {
      await _analytics?.logEvent(
        name: AppConstants.eventBudgetCreated,
        parameters: {
          'name': name,
          'amount': amount,
          'currency_code': currencyCode,
          'category_id': categoryId,
        },
      );
    } catch (e) {
      print('Error logging budget created: $e');
    }
  }
  
  // Log language changed event
  Future<void> logLanguageChanged({
    required String languageCode,
  }) async {
    if (!_isInitialized) return;
    
    try {
      await _analytics?.logEvent(
        name: AppConstants.eventLanguageChanged,
        parameters: {
          'language_code': languageCode,
        },
      );
    } catch (e) {
      print('Error logging language changed: $e');
    }
  }
  
  // Log currency changed event
  Future<void> logCurrencyChanged({
    required String currencyCode,
  }) async {
    if (!_isInitialized) return;
    
    try {
      await _analytics?.logEvent(
        name: AppConstants.eventCurrencyChanged,
        parameters: {
          'currency_code': currencyCode,
        },
      );
    } catch (e) {
      print('Error logging currency changed: $e');
    }
  }
  
  // Log subscription started event
  Future<void> logSubscriptionStarted({
    required String subscriptionId,
    required double price,
    required String currencyCode,
  }) async {
    if (!_isInitialized) return;
    
    try {
      await _analytics?.logEvent(
        name: AppConstants.eventSubscriptionStarted,
        parameters: {
          'subscription_id': subscriptionId,
          'price': price,
          'currency_code': currencyCode,
        },
      );
    } catch (e) {
      print('Error logging subscription started: $e');
    }
  }
  
  // Log ad viewed event
  Future<void> logAdViewed({
    required String adType,
    required String adUnitId,
  }) async {
    if (!_isInitialized) return;
    
    try {
      await _analytics?.logEvent(
        name: AppConstants.eventAdViewed,
        parameters: {
          'ad_type': adType,
          'ad_unit_id': adUnitId,
        },
      );
    } catch (e) {
      print('Error logging ad viewed: $e');
    }
  }
  
  // Set user properties
  Future<void> setUserProperties({
    required String userId,
    required bool isPremium,
    required String languageCode,
    required String currencyCode,
  }) async {
    if (!_isInitialized) return;
    
    try {
      await _analytics?.setUserId(id: userId);
      await _analytics?.setUserProperty(name: 'is_premium', value: isPremium.toString());
      await _analytics?.setUserProperty(name: 'language_code', value: languageCode);
      await _analytics?.setUserProperty(name: 'currency_code', value: currencyCode);
    } catch (e) {
      print('Error setting user properties: $e');
    }
  }
}