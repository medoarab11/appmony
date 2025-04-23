import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/navigation/app_router.dart';
import '../../../models/category/category_model.dart';
import '../../../models/transaction/transaction_model.dart';
import '../../../models/wallet/wallet_model.dart';
import '../../../services/analytics/analytics_service.dart';
import '../../../services/database/database_service.dart';
import '../../settings/providers/settings_provider.dart';

class TransactionDetailScreen extends StatefulWidget {
  final String transactionId;

  const TransactionDetailScreen({
    Key? key,
    required this.transactionId,
  }) : super(key: key);

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  TransactionModel? _transaction;
  CategoryModel? _category;
  WalletModel? _wallet;
  WalletModel? _toWallet;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    
    // Log screen view
    final analyticsService = Provider.of<AnalyticsService>(context, listen: false);
    analyticsService.logScreenView(
      screenName: 'transaction_detail',
      screenClass: 'TransactionDetailScreen',
    );
    
    // Load transaction data
    _loadTransactionData();
  }
  
  Future<void> _loadTransactionData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final databaseService = Provider.of<DatabaseService>(context, listen: false);
      
      // Load transaction
      final transaction = await databaseService.getTransactionById(widget.transactionId);
      
      if (transaction == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaction not found'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.of(context).pop();
        }
        return;
      }
      
      // Load category if available
      CategoryModel? category;
      if (transaction.categoryId != null) {
        category = await databaseService.getCategoryById(transaction.categoryId!);
      }
      
      // Load wallet
      final wallet = await databaseService.getWalletById(transaction.walletId);
      
      // Load to wallet if it's a transfer
      WalletModel? toWallet;
      if (transaction.isTransfer && transaction.toWalletId != null) {
        toWallet = await databaseService.getWalletById(transaction.toWalletId!);
      }
      
      if (mounted) {
        setState(() {
          _transaction = transaction;
          _category = category;
          _wallet = wallet;
          _toWallet = toWallet;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading transaction: $e'),
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_transaction == null) {
      return const Scaffold(
        body: Center(child: Text('Transaction not found')),
      );
    }
    
    final settingsProvider = Provider.of<SettingsProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_transaction!.isExpense ? 'Expense' : (_transaction!.isIncome ? 'Income' : 'Transfer')),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).pushNamed(
                AppRouter.createTransaction,
                arguments: _transaction,
              ).then((_) => _loadTransactionData());
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
                    Text('Delete Transaction'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transaction amount card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Transaction type icon
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: _getTransactionColor().withOpacity(0.2),
                      child: Icon(
                        _getTransactionIcon(),
                        color: _getTransactionColor(),
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Amount
                    Text(
                      settingsProvider.formatAmount(_transaction!.amount),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getTransactionColor(),
                      ),
                    ),
                    
                    // Transaction type
                    Text(
                      _transaction!.isExpense
                          ? 'Expense'
                          : (_transaction!.isIncome ? 'Income' : 'Transfer'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Transaction details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaction Details',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Date
                    _buildDetailRow(
                      context,
                      icon: Icons.calendar_today,
                      label: 'Date',
                      value: DateFormat.yMMMd().format(_transaction!.date),
                    ),
                    
                    // Time
                    _buildDetailRow(
                      context,
                      icon: Icons.access_time,
                      label: 'Time',
                      value: DateFormat.jm().format(_transaction!.date),
                    ),
                    
                    // Category
                    if (_category != null)
                      _buildDetailRow(
                        context,
                        icon: Icons.category,
                        label: 'Category',
                        value: _category!.name,
                        color: Color(_category!.color ?? 0xFF9E9E9E),
                      ),
                    
                    // Wallet
                    if (_wallet != null)
                      _buildDetailRow(
                        context,
                        icon: Icons.account_balance_wallet,
                        label: _transaction!.isTransfer ? 'From Wallet' : 'Wallet',
                        value: _wallet!.name,
                      ),
                    
                    // To Wallet (for transfers)
                    if (_transaction!.isTransfer && _toWallet != null)
                      _buildDetailRow(
                        context,
                        icon: Icons.account_balance_wallet,
                        label: 'To Wallet',
                        value: _toWallet!.name,
                      ),
                    
                    // Description
                    if (_transaction!.description != null && _transaction!.description!.isNotEmpty)
                      _buildDetailRow(
                        context,
                        icon: Icons.description,
                        label: 'Description',
                        value: _transaction!.description!,
                      ),
                    
                    // Notes
                    if (_transaction!.notes != null && _transaction!.notes!.isNotEmpty)
                      _buildDetailRow(
                        context,
                        icon: Icons.note,
                        label: 'Notes',
                        value: _transaction!.notes!,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: (color ?? Theme.of(context).colorScheme.primary).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color ?? Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getTransactionIcon() {
    if (_category != null && _category!.icon != null) {
      // TODO: Convert string icon to IconData
      return Icons.category;
    }
    
    if (_transaction!.isExpense) {
      return Icons.arrow_upward;
    } else if (_transaction!.isIncome) {
      return Icons.arrow_downward;
    } else {
      return Icons.swap_horiz;
    }
  }
  
  Color _getTransactionColor() {
    if (_category != null && _category!.color != null) {
      return Color(_category!.color!);
    }
    
    if (_transaction!.isExpense) {
      return Colors.red;
    } else if (_transaction!.isIncome) {
      return Colors.green;
    } else {
      return Colors.blue;
    }
  }
  
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text(
          'Are you sure you want to delete this transaction? '
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
              await _deleteTransaction();
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
  
  Future<void> _deleteTransaction() async {
    try {
      final databaseService = Provider.of<DatabaseService>(context, listen: false);
      final analyticsService = Provider.of<AnalyticsService>(context, listen: false);
      
      // Delete transaction
      await databaseService.deleteTransaction(_transaction!.id!);
      
      // Log event
      analyticsService.logTransactionDeleted(
        amount: _transaction!.amount,
        type: _transaction!.isExpense
            ? 'expense'
            : (_transaction!.isIncome ? 'income' : 'transfer'),
      );
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction deleted successfully'),
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