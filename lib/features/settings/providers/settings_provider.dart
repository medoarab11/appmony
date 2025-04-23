import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../models/currency/currency_model.dart';
import '../../../models/language/language_model.dart';
import '../../../services/localization/localization_service.dart';

class SettingsProvider extends ChangeNotifier {
  final LocalizationService localizationService;
  late SharedPreferences _prefs;
  
  // Theme mode
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;
  
  // Locale
  Locale _locale = const Locale('en');
  Locale get locale => _locale;
  
  // Currency code
  String _currencyCode = 'USD';
  String get currencyCode => _currencyCode;
  
  // Currency model
  CurrencyModel? _currency;
  CurrencyModel get currency => _currency ?? CurrencyModel.usd;
  
  // Language model
  LanguageModel? _language;
  LanguageModel get language => _language ?? const LanguageModel(
    code: 'en',
    name: 'English',
    nativeName: 'English',
    flagAsset: 'assets/flags/us.png',
  );
  
  // First launch
  bool _isFirstLaunch = true;
  bool get isFirstLaunch => _isFirstLaunch;
  
  // Onboarding completed
  bool _hasCompletedOnboarding = false;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  
  // Notifications enabled
  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;
  
  SettingsProvider({
    required this.localizationService,
  }) {
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    
    // Load theme mode
    final String? themeModeString = _prefs.getString(AppConstants.prefThemeMode);
    if (themeModeString != null) {
      switch (themeModeString) {
        case 'ThemeMode.light':
          _themeMode = ThemeMode.light;
          break;
        case 'ThemeMode.dark':
          _themeMode = ThemeMode.dark;
          break;
        default:
          _themeMode = ThemeMode.system;
      }
    }
    
    // Load locale
    final String languageCode = _prefs.getString(AppConstants.prefLanguageCode) ?? 'en';
    _locale = Locale(languageCode);
    _language = localizationService.getLanguageByCode(languageCode);
    
    // Load currency
    _currencyCode = _prefs.getString(AppConstants.prefCurrencyCode) ?? 'USD';
    _currency = CurrencyModel.findByCode(_currencyCode);
    
    // Load first launch
    _isFirstLaunch = _prefs.getBool(AppConstants.prefIsFirstLaunch) ?? true;
    
    // Load onboarding completed
    _hasCompletedOnboarding = _prefs.getBool(AppConstants.prefHasCompletedOnboarding) ?? false;
    
    // Load notifications enabled
    _notificationsEnabled = _prefs.getBool(AppConstants.prefNotificationsEnabled) ?? true;
    
    notifyListeners();
  }
  
  // Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setString(AppConstants.prefThemeMode, mode.toString());
    notifyListeners();
  }
  
  // Set locale
  Future<void> setLocale(String languageCode) async {
    _locale = Locale(languageCode);
    _language = localizationService.getLanguageByCode(languageCode);
    await _prefs.setString(AppConstants.prefLanguageCode, languageCode);
    await localizationService.setLanguageCode(languageCode);
    notifyListeners();
  }
  
  // Set language
  Future<void> setLanguage(LanguageModel language) async {
    _language = language;
    _locale = Locale(language.code);
    await _prefs.setString(AppConstants.prefLanguageCode, language.code);
    await localizationService.setLanguageCode(language.code);
    notifyListeners();
  }
  
  // Set currency by code
  Future<void> setCurrencyByCode(String currencyCode) async {
    _currencyCode = currencyCode;
    _currency = CurrencyModel.findByCode(currencyCode);
    await _prefs.setString(AppConstants.prefCurrencyCode, currencyCode);
    notifyListeners();
  }
  
  // Set currency using model
  Future<void> setCurrency(CurrencyModel currency) async {
    _currency = currency;
    _currencyCode = currency.code;
    await _prefs.setString(AppConstants.prefCurrencyCode, currency.code);
    notifyListeners();
  }
  
  // Set notifications enabled
  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await _prefs.setBool(AppConstants.prefNotificationsEnabled, enabled);
    notifyListeners();
  }
  
  // Set first launch
  Future<void> setFirstLaunch(bool isFirstLaunch) async {
    _isFirstLaunch = isFirstLaunch;
    await _prefs.setBool(AppConstants.prefIsFirstLaunch, isFirstLaunch);
    notifyListeners();
  }
  
  // Set onboarding completed
  Future<void> setOnboardingCompleted(bool hasCompleted) async {
    _hasCompletedOnboarding = hasCompleted;
    await _prefs.setBool(AppConstants.prefHasCompletedOnboarding, hasCompleted);
    notifyListeners();
  }
  
  // Format amount
  String formatAmount(double amount, {bool showSymbol = true}) {
    return currency.format(amount, showSymbol: showSymbol);
  }
}