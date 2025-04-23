import 'package:flutter/material.dart';

import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/budgets/screens/budget_detail_screen.dart';
import '../../features/budgets/screens/budgets_screen.dart';
import '../../features/budgets/screens/create_budget_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/premium/screens/premium_screen.dart';
import '../../features/reports/screens/reports_screen.dart';
import '../../features/settings/screens/currency_settings_screen.dart';
import '../../features/settings/screens/language_settings_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/transactions/screens/create_transaction_screen.dart';
import '../../features/transactions/screens/transaction_detail_screen.dart';
import '../../features/transactions/screens/transactions_screen.dart';
import '../../features/wallets/screens/create_wallet_screen.dart';
import '../../features/wallets/screens/wallet_details_screen.dart';
import '../../features/wallets/screens/wallets_screen.dart';
import '../../models/wallet/wallet_model.dart';

class AppRouter {
  // Route Names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String dashboard = '/dashboard';
  static const String transactions = '/transactions';
  static const String createTransaction = '/transactions/create';
  static const String transactionDetail = '/transactions/detail';
  static const String budgets = '/budgets';
  static const String createBudget = '/budgets/create';
  static const String budgetDetail = '/budgets/detail';
  static const String reports = '/reports';
  static const String settings = '/settings';
  static const String languageSettings = '/settings/language';
  static const String currencySettings = '/settings/currency';
  static const String premium = '/premium';
  static const String wallets = '/wallets';
  static const String createWallet = '/wallets/create';
  static const String walletDetail = '/wallets/detail';
  
  // Initial Route
  static String get initialRoute => splash;
  
  // Route Generator
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      
      case transactions:
        return MaterialPageRoute(builder: (_) => const TransactionsScreen());
      
      case createTransaction:
        final Map<String, dynamic>? args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => CreateTransactionScreen(
            walletId: args?['walletId'],
            categoryId: args?['categoryId'],
            isExpense: args?['isExpense'] ?? true,
          ),
        );
      
      case transactionDetail:
        final String transactionId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => TransactionDetailScreen(transactionId: transactionId),
        );
      
      case budgets:
        return MaterialPageRoute(builder: (_) => const BudgetsScreen());
      
      case createBudget:
        final Map<String, dynamic>? args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => CreateBudgetScreen(
            categoryId: args?['categoryId'],
          ),
        );
      
      case budgetDetail:
        final String budgetId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => BudgetDetailScreen(budgetId: budgetId),
        );
      
      case reports:
        return MaterialPageRoute(builder: (_) => const ReportsScreen());
      
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      
      case languageSettings:
        return MaterialPageRoute(builder: (_) => const LanguageSettingsScreen());
      
      case currencySettings:
        return MaterialPageRoute(builder: (_) => const CurrencySettingsScreen());
      
      case premium:
        return MaterialPageRoute(builder: (_) => const PremiumScreen());
      
      case wallets:
        return MaterialPageRoute(builder: (_) => const WalletsScreen());
      
      case createWallet:
        final WalletModel? wallet = settings.arguments as WalletModel?;
        return MaterialPageRoute(
          builder: (_) => CreateWalletScreen(wallet: wallet),
        );
      
      case walletDetail:
        final WalletModel wallet = settings.arguments as WalletModel;
        return MaterialPageRoute(
          builder: (_) => WalletDetailsScreen(wallet: wallet),
        );
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}