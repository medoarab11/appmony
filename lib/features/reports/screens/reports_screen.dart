import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/transaction/transaction_model.dart';
import '../../../services/admob/admob_service.dart';
import '../../../services/analytics/analytics_service.dart';
import '../../../services/database/database_service.dart';
import '../../../services/subscription/subscription_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../widgets/category_distribution_chart.dart';
import '../widgets/expense_income_chart.dart';
import '../widgets/monthly_trend_chart.dart';
import '../widgets/premium_report_card.dart';
import '../widgets/report_filter.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'month';
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  
  BannerAd? _bannerAd;
  
  @override
  void initState() {
    super.initState();
    
    // Log screen view
    final analyticsService = Provider.of<AnalyticsService>(context, listen: false);
    analyticsService.logScreenView(
      screenName: 'reports',
      screenClass: 'ReportsScreen',
    );
    
    // Load banner ad
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
    final databaseService = Provider.of<DatabaseService>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final subscriptionService = Provider.of<SubscriptionService>(context);
    final isPremium = subscriptionService.isPremium;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
      ),
      body: Column(
        children: [
          // Report filters
          ReportFilter(
            selectedPeriod: _selectedPeriod,
            startDate: _startDate,
            endDate: _endDate,
            onPeriodChanged: (period) {
              setState(() {
                _selectedPeriod = period;
                
                // Update date range based on period
                final now = DateTime.now();
                switch (period) {
                  case 'week':
                    _startDate = now.subtract(const Duration(days: 7));
                    _endDate = now;
                    break;
                  case 'month':
                    _startDate = DateTime(now.year, now.month - 1, now.day);
                    _endDate = now;
                    break;
                  case 'quarter':
                    _startDate = DateTime(now.year, now.month - 3, now.day);
                    _endDate = now;
                    break;
                  case 'year':
                    _startDate = DateTime(now.year - 1, now.month, now.day);
                    _endDate = now;
                    break;
                  case 'custom':
                    // Keep current custom dates
                    break;
                }
              });
            },
            onDateRangeChanged: (start, end) {
              setState(() {
                _startDate = start;
                _endDate = end;
                _selectedPeriod = 'custom';
              });
            },
          ),
          
          // Reports content
          Expanded(
            child: FutureBuilder<List<TransactionModel>>(
              future: databaseService.getTransactionsByDateRange(
                startDate: _startDate,
                endDate: _endDate,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading reports: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                
                final transactions = snapshot.data ?? [];
                
                if (transactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.bar_chart,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions found',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add some transactions to see your reports',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                // Calculate total income and expenses
                double totalIncome = 0;
                double totalExpense = 0;
                
                for (final transaction in transactions) {
                  if (transaction.isExpense) {
                    totalExpense += transaction.amount;
                  } else {
                    totalIncome += transaction.amount;
                  }
                }
                
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Income vs Expense summary
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Income vs Expense',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Income',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          settingsProvider.formatAmount(totalIncome),
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Expense',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          settingsProvider.formatAmount(totalExpense),
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 200,
                                child: ExpenseIncomeChart(
                                  income: totalIncome,
                                  expense: totalExpense,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Category distribution
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Expense by Category',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 250,
                                child: CategoryDistributionChart(
                                  transactions: transactions.where((t) => t.isExpense).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Monthly trend (premium feature)
                      if (isPremium)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Monthly Trend',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 250,
                                  child: MonthlyTrendChart(
                                    transactions: transactions,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        PremiumReportCard(
                          title: 'Monthly Trend',
                          description: 'Track your income and expenses over time with detailed monthly trends.',
                          icon: Icons.trending_up,
                        ),
                      
                      const SizedBox(height: 16),
                      
                      // Export options (premium feature)
                      if (isPremium)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Export Data',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          // TODO: Implement CSV export
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Exporting to CSV...'),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.file_download),
                                        label: const Text('CSV'),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          // TODO: Implement Google Sheets export
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Exporting to Google Sheets...'),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.table_chart),
                                        label: const Text('Google Sheets'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        PremiumReportCard(
                          title: 'Export Data',
                          description: 'Export your financial data to CSV or Google Sheets for further analysis.',
                          icon: Icons.file_download,
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Ad banner for free users
          if (!isPremium && _bannerAd != null)
            Container(
              alignment: Alignment.center,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            )
        ],
      ),
    );
  }
}