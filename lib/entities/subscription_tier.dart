/// Represents the different subscription tiers available in the app
enum SubscriptionTier {
  /// Free tier with limited features (500 words limit)
  free,
  
  /// Monthly subscription with full premium features
  monthly,
  
  /// Yearly subscription with full premium features (discounted)
  yearly,
  
  /// One-time lifetime purchase with full premium features
  lifetime,
}

/// Extensions for SubscriptionTier enum
extension SubscriptionTierExtension on SubscriptionTier {
  /// Returns the Google Play product ID for this subscription tier
  String get productId {
    switch (this) {
      case SubscriptionTier.free:
        return '';
      case SubscriptionTier.monthly:
        return 'premium_monthly';
      case SubscriptionTier.yearly:
        return 'premium_yearly';
      case SubscriptionTier.lifetime:
        return 'premium_lifetime';
    }
  }

  /// Returns whether this tier has premium features
  bool get isPremium {
    switch (this) {
      case SubscriptionTier.free:
        return false;
      case SubscriptionTier.monthly:
      case SubscriptionTier.yearly:
      case SubscriptionTier.lifetime:
        return true;
    }
  }

  /// Returns the word limit for this tier
  int get wordLimit {
    switch (this) {
      case SubscriptionTier.free:
        return 500;
      case SubscriptionTier.monthly:
      case SubscriptionTier.yearly:
      case SubscriptionTier.lifetime:
        return -1; // Unlimited
    }
  }

  /// Returns whether this tier is a recurring subscription
  bool get isRecurring {
    switch (this) {
      case SubscriptionTier.free:
      case SubscriptionTier.lifetime:
        return false;
      case SubscriptionTier.monthly:
      case SubscriptionTier.yearly:
        return true;
    }
  }

  /// Returns the display name for this tier
  String get displayName {
    switch (this) {
      case SubscriptionTier.free:
        return 'Free';
      case SubscriptionTier.monthly:
        return 'Premium Monthly';
      case SubscriptionTier.yearly:
        return 'Premium Yearly';
      case SubscriptionTier.lifetime:
        return 'Premium Lifetime';
    }
  }
}