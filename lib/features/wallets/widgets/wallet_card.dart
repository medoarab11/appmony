import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/wallet/wallet_model.dart';
import '../../settings/providers/settings_provider.dart';

class WalletCard extends StatelessWidget {
  final WalletModel wallet;
  final VoidCallback onTap;

  const WalletCard({
    Key? key,
    required this.wallet,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wallet name and type
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    child: Icon(
                      _getWalletIcon(),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          wallet.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getWalletTypeText(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 16),
              
              // Balance
              Text(
                'Current Balance',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                settingsProvider.formatAmount(wallet.balance),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: wallet.balance >= 0 ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              
              // Income and expense summary
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Income',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          settingsProvider.formatAmount(wallet.totalIncome),
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expense',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          settingsProvider.formatAmount(wallet.totalExpense),
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
  
  IconData _getWalletIcon() {
    switch (wallet.type) {
      case 'cash':
        return Icons.money;
      case 'bank':
        return Icons.account_balance;
      case 'credit_card':
        return Icons.credit_card;
      case 'savings':
        return Icons.savings;
      case 'investment':
        return Icons.trending_up;
      default:
        return Icons.account_balance_wallet;
    }
  }
  
  String _getWalletTypeText() {
    switch (wallet.type) {
      case 'cash':
        return 'Cash';
      case 'bank':
        return 'Bank Account';
      case 'credit_card':
        return 'Credit Card';
      case 'savings':
        return 'Savings Account';
      case 'investment':
        return 'Investment Account';
      default:
        return 'Wallet';
    }
  }
}