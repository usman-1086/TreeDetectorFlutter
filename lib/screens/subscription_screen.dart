import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dashboard_screen.dart';
import '../providers/subscription_provider.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(premiumStatusProvider.notifier).initPlayStoreProducts(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final double height = MediaQuery.sizeOf(context).height;

    final selectedPlan = ref.watch(selectedPlanProvider);
    final isFreeTrialEnabled = ref.watch(freeTrialProvider);
    final premiumData = ref.watch(premiumStatusProvider);
    final premiumNotifier = ref.read(premiumStatusProvider.notifier);

    ref.listen<PremiumInfo>(premiumStatusProvider, (previous, next) {
      if (!(previous?.isPremium ?? false) && next.isPremium) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 Premium activated!'),
              backgroundColor: Color(0xFF2E7D32),
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.of(context).pop();
        }
      }

      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.errorMessage!),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
              color: Colors.white,
              colorBlendMode: BlendMode.dstATop,
            ),
          ),
          Positioned.fill(child: Container(color: Colors.black.withAlpha(140))),

          Positioned(
            top: 50,
            left: width * 0.05,
            right: width * 0.05,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: premiumData.isLoading
                      ? null
                      : () => premiumNotifier.restorePurchases(),
                  child: const Text(
                    "Restore",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const DashboardScreen()),
                  ),
                  child: const Text(
                    "Skip",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: height * 0.15,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  "Plantoo Premium",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Premium Status",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildBadge("🏆 APP OF THE", "MONTH #1"),
                    const SizedBox(width: 20),
                    _buildBadge("🌿 FEATURED IN", "20+ COUNTRIES"),
                  ],
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: 30,
                left: width * 0.05,
                right: width * 0.05,
                bottom: 40,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPlanCard(
                    ref: ref,
                    planId: kLifetimeId,
                    currentSelected: selectedPlan,
                    title: "Lifetime",
                    subtitle: "\$220.51  →  \$50.40 one payment",
                    tag: "-80% OFF",
                  ),
                  const SizedBox(height: 15),
                  _buildPlanCard(
                    ref: ref,
                    planId: kYearlyId,
                    currentSelected: selectedPlan,
                    title: "Yearly",
                    subtitle: "Just \$80/year, auto renewable",
                  ),
                  const SizedBox(height: 15),
                  _buildPlanCard(
                    ref: ref,
                    planId: kMonthlyId,
                    currentSelected: selectedPlan,
                    title: "Monthly",
                    subtitle: "Just \$10/month, auto renewable",
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    "Try 3 days free, then \$5 per week",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Auto renewable & Cancel anytime",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Enable Free Trial",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        CupertinoSwitch(
                          activeTrackColor: const Color(0xFF4CAF50),
                          value: isFreeTrialEnabled,
                          onChanged: (val) {
                            ref.read(freeTrialProvider.notifier).state = val;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: premiumData.isLoading
                            ? null
                            : () => premiumNotifier.startRealPurchase(
                                selectedPlan,
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          disabledBackgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: premiumData.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                "Next",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String title, String subtitle) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.amber,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required WidgetRef ref,
    required String planId,
    required String currentSelected,
    required String title,
    required String subtitle,
    String? tag,
  }) {
    final bool isSelected = planId == currentSelected;

    return GestureDetector(
      onTap: () => ref.read(selectedPlanProvider.notifier).state = planId,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade300,
            width: isSelected ? 2.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected
                  ? const Color(0xFF2E7D32)
                  : Colors.grey.shade400,
              size: 26,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (tag != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFA5D6A7).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    color: Color(0xFF1B5E20),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
