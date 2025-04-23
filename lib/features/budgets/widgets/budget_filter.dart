import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/category/category_model.dart';
import '../../../services/database/database_service.dart';

class BudgetFilter extends StatefulWidget {
  final String? selectedCategoryId;
  final bool showActive;
  final Function(String?, bool) onApplyFilters;
  final VoidCallback onResetFilters;

  const BudgetFilter({
    Key? key,
    this.selectedCategoryId,
    this.showActive = true,
    required this.onApplyFilters,
    required this.onResetFilters,
  }) : super(key: key);

  @override
  State<BudgetFilter> createState() => _BudgetFilterState();
}

class _BudgetFilterState extends State<BudgetFilter> {
  String? _selectedCategoryId;
  bool _showActive = true;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize with current values
    _selectedCategoryId = widget.selectedCategoryId;
    _showActive = widget.showActive;
  }
  
  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseService>(context);
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Budgets',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          const Divider(),
          
          // Show active/all budgets
          const Text(
            'Budget Status',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildFilterChip(
                  label: 'Active Budgets',
                  selected: _showActive,
                  onSelected: (selected) {
                    setState(() {
                      _showActive = selected;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterChip(
                  label: 'All Budgets',
                  selected: !_showActive,
                  onSelected: (selected) {
                    setState(() {
                      _showActive = !selected;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Category
          const Text(
            'Category',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<CategoryModel>>(
            future: databaseService.getCategories(type: 'expense'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final categories = snapshot.data ?? [];
              
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFilterChip(
                    label: 'All Categories',
                    selected: _selectedCategoryId == null,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategoryId = null;
                      });
                    },
                  ),
                  ...categories.map((category) => _buildFilterChip(
                    label: category.name,
                    selected: _selectedCategoryId == category.id,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategoryId = selected ? category.id : null;
                      });
                    },
                  )),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: widget.onResetFilters,
                child: const Text('Reset'),
              ),
              ElevatedButton(
                onPressed: () {
                  widget.onApplyFilters(
                    _selectedCategoryId,
                    _showActive,
                  );
                },
                child: const Text('Apply Filters'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      showCheckmark: true,
    );
  }
}