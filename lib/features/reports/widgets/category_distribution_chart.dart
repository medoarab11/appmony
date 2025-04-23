import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../../../models/category/category_model.dart';
import '../../../models/transaction/transaction_model.dart';
import '../../../services/database/database_service.dart';
import '../../settings/providers/settings_provider.dart';

class CategoryDistributionChart extends StatefulWidget {
  final List<TransactionModel> transactions;
  
  const CategoryDistributionChart({
    Key? key,
    required this.transactions,
  }) : super(key: key);

  @override
  State<CategoryDistributionChart> createState() => _CategoryDistributionChartState();
}

class _CategoryDistributionChartState extends State<CategoryDistributionChart> {
  int _touchedIndex = -1;
  
  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseService>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    
    // If there's no data, show a placeholder
    if (widget.transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.pie_chart,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No expense data to display',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
    
    // Group transactions by category
    final Map<String, double> categoryAmounts = {};
    
    for (final transaction in widget.transactions) {
      final categoryId = transaction.categoryId;
      if (categoryId != null) {
        categoryAmounts[categoryId] = (categoryAmounts[categoryId] ?? 0) + transaction.amount;
      }
    }
    
    // Sort categories by amount (descending)
    final sortedCategoryIds = categoryAmounts.keys.toList()
      ..sort((a, b) => categoryAmounts[b]!.compareTo(categoryAmounts[a]!));
    
    // Calculate total amount
    final totalAmount = categoryAmounts.values.fold<double>(0, (sum, amount) => sum + amount);
    
    return FutureBuilder<List<CategoryModel>>(
      future: databaseService.getAllCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading categories: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        
        final categories = snapshot.data ?? [];
        final categoryMap = {for (var category in categories) category.id: category};
        
        return Row(
          children: [
            // Pie chart
            Expanded(
              flex: 3,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          _touchedIndex = -1;
                          return;
                        }
                        _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  sections: _buildPieChartSections(
                    sortedCategoryIds,
                    categoryAmounts,
                    totalAmount,
                    categoryMap,
                  ),
                ),
              ),
            ),
            
            // Legend
            Expanded(
              flex: 2,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: sortedCategoryIds.length > 5 ? 5 : sortedCategoryIds.length,
                itemBuilder: (context, index) {
                  final categoryId = sortedCategoryIds[index];
                  final category = categoryMap[categoryId];
                  final amount = categoryAmounts[categoryId] ?? 0;
                  final percentage = (amount / totalAmount) * 100;
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: category?.color ?? Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category?.name ?? 'Unknown',
                                style: Theme.of(context).textTheme.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${percentage.toStringAsFixed(1)}% (${settingsProvider.formatAmount(amount)})',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
  
  List<PieChartSectionData> _buildPieChartSections(
    List<String> categoryIds,
    Map<String, double> categoryAmounts,
    double totalAmount,
    Map<String, CategoryModel> categoryMap,
  ) {
    return List.generate(categoryIds.length, (index) {
      final categoryId = categoryIds[index];
      final category = categoryMap[categoryId];
      final amount = categoryAmounts[categoryId] ?? 0;
      final percentage = (amount / totalAmount) * 100;
      
      final isTouched = index == _touchedIndex;
      final radius = isTouched ? 110.0 : 100.0;
      
      return PieChartSectionData(
        color: category?.color ?? Colors.grey,
        value: amount,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }
}