import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/category/category_model.dart';
import '../../../models/transaction/transaction_model.dart';
import '../../../models/wallet/wallet_model.dart';
import '../../../services/analytics/analytics_service.dart';
import '../../../services/database/database_service.dart';
import '../../../services/subscription/subscription_service.dart';
import '../../settings/providers/settings_provider.dart';

class CreateTransactionScreen extends StatefulWidget {
  final TransactionModel? transaction;

  const CreateTransactionScreen({
    Key? key,
    this.transaction,
  }) : super(key: key);

  @override
  State<CreateTransactionScreen> createState() => _CreateTransactionScreenState();
}

class _CreateTransactionScreenState extends State<CreateTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // Form values
  String _transactionType = 'expense';
  String? _selectedCategoryId;
  String? _selectedWalletId;
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;
  String _recurringType = 'monthly';
  int _recurringInterval = 1;
  
  // Loading state
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    
    // Log screen view
    final analyticsService = Provider.of<AnalyticsService>(context, listen: false);
    analyticsService.logScreenView(
      screenName: 'create_transaction',
      screenClass: 'CreateTransactionScreen',
    );
    
    // If editing an existing transaction, populate the form
    if (widget.transaction != null) {
      _populateForm();
    }
  }
  
  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  void _populateForm() {
    final transaction = widget.transaction!;
    
    setState(() {
      _transactionType = transaction.type;
      _selectedCategoryId = transaction.categoryId;
      _selectedWalletId = transaction.walletId;
      _selectedDate = transaction.date;
      _isRecurring = transaction.isRecurring;
      _recurringType = transaction.recurringType ?? 'monthly';
      _recurringInterval = transaction.recurringInterval ?? 1;
      
      _amountController.text = transaction.amount.toString();
      _descriptionController.text = transaction.description ?? '';
    });
  }
  
  Future<void> _saveTransaction() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Check if wallet is selected
    if (_selectedWalletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a wallet'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final databaseService = Provider.of<DatabaseService>(context, listen: false);
      final analyticsService = Provider.of<AnalyticsService>(context, listen: false);
      
      // Parse amount
      final amount = double.parse(_amountController.text);
      
      // Create transaction model
      final transaction = TransactionModel(
        id: widget.transaction?.id,
        amount: amount,
        type: _transactionType,
        categoryId: _selectedCategoryId,
        walletId: _selectedWalletId!,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        date: _selectedDate,
        isRecurring: _isRecurring,
        recurringType: _isRecurring ? _recurringType : null,
        recurringInterval: _isRecurring ? _recurringInterval : null,
      );
      
      // Save transaction
      if (widget.transaction == null) {
        // Create new transaction
        await databaseService.createTransaction(transaction);
        
        // Log event
        analyticsService.logTransactionCreated(
          amount: amount,
          type: _transactionType,
          isRecurring: _isRecurring,
        );
      } else {
        // Update existing transaction
        await databaseService.updateTransaction(transaction);
        
        // Log event
        analyticsService.logTransactionUpdated(
          amount: amount,
          type: _transactionType,
          isRecurring: _isRecurring,
        );
      }
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.transaction == null
                  ? 'Transaction created successfully'
                  : 'Transaction updated successfully',
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
          widget.transaction == null
              ? 'Create Transaction'
              : 'Edit Transaction',
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
                    // Transaction type selector
                    _buildTransactionTypeSelector(),
                    const SizedBox(height: 24),
                    
                    // Amount field
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: 'Amount',
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
                    
                    // Wallet selector
                    _buildWalletSelector(),
                    const SizedBox(height: 16),
                    
                    // Date picker
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Description field
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    
                    // Recurring transaction (premium feature)
                    SwitchListTile(
                      title: const Text('Recurring Transaction'),
                      subtitle: Text(
                        isPremium
                            ? 'This transaction will repeat automatically'
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
                                      value: 'daily',
                                      child: Text('Daily'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'weekly',
                                      child: Text('Weekly'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'monthly',
                                      child: Text('Monthly'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'yearly',
                                      child: Text('Yearly'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _recurringType = value!;
                                    });
                                  },
                                ),
                                const SizedBox(height: 16),
                                
                                // Recurring interval
                                Row(
                                  children: [
                                    const Text('Repeat every'),
                                    const SizedBox(width: 16),
                                    DropdownButton<int>(
                                      value: _recurringInterval,
                                      items: List.generate(
                                        10,
                                        (index) => DropdownMenuItem(
                                          value: index + 1,
                                          child: Text('${index + 1}'),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          _recurringInterval = value!;
                                        });
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _recurringType == 'daily'
                                          ? _recurringInterval == 1
                                              ? 'day'
                                              : 'days'
                                          : _recurringType == 'weekly'
                                              ? _recurringInterval == 1
                                                  ? 'week'
                                                  : 'weeks'
                                              : _recurringType == 'monthly'
                                                  ? _recurringInterval == 1
                                                      ? 'month'
                                                      : 'months'
                                                  : _recurringInterval == 1
                                                      ? 'year'
                                                      : 'years',
                                    ),
                                  ],
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
                        onPressed: _saveTransaction,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        child: Text(
                          widget.transaction == null ? 'Create Transaction' : 'Update Transaction',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildTransactionTypeSelector() {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(
          value: 'expense',
          label: Text('Expense'),
          icon: Icon(Icons.arrow_upward),
        ),
        ButtonSegment(
          value: 'income',
          label: Text('Income'),
          icon: Icon(Icons.arrow_downward),
        ),
        ButtonSegment(
          value: 'transfer',
          label: Text('Transfer'),
          icon: Icon(Icons.swap_horiz),
        ),
      ],
      selected: {_transactionType},
      onSelectionChanged: (selected) {
        setState(() {
          _transactionType = selected.first;
        });
      },
    );
  }
  
  Widget _buildCategorySelector() {
    return FutureBuilder<List<CategoryModel>>(
      future: Provider.of<DatabaseService>(context).getCategories(
        type: _transactionType,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final categories = snapshot.data ?? [];
        
        return DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Category',
            border: OutlineInputBorder(),
          ),
          value: _selectedCategoryId,
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('Select a category'),
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
  
  Widget _buildWalletSelector() {
    return FutureBuilder<List<WalletModel>>(
      future: Provider.of<DatabaseService>(context).getWallets(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final wallets = snapshot.data ?? [];
        
        if (wallets.isEmpty) {
          return const Card(
            color: AppColors.error,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'You need to create a wallet first',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }
        
        return DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Wallet',
            border: OutlineInputBorder(),
          ),
          value: _selectedWalletId ?? wallets.first.id,
          items: wallets.map((wallet) => DropdownMenuItem(
            value: wallet.id,
            child: Text(wallet.name),
          )).toList(),
          onChanged: (value) {
            setState(() {
              _selectedWalletId = value;
            });
          },
        );
      },
    );
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
}