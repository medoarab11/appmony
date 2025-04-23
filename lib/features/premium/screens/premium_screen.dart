import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/subscription/subscription_model.dart';
import '../../../services/analytics/analytics_service.dart';
import '../../../services/subscription/subscription_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../widgets/subscription_card.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({Key? key}) : super(key: key);

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _isLoading = false;
  String? _selectedSubscriptionId;
  
  @override
  Widget build(BuildContext context) {
    final subscriptionService = Provider.of<SubscriptionService>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final currencyCode = settingsProvider.currencyCode;
    
    final subscriptions = subscriptionService.getSubscriptions(currencyCode);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium Subscription'),
        actions: [
          TextButton(
            onPressed: _restorePurchases,
            child: const Text('Restore'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Premium header
                    _buildPremiumHeader(),
                    const SizedBox(height: 24),
                    
                    // Premium features
                    _buildPremiumFeatures(),
                    const SizedBox(height: 32),
                    
                    // Subscription options
                    Text(
                      'Choose a Plan',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Subscription cards
                    ...subscriptions.map((subscription) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: SubscriptionCard(
                        subscription: subscription,
                        isSelected: _selectedSubscriptionId == subscription.id,
                        onTap: () {
                          setState(() {
                            _selectedSubscriptionId = subscription.id;
                          });
                        },
                      ),
                    )),
                    
                    const SizedBox(height: 24),
                    
                    // Subscribe button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selectedSubscriptionId == null
                            ? null
                            : () => _subscribe(_selectedSubscriptionId!),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        child: const Text('Subscribe Now'),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Terms and conditions
                    Text(
                      'By subscribing, you agree to our Terms of Service and Privacy Policy. '
                      'Subscriptions will automatically renew unless canceled at least 24 hours before the end of the current period. '
                      'You can cancel anytime in your Google Play account settings.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildPremiumHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.premiumGold,
            AppColors.premiumGoldLight,
          ],
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.star,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Upgrade to Premium',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Unlock all features and remove ads',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildPremiumFeatures() {
    final features = [
      {
        'icon': Icons.account_balance_wallet,
        'title': 'Unlimited Wallets',
        'description': 'Create as many wallets as you need',
      },
      {
        'icon': Icons.pie_chart,
        'title': 'Advanced Reports',
        'description': 'Detailed financial insights and analytics',
      },
      {
        'icon': Icons.sync,
        'title': 'Cloud Sync',
        'description': 'Sync your data across all your devices',
      },
      {
        'icon': Icons.block,
        'title': 'Ad-Free Experience',
        'description': 'Enjoy the app without any advertisements',
      },
      {
        'icon': Icons.repeat,
        'title': 'Recurring Budgets',
        'description': 'Set up recurring budgets that reset automatically',
      },
      {
        'icon': Icons.file_download,
        'title': 'Data Export',
        'description': 'Export your financial data to CSV or Google Sheets',
      },
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Premium Features',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...features.map((feature) => Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(
                  feature['icon'] as IconData,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature['title'] as String,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      feature['description'] as String,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
  
  Future<void> _subscribe(String subscriptionId) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final subscriptionService = Provider.of<SubscriptionService>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final analyticsService = Provider.of<AnalyticsService>(context, listen: false);
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      
      final success = await subscriptionService.purchaseSubscription(subscriptionId);
      
      if (success) {
        // Update user premium status
        await authProvider.updateUser(isPremium: true);
        
        // Log subscription event
        final subscription = subscriptionService.getSubscriptions(settingsProvider.currencyCode)
            .firstWhere((s) => s.id == subscriptionId);
        
        await analyticsService.logSubscriptionStarted(
          subscriptionId: subscriptionId,
          price: subscription.price,
          currencyCode: subscription.currencyCode,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Subscription successful! You are now a premium user.'),
              backgroundColor: Colors.green,
            ),
          );
          
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Subscription failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _restorePurchases() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final subscriptionService = Provider.of<SubscriptionService>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await subscriptionService.restorePurchases();
      
      if (success && subscriptionService.isPremium) {
        // Update user premium status
        await authProvider.updateUser(isPremium: true);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Purchases restored successfully! You are now a premium user.'),
              backgroundColor: Colors.green,
            ),
          );
          
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No previous purchases found.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}