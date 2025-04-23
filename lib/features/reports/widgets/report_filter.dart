import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportFilter extends StatelessWidget {
  final String selectedPeriod;
  final DateTime startDate;
  final DateTime endDate;
  final Function(String) onPeriodChanged;
  final Function(DateTime, DateTime) onDateRangeChanged;
  
  const ReportFilter({
    Key? key,
    required this.selectedPeriod,
    required this.startDate,
    required this.endDate,
    required this.onPeriodChanged,
    required this.onDateRangeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPeriodButton(
                  context,
                  label: 'Week',
                  value: 'week',
                ),
                _buildPeriodButton(
                  context,
                  label: 'Month',
                  value: 'month',
                ),
                _buildPeriodButton(
                  context,
                  label: 'Quarter',
                  value: 'quarter',
                ),
                _buildPeriodButton(
                  context,
                  label: 'Year',
                  value: 'year',
                ),
                _buildPeriodButton(
                  context,
                  label: 'Custom',
                  value: 'custom',
                ),
              ],
            ),
          ),
          
          // Date range selector (only visible for custom period)
          if (selectedPeriod == 'custom')
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildDateSelector(
                      context,
                      label: 'From',
                      date: startDate,
                      onSelect: (date) {
                        if (date != null) {
                          onDateRangeChanged(date, endDate);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDateSelector(
                      context,
                      label: 'To',
                      date: endDate,
                      onSelect: (date) {
                        if (date != null) {
                          onDateRangeChanged(startDate, date);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          
          // Date range display (for non-custom periods)
          if (selectedPeriod != 'custom')
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '${DateFormat('MMM d, yyyy').format(startDate)} - ${DateFormat('MMM d, yyyy').format(endDate)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildPeriodButton(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final isSelected = selectedPeriod == value;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            onPeriodChanged(value);
          }
        },
      ),
    );
  }
  
  Widget _buildDateSelector(
    BuildContext context, {
    required String label,
    required DateTime date,
    required Function(DateTime?) onSelect,
  }) {
    return InkWell(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        
        onSelect(selectedDate);
      },
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 8.0,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMM d, yyyy').format(date),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}