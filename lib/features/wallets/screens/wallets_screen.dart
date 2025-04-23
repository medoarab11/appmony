import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/navigation/app_router.dart';
import '../../../l10n/generated/l10n.dart';
import '../../../models/wallet/wallet_model.dart';
import '../../../services/admob/admob_service.dart';
import '../../../services/analytics/analytics_service.dart';
import '../../../services/database/database_service.dart';
import '../../../services/subscription/subscription_service.dart';
import '../../settings/providers/settings_provider.dart';
import '../widgets/wallet_card.dart';

class WalletsScreen extends StatefulWidget {
  const WalletsScreen({Key? key}) : super(key: key);

  @override
  State<WalletsScreen> createState() => _WalletsScreenState();
}

class _WalletsScreenState extends State<WalletsScreen> {
  List<WalletModel> _wallets = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    
    // Log screen view
    final analyticsService = Provider.of<AnalyticsService>(context, listen: false);
    analyticsService.logScreenView(
      screenName: 'wallets',
      screenClass: 'WalletsScreen',
    );
    
    // Load wallets
    _loadWallets();
  }
  
  Future<void> _loadWallets() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final databaseService = Provider.of<DatabaseService>(context, listen: false);
      final wallets = await databaseService.getWallets();
      
      if (mounted) {
        setState(() {
          _wallets = wallets;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading wallets: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final subscriptionService = Provider.of<SubscriptionService>(context);
    final adMobService = Provider.of<AdMobService>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    
    final isPremium = subscriptionService.isPremium;
    final maxWalletsInFreeTier = AppConstants.maxWalletsInFreeTier;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.wallets),
      ),
      body: RefreshIndicator(
        onRefresh: _loadWallets,
        child: Column(
          children: [
            // Ad banner for free users
            if (!isPremium)
              Container(
                height: 50,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: adMobService.getBannerWidget(),
              ),
            
            // Wallets list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _wallets.isEmpty
                      ? _buildEmptyState(context)
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: _wallets.length,
                          itemBuilder: (context, index) {
                            final wallet = _wallets[index];
                            return WalletCard(
                              wallet: wallet,
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  '/wallets/detail',
                                  arguments: wallet,
                                ).then((_) => _loadWallets());
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Check if user can add more wallets
          if (!isPremium && _wallets.length >= maxWalletsInFreeTier) {
            _showPremiumDialog(context);
          } else {
            Navigator.of(context).pushNamed(
              '/wallets/create',
            ).then((_) => _loadWallets());
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              localizations.noWallets,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              localizations.addYourFirst(localizations.wallet.toLowerCase()),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  '/wallets/create',
                ).then((_) => _loadWallets());
              },
              icon: const Icon(Icons.add),
              label: Text(localizations.addWallet),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showPremiumDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.goPremium),
        content: Text(
          'You have reached the maximum number of wallets in the free tier. '
          'Upgrade to premium to create unlimited wallets and enjoy other premium features.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(localizations.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(AppRouter.premium);
            },
            child: Text(localizations.goPremium),
          ),
        ],
      ),
    );
  }
}