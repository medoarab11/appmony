import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../models/user/user_model.dart';
import '../../../services/analytics/analytics_service.dart';
import '../../../services/database/database_service.dart';

class AuthProvider extends ChangeNotifier {
  final DatabaseService databaseService;
  final AnalyticsService analyticsService;
  late SharedPreferences _prefs;
  
  UserModel? _user;
  UserModel? get user => _user;
  
  bool get isAuthenticated => _user != null;
  
  AuthProvider({
    required this.databaseService,
    required this.analyticsService,
  }) {
    _initialize();
  }
  
  Future<void> _initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadUser();
  }
  
  Future<void> _loadUser() async {
    // Try to get user from database
    final user = await databaseService.getUser();
    
    if (user != null) {
      _user = user;
      
      // Update analytics
      await analyticsService.setUserProperties(
        userId: user.id,
        isPremium: user.isPremium,
        languageCode: user.languageCode,
        currencyCode: user.currencyCode,
      );
    }
    
    notifyListeners();
  }
  
  Future<void> createUser({
    required String languageCode,
    required String currencyCode,
  }) async {
    final userId = const Uuid().v4();
    
    final user = UserModel(
      id: userId,
      languageCode: languageCode,
      currencyCode: currencyCode,
    );
    
    await databaseService.saveUser(user);
    await _prefs.setString(AppConstants.prefUserId, userId);
    
    _user = user;
    
    // Update analytics
    await analyticsService.setUserProperties(
      userId: user.id,
      isPremium: user.isPremium,
      languageCode: user.languageCode,
      currencyCode: user.currencyCode,
    );
    
    notifyListeners();
  }
  
  Future<void> updateUser({
    String? name,
    String? email,
    bool? isPremium,
    DateTime? premiumExpiryDate,
    String? languageCode,
    String? currencyCode,
    ThemeMode? themeMode,
  }) async {
    if (_user == null) return;
    
    final updatedUser = _user!.copyWith(
      name: name,
      email: email,
      isPremium: isPremium,
      premiumExpiryDate: premiumExpiryDate,
      languageCode: languageCode,
      currencyCode: currencyCode,
      themeMode: themeMode,
    );
    
    await databaseService.updateUser(updatedUser);
    
    _user = updatedUser;
    
    // Update analytics
    await analyticsService.setUserProperties(
      userId: updatedUser.id,
      isPremium: updatedUser.isPremium,
      languageCode: updatedUser.languageCode,
      currencyCode: updatedUser.currencyCode,
    );
    
    notifyListeners();
  }
  
  Future<void> logout() async {
    _user = null;
    await _prefs.remove(AppConstants.prefUserId);
    notifyListeners();
  }
}