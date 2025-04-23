import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/budget/budget_model.dart';
import '../../../models/category/category_model.dart';
import '../../../models/transaction/transaction_model.dart';
import '../../../services/analytics/analytics_service.dart';
import '../../../services/database/database_service.dart';
import '../../../services/subscription/subscription_service.dart';
import '../../settings/providers/settings_provider.dart';
import '../../transactions/widgets/transaction_list_item.dart';

class BudgetDetailScreen extends StatefulWidget {
  final String budgetId;

  const BudgetDetailScreen({
    Key? key,
    required this.budgetId,
  }) : super(key: key);

  @override
  State<BudgetDetailScreen> createState() => _BudgetDetailScreenState();
}

class _BudgetDetailScreenState extends State<BudgetDetailScreen> {
  BudgetModel? _budget;
  CategoryModel? _category;
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    
    // Log screen view
    final analyticsService = Provider.of<AnalyticsService>(context, listen: false);
    analyticsService.logScreenView(
      screenName: 'budget_detail',
      screenClass: 'BudgetDetailScreen',
    );
    
    // Load budget data
    _loadBudgetData();
  }
  
  Future<void> _loadBudgetData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final databaseService = Provider.of<DatabaseService>(context, listen: false);
      
      // Load budget
      final budget = await databaseService.getBudgetById(widget.budgetId);
      
      if (budget == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Budget not found'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.of(context).pop();
        }
        return;
      }
      
      // Load category if available
      CategoryModel? category;
      if (budget.categoryId != null) {
        category = await databaseService.getCategoryById(budget.categoryId!);
      }
      
      // Load transactions for this budget
      final transactions = await databaseService.getTransactionsForBudget(budget);
      
      if (mounted) {
        setState(() {
          _budget = budget;
          _category = category;
          _transactions = transactions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading budget: $e'),
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
    
    if (_budget == null) {
      return const Scaffold(
        body: Center(child: Text('Budget not found')),
      );
    }
    
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final subscriptionService = Provider.of<SubscriptionService>(context);
    final isPremium = subscriptionService.isPremium;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_budget!.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).pushNamed(
                AppRouter.createBudget,
                arguments: _budget,
              ).then((_) => _loadBudgetData());
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
                    Text('Delete Budget'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadBudgetData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Budget summary card
              _buildBudgetSummary(context),
              
              // Budget progress chart
              if (isPremium)
                _buildBudgetChart(context),
              
              // Transactions list
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Transactions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              if (_transactions.isEmpty)
                _buildEmptyTransactions(context)
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = _transactions[index];
                    return TransactionListItem(
                      transaction: transaction,
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          AppRouter.createTransaction,
                          arguments: transaction,
                        ).then((_) => _loadBudgetData());
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(
            AppRouter.createTransaction,
            arguments: {
              'categoryId': _budget!.categoryId,
              'isExpense': true,
            },
          ).then((_) => _loadBudgetData());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildBudgetSummary(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Budget name and category
            Row(
              children: [
                if (_category != null)
                  CircleAvatar(
                    backgroundColor: Color(_category!.color ?? 0xFF9E9E9E).withOpacity(0.2),
                    child: Icon(
                      _category!.icon != null ? Icons.category : Icons.category,
                      color: Color(_category!.color ?? 0xFF9E9E9E),
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _budget!.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_category != null)
                        Text(
                          _category!.name,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
                if (_budget!.isRecurring)
                  Tooltip(
                    message: 'Recurring Budget',
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.repeat,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Budget period
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  '${DateFormat.yMMMd().format(_budget!.startDate)} - ${DateFormat.yMMMd().format(_budget!.endDate)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Budget progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Budget',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      settingsProvider.formatAmount(_budget!.amount),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Spent',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      settingsProvider.formatAmount(_budget!.spent),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _budget!.isOverBudget ? Colors.red : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: _budget!.percentSpent / 100 > 1.0 ? 1.0 : _budget!.percentSpent / 100,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  color: _getProgressColor(_budget!.percentSpent),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _budget!.isOverBudget
                          ? 'Over budget by ${settingsProvider.formatAmount(_budget!.spent - _budget!.amount)}'
                          : 'Remaining: ${settingsProvider.formatAmount(_budget!.remaining)}',
                      style: TextStyle(
                        color: _budget!.isOverBudget ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_budget!.percentSpent.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: _getProgressColor(_budget!.percentSpent),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBudgetChart(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    
    // Group transactions by day
    final Map<DateTime, double> dailySpending = {};
    
    for (final transaction in _transactions) {
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      
      if (!dailySpending.containsKey(date)) {
        dailySpending[date] = 0;
      }
      
      dailySpending[date] = dailySpending[date]! + transaction.amount;
    }
    
    // Sort dates
    final sortedDates = dailySpending.keys.toList()..sort();
    
    // Create chart data
    final spots = <FlSpot>[];
    double cumulativeSpending = 0;
    
    for (int i = 0; i < sortedDates.length; i++) {
      final date = sortedDates[i];
      cumulativeSpending += dailySpending[date]!;
      spots.add(FlSpot(i.toDouble(), cumulativeSpending));
    }
    
    if (spots.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending Trend',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= sortedDates.length || value.toInt() < 0) {
                            return const SizedBox.shrink();
                          }
                          
                          // Only show some dates to avoid overcrowding
                          if (sortedDates.length <= 5 || 
                              value.toInt() == 0 || 
                              value.toInt() == sortedDates.length - 1 ||
                              value.toInt() % (sortedDates.length ~/ 5) == 0) {
                            final date = sortedDates[value.toInt()];
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                DateFormat('d MMM').format(date),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }
                          
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                    // Budget line
                    LineChartBarData(
                      spots: [
                        FlSpot(0, _budget!.amount),
                        FlSpot(sortedDates.length - 1.0, _budget!.amount),
                      ],
                      isCurved: false,
                      color: Colors.red,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      dashArray: [5, 5],
                    ),
                  ],
                  minY: 0,
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((spot) {
                          if (spot.barIndex == 0) {
                            return LineTooltipItem(
                              settingsProvider.formatAmount(spot.y),
                              const TextStyle(color: Colors.white),
                            );
                          } else {
                            return LineTooltipItem(
                              'Budget: ${settingsProvider.formatAmount(spot.y)}',
                              const TextStyle(color: Colors.white),
                            );
                          }
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyTransactions(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No transactions yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first transaction to start tracking your budget',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  AppRouter.createTransaction,
                  arguments: {
                    'categoryId': _budget!.categoryId,
                    'isExpense': true,
                  },
                ).then((_) => _loadBudgetData());
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Transaction'),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getProgressColor(double percent) {
    if (percent >= 100) {
      return Colors.red;
    } else if (percent >= 80) {
      return Colors.orange;
    } else if (percent >= 60) {
      return Colors.amber;
    } else {
      return Colors.green;
    }
  }
  
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: Text(
          'Are you sure you want to delete "${_budget!.name}"? '
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
              await _deleteBudget();
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
  
  Future<void> _deleteBudget() async {
    try {
      final databaseService = Provider.of<DatabaseService>(context, listen: false);
      final analyticsService = Provider.of<AnalyticsService>(context, listen: false);
      
      // Delete budget
      await databaseService.deleteBudget(_budget!.id!);
      
      // Log event
      analyticsService.logBudgetDeleted(
        amount: _budget!.amount,
        isRecurring: _budget!.isRecurring,
      );
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Budget deleted successfully'),
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