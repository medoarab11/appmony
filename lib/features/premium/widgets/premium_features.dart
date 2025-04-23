import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class PremiumFeatures extends StatelessWidget {
  const PremiumFeatures({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Premium Features',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Feature list
        _buildFeatureItem(
          context,
          icon: Icons.wallet,
          title: 'Unlimited Wallets',
          description: 'Create and manage as many wallets as you need',
        ),
        _buildFeatureItem(
          context,
          icon: Icons.pie_chart,
          title: 'Advanced Reports',
          description: 'Get detailed insights with advanced analytics and charts',
        ),
        _buildFeatureItem(
          context,
          icon: Icons.sync,
          title: 'Cloud Sync',
          description: 'Sync your data across all your devices',
        ),
        _buildFeatureItem(
          context,
          icon: Icons.repeat,
          title: 'Recurring Budgets',
          description: 'Set up recurring budgets that reset automatically',
        ),
        _buildFeatureItem(
          context,
          icon: Icons.file_download,
          title: 'Data Export',
          description: 'Export your financial data to CSV or Google Sheets',
        ),
        _buildFeatureItem(
          context,
          icon: Icons.block,
          title: 'Ad-Free Experience',
          description: 'Enjoy the app without any advertisements',
        ),
        _buildFeatureItem(
          context,
          icon: Icons.color_lens,
          title: 'Premium Themes',
          description: 'Access exclusive themes and customization options',
        ),
      ],
    );
  }
  
  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: AppColors.premiumGold.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.premiumGold,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}