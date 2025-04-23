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
import '../widgets/transaction_filter.dart';
import '../widgets/transaction_list_item.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  // Filter values
  String? _selectedWalletId;
  String? _selectedCategoryId;
  String? _selectedType;
  DateTime? _startDate;
  DateTime? _endDate;
  
  // Search query
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    
    // Log screen view
    final analyticsService = Provider.of<AnalyticsService>(context, listen: false);
    analyticsService.logScreenView(
      screenName: 'transactions',
      screenClass: 'TransactionsScreen',
    );
    
    // Add listener to search controller
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _resetFilters() {
    setState(() {
      _selectedWalletId = null;
      _selectedCategoryId = null;
      _selectedType = null;
      _startDate = null;
      _endDate = null;
      _searchController.clear();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterBottomSheet(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search transactions',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 16.0,
                ),
              ),
            ),
          ),
          
          // Active filters
          if (_selectedWalletId != null ||
              _selectedCategoryId != null ||
              _selectedType != null ||
              _startDate != null ||
              _endDate != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Text('Active filters:'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (_selectedWalletId != null)
                            _buildFilterChip(
                              label: 'Wallet',
                              onDeleted: () {
                                setState(() {
                                  _selectedWalletId = null;
                                });
                              },
                            ),
                          if (_selectedCategoryId != null)
                            _buildFilterChip(
                              label: 'Category',
                              onDeleted: () {
                                setState(() {
                                  _selectedCategoryId = null;
                                });
                              },
                            ),
                          if (_selectedType != null)
                            _buildFilterChip(
                              label: _selectedType!.capitalize(),
                              onDeleted: () {
                                setState(() {
                                  _selectedType = null;
                                });
                              },
                            ),
                          if (_startDate != null || _endDate != null)
                            _buildFilterChip(
                              label: 'Date Range',
                              onDeleted: () {
                                setState(() {
                                  _startDate = null;
                                  _endDate = null;
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _resetFilters,
                    child: const Text('Reset'),
                  ),
                ],
              ),
            ),
          
          // Transactions list
          Expanded(
            child: FutureBuilder<List<TransactionModel>>(
              future: databaseService.getFilteredTransactions(
                walletId: _selectedWalletId,
                categoryId: _selectedCategoryId,
                type: _selectedType,
                startDate: _startDate,
                endDate: _endDate,
                searchQuery: _searchQuery,
              ),
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
                          _searchQuery.isNotEmpty || 
                          _selectedWalletId != null ||
                          _selectedCategoryId != null ||
                          _selectedType != null ||
                          _startDate != null ||
                          _endDate != null
                              ? 'No transactions match your filters'
                              : 'No transactions yet',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        if (_searchQuery.isEmpty && 
                            _selectedWalletId == null &&
                            _selectedCategoryId == null &&
                            _selectedType == null &&
                            _startDate == null &&
                            _endDate == null)
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pushNamed(AppRouter.createTransaction);
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
          Navigator.of(context).pushNamed(AppRouter.createTransaction);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildFilterChip({
    required String label,
    required VoidCallback onDeleted,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        label: Text(label),
        deleteIcon: const Icon(Icons.close, size: 16),
        onDeleted: onDeleted,
      ),
    );
  }
  
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return TransactionFilter(
          selectedWalletId: _selectedWalletId,
          selectedCategoryId: _selectedCategoryId,
          selectedType: _selectedType,
          startDate: _startDate,
          endDate: _endDate,
          onApplyFilters: (walletId, categoryId, type, startDate, endDate) {
            setState(() {
              _selectedWalletId = walletId;
              _selectedCategoryId = categoryId;
              _selectedType = type;
              _startDate = startDate;
              _endDate = endDate;
            });
            Navigator.pop(context);
          },
          onResetFilters: () {
            _resetFilters();
            Navigator.pop(context);
          },
        );
      },
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
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}