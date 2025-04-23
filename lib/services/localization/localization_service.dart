import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../models/language/language_model.dart';

class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  late SharedPreferences _prefs;
  
  // Default language
  static const String defaultLanguageCode = 'en';
  
  // List of supported languages
  List<LanguageModel> get supportedLanguages => LanguageModel.supportedLanguages;
  
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // Get the current language code
  String getLanguageCode() {
    return _prefs.getString(AppConstants.prefLanguageCode) ?? defaultLanguageCode;
  }
  
  // Set the language code
  Future<void> setLanguageCode(String languageCode) async {
    await _prefs.setString(AppConstants.prefLanguageCode, languageCode);
  }
  
  // Get the current locale
  Locale getLocale() {
    final languageCode = getLanguageCode();
    return Locale(languageCode);
  }
  
  // Get language by code
  LanguageModel? getLanguageByCode(String code) {
    return LanguageModel.findByCode(code);
  }
  
  // Get the current language
  LanguageModel getCurrentLanguage() {
    final languageCode = getLanguageCode();
    return getLanguageByCode(languageCode) ?? supportedLanguages.first;
  }
  
  // Check if the language is RTL
  bool isRtl(String languageCode) {
    return ['ar', 'fa', 'he', 'ur'].contains(languageCode);
  }
  
  // Get text direction
  TextDirection getTextDirection() {
    final languageCode = getLanguageCode();
    return isRtl(languageCode) ? TextDirection.rtl : TextDirection.ltr;
  }
}
