import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../models/subscription/subscription_model.dart';
import '../../models/currency/currency_model.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  late SharedPreferences _prefs;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> _products = [];
  
  // Subscription IDs
  final List<String> _subscriptionIds = [
    AppConstants.monthlySubscriptionId,
    AppConstants.yearlySubscriptionId,
  ];
  
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    
    // Listen for purchases
    final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onDone: _updateStreamOnDone,
      onError: _updateStreamOnError,
    );
    
    // Load products
    await _loadProducts();
  }
  
  // Load available products
  Future<void> _loadProducts() async {
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      _products = [];
      return;
    }
    
    try {
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_subscriptionIds.toSet());
      if (response.notFoundIDs.isNotEmpty) {
        print('Products not found: ${response.notFoundIDs}');
      }
      
      _products = response.productDetails;
    } catch (e) {
      print('Error loading products: $e');
      _products = [];
    }
  }
  
  // Get available subscriptions
  List<SubscriptionModel> getSubscriptions(String currencyCode) {
    if (_products.isEmpty) {
      // Return placeholder subscriptions if products are not loaded
      return [
        SubscriptionModel.monthlyPlan(
          currencyCode: currencyCode,
          price: 4.99,
        ),
        SubscriptionModel.yearlyPlan(
          currencyCode: currencyCode,
          price: 49.99,
        ),
      ];
    }
    
    final List<SubscriptionModel> subscriptions = [];
    
    // Find monthly subscription
    final monthlyProduct = _products.firstWhere(
      (product) => product.id == AppConstants.monthlySubscriptionId,
      orElse: () => ProductDetails(
        id: AppConstants.monthlySubscriptionId,
        title: 'Monthly Premium',
        description: 'Full access to all premium features',
        price: '4.99',
        rawPrice: 4.99,
        currencyCode: currencyCode,
      ),
    );
    
    subscriptions.add(SubscriptionModel.monthlyPlan(
      currencyCode: monthlyProduct.currencyCode,
      price: monthlyProduct.rawPrice.toDouble(),
    ));
    
    // Find yearly subscription
    final yearlyProduct = _products.firstWhere(
      (product) => product.id == AppConstants.yearlySubscriptionId,
      orElse: () => ProductDetails(
        id: AppConstants.yearlySubscriptionId,
        title: 'Yearly Premium',
        description: 'Full access to all premium features',
        price: '49.99',
        rawPrice: 49.99,
        currencyCode: currencyCode,
      ),
    );
    
    subscriptions.add(SubscriptionModel.yearlyPlan(
      currencyCode: yearlyProduct.currencyCode,
      price: yearlyProduct.rawPrice.toDouble(),
    ));
    
    // Add free trial if available
    subscriptions.add(SubscriptionModel.freeTrial(
      currencyCode: currencyCode,
    ));
    
    return subscriptions;
  }
  
  // Purchase a subscription
  Future<bool> purchaseSubscription(String subscriptionId) async {
    if (_products.isEmpty) {
      await _loadProducts();
    }
    
    try {
      final ProductDetails? productDetails = _products.firstWhere(
        (product) => product.id == subscriptionId,
        orElse: () => null,
      );
      
      if (productDetails == null) {
        print('Product not found: $subscriptionId');
        return false;
      }
      
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
        applicationUserName: null,
      );
      
      return await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      print('Error purchasing subscription: $e');
      return false;
    }
  }
  
  // Handle purchase updates
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show pending UI
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        // Show error UI
        print('Purchase error: ${purchaseDetails.error}');
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                 purchaseDetails.status == PurchaseStatus.restored) {
        // Grant entitlement for the purchased product
        _verifyPurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        // Show canceled UI
      }
      
      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }
  
  // Verify purchase
  Future<void> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // In a production app, you would verify the purchase on your server
    // For this example, we'll just mark the user as premium
    
    if (_subscriptionIds.contains(purchaseDetails.productID)) {
      await _prefs.setBool(AppConstants.prefIsPremium, true);
      
      // Set expiry date (1 month for monthly, 1 year for yearly)
      final DateTime now = DateTime.now();
      DateTime expiryDate;
      
      if (purchaseDetails.productID == AppConstants.monthlySubscriptionId) {
        expiryDate = DateTime(now.year, now.month + 1, now.day);
      } else {
        expiryDate = DateTime(now.year + 1, now.month, now.day);
      }
      
      await _prefs.setInt('premium_expiry_date', expiryDate.millisecondsSinceEpoch);
    }
  }
  
  // Check if user is premium
  bool get isPremium => _prefs.getBool(AppConstants.prefIsPremium) ?? false;
  
  // Get premium expiry date
  DateTime? get premiumExpiryDate {
    final int? timestamp = _prefs.getInt('premium_expiry_date');
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }
  
  // Restore purchases
  Future<bool> restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
      return true;
    } catch (e) {
      print('Error restoring purchases: $e');
      return false;
    }
  }
  
  // Stream update handlers
  void _updateStreamOnDone() {
    _subscription?.cancel();
  }
  
  void _updateStreamOnError(dynamic error) {
    print('Stream error: $error');
  }
  
  // Dispose
  void dispose() {
    _subscription?.cancel();
  }
}