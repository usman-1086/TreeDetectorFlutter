import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_detector/screens/subscription_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../custom_drawer.dart';
import '../providers/subscription_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _launchURL(String urlString, BuildContext context) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $urlString');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not open link: $e")),
        );
      }
    }
  }

  Future<void> _launchEmail(BuildContext context) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'abc@gmail.com',
      queryParameters: {'subject': 'Tree Identity App Support'},
    );
    try {
      if (!await launchUrl(emailLaunchUri)) throw Exception();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mail to: abc@gmail.com")),
        );
      }
    }
  }

  void _goToSubscriptionScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premiumData = ref.watch(premiumStatusProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Settings",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF2E7D32),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const CustomDrawer(currentRoute: 'settings'),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // ── Membership Status ──────────────────────────────────
          const Text("Membership Status",
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
          const SizedBox(height: 8),
          Card(
            color: Colors.white,
            elevation: 0.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.grey.withOpacity(0.15)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                leading: Icon(
                  premiumData.isPremium
                      ? Icons.star_rounded
                      : Icons.workspace_premium_outlined,
                  color: premiumData.isPremium
                      ? const Color(0xFFFF9800)
                      : const Color(0xFF2E7D32),
                  size: 28,
                ),
                title: Text(
                  premiumData.isPremium
                      ? "Premium Active"
                      : "Upgrade to Premium",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF263238)),
                ),
                subtitle: Text(
                  premiumData.isPremium
                      ? "Plan: ${premiumData.planName} (${premiumData.pricePaid})"
                      : "Get unlimited access to all features",
                ),
                trailing: premiumData.isPremium
                    ? TextButton(
                  onPressed: () => _goToSubscriptionScreen(context),
                  child: const Text(
                    "Change Plan",
                    style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.bold),
                  ),
                )
                    : TextButton(
                  onPressed: () => _goToSubscriptionScreen(context),
                  child: const Text(
                    "Upgrade",
                    style: TextStyle(
                        color: Color(0xFFFF9800),
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),

          // ── Cancel Plan (sirf premium users ko dikhao) ─────────
          if (premiumData.isPremium) ...[
            const SizedBox(height: 8),
            Card(
              color: Colors.white,
              elevation: 0.5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: Colors.grey.withOpacity(0.15)),
              ),
              child: ListTile(
                leading: const Icon(Icons.cancel_outlined, color: Colors.red),
                title: const Text("Cancel Subscription",
                    style: TextStyle(color: Colors.red)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: Colors.grey),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Cancel Subscription"),
                      content: const Text(
                          "Are you sure you want to cancel your plan?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("No"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            ref
                                .read(premiumStatusProvider.notifier)
                                .cancelSubscription();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                  Text("Subscription cancelled.")),
                            );
                          },
                          child: const Text("Yes, Cancel",
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 24),

          // ── App Actions ────────────────────────────────────────
          const Text("App Actions",
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
          const SizedBox(height: 8),
          Card(
            color: Colors.white,
            elevation: 0.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.grey.withOpacity(0.15)),
            ),
            child: Column(
              children: [
                ListTile(
                  leading:
                  const Icon(Icons.share_outlined, color: Color(0xFF2E7D32)),
                  title: const Text("Share App",
                      style: TextStyle(color: Color(0xFF263238))),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: Colors.grey),
                  onTap: () {
                    Share.share(
                      'Check out this amazing Tree Identity App! Diagnose tree diseases instantly.\n\nDownload now from Play Store: https://play.google.com/store/apps/details?id=com.ai.plant.identifier',
                      subject: 'Tree Identity App',
                    );
                  },
                ),
                const Divider(height: 1, indent: 50),
                ListTile(
                  leading: const Icon(Icons.star_outline_rounded,
                      color: Color(0xFF2E7D32)),
                  title: const Text("Rate App",
                      style: TextStyle(color: Color(0xFF263238))),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: Colors.grey),
                  onTap: () {
                    const String packageName = "com.ai.plant.identifier";
                    if (packageName == "com.example") {
                      _launchURL(
                          "https://play.google.com/store/apps", context);
                    } else {
                      _launchURL(
                          "market://details?id=$packageName", context);
                    }
                  },
                ),
                const Divider(height: 1, indent: 50),
                ListTile(
                  leading: const Icon(Icons.mail_outline_rounded,
                      color: Color(0xFF2E7D32)),
                  title: const Text("Contact Us",
                      style: TextStyle(color: Color(0xFF263238))),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: Colors.grey),
                  onTap: () => _launchEmail(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text("Legal & About",
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
          const SizedBox(height: 8),
          Card(
            color: Colors.white,
            elevation: 0.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.grey.withOpacity(0.15)),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined,
                      color: Color(0xFF2E7D32)),
                  title: const Text("Privacy Policy",
                      style: TextStyle(color: Color(0xFF263238))),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: Colors.grey),
                  onTap: () => _launchURL(
                      "https://www.google.com/intl/en/policies/privacy/",
                      context),
                ),
                const Divider(height: 1, indent: 50),
                ListTile(
                  leading: const Icon(Icons.description_outlined,
                      color: Color(0xFF2E7D32)),
                  title: const Text("Terms & Conditions",
                      style: TextStyle(color: Color(0xFF263238))),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: Colors.grey),
                  onTap: () => _launchURL(
                      "https://policies.google.com/terms", context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
          Center(
            child: Text(
              "App Version 1.0.0 (Build 2026)",
              style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}