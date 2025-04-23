import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/transaction/transaction_model.dart';
import '../../settings/providers/settings_provider.dart';

class MonthlyTrendChart extends StatelessWidget {
  final List<TransactionModel> transactions;
  
  const MonthlyTrendChart({
    Key? key,
    required this.transactions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    
    // If there's no data, show a placeholder
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.trending_up,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No data to display',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
    
    // Group transactions by month
    final Map<String, double> monthlyIncome = {};
    final Map<String, double> monthlyExpense = {};
    
    // Get the last 6 months
    final List<DateTime> months = [];
    final now = DateTime.now();
    for (int i = 5; i >= 0; i--) {
      months.add(DateTime(now.year, now.month - i, 1));
    }
    
    // Initialize maps with zero values for all months
    for (final month in months) {
      final monthKey = DateFormat('yyyy-MM').format(month);
      monthlyIncome[monthKey] = 0;
      monthlyExpense[monthKey] = 0;
    }
    
    // Populate with actual data
    for (final transaction in transactions) {
      final date = transaction.date;
      final monthKey = DateFormat('yyyy-MM').format(date);
      
      if (transaction.isExpense) {
        monthlyExpense[monthKey] = (monthlyExpense[monthKey] ?? 0) + transaction.amount;
      } else {
        monthlyIncome[monthKey] = (monthlyIncome[monthKey] ?? 0) + transaction.amount;
      }
    }
    
    // Prepare data for the chart
    final List<FlSpot> incomeSpots = [];
    final List<FlSpot> expenseSpots = [];
    final List<String> bottomTitles = [];
    
    for (int i = 0; i < months.length; i++) {
      final monthKey = DateFormat('yyyy-MM').format(months[i]);
      bottomTitles.add(DateFormat('MMM').format(months[i]));
      
      incomeSpots.add(FlSpot(i.toDouble(), monthlyIncome[monthKey] ?? 0));
      expenseSpots.add(FlSpot(i.toDouble(), monthlyExpense[monthKey] ?? 0));
    }
    
    // Find max value for Y axis
    final maxIncome = incomeSpots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    final maxExpense = expenseSpots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    final maxY = (maxIncome > maxExpense ? maxIncome : maxExpense) * 1.2;
    
    return Column(
      children: [
        // Chart
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: maxY / 5,
                verticalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.3),
                    strokeWidth: 1,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.3),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < bottomTitles.length) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            bottomTitles[value.toInt()],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: maxY / 5,
                    reservedSize: 42,
                    getTitlesWidget: (value, meta) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          settingsProvider.formatAmount(value, showSymbol: false),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              minX: 0,
              maxX: months.length - 1.0,
              minY: 0,
              maxY: maxY,
              lineBarsData: [
                // Income line
                LineChartBarData(
                  spots: incomeSpots,
                  isCurved: true,
                  color: Colors.green,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.green.withOpacity(0.1),
                  ),
                ),
                // Expense line
                LineChartBarData(
                  spots: expenseSpots,
                  isCurved: true,
                  color: Colors.red,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.red.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Legend
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(context, color: Colors.green, label: 'Income'),
              const SizedBox(width: 24),
              _buildLegendItem(context, color: Colors.red, label: 'Expense'),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildLegendItem(
    BuildContext context, {
    required Color color,
    required String label,
  }) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}