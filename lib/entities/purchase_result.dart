import 'package:in_app_purchase/in_app_purchase.dart';
import 'subscription_tier.dart';

/// Represents the result of a purchase operation
class PurchaseResult {
  final bool success;
  final String? errorMessage;
  final PurchaseDetails? purchaseDetails;
  final SubscriptionTier? tier;

  const PurchaseResult({
    required this.success,
    this.errorMessage,
    this.purchaseDetails,
    this.tier,
  });

  /// Creates a successful purchase result
  factory PurchaseResult.success({
    required PurchaseDetails purchaseDetails,
    required SubscriptionTier tier,
  }) {
    return PurchaseResult(
      success: true,
      purchaseDetails: purchaseDetails,
      tier: tier,
    );
  }

  /// Creates a failed purchase result
  factory PurchaseResult.failure({required String errorMessage}) {
    return PurchaseResult(
      success: false,
      errorMessage: errorMessage,
    );
  }

  /// Creates a cancelled purchase result
  factory PurchaseResult.cancelled() {
    return const PurchaseResult(
      success: false,
      errorMessage: 'Purchase cancelled by user',
    );
  }

  @override
  String toString() {
    return 'PurchaseResult(success: $success, errorMessage: $errorMessage, '
           'tier: $tier)';
  }
}

/// Extensions for PurchaseStatus
extension PurchaseStatusExtension on PurchaseStatus {
  /// Returns whether the purchase was successful
  bool get isSuccessful {
    switch (this) {
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        return true;
      case PurchaseStatus.pending:
      case PurchaseStatus.error:
      case PurchaseStatus.canceled:
        return false;
    }
  }

  /// Returns whether the purchase is pending
  bool get isPending => this == PurchaseStatus.pending;

  /// Returns whether the purchase was cancelled
  bool get isCancelled => this == PurchaseStatus.canceled;

  /// Returns whether the purchase had an error
  bool get hasError => this == PurchaseStatus.error;
}