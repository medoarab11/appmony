import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/budget/budget_model.dart';
import '../../../models/transaction/transaction_model.dart';
import '../../../models/wallet/wallet_model.dart';
import '../../../services/admob/admob_service.dart';
import '../../../services/database/database_service.dart';
import '../../../services/subscription/subscription_service.dart';
import '../../settings/providers/settings_provider.dart';
import '../../transactions/screens/transactions_screen.dart';
import '../../budgets/screens/budgets_screen.dart';
import '../widgets/balance_card.dart';
import '../widgets/budget_summary.dart';
import '../widgets/recent_transactions.dart';
import '../widgets/wallet_list.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  BannerAd? _bannerAd;
  
  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }
  
  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
  
  void _loadBannerAd() {
    final adMobService = Provider.of<AdMobService>(context, listen: false);
    final subscriptionService = Provider.of<SubscriptionService>(context, listen: false);
    
    if (!subscriptionService.isPremium) {
      _bannerAd = adMobService.createBannerAd()..load();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final subscriptionService = Provider.of<SubscriptionService>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboardTab(),
          _buildTransactionsTab(),
          _buildBudgetsTab(),
          _buildReportsTab(),
          _buildSettingsTab(),
        ],
      ),
      floatingActionButton: _currentIndex <= 2
          ? FloatingActionButton(
              onPressed: () {
                switch (_currentIndex) {
                  case 0: // Dashboard - Add transaction
                    Navigator.of(context).pushNamed(AppRouter.createTransaction);
                    break;
                  case 1: // Transactions - Add transaction
                    Navigator.of(context).pushNamed(AppRouter.createTransaction);
                    break;
                  case 2: // Budgets - Add budget
                    Navigator.of(context).pushNamed(AppRouter.createBudget);
                    break;
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Banner ad
          if (_bannerAd != null && !subscriptionService.isPremium)
            Container(
              alignment: Alignment.center,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
          
          // Bottom navigation bar
          BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long),
                label: 'Transactions',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet),
                label: 'Budgets',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.pie_chart),
                label: 'Reports',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildDashboardTab() {
    return FutureBuilder<List<WalletModel>>(
      future: Provider.of<DatabaseService>(context).getWallets(),
      builder: (context, walletsSnapshot) {
        if (walletsSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final wallets = walletsSnapshot.data ?? [];
        
        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: CustomScrollView(
            slivers: [
              // App bar
              SliverAppBar(
                floating: true,
                title: const Text('Dashboard'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      // TODO: Show notifications
                    },
                  ),
                ],
              ),
              
              // Wallets
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'My Wallets',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed(AppRouter.wallets);
                            },
                            child: const Text('See All'),
                          ),
                        ],
                      ),
                      
                      // Wallet list
                      WalletList(wallets: wallets),
                      
                      // Premium upgrade card
                      if (wallets.length >= AppConstants.maxWalletsInFreeTier &&
                          !Provider.of<SubscriptionService>(context).isPremium)
                        _buildPremiumCard(),
                    ],
                  ),
                ),
              ),
              
              // Recent transactions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Transactions',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _currentIndex = 1; // Switch to Transactions tab
                              });
                            },
                            child: const Text('See All'),
                          ),
                        ],
                      ),
                      
                      // Recent transactions list
                      FutureBuilder<List<TransactionModel>>(
                        future: Provider.of<DatabaseService>(context).getTransactions(
                          limit: 5,
                        ),
                        builder: (context, transactionsSnapshot) {
                          if (transactionsSnapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          
                          final transactions = transactionsSnapshot.data ?? [];
                          
                          if (transactions.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('No transactions yet. Add your first one!'),
                              ),
                            );
                          }
                          
                          return RecentTransactions(transactions: transactions);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              // Budget summary
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Budget Summary',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _currentIndex = 2; // Switch to Budgets tab
                              });
                            },
                            child: const Text('See All'),
                          ),
                        ],
                      ),
                      
                      // Budget summary
                      FutureBuilder<List<BudgetModel>>(
                        future: Provider.of<DatabaseService>(context).getBudgets(),
                        builder: (context, budgetsSnapshot) {
                          if (budgetsSnapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          
                          final budgets = budgetsSnapshot.data ?? [];
                          
                          if (budgets.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('No budgets yet. Create your first one!'),
                              ),
                            );
                          }
                          
                          return BudgetSummary(budgets: budgets);
                        },
                      ),
                      
                      // Premium upgrade card
                      FutureBuilder<List<BudgetModel>>(
                        future: Provider.of<DatabaseService>(context).getBudgets(),
                        builder: (context, budgetsSnapshot) {
                          final budgets = budgetsSnapshot.data ?? [];
                          if (budgets.length >= AppConstants.maxBudgetsInFreeTier &&
                              !Provider.of<SubscriptionService>(context).isPremium) {
                            return _buildPremiumCard();
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildTransactionsTab() {
    return const TransactionsScreen();
  }
  
  Widget _buildBudgetsTab() {
    return const BudgetsScreen();
  }
  
  Widget _buildReportsTab() {
    // Navigate to the reports screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_currentIndex == 3) {
        Navigator.of(context).pushReplacementNamed(AppRouter.reports);
      }
    });
    
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
  
  Widget _buildSettingsTab() {
    // Navigate to the settings screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_currentIndex == 4) {
        Navigator.of(context).pushReplacementNamed(AppRouter.settings);
      }
    });
    
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
  
  Widget _buildPremiumCard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      color: AppColors.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(
          color: AppColors.primary.withOpacity(0.3),
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.star,
                  color: AppColors.premiumGold,
                ),
                const SizedBox(width: 8.0),
                Text(
                  'Upgrade to Premium',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              'Unlock unlimited wallets, budgets, and more premium features.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRouter.premium);
              },
              child: const Text('Upgrade Now'),
            ),
          ],
        ),
      ),
    );
  }
}