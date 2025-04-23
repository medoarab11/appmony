import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/currency/currency_model.dart';
import '../../../models/language/language_model.dart';
import '../../../services/analytics/analytics_service.dart';
import '../../../services/localization/localization_service.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/auth_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // Selected language and currency
  String _selectedLanguageCode = 'en';
  String _selectedCurrencyCode = 'USD';
  
  // Onboarding pages
  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Welcome to AppMony',
      'description': 'The personal finance app that works for you. Track expenses, set budgets, and achieve your financial goals.',
      'icon': Icons.account_balance_wallet,
    },
    {
      'title': 'Choose Your Language',
      'description': 'Select your preferred language for the app interface.',
      'icon': Icons.language,
    },
    {
      'title': 'Select Your Currency',
      'description': 'Choose the primary currency for your transactions and budgets.',
      'icon': Icons.currency_exchange,
    },
    {
      'title': 'Works Offline',
      'description': 'Access your financial data anytime, even without an internet connection.',
      'icon': Icons.offline_bolt,
    },
    {
      'title': 'Ready to Start',
      'description': 'Your personal finance journey begins now. Let\'s get started!',
      'icon': Icons.rocket_launch,
    },
  ];
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }
  
  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  Future<void> _completeOnboarding() async {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final analyticsService = Provider.of<AnalyticsService>(context, listen: false);
    
    // Set language and currency
    await settingsProvider.setLocale(_selectedLanguageCode);
    await settingsProvider.setCurrency(_selectedCurrencyCode);
    
    // Log events
    await analyticsService.logLanguageChanged(languageCode: _selectedLanguageCode);
    await analyticsService.logCurrencyChanged(currencyCode: _selectedCurrencyCode);
    
    // Create user if not authenticated
    if (!authProvider.isAuthenticated) {
      await authProvider.createUser(
        languageCode: _selectedLanguageCode,
        currencyCode: _selectedCurrencyCode,
      );
    }
    
    // Mark onboarding as completed
    await settingsProvider.setFirstLaunch(false);
    await settingsProvider.setOnboardingCompleted(true);
    
    // Navigate to dashboard
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppRouter.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: const Text('Skip'),
                ),
              ),
            ),
            
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildPage(index);
                },
              ),
            ),
            
            // Page indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => _buildPageIndicator(index),
                ),
              ),
            ),
            
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  _currentPage > 0
                      ? ElevatedButton(
                          onPressed: _previousPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            foregroundColor: Theme.of(context).colorScheme.primary,
                          ),
                          child: const Text('Back'),
                        )
                      : const SizedBox(width: 80),
                  
                  // Next/Get Started button
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32.0,
                        vertical: 12.0,
                      ),
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPage(int index) {
    final page = _pages[index];
    
    switch (index) {
      case 1: // Language selection page
        return _buildLanguageSelectionPage(page);
      case 2: // Currency selection page
        return _buildCurrencySelectionPage(page);
      default: // Regular pages
        return _buildRegularPage(page);
    }
  }
  
  Widget _buildRegularPage(Map<String, dynamic> page) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Icon(
            page['icon'],
            size: 100,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 48),
          
          // Title
          Text(
            page['title'],
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // Description
          Text(
            page['description'],
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildLanguageSelectionPage(Map<String, dynamic> page) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Icon(
            page['icon'],
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 32),
          
          // Title
          Text(
            page['title'],
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // Description
          Text(
            page['description'],
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Language selection
          Expanded(
            child: ListView.builder(
              itemCount: LocalizationService.supportedLanguages.length,
              itemBuilder: (context, index) {
                final language = LocalizationService.supportedLanguages[index];
                final isSelected = language.code == _selectedLanguageCode;
                
                return ListTile(
                  title: Text(language.name),
                  subtitle: Text(language.localName),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedLanguageCode = language.code;
                    });
                  },
                  selected: isSelected,
                  selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCurrencySelectionPage(Map<String, dynamic> page) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Icon(
            page['icon'],
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 32),
          
          // Title
          Text(
            page['title'],
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // Description
          Text(
            page['description'],
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Currency selection
          Expanded(
            child: ListView.builder(
              itemCount: CurrencyModel.allCurrencies.length,
              itemBuilder: (context, index) {
                final currency = CurrencyModel.allCurrencies[index];
                final isSelected = currency.code == _selectedCurrencyCode;
                
                return ListTile(
                  title: Text('${currency.name} (${currency.code})'),
                  subtitle: Text(currency.format(1234.56)),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    child: Text(
                      currency.symbol,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedCurrencyCode = currency.code;
                    });
                  },
                  selected: isSelected,
                  selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPageIndicator(int index) {
    final isActive = index == _currentPage;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: isActive ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.primary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }
}