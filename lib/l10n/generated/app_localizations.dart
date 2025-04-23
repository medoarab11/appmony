import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
/// dev_dependencies:
///   intl_utils: any
/// ```
///
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
    Locale('es'),
    Locale('fr')
  ];

  // App title
  String get appTitle;

  // Onboarding
  String get onboardingTitle1;
  String get onboardingTitle2;
  String get onboardingTitle3;
  String get onboardingDesc1;
  String get onboardingDesc2;
  String get onboardingDesc3;
  String get getStarted;
  String get skip;
  String get next;

  // Auth
  String get login;
  String get signup;
  String get email;
  String get password;
  String get forgotPassword;
  String get dontHaveAccount;
  String get alreadyHaveAccount;
  String get createAccount;
  String get continueWithGoogle;
  String get continueAsGuest;

  // Dashboard
  String get dashboard;
  String get totalBalance;
  String get income;
  String get expense;
  String get recentTransactions;
  String get viewAll;
  String get budgetSummary;
  String get addTransaction;
  String get addBudget;
  String get addWallet;

  // Transactions
  String get transactions;
  String get noTransactions;
  String get addNewTransaction;
  String get editTransaction;
  String get deleteTransaction;
  String get transactionDeleted;
  String get amount;
  String get category;
  String get date;
  String get description;
  String get wallet;
  String get selectCategory;
  String get selectWallet;
  String get selectDate;
  String get save;
  String get cancel;
  String get delete;
  String get confirmDelete;
  String get confirmDeleteTransaction;

  // Categories
  String get categories;
  String get addCategory;
  String get editCategory;
  String get deleteCategory;
  String get categoryName;
  String get categoryIcon;
  String get categoryColor;
  String get confirmDeleteCategory;

  // Budgets
  String get budgets;
  String get noBudgets;
  String get addNewBudget;
  String get editBudget;
  String get deleteBudget;
  String get budgetName;
  String get budgetAmount;
  String get budgetPeriod;
  String get startDate;
  String get endDate;
  String get confirmDeleteBudget;
  String get daily;
  String get weekly;
  String get monthly;
  String get yearly;
  String get remaining;
  String get spent;
  String get budgetDetails;

  // Wallets
  String get wallets;
  String get noWallets;
  String get addNewWallet;
  String get editWallet;
  String get deleteWallet;
  String get walletName;
  String get walletType;
  String get initialBalance;
  String get walletCurrency;
  String get confirmDeleteWallet;
  String get cash;
  String get bankAccount;
  String get creditCard;
  String get investment;
  String get savings;
  String get other;

  // Reports
  String get reports;
  String get noData;
  String get incomeVsExpense;
  String get spendingByCategory;
  String get monthlyOverview;
  String get savingsRate;
  String get exportData;
  String get thisWeek;
  String get thisMonth;
  String get last3Months;
  String get last6Months;
  String get thisYear;
  String get custom;

  // Settings
  String get settings;
  String get account;
  String get appearance;
  String get language;
  String get currency;
  String get notifications;
  String get security;
  String get about;
  String get logout;
  String get darkMode;
  String get lightMode;
  String get systemDefault;
  String get english;
  String get arabic;
  String get spanish;
  String get french;

  // Premium
  String get premium;
  String get upgradeToPremium;
  String get premiumFeatures;
  String get unlimitedWallets;
  String get unlimitedBudgets;
  String get advancedReports;
  String get dataExport;
  String get cloudSync;
  String get removeAds;
  String get subscribe;
  String get restorePurchases;
  String get monthly;
  String get yearly;
  String get lifetime;
  String get mostPopular;
  String get bestValue;
  String get perMonth;
  String get perYear;
  String get oneTimePurchase;
  String get freeTrial;
  String get cancelAnytime;
  String get subscriptionDetails;

  // Errors
  String get error;
  String get somethingWentWrong;
  String get tryAgain;
  String get connectionError;
  String get invalidEmail;
  String get invalidPassword;
  String get requiredField;
  String get invalidAmount;
  String get invalidDate;
  String get invalidName;
  String get invalidCategory;
  String get invalidWallet;
  String get invalidBudget;
  String get invalidCurrency;
  String get invalidLanguage;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}