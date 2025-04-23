import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../models/category/category_model.dart';
import '../../../models/wallet/wallet_model.dart';
import '../../../services/database/database_service.dart';

class TransactionFilter extends StatefulWidget {
  final String? selectedWalletId;
  final String? selectedCategoryId;
  final String? selectedType;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(String?, String?, String?, DateTime?, DateTime?) onApplyFilters;
  final VoidCallback onResetFilters;

  const TransactionFilter({
    Key? key,
    this.selectedWalletId,
    this.selectedCategoryId,
    this.selectedType,
    this.startDate,
    this.endDate,
    required this.onApplyFilters,
    required this.onResetFilters,
  }) : super(key: key);

  @override
  State<TransactionFilter> createState() => _TransactionFilterState();
}

class _TransactionFilterState extends State<TransactionFilter> {
  String? _selectedWalletId;
  String? _selectedCategoryId;
  String? _selectedType;
  DateTime? _startDate;
  DateTime? _endDate;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize with current values
    _selectedWalletId = widget.selectedWalletId;
    _selectedCategoryId = widget.selectedCategoryId;
    _selectedType = widget.selectedType;
    _startDate = widget.startDate;
    _endDate = widget.endDate;
  }
  
  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseService>(context);
    
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Transactions',
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
              
              // Filter options
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    // Transaction type
                    const Text(
                      'Transaction Type',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildFilterChip(
                          label: 'All',
                          selected: _selectedType == null,
                          onSelected: (selected) {
                            setState(() {
                              _selectedType = null;
                            });
                          },
                        ),
                        _buildFilterChip(
                          label: 'Expense',
                          selected: _selectedType == 'expense',
                          onSelected: (selected) {
                            setState(() {
                              _selectedType = selected ? 'expense' : null;
                            });
                          },
                        ),
                        _buildFilterChip(
                          label: 'Income',
                          selected: _selectedType == 'income',
                          onSelected: (selected) {
                            setState(() {
                              _selectedType = selected ? 'income' : null;
                            });
                          },
                        ),
                        _buildFilterChip(
                          label: 'Transfer',
                          selected: _selectedType == 'transfer',
                          onSelected: (selected) {
                            setState(() {
                              _selectedType = selected ? 'transfer' : null;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Wallet
                    const Text(
                      'Wallet',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<List<WalletModel>>(
                      future: databaseService.getWallets(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        
                        final wallets = snapshot.data ?? [];
                        
                        return Wrap(
                          spacing: 8,
                          children: [
                            _buildFilterChip(
                              label: 'All',
                              selected: _selectedWalletId == null,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedWalletId = null;
                                });
                              },
                            ),
                            ...wallets.map((wallet) => _buildFilterChip(
                              label: wallet.name,
                              selected: _selectedWalletId == wallet.id,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedWalletId = selected ? wallet.id : null;
                                });
                              },
                            )),
                          ],
                        );
                      },
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
                      future: databaseService.getCategories(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        
                        final categories = snapshot.data ?? [];
                        
                        return Wrap(
                          spacing: 8,
                          children: [
                            _buildFilterChip(
                              label: 'All',
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
                    const SizedBox(height: 16),
                    
                    // Date range
                    const Text(
                      'Date Range',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectStartDate(context),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'From',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                _startDate != null
                                    ? DateFormat('MMM d, yyyy').format(_startDate!)
                                    : 'Any',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectEndDate(context),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'To',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                _endDate != null
                                    ? DateFormat('MMM d, yyyy').format(_endDate!)
                                    : 'Any',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildFilterChip(
                          label: 'All Time',
                          selected: _startDate == null && _endDate == null,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _startDate = null;
                                _endDate = null;
                              });
                            }
                          },
                        ),
                        _buildFilterChip(
                          label: 'Today',
                          selected: _isToday(),
                          onSelected: (selected) {
                            if (selected) {
                              final now = DateTime.now();
                              setState(() {
                                _startDate = DateTime(now.year, now.month, now.day);
                                _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
                              });
                            }
                          },
                        ),
                        _buildFilterChip(
                          label: 'This Week',
                          selected: _isThisWeek(),
                          onSelected: (selected) {
                            if (selected) {
                              final now = DateTime.now();
                              final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
                              setState(() {
                                _startDate = DateTime(firstDayOfWeek.year, firstDayOfWeek.month, firstDayOfWeek.day);
                                _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
                              });
                            }
                          },
                        ),
                        _buildFilterChip(
                          label: 'This Month',
                          selected: _isThisMonth(),
                          onSelected: (selected) {
                            if (selected) {
                              final now = DateTime.now();
                              setState(() {
                                _startDate = DateTime(now.year, now.month, 1);
                                _endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
                              });
                            }
                          },
                        ),
                        _buildFilterChip(
                          label: 'This Year',
                          selected: _isThisYear(),
                          onSelected: (selected) {
                            if (selected) {
                              final now = DateTime.now();
                              setState(() {
                                _startDate = DateTime(now.year, 1, 1);
                                _endDate = DateTime(now.year, 12, 31, 23, 59, 59);
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
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
                        _selectedWalletId,
                        _selectedCategoryId,
                        _selectedType,
                        _startDate,
                        _endDate,
                      );
                    },
                    child: const Text('Apply Filters'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
  
  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked;
        
        // If end date is before start date, reset it
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
        }
      });
    }
  }
  
  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2000),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        _endDate = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
      });
    }
  }
  
  bool _isToday() {
    if (_startDate == null || _endDate == null) return false;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    return _startDate!.isAtSameMomentAs(today) && 
           _endDate!.isAtSameMomentAs(todayEnd);
  }
  
  bool _isThisWeek() {
    if (_startDate == null || _endDate == null) return false;
    
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final firstDay = DateTime(firstDayOfWeek.year, firstDayOfWeek.month, firstDayOfWeek.day);
    final lastDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    return _startDate!.isAtSameMomentAs(firstDay) && 
           _endDate!.isAtSameMomentAs(lastDay);
  }
  
  bool _isThisMonth() {
    if (_startDate == null || _endDate == null) return false;
    
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    
    return _startDate!.isAtSameMomentAs(firstDay) && 
           _endDate!.isAtSameMomentAs(lastDay);
  }
  
  bool _isThisYear() {
    if (_startDate == null || _endDate == null) return false;
    
    final now = DateTime.now();
    final firstDay = DateTime(now.year, 1, 1);
    final lastDay = DateTime(now.year, 12, 31, 23, 59, 59);
    
    return _startDate!.isAtSameMomentAs(firstDay) && 
           _endDate!.isAtSameMomentAs(lastDay);
  }
}