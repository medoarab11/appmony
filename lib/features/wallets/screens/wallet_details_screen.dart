import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/navigation/app_router.dart';
import '../../../models/transaction/transaction_model.dart';
import '../../../models/wallet/wallet_model.dart';
import '../../../services/admob/admob_service.dart';
import '../../../services/analytics/analytics_service.dart';
import '../../../services/database/database_service.dart';
import '../../../services/subscription/subscription_service.dart';
import '../../settings/providers/settings_provider.dart';
import '../../transactions/widgets/transaction_list_item.dart';

class WalletDetailsScreen extends StatefulWidget {
  final WalletModel wallet;

  const WalletDetailsScreen({
    Key? key,
    required this.wallet,
  }) : super(key: key);

  @override
  State<WalletDetailsScreen> createState() => _WalletDetailsScreenState();
}

class _WalletDetailsScreenState extends State<WalletDetailsScreen> {
  // Selected time period
  String _selectedPeriod = 'month';
  
  @override
  void initState() {
    super.initState();
    
    // Log screen view
    final analyticsService = Provider.of<AnalyticsService>(context, listen: false);
    analyticsService.logScreenView(
      screenName: 'wallet_details',
      screenClass: 'WalletDetailsScreen',
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseService>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final subscriptionService = Provider.of<SubscriptionService>(context);
    final adMobService = Provider.of<AdMobService>(context);
    
    final isPremium = subscriptionService.isPremium;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.wallet.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).pushNamed(
                AppRouter.createWallet,
                arguments: widget.wallet,
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteConfirmation(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete Wallet'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Wallet summary card
          _buildWalletSummary(context),
          
          // Time period selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text('Show transactions for: '),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedPeriod,
                  onChanged: (value) {
                    setState(() {
                      _selectedPeriod = value!;
                    });
                  },
                  items: const [
                    DropdownMenuItem(
                      value: 'week',
                      child: Text('This Week'),
                    ),
                    DropdownMenuItem(
                      value: 'month',
                      child: Text('This Month'),
                    ),
                    DropdownMenuItem(
                      value: 'year',
                      child: Text('This Year'),
                    ),
                    DropdownMenuItem(
                      value: 'all',
                      child: Text('All Time'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Ad banner for free users
          if (!isPremium)
            Container(
              height: 50,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: adMobService.getBannerWidget(),
            ),
          
          // Transactions list
          Expanded(
            child: FutureBuilder<List<TransactionModel>>(
              future: _getTransactionsForPeriod(databaseService),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading transactions: ${snapshot.error}',
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
                          Icons.receipt_long,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions for this period',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              AppRouter.createTransaction,
                              arguments: {'walletId': widget.wallet.id},
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Transaction'),
                        ),
                      ],
                    ),
                  );
                }
                
                // Group transactions by date
                final groupedTransactions = _groupTransactionsByDate(transactions);
                
                return ListView.builder(
                  itemCount: groupedTransactions.length,
                  itemBuilder: (context, index) {
                    final date = groupedTransactions.keys.elementAt(index);
                    final dateTransactions = groupedTransactions[date]!;
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date header
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            _formatDateHeader(date),
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        
                        // Transactions for this date
                        ...dateTransactions.map((transaction) => TransactionListItem(
                          transaction: transaction,
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              AppRouter.createTransaction,
                              arguments: transaction,
                            );
                          },
                        )),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(
            AppRouter.createTransaction,
            arguments: {'walletId': widget.wallet.id},
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildWalletSummary(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wallet type and name
            Row(
              children: [
                Icon(
                  _getWalletIcon(),
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.wallet.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Balance
            Text(
              'Current Balance',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              settingsProvider.formatAmount(widget.wallet.balance),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: widget.wallet.balance >= 0 ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            
            // Income and expense summary
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Income',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        settingsProvider.formatAmount(widget.wallet.totalIncome),
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
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
                        'Total Expense',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        settingsProvider.formatAmount(widget.wallet.totalExpense),
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getWalletIcon() {
    switch (widget.wallet.type) {
      case 'cash':
        return Icons.money;
      case 'bank':
        return Icons.account_balance;
      case 'credit_card':
        return Icons.credit_card;
      case 'savings':
        return Icons.savings;
      case 'investment':
        return Icons.trending_up;
      default:
        return Icons.account_balance_wallet;
    }
  }
  
  Future<List<TransactionModel>> _getTransactionsForPeriod(DatabaseService databaseService) async {
    final now = DateTime.now();
    DateTime? startDate;
    
    switch (_selectedPeriod) {
      case 'week':
        // Start of current week (Monday)
        final weekday = now.weekday;
        startDate = now.subtract(Duration(days: weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case 'month':
        // Start of current month
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'year':
        // Start of current year
        startDate = DateTime(now.year, 1, 1);
        break;
      case 'all':
        // All transactions
        startDate = null;
        break;
    }
    
    return databaseService.getFilteredTransactions(
      walletId: widget.wallet.id,
      startDate: startDate,
    );
  }
  
  Map<DateTime, List<TransactionModel>> _groupTransactionsByDate(List<TransactionModel> transactions) {
    final groupedTransactions = <DateTime, List<TransactionModel>>{};
    
    for (final transaction in transactions) {
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      
      if (!groupedTransactions.containsKey(date)) {
        groupedTransactions[date] = [];
      }
      
      groupedTransactions[date]!.add(transaction);
    }
    
    return groupedTransactions;
  }
  
  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    } else if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      return 'Yesterday';
    } else if (date.year == now.year) {
      return DateFormat('EEEE, MMMM d').format(date);
    } else {
      return DateFormat('EEEE, MMMM d, yyyy').format(date);
    }
  }
  
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Wallet'),
        content: Text(
          'Are you sure you want to delete "${widget.wallet.name}"? '
          'This will also delete all transactions associated with this wallet. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteWallet();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _deleteWallet() async {
    try {
      final databaseService = Provider.of<DatabaseService>(context, listen: false);
      final analyticsService = Provider.of<AnalyticsService>(context, listen: false);
      
      // Delete wallet
      await databaseService.deleteWallet(widget.wallet.id!);
      
      // Log event
      analyticsService.logWalletDeleted(
        walletType: widget.wallet.type,
      );
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wallet deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate back
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}