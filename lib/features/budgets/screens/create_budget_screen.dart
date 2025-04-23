import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/budget/budget_model.dart';
import '../../../models/category/category_model.dart';
import '../../../services/analytics/analytics_service.dart';
import '../../../services/database/database_service.dart';
import '../../../services/subscription/subscription_service.dart';
import '../../settings/providers/settings_provider.dart';

class CreateBudgetScreen extends StatefulWidget {
  final BudgetModel? budget;

  const CreateBudgetScreen({
    Key? key,
    this.budget,
  }) : super(key: key);

  @override
  State<CreateBudgetScreen> createState() => _CreateBudgetScreenState();
}

class _CreateBudgetScreenState extends State<CreateBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  
  // Form values
  String? _selectedCategoryId;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  bool _isRecurring = false;
  String _recurringType = 'monthly';
  
  // Loading state
  bool _isLoading = false;
  
  // Budget count for free tier limit check
  int _budgetCount = 0;
  
  @override
  void initState() {
    super.initState();
    
    // Log screen view
    final analyticsService = Provider.of<AnalyticsService>(context, listen: false);
    analyticsService.logScreenView(
      screenName: 'create_budget',
      screenClass: 'CreateBudgetScreen',
    );
    
    // If editing an existing budget, populate the form
    if (widget.budget != null) {
      _populateForm();
    } else {
      // Set default name
      _nameController.text = 'Monthly Budget';
    }
    
    // Get budget count
    _getBudgetCount();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }
  
  Future<void> _getBudgetCount() async {
    final databaseService = Provider.of<DatabaseService>(context, listen: false);
    final budgets = await databaseService.getBudgets();
    
    setState(() {
      _budgetCount = budgets.length;
    });
  }
  
  void _populateForm() {
    final budget = widget.budget!;
    
    setState(() {
      _nameController.text = budget.name;
      _amountController.text = budget.amount.toString();
      _selectedCategoryId = budget.categoryId;
      _startDate = budget.startDate;
      _endDate = budget.endDate;
      _isRecurring = budget.isRecurring;
      _recurringType = budget.recurringType ?? 'monthly';
    });
  }
  
  Future<void> _saveBudget() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final databaseService = Provider.of<DatabaseService>(context, listen: false);
      final analyticsService = Provider.of<AnalyticsService>(context, listen: false);
      final subscriptionService = Provider.of<SubscriptionService>(context, listen: false);
      
      // Check if user can create more budgets
      if (widget.budget == null && 
          _budgetCount >= AppConstants.maxBudgetsInFreeTier && 
          !subscriptionService.isPremium) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Free users can only create ${AppConstants.maxBudgetsInFreeTier} budgets. '
              'Upgrade to premium to create unlimited budgets.',
            ),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Upgrade',
              onPressed: () {
                Navigator.of(context).pushNamed('/premium');
              },
            ),
          ),
        );
        return;
      }
      
      // Parse amount
      final amount = double.parse(_amountController.text);
      
      // Create budget model
      final budget = BudgetModel(
        id: widget.budget?.id,
        name: _nameController.text,
        amount: amount,
        spent: widget.budget?.spent ?? 0.0,
        categoryId: _selectedCategoryId,
        startDate: _startDate,
        endDate: _endDate,
        isRecurring: _isRecurring,
        recurringType: _isRecurring ? _recurringType : null,
      );
      
      // Save budget
      if (widget.budget == null) {
        // Create new budget
        await databaseService.createBudget(budget);
        
        // Log event
        analyticsService.logBudgetCreated(
          amount: amount,
          isRecurring: _isRecurring,
        );
      } else {
        // Update existing budget
        await databaseService.updateBudget(budget);
        
        // Log event
        analyticsService.logBudgetUpdated(
          amount: amount,
          isRecurring: _isRecurring,
        );
      }
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.budget == null
                  ? 'Budget created successfully'
                  : 'Budget updated successfully',
            ),
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final subscriptionService = Provider.of<SubscriptionService>(context);
    final isPremium = subscriptionService.isPremium;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.budget == null
              ? 'Create Budget'
              : 'Edit Budget',
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Budget Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Amount field
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: 'Budget Amount',
                        prefixText: settingsProvider.currency.symbol,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        
                        try {
                          final amount = double.parse(value);
                          if (amount <= 0) {
                            return 'Amount must be greater than zero';
                          }
                        } catch (e) {
                          return 'Please enter a valid number';
                        }
                        
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Category selector
                    _buildCategorySelector(),
                    const SizedBox(height: 16),
                    
                    // Date range
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectStartDate(context),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Start Date',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                DateFormat('MMM d, yyyy').format(_startDate),
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
                                labelText: 'End Date',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                DateFormat('MMM d, yyyy').format(_endDate),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Recurring budget (premium feature)
                    SwitchListTile(
                      title: const Text('Recurring Budget'),
                      subtitle: Text(
                        isPremium
                            ? 'This budget will reset automatically'
                            : 'Premium feature',
                      ),
                      value: isPremium && _isRecurring,
                      onChanged: isPremium
                          ? (value) {
                              setState(() {
                                _isRecurring = value;
                              });
                            }
                          : null,
                      secondary: Icon(
                        Icons.repeat,
                        color: isPremium ? null : Colors.grey,
                      ),
                    ),
                    
                    // Recurring options
                    if (isPremium && _isRecurring)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Recurring Options',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                // Recurring type
                                DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: 'Frequency',
                                    border: OutlineInputBorder(),
                                  ),
                                  value: _recurringType,
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'monthly',
                                      child: Text('Monthly'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'quarterly',
                                      child: Text('Quarterly'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'yearly',
                                      child: Text('Yearly'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _recurringType = value!;
                                      
                                      // Update end date based on recurring type
                                      if (value == 'monthly') {
                                        _endDate = DateTime(
                                          _startDate.year,
                                          _startDate.month + 1,
                                          _startDate.day - 1,
                                        );
                                      } else if (value == 'quarterly') {
                                        _endDate = DateTime(
                                          _startDate.year,
                                          _startDate.month + 3,
                                          _startDate.day - 1,
                                        );
                                      } else if (value == 'yearly') {
                                        _endDate = DateTime(
                                          _startDate.year + 1,
                                          _startDate.month,
                                          _startDate.day - 1,
                                        );
                                      }
                                    });
                                  },
                                ),
                                const SizedBox(height: 16),
                                
                                // Rollover option
                                SwitchListTile(
                                  title: const Text('Rollover Unused Budget'),
                                  subtitle: const Text(
                                    'Unused budget will be added to the next period',
                                  ),
                                  value: false, // TODO: Implement rollover functionality
                                  onChanged: (value) {
                                    // TODO: Implement rollover functionality
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 32),
                    
                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveBudget,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        child: Text(
                          widget.budget == null ? 'Create Budget' : 'Update Budget',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildCategorySelector() {
    return FutureBuilder<List<CategoryModel>>(
      future: Provider.of<DatabaseService>(context).getCategories(
        type: 'expense',
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final categories = snapshot.data ?? [];
        
        return DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Category (Optional)',
            border: OutlineInputBorder(),
          ),
          value: _selectedCategoryId,
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('All Categories'),
            ),
            ...categories.map((category) => DropdownMenuItem(
              value: category.id,
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Color(category.color ?? 0xFF9E9E9E),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(category.name),
                ],
              ),
            )),
          ],
          onChanged: (value) {
            setState(() {
              _selectedCategoryId = value;
            });
          },
        );
      },
    );
  }
  
  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        
        // Ensure end date is after start date
        if (_endDate.isBefore(_startDate)) {
          // Set end date based on recurring type
          if (_isRecurring) {
            if (_recurringType == 'monthly') {
              _endDate = DateTime(
                _startDate.year,
                _startDate.month + 1,
                _startDate.day - 1,
              );
            } else if (_recurringType == 'quarterly') {
              _endDate = DateTime(
                _startDate.year,
                _startDate.month + 3,
                _startDate.day - 1,
              );
            } else if (_recurringType == 'yearly') {
              _endDate = DateTime(
                _startDate.year + 1,
                _startDate.month,
                _startDate.day - 1,
              );
            }
          } else {
            _endDate = _startDate.add(const Duration(days: 30));
          }
        }
      });
    }
  }
  
  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate.isAfter(_startDate) ? _endDate : _startDate.add(const Duration(days: 1)),
      firstDate: _startDate.add(const Duration(days: 1)),
      lastDate: DateTime(2100),
    );
    
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }
}