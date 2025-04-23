import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/analytics/analytics_service.dart';
import '../../../services/subscription/subscription_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '';
  bool _isDarkMode = false;
  
  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    
    // Log screen view
    final analyticsService = Provider.of<AnalyticsService>(context, listen: false);
    analyticsService.logScreenView(
      screenName: 'settings',
      screenClass: 'SettingsScreen',
    );
    
    // Get current theme mode
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    _isDarkMode = settingsProvider.themeMode == ThemeMode.dark;
  }
  
  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final subscriptionService = Provider.of<SubscriptionService>(context);
    final isPremium = subscriptionService.isPremium;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // User profile section
          if (authProvider.isAuthenticated)
            _buildProfileSection(context, authProvider),
          
          // App settings
          _buildSectionHeader(context, 'App Settings'),
          
          // Language
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: Text(settingsProvider.language.name),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).pushNamed(AppRouter.languageSettings);
            },
          ),
          
          // Currency
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Currency'),
            subtitle: Text(settingsProvider.currency.code),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).pushNamed(AppRouter.currencySettings);
            },
          ),
          
          // Theme
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            value: _isDarkMode,
            onChanged: (value) {
              setState(() {
                _isDarkMode = value;
                settingsProvider.setThemeMode(
                  value ? ThemeMode.dark : ThemeMode.light,
                );
              });
            },
          ),
          
          // Notifications
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            value: settingsProvider.notificationsEnabled,
            onChanged: (value) {
              settingsProvider.setNotificationsEnabled(value);
            },
          ),
          
          // Premium
          _buildSectionHeader(context, 'Premium'),
          
          ListTile(
            leading: Icon(
              Icons.workspace_premium,
              color: isPremium ? AppColors.premiumGold : null,
            ),
            title: Text(
              isPremium ? 'Premium Subscription' : 'Upgrade to Premium',
            ),
            subtitle: Text(
              isPremium ? 'You have access to all premium features' : 'Remove ads and unlock all features',
            ),
            trailing: isPremium
                ? Icon(
                    Icons.check_circle,
                    color: AppColors.premiumGold,
                  )
                : const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).pushNamed(AppRouter.premium);
            },
          ),
          
          // About
          _buildSectionHeader(context, 'About'),
          
          // Rate app
          ListTile(
            leading: const Icon(Icons.star_rate),
            title: const Text('Rate App'),
            onTap: () {
              // TODO: Open app store rating
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening app store...'),
                ),
              );
            },
          ),
          
          // Privacy policy
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            onTap: () {
              // TODO: Open privacy policy
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening privacy policy...'),
                ),
              );
            },
          ),
          
          // Terms of service
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms of Service'),
            onTap: () {
              // TODO: Open terms of service
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening terms of service...'),
                ),
              );
            },
          ),
          
          // App version
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('App Version'),
            subtitle: Text(_appVersion),
            enabled: false,
          ),
          
          // Sign out
          if (authProvider.isAuthenticated)
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                _showSignOutDialog(context);
              },
            ),
        ],
      ),
    );
  }
  
  Widget _buildProfileSection(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.user;
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey[300],
            child: const Icon(Icons.person, size: 40, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Text(
            user?.name ?? 'User',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            user?.email ?? '',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              // TODO: Navigate to profile edit screen
            },
            child: const Text('Edit Profile'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              
              authProvider.logout().then((_) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRouter.onboarding,
                  (route) => false,
                );
              });
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}