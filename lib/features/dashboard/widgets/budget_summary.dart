import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/navigation/app_router.dart';
import '../../../models/budget/budget_model.dart';
import '../../../services/database/database_service.dart';
import '../../settings/providers/settings_provider.dart';

class BudgetSummary extends StatelessWidget {
  final List<BudgetModel> budgets;
  
  const BudgetSummary({
    Key? key,
    required this.budgets,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (budgets.isEmpty) {
      return _buildEmptyState(context);
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: budgets.length > 3 ? 3 : budgets.length,
      itemBuilder: (context, index) {
        final budget = budgets[index];
        return _buildBudgetItem(context, budget);
      },
    );
  }
  
  Widget _buildBudgetItem(BuildContext context, BudgetModel budget) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final databaseService = Provider.of<DatabaseService>(context);
    
    return FutureBuilder(
      future: databaseService.getCategoryById(budget.categoryId),
      builder: (context, snapshot) {
        final category = snapshot.data;
        
        // Calculate progress
        final progress = budget.spent / budget.amount;
        final isOverBudget = progress > 1.0;
        
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(
                AppRouter.budgetDetail,
                arguments: budget,
              );
            },
            borderRadius: BorderRadius.circular(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Budget name and icon
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: category?.color?.withOpacity(0.2) ?? Colors.blue.withOpacity(0.2),
                        child: Icon(
                          category?.icon ?? Icons.category,
                          color: category?.color ?? Colors.blue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              budget.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              category?.name ?? 'Category',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${settingsProvider.formatAmount(budget.spent)} / ${settingsProvider.formatAmount(budget.amount)}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isOverBudget ? Colors.red : null,
                            ),
                          ),
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}%',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isOverBudget ? Colors.red : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress > 1.0 ? 1.0 : progress,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      color: isOverBudget ? Colors.red : Colors.green,
                      minHeight: 8,
                    ),
                  ),
                  
                  if (isOverBudget)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Over budget by ${settingsProvider.formatAmount(budget.spent - budget.amount)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_balance_wallet_outlined,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No budgets yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first budget to start managing your expenses',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRouter.createBudget);
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Budget'),
            ),
          ],
        ),
      ),
    );
  }
}