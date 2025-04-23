import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../models/category/category_model.dart';
import '../../../models/transaction/transaction_model.dart';
import '../../../models/wallet/wallet_model.dart';
import '../../../services/database/database_service.dart';
import '../../settings/providers/settings_provider.dart';

class TransactionListItem extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const TransactionListItem({
    Key? key,
    required this.transaction,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseService>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    
    return FutureBuilder<CategoryModel?>(
      future: transaction.categoryId != null
          ? databaseService.getCategoryById(transaction.categoryId!)
          : Future.value(null),
      builder: (context, categorySnapshot) {
        final category = categorySnapshot.data;
        
        return FutureBuilder<WalletModel?>(
          future: databaseService.getWalletById(transaction.walletId),
          builder: (context, walletSnapshot) {
            final wallet = walletSnapshot.data;
            
            return ListTile(
              leading: _buildLeadingIcon(context, category),
              title: Text(
                category?.name ?? 
                (transaction.isTransfer ? 'Transfer' : 
                (transaction.isIncome ? 'Income' : 'Expense')),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (transaction.description != null && transaction.description!.isNotEmpty)
                    Text(
                      transaction.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(
                    wallet != null ? 'Wallet: ${wallet.name}' : '',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    transaction.isExpense
                        ? '- ${settingsProvider.formatAmount(transaction.amount)}'
                        : '+ ${settingsProvider.formatAmount(transaction.amount)}',
                    style: TextStyle(
                      color: transaction.isExpense
                          ? Colors.red
                          : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormat('h:mm a').format(transaction.date),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              onTap: onTap,
              onLongPress: onLongPress,
            );
          },
        );
      },
    );
  }
  
  Widget _buildLeadingIcon(BuildContext context, CategoryModel? category) {
    final iconData = _getCategoryIcon(category);
    final color = category != null && category.color != null
        ? Color(category.color!)
        : _getDefaultColor(context);
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: color,
      ),
    );
  }
  
  IconData _getCategoryIcon(CategoryModel? category) {
    if (category != null && category.icon != null) {
      // TODO: Convert string icon to IconData
      return Icons.category;
    }
    
    if (transaction.isExpense) {
      return Icons.arrow_upward;
    } else if (transaction.isIncome) {
      return Icons.arrow_downward;
    } else {
      return Icons.swap_horiz;
    }
  }
  
  Color _getDefaultColor(BuildContext context) {
    if (transaction.isExpense) {
      return Colors.red;
    } else if (transaction.isIncome) {
      return Colors.green;
    } else {
      return Colors.blue;
    }
  }
}