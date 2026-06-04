import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:url_launcher/url_launcher.dart';

import '../custom_drawer.dart';

final isPremiumUserProvider = StateProvider<bool>((ref) => false);

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
    );
    try {
      if (!await launchUrl(emailLaunchUri)) {
        throw Exception('Could not launch email client');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open email client. Mail to: abc@gmail.com")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumUserProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF2E7D32),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const CustomDrawer(currentRoute: 'settings'),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [

          const Text("Membership Status", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
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
              child: isPremium
                  ? ListTile(
                leading: const Icon(Icons.star_rounded, color: Color(0xFFFF9800), size: 28),
                title: const Text("Premium Active", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF263238))),
                subtitle: const Text("You have unlimited scans & AI diagnostics."),
                trailing: TextButton(
                  onPressed: () {
                    ref.read(isPremiumUserProvider.notifier).state = false;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Subscription cancelled. Switched to Free Plan.")),
                    );
                  },
                  child: const Text("Cancel Plan", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                ),
              )
                  : ListTile(
                leading: const Icon(Icons.workspace_premium_outlined, color: Color(0xFF2E7D32), size: 28),
                title: const Text("Upgrade to Premium", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF263238))),
                subtitle: const Text("Unlock advanced fungus & health features."),
                trailing: ElevatedButton(
                  onPressed: () {
                    ref.read(isPremiumUserProvider.notifier).state = true;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Congratulations! Premium unlocked successfully.")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  ),
                  child: const Text("Upgrade", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          const Text("App Actions", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
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
                  leading: const Icon(Icons.share_outlined, color: Color(0xFF2E7D32)),
                  title: const Text("Share App", style: TextStyle(color: Color(0xFF263238))),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Opening share dialog...")),
                    );
                  },
                ),
                const Divider(height: 1, indent: 50),
                ListTile(
                  leading: const Icon(Icons.star_outline_rounded, color: Color(0xFF2E7D32)),
                  title: const Text("Rate App", style: TextStyle(color: Color(0xFF263238))),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Redirecting to Google Play Store...")),
                    );
                  },
                ),
                const Divider(height: 1, indent: 50),
                ListTile(
                  leading: const Icon(Icons.mail_outline_rounded, color: Color(0xFF2E7D32)),
                  title: const Text("Contact Us", style: TextStyle(color: Color(0xFF263238))),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                  onTap: () {
                    _launchEmail(context);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text("Legal & About", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
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
                  leading: const Icon(Icons.privacy_tip_outlined, color: Color(0xFF2E7D32)),
                  title: const Text("Privacy Policy", style: TextStyle(color: Color(0xFF263238))),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                  onTap: () {
                    _launchURL("https://www.google.com/intl/en/policies/privacy/", context);
                  },
                ),
                const Divider(height: 1, indent: 50),
                ListTile(
                  leading: const Icon(Icons.description_outlined, color: Color(0xFF2E7D32)),
                  title: const Text("Terms & Conditions", style: TextStyle(color: Color(0xFF263238))),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                  onTap: () {
                    _launchURL("https://policies.google.com/terms", context);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
          Center(
            child: Text(
                "App Version 1.0.0 (Build 2026)",
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.w500)
            ),
          )
        ],
      ),
    );
  }
}