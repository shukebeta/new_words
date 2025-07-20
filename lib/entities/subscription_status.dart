import 'subscription_tier.dart';

/// Represents the current subscription status of a user
class SubscriptionStatus {
  final SubscriptionTier tier;
  final DateTime? expiresAt;
  final bool isActive;
  final int currentWordCount;
  final String? purchaseToken;
  final String? productId;

  const SubscriptionStatus({
    required this.tier,
    this.expiresAt,
    required this.isActive,
    required this.currentWordCount,
    this.purchaseToken,
    this.productId,
  });

  /// Creates a free subscription status
  factory SubscriptionStatus.free({required int currentWordCount}) {
    return SubscriptionStatus(
      tier: SubscriptionTier.free,
      isActive: true,
      currentWordCount: currentWordCount,
    );
  }

  /// Creates a premium subscription status
  factory SubscriptionStatus.premium({
    required SubscriptionTier tier,
    required int currentWordCount,
    DateTime? expiresAt,
    String? purchaseToken,
    String? productId,
  }) {
    return SubscriptionStatus(
      tier: tier,
      expiresAt: expiresAt,
      isActive: true,
      currentWordCount: currentWordCount,
      purchaseToken: purchaseToken,
      productId: productId,
    );
  }

  /// Returns whether the user has premium features
  bool get hasPremiumFeatures => isActive && tier.isPremium;

  /// Returns whether the user can add more words
  bool get canAddWords {
    if (hasPremiumFeatures) return true;
    return currentWordCount < tier.wordLimit;
  }

  /// Returns the remaining word count for free users
  int get remainingWords {
    if (hasPremiumFeatures) return -1; // Unlimited
    return (tier.wordLimit - currentWordCount).clamp(0, tier.wordLimit);
  }

  /// Returns whether the subscription has expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Returns whether the subscription will expire soon (within 7 days)
  bool get willExpireSoon {
    if (expiresAt == null) return false;
    final sevenDaysFromNow = DateTime.now().add(const Duration(days: 7));
    return expiresAt!.isBefore(sevenDaysFromNow);
  }

  /// Creates a copy with updated values
  SubscriptionStatus copyWith({
    SubscriptionTier? tier,
    DateTime? expiresAt,
    bool? isActive,
    int? currentWordCount,
    String? purchaseToken,
    String? productId,
  }) {
    return SubscriptionStatus(
      tier: tier ?? this.tier,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
      currentWordCount: currentWordCount ?? this.currentWordCount,
      purchaseToken: purchaseToken ?? this.purchaseToken,
      productId: productId ?? this.productId,
    );
  }

  /// Creates a SubscriptionStatus from JSON
  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatus(
      tier: SubscriptionTier.values.firstWhere(
        (e) => e.name == json['tier'],
        orElse: () => SubscriptionTier.free,
      ),
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt'])
          : null,
      isActive: json['isActive'] ?? true,
      currentWordCount: json['currentWordCount'] ?? 0,
      purchaseToken: json['purchaseToken'],
      productId: json['productId'],
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'tier': tier.name,
      'expiresAt': expiresAt?.toIso8601String(),
      'isActive': isActive,
      'currentWordCount': currentWordCount,
      'purchaseToken': purchaseToken,
      'productId': productId,
    };
  }

  @override
  String toString() {
    return 'SubscriptionStatus(tier: $tier, isActive: $isActive, '
           'currentWordCount: $currentWordCount, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubscriptionStatus &&
           other.tier == tier &&
           other.expiresAt == expiresAt &&
           other.isActive == isActive &&
           other.currentWordCount == currentWordCount &&
           other.purchaseToken == purchaseToken &&
           other.productId == productId;
  }

  @override
  int get hashCode {
    return Object.hash(
      tier,
      expiresAt,
      isActive,
      currentWordCount,
      purchaseToken,
      productId,
    );
  }
}