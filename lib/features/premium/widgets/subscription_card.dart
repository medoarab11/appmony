import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/subscription/subscription_model.dart';

class SubscriptionCard extends StatelessWidget {
  final SubscriptionModel subscription;
  final bool isSelected;
  final VoidCallback onTap;
  
  const SubscriptionCard({
    Key? key,
    required this.subscription,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Radio button
              Radio<bool>(
                value: true,
                groupValue: isSelected ? true : null,
                onChanged: (_) => onTap(),
                activeColor: AppColors.primary,
              ),
              const SizedBox(width: 8),
              
              // Subscription details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          subscription.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (subscription.isPopular)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.premiumGold.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'POPULAR',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.premiumGold,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subscription.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    if (subscription.discountPercentage != null && subscription.discountPercentage! > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Save ${subscription.discountPercentage!.toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${subscription.currencyCode} ${subscription.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subscription.period == 'monthly' ? 'per month' : 
                    subscription.period == 'yearly' ? 'per year' : 
                    subscription.period == 'trial' ? 'free trial' : '',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
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
}