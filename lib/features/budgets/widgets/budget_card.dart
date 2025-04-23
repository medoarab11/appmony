import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../models/budget/budget_model.dart';
import '../../../models/category/category_model.dart';
import '../../../services/database/database_service.dart';
import '../../settings/providers/settings_provider.dart';

class BudgetCard extends StatelessWidget {
  final BudgetModel budget;
  final VoidCallback? onTap;

  const BudgetCard({
    Key? key,
    required this.budget,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseService>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Budget name and category
              Row(
                children: [
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
                        if (budget.categoryId != null)
                          FutureBuilder<CategoryModel?>(
                            future: databaseService.getCategoryById(budget.categoryId!),
                            builder: (context, snapshot) {
                              final category = snapshot.data;
                              
                              return Text(
                                category?.name ?? 'Loading category...',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                  if (budget.isRecurring)
                    Tooltip(
                      message: 'Recurring Budget',
                      child: Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Icon(
                          Icons.repeat,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Budget progress
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Spent: ${settingsProvider.formatAmount(budget.spent)}',
                        style: TextStyle(
                          color: budget.isOverBudget ? Colors.red : null,
                        ),
                      ),
                      Text(
                        'Budget: ${settingsProvider.formatAmount(budget.amount)}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: budget.percentSpent / 100,
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    color: _getProgressColor(budget.percentSpent),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        budget.isOverBudget
                            ? 'Over budget by ${settingsProvider.formatAmount(budget.spent - budget.amount)}'
                            : 'Remaining: ${settingsProvider.formatAmount(budget.remaining)}',
                        style: TextStyle(
                          color: budget.isOverBudget ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${budget.percentSpent.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: _getProgressColor(budget.percentSpent),
                        ),
                      ),
                    ],
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
                  const SizedBox(width: 4),
                  Text(
                    '${DateFormat('MMM d').format(budget.startDate)} - ${DateFormat('MMM d').format(budget.endDate)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  if (budget.isRecurring)
                    Text(
                      ' (${_getRecurringTypeText(budget.recurringType)})',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ],
          ),
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
  
  String _getRecurringTypeText(String? recurringType) {
    switch (recurringType) {
      case 'monthly':
        return 'Monthly';
      case 'quarterly':
        return 'Quarterly';
      case 'yearly':
        return 'Yearly';
      default:
        return 'Recurring';
    }
  }
}