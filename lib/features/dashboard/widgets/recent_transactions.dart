import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/navigation/app_router.dart';
import '../../../models/transaction/transaction_model.dart';
import '../../../services/database/database_service.dart';
import '../../settings/providers/settings_provider.dart';

class RecentTransactions extends StatelessWidget {
  final List<TransactionModel> transactions;
  
  const RecentTransactions({
    Key? key,
    required this.transactions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return _buildEmptyState(context);
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _buildTransactionItem(context, transaction);
      },
    );
  }
  
  Widget _buildTransactionItem(BuildContext context, TransactionModel transaction) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final databaseService = Provider.of<DatabaseService>(context);
    
    return FutureBuilder(
      future: Future.wait([
        databaseService.getCategoryById(transaction.categoryId),
        databaseService.getWalletById(transaction.walletId),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        final category = snapshot.data?[0];
        final wallet = snapshot.data?[1];
        
        return ListTile(
          onTap: () {
            Navigator.of(context).pushNamed(
              AppRouter.transactionDetail,
              arguments: transaction,
            );
          },
          leading: CircleAvatar(
            backgroundColor: category?.color?.withOpacity(0.2) ?? 
                            (transaction.isExpense ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.2)),
            child: Icon(
              category?.icon ?? (transaction.isExpense ? Icons.arrow_downward : Icons.arrow_upward),
              color: category?.color ?? (transaction.isExpense ? Colors.red : Colors.green),
            ),
          ),
          title: Text(
            transaction.description.isNotEmpty ? transaction.description : (category?.name ?? 'Transaction'),
          ),
          subtitle: Text(
            '${wallet?.name ?? 'Wallet'} • ${DateFormat.yMMMd().format(transaction.date)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
          ),
          trailing: Text(
            (transaction.isExpense ? '- ' : '+ ') + settingsProvider.formatAmount(transaction.amount),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: transaction.isExpense ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No transactions yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first transaction to start tracking your finances',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRouter.createTransaction);
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Transaction'),
            ),
          ],
        ),
      ),
    );
  }
}