class SubscriptionModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final String currencyCode;
  final String period; // 'monthly' or 'yearly'
  final int durationMonths;
  final List<String> features;
  final double? discountPercentage;
  final bool isPopular;

  const SubscriptionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.currencyCode,
    required this.period,
    required this.durationMonths,
    required this.features,
    this.discountPercentage,
    this.isPopular = false,
  });

  // Calculate the monthly price
  double get monthlyPrice => period == 'monthly'
      ? price
      : price / durationMonths;

  // Calculate the discounted price
  double? get discountedPrice => discountPercentage != null
      ? price * (1 - discountPercentage! / 100)
      : null;

  // Calculate the savings amount
  double? get savingsAmount => discountPercentage != null
      ? price * (discountPercentage! / 100)
      : null;

  // Check if this is a free trial
  bool get isFreeTrial => price == 0;

  // Standard subscription plans
  static SubscriptionModel monthlyPlan({
    required String currencyCode,
    required double price,
  }) {
    return SubscriptionModel(
      id: 'appmony_premium_monthly',
      title: 'Monthly Premium',
      description: 'Full access to all premium features',
      price: price,
      currencyCode: currencyCode,
      period: 'monthly',
      durationMonths: 1,
      features: [
        'Unlimited wallets',
        'Unlimited budgets',
        'Recurring transactions',
        'Advanced reports and analytics',
        'Data backup and sync',
        'Export to CSV/Google Sheets',
        'No advertisements',
        'Premium themes',
      ],
      isPopular: false,
    );
  }

  static SubscriptionModel yearlyPlan({
    required String currencyCode,
    required double price,
    double discountPercentage = 16.67, // 2 months free (16.67% discount)
  }) {
    return SubscriptionModel(
      id: 'appmony_premium_yearly',
      title: 'Yearly Premium',
      description: 'Full access to all premium features',
      price: price,
      currencyCode: currencyCode,
      period: 'yearly',
      durationMonths: 12,
      features: [
        'Unlimited wallets',
        'Unlimited budgets',
        'Recurring transactions',
        'Advanced reports and analytics',
        'Data backup and sync',
        'Export to CSV/Google Sheets',
        'No advertisements',
        'Premium themes',
      ],
      discountPercentage: discountPercentage,
      isPopular: true,
    );
  }

  static SubscriptionModel freeTrial({
    required String currencyCode,
  }) {
    return SubscriptionModel(
      id: 'appmony_premium_trial',
      title: '7-Day Free Trial',
      description: 'Try all premium features for free',
      price: 0,
      currencyCode: currencyCode,
      period: 'trial',
      durationMonths: 0,
      features: [
        'Unlimited wallets',
        'Unlimited budgets',
        'Recurring transactions',
        'Advanced reports and analytics',
        'Data backup and sync',
        'Export to CSV/Google Sheets',
        'No advertisements',
        'Premium themes',
      ],
      isPopular: true,
    );
  }
}