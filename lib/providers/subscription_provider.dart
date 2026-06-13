import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

final selectedPlanProvider = StateProvider<String>((ref) => 'lifetime');
final freeTrialProvider = StateProvider<bool>((ref) => true);

// ⚡ IDs are matched exactly with SubscriptionScreen selections
const String kMonthlyId = 'monthly';
const String kYearlyId = 'yearly';
const String kLifetimeId = 'lifetime';

// ─── Data Model ───────────────────────────────────────────────────
class PremiumInfo {
  final bool isPremium;
  final String planName;
  final String pricePaid;
  final List<ProductDetails> availableProducts;
  final bool isLoading;
  final String? errorMessage;

  const PremiumInfo({
    this.isPremium = false,
    this.planName = 'Free Plan',
    this.pricePaid = '0',
    this.availableProducts = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  PremiumInfo copyWith({
    bool? isPremium,
    String? planName,
    String? pricePaid,
    List<ProductDetails>? availableProducts,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PremiumInfo(
      isPremium: isPremium ?? this.isPremium,
      planName: planName ?? this.planName,
      pricePaid: pricePaid ?? this.pricePaid,
      availableProducts: availableProducts ?? this.availableProducts,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class PremiumNotifier extends StateNotifier<PremiumInfo> {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription; // ⚡ Fixed initialization crash

  PremiumNotifier() : super(const PremiumInfo()) {
    // ⚡ Safe stream listening structure implementation
    _purchaseSubscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _purchaseSubscription?.cancel(),
      onError: (error) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Billing error: $error',
        );
      },
    );
    initPlayStoreProducts();
  }

  Future<void> initPlayStoreProducts() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final bool available = await _iap.isAvailable();
      if (!available) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Play Store not available right now.',
        );
        return;
      }

      const Set<String> productIds = {kMonthlyId, kYearlyId, kLifetimeId};
      final ProductDetailsResponse response = await _iap.queryProductDetails(productIds);

      if (response.error != null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Products not loaded: ${response.error!.message}',
        );
        return;
      }

      state = state.copyWith(
        isLoading: false,
        availableProducts: response.productDetails,
        errorMessage: response.productDetails.isEmpty ? 'No plan found on console configuration.' : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Init setup caught error safely.',
      );
    }
  }

  Future<void> startRealPurchase(String planId) async {
    // ⚡ Agar list empty hai to crash hone ke bajaye safely info update karega
    if (state.availableProducts.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Plans are empty. Setup Google Play Console dashboard.',
      );
      return;
    }

    final matchingProducts = state.availableProducts
        .where((p) => p.id == planId)
        .toList();

    if (matchingProducts.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Plan ID "$planId" not found on console matches.',
      );
      return;
    }

    final ProductDetails product = matchingProducts.first;
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);

    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Purchase process aborted: $e',
      );
    }
  }

  Future<void> restorePurchases() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _iap.restorePurchases();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Not Restored: $e',
      );
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchase in purchaseDetailsList) {
      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        String name = 'Free Plan';
        String price = '0';

        if (purchase.productID == kLifetimeId) {
          name = 'Lifetime Premium';
          price = '\$50.40';
        } else if (purchase.productID == kYearlyId) {
          name = 'Yearly Premium';
          price = '\$80.00/yr';
        } else if (purchase.productID == kMonthlyId) {
          name = 'Monthly Premium';
          price = '\$10.00/mo';
        }

        state = state.copyWith(
          isPremium: true,
          planName: name,
          pricePaid: price,
          isLoading: false,
          errorMessage: null,
        );
      } else if (purchase.status == PurchaseStatus.error) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: purchase.error?.message ?? 'Purchase execution failed.',
        );
      } else if (purchase.status == PurchaseStatus.canceled) {
        state = state.copyWith(isLoading: false, errorMessage: null);
      }
    }
  }

  void cancelSubscription() {
    state = state.copyWith(
      isPremium: false,
      planName: 'Free Plan',
      pricePaid: '0',
      errorMessage: null,
    );
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }
}

final premiumStatusProvider = StateNotifierProvider<PremiumNotifier, PremiumInfo>((ref) {
  return PremiumNotifier();
});