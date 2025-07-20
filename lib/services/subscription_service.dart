import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:logger/logger.dart';

import '../entities/subscription_tier.dart';
import '../entities/purchase_result.dart';

/// Service for handling Google Play in-app purchases and subscriptions
class SubscriptionService {
  static const String _tag = 'SubscriptionService';
  
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final Logger _logger = Logger();
  
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  final StreamController<PurchaseResult> _purchaseController = 
      StreamController<PurchaseResult>.broadcast();

  /// Stream of purchase results
  Stream<PurchaseResult> get purchaseStream => _purchaseController.stream;

  /// Product IDs for all subscription tiers
  static const Set<String> _productIds = {
    'premium_monthly',
    'premium_yearly', 
    'premium_lifetime',
  };

  Future<void> initialize() async {
    _logger.d('$_tag: Initializing subscription service');
    
    try {
      // Check if in-app purchase is available
      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        throw Exception('In-app purchases not available on this device');
      }

      // Note: Pending purchases are enabled by default in newer versions

      // Listen to purchase updates
      _subscription = _inAppPurchase.purchaseStream.listen(
        _onPurchaseUpdated,
        onDone: () => _logger.d('$_tag: Purchase stream done'),
        onError: (error) => _logger.e('$_tag: Purchase stream error: $error'),
      );

      _logger.i('$_tag: Subscription service initialized successfully');
    } catch (e) {
      _logger.e('$_tag: Failed to initialize subscription service: $e');
      throw Exception('Failed to initialize subscription service: $e');
    }
  }

  /// Gets available products from Google Play
  Future<List<ProductDetails>> getAvailableProducts() async {
    _logger.d('$_tag: Getting available products');
    
    try {
      final ProductDetailsResponse response = 
          await _inAppPurchase.queryProductDetails(_productIds);
      
      if (response.error != null) {
        throw Exception('Failed to get products: ${response.error!.message}');
      }

      _logger.d('$_tag: Found ${response.productDetails.length} available products');
      return response.productDetails;
    } catch (e) {
      _logger.e('$_tag: Failed to get available products: $e');
      throw Exception('Failed to get available products: $e');
    }
  }

  /// Initiates a purchase for the specified subscription tier
  Future<void> purchaseSubscription(SubscriptionTier tier) async {
    _logger.d('$_tag: Purchasing subscription: ${tier.name}');
    
    try {
      if (tier == SubscriptionTier.free) {
        throw Exception('Cannot purchase free tier');
      }

      final products = await getAvailableProducts();
      final ProductDetails? product = products
          .where((p) => p.id == tier.productId)
          .firstOrNull;

      if (product == null) {
        throw Exception('Product not found: ${tier.productId}');
      }

      late PurchaseParam purchaseParam;
      
      // Different purchase parameters for subscriptions vs one-time purchases
      if (tier.isRecurring) {
        purchaseParam = PurchaseParam(productDetails: product);
      } else {
        // For lifetime purchases (one-time products)
        purchaseParam = PurchaseParam(productDetails: product);
      }

      bool success;
      if (tier.isRecurring) {
        success = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        success = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      }

      if (!success) {
        throw Exception('Failed to initiate purchase');
      }

      _logger.i('$_tag: Purchase initiated for ${tier.name}');
    } catch (e) {
      _logger.e('$_tag: Failed to purchase subscription: $e');
      _purchaseController.add(PurchaseResult.failure(errorMessage: e.toString()));
      throw Exception('Failed to purchase subscription: $e');
    }
  }

  /// Restores previous purchases
  Future<void> restorePurchases() async {
    _logger.d('$_tag: Restoring purchases');
    
    try {
      await _inAppPurchase.restorePurchases();
      _logger.i('$_tag: Restore purchases initiated');
    } catch (e) {
      _logger.e('$_tag: Failed to restore purchases: $e');
      throw Exception('Failed to restore purchases: $e');
    }
  }

  /// Gets past purchases for verification
  Future<List<PurchaseDetails>> getPastPurchases() async {
    _logger.d('$_tag: Getting past purchases');
    
    try {
      // For now, return empty list - this will be implemented when backend is ready
      _logger.d('$_tag: Found 0 past purchases (not implemented yet)');
      return [];
    } catch (e) {
      _logger.e('$_tag: Failed to get past purchases: $e');
      throw Exception('Failed to get past purchases: $e');
    }
  }

  /// Handles purchase updates from the platform
  void _onPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      _logger.d('$_tag: Purchase update - ${purchaseDetails.status} for ${purchaseDetails.productID}');
      
      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        
        // Find the subscription tier for this product
        final SubscriptionTier? tier = SubscriptionTier.values
            .where((t) => t.productId == purchaseDetails.productID)
            .firstOrNull;
        
        if (tier != null) {
          _purchaseController.add(PurchaseResult.success(
            purchaseDetails: purchaseDetails,
            tier: tier,
          ));
        }
        
        // Complete the purchase
        _inAppPurchase.completePurchase(purchaseDetails);
        
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        _purchaseController.add(PurchaseResult.failure(
          errorMessage: purchaseDetails.error?.message ?? 'Purchase failed',
        ));
        
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        _purchaseController.add(PurchaseResult.cancelled());
      }
      
      // Handle pending purchases
      if (purchaseDetails.status == PurchaseStatus.pending) {
        _logger.i('$_tag: Purchase pending for ${purchaseDetails.productID}');
      }
    }
  }

  /// Verifies a purchase with the backend
  Future<bool> verifyPurchase(PurchaseDetails purchase) async {
    _logger.d('$_tag: Verifying purchase: ${purchase.productID}');
    
    try {
      // This would typically call your backend API to verify the purchase
      // For now, we'll assume verification is successful
      // TODO: Implement backend verification API call
      
      _logger.i('$_tag: Purchase verified for ${purchase.productID}');
      return true;
    } catch (e) {
      _logger.e('$_tag: Failed to verify purchase: $e');
      return false;
    }
  }

  void dispose() {
    _subscription.cancel();
    _purchaseController.close();
  }
}