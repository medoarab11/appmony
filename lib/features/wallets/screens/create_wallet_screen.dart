import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../models/wallet/wallet_model.dart';
import '../../../services/analytics/analytics_service.dart';
import '../../../services/database/database_service.dart';
import '../../../services/subscription/subscription_service.dart';
import '../../settings/providers/settings_provider.dart';

class CreateWalletScreen extends StatefulWidget {
  final WalletModel? wallet;

  const CreateWalletScreen({
    Key? key,
    this.wallet,
  }) : super(key: key);

  @override
  State<CreateWalletScreen> createState() => _CreateWalletScreenState();
}

class _CreateWalletScreenState extends State<CreateWalletScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  
  // Form values
  String _walletType = 'cash';
  
  // Loading state
  bool _isLoading = false;
  
  // Wallet count for free tier limit check
  int _walletCount = 0;
  
  @override
  void initState() {
    super.initState();
    
    // Log screen view
    final analyticsService = Provider.of<AnalyticsService>(context, listen: false);
    analyticsService.logScreenView(
      screenName: 'create_wallet',
      screenClass: 'CreateWalletScreen',
    );
    
    // If editing an existing wallet, populate the form
    if (widget.wallet != null) {
      _populateForm();
    } else {
      // Set default name
      _nameController.text = 'My Wallet';
      _balanceController.text = '0.00';
    }
    
    // Get wallet count
    _getWalletCount();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }
  
  Future<void> _getWalletCount() async {
    final databaseService = Provider.of<DatabaseService>(context, listen: false);
    final wallets = await databaseService.getWallets();
    
    setState(() {
      _walletCount = wallets.length;
    });
  }
  
  void _populateForm() {
    final wallet = widget.wallet!;
    
    setState(() {
      _nameController.text = wallet.name;
      _balanceController.text = wallet.balance.toString();
      _walletType = wallet.type;
    });
  }
  
  Future<void> _saveWallet() async {
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
      
      // Check if user can create more wallets
      if (widget.wallet == null && 
          _walletCount >= AppConstants.maxWalletsInFreeTier && 
          !subscriptionService.isPremium) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Free users can only create ${AppConstants.maxWalletsInFreeTier} wallets. '
              'Upgrade to premium to create unlimited wallets.',
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
      
      // Parse balance
      final balance = double.parse(_balanceController.text);
      
      // Create wallet model
      final wallet = WalletModel(
        id: widget.wallet?.id,
        name: _nameController.text,
        balance: balance,
        type: _walletType,
        totalIncome: widget.wallet?.totalIncome ?? 0.0,
        totalExpense: widget.wallet?.totalExpense ?? 0.0,
      );
      
      // Save wallet
      if (widget.wallet == null) {
        // Create new wallet
        await databaseService.createWallet(wallet);
        
        // Log event
        analyticsService.logWalletCreated(
          walletType: _walletType,
          initialBalance: balance,
        );
      } else {
        // Update existing wallet
        await databaseService.updateWallet(wallet);
        
        // Log event
        analyticsService.logWalletUpdated(
          walletType: _walletType,
          balance: balance,
        );
      }
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.wallet == null
                  ? 'Wallet created successfully'
                  : 'Wallet updated successfully',
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
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.wallet == null
              ? 'Create Wallet'
              : 'Edit Wallet',
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
                        labelText: 'Wallet Name',
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
                    
                    // Balance field
                    TextFormField(
                      controller: _balanceController,
                      decoration: InputDecoration(
                        labelText: 'Initial Balance',
                        prefixText: settingsProvider.currency.symbol,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a balance';
                        }
                        
                        try {
                          double.parse(value);
                        } catch (e) {
                          return 'Please enter a valid number';
                        }
                        
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Wallet type
                    const Text(
                      'Wallet Type',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildWalletTypeSelector(),
                    const SizedBox(height: 32),
                    
                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveWallet,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        child: Text(
                          widget.wallet == null ? 'Create Wallet' : 'Update Wallet',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildWalletTypeSelector() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildWalletTypeOption(
          type: 'cash',
          icon: Icons.money,
          label: 'Cash',
        ),
        _buildWalletTypeOption(
          type: 'bank',
          icon: Icons.account_balance,
          label: 'Bank',
        ),
        _buildWalletTypeOption(
          type: 'credit_card',
          icon: Icons.credit_card,
          label: 'Credit Card',
        ),
        _buildWalletTypeOption(
          type: 'savings',
          icon: Icons.savings,
          label: 'Savings',
        ),
        _buildWalletTypeOption(
          type: 'investment',
          icon: Icons.trending_up,
          label: 'Investment',
        ),
        _buildWalletTypeOption(
          type: 'other',
          icon: Icons.account_balance_wallet,
          label: 'Other',
        ),
      ],
    );
  }
  
  Widget _buildWalletTypeOption({
    required String type,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _walletType == type;
    
    return InkWell(
      onTap: () {
        setState(() {
          _walletType = type;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}