import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/budget/budget_model.dart';
import '../../../models/category/category_model.dart';
import '../../../services/analytics/analytics_service.dart';
import '../../../services/database/database_service.dart';
import '../../../services/subscription/subscription_service.dart';
import '../../settings/providers/settings_provider.dart';
import '../widgets/budget_card.dart';
import '../widgets/budget_filter.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({Key? key}) : super(key: key);

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  // Filter values
  String? _selectedCategoryId;
  bool _showActive = true;
  
  @override
  void initState() {
    super.initState();
    
    // Log screen view
    final analyticsService = Provider.of<AnalyticsService>(context, listen: false);
    analyticsService.logScreenView(
      screenName: 'budgets',
      screenClass: 'BudgetsScreen',
    );
  }
  
  void _resetFilters() {
    setState(() {
      _selectedCategoryId = null;
      _showActive = true;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseService>(context);
    final subscriptionService = Provider.of<SubscriptionService>(context);
    final isPremium = subscriptionService.isPremium;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
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
          // Active filters
          if (_selectedCategoryId != null || !_showActive)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Text('Active filters:'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (_selectedCategoryId != null)
                            _buildFilterChip(
                              label: 'Category',
                              onDeleted: () {
                                setState(() {
                                  _selectedCategoryId = null;
                                });
                              },
                            ),
                          if (!_showActive)
                            _buildFilterChip(
                              label: 'Show All',
                              onDeleted: () {
                                setState(() {
                                  _showActive = true;
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
          
          // Budgets list
          Expanded(
            child: FutureBuilder<List<BudgetModel>>(
              future: databaseService.getFilteredBudgets(
                categoryId: _selectedCategoryId,
                activeOnly: _showActive,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading budgets: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                
                final budgets = snapshot.data ?? [];
                
                if (budgets.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.account_balance_wallet,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedCategoryId != null || !_showActive
                              ? 'No budgets match your filters'
                              : 'No budgets yet',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        if (_selectedCategoryId == null && _showActive)
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pushNamed(AppRouter.createBudget);
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Create Budget'),
                          ),
                      ],
                    ),
                  );
                }
                
                // Check if user has reached the free tier limit
                final showUpgradeCard = !isPremium && 
                    budgets.length >= AppConstants.maxBudgetsInFreeTier;
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: budgets.length + (showUpgradeCard ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (showUpgradeCard && index == 0) {
                      return _buildPremiumCard();
                    }
                    
                    final actualIndex = showUpgradeCard ? index - 1 : index;
                    final budget = budgets[actualIndex];
                    
                    return BudgetCard(
                      budget: budget,
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          AppRouter.createBudget,
                          arguments: budget,
                        );
                      },
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
          Navigator.of(context).pushNamed(AppRouter.createBudget);
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
        return BudgetFilter(
          selectedCategoryId: _selectedCategoryId,
          showActive: _showActive,
          onApplyFilters: (categoryId, showActive) {
            setState(() {
              _selectedCategoryId = categoryId;
              _showActive = showActive;
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
  
  Widget _buildPremiumCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
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
              'You\'ve reached the limit of ${AppConstants.maxBudgetsInFreeTier} budgets in the free version. '
              'Upgrade to premium for unlimited budgets and more features.',
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