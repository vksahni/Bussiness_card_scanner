import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../models/app_enums.dart';

class SubscriptionState {
  const SubscriptionState({
    required this.plan,
    required this.isActive,
    required this.remainingFreeScans,
    required this.trialEndsAt,
  });

  final SubscriptionPlan plan;
  final bool isActive;
  final int remainingFreeScans;
  final DateTime? trialEndsAt;
}

class SubscriptionService {
  Future<void> initialize({required String apiKey, String? appUserId}) async {
    if (apiKey.isEmpty) {
      return;
    }
    final config = PurchasesConfiguration(apiKey)..appUserID = appUserId;
    await Purchases.configure(config);
  }

  Future<SubscriptionState> loadState() async {
    try {
      final CustomerInfo info = await Purchases.getCustomerInfo();
      final entitlements = info.entitlements.active.keys;
      if (entitlements.contains('company')) {
        return SubscriptionState(
          plan: SubscriptionPlan.company,
          isActive: true,
          remainingFreeScans: 0,
          trialEndsAt: null,
        );
      }
      if (entitlements.contains('pro')) {
        return SubscriptionState(
          plan: SubscriptionPlan.proMonthly,
          isActive: true,
          remainingFreeScans: 0,
          trialEndsAt: null,
        );
      }
    } catch (error) {
      debugPrint('RevenueCat unavailable: $error');
    }

    return SubscriptionState(
      plan: SubscriptionPlan.free,
      isActive: false,
      remainingFreeScans: 20,
      trialEndsAt: DateTime.now().add(const Duration(days: 7)),
    );
  }

  Future<void> restore() => Purchases.restorePurchases();
}
