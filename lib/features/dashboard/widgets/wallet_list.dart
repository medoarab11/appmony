import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/navigation/app_router.dart';
import '../../../models/wallet/wallet_model.dart';
import '../../../services/admob/admob_service.dart';
import 'balance_card.dart';

class WalletList extends StatelessWidget {
  final List<WalletModel> wallets;
  
  const WalletList({
    Key? key,
    required this.wallets,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (wallets.isEmpty) {
      return _buildEmptyState(context);
    }
    
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: wallets.length + 1, // +1 for the "Add Wallet" card
        itemBuilder: (context, index) {
          if (index == wallets.length) {
            return _buildAddWalletCard(context);
          }
          
          final wallet = wallets[index];
          return SizedBox(
            width: 300,
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: BalanceCard(
                wallet: wallet,
                onTap: () {
                  Navigator.of(context).pushNamed(
                    AppRouter.walletDetail,
                    arguments: wallet,
                  );
                  
                  // Show interstitial ad occasionally
                  final adMobService = Provider.of<AdMobService>(context, listen: false);
                  adMobService.showInterstitialAd();
                },
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.account_balance_wallet_outlined,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No wallets yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first wallet to start tracking your finances',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRouter.createWallet);
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Wallet'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAddWalletCard(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () {
            Navigator.of(context).pushNamed(AppRouter.createWallet);
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_circle_outline,
                size: 48,
              ),
              const SizedBox(height: 8),
              Text(
                'Add Wallet',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}