import 'package:flutter/material.dart';
import 'package:plant_detector/screens/favourite_screen.dart';
import 'package:plant_detector/screens/setting_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/home_screen.dart';

class CustomDrawer extends StatelessWidget {
  final String currentRoute;

  const CustomDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF2E7D32)),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.eco, size: 40, color: Color(0xFF2E7D32)),
            ),
            accountName: const Text("Tree Identity App", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            accountEmail: Text("Version 1.0.0", style: TextStyle(color: Colors.white.withOpacity(0.8))),
          ),

          ListTile(
            leading: Icon(Icons.dashboard_rounded,
                color: currentRoute == 'dashboard' ? const Color(0xFF2E7D32) : Colors.grey),
            title: Text("Dashboard",
                style: TextStyle(fontSize: 16, fontWeight: currentRoute == 'dashboard' ? FontWeight.bold : FontWeight.normal)),
            selected: currentRoute == 'dashboard',
            selectedTileColor: const Color(0xFFE8F5E9),
            onTap: () {
              Navigator.pop(context);
              if (currentRoute != 'dashboard') {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const DashboardScreen()),
                );
              }
            },
          ),

          ListTile(
            leading: Icon(Icons.history_toggle_off_rounded,
                color: currentRoute == 'home' ? const Color(0xFF2E7D32) : Colors.grey),
            title: Text("Scanned History",
                style: TextStyle(fontSize: 16, fontWeight: currentRoute == 'home' ? FontWeight.bold : FontWeight.normal)),
            selected: currentRoute == 'home',
            selectedTileColor: const Color(0xFFE8F5E9),
            onTap: () {
              Navigator.pop(context);
              if (currentRoute != 'home') {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              }
            },
          ),

          ListTile(
            leading: Icon(Icons.settings_rounded,
                color: currentRoute == 'settings' ? const Color(0xFF2E7D32) : Colors.grey),
            title: Text("Settings",
                style: TextStyle(fontSize: 16, fontWeight: currentRoute == 'settings' ? FontWeight.bold : FontWeight.normal)),
            selected: currentRoute == 'settings',
            selectedTileColor: const Color(0xFFE8F5E9),
            onTap: () {
              Navigator.pop(context);
              if (currentRoute != 'settings') {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              }
            },
          ),

          ListTile(
            leading: Icon(Icons.favorite_rounded,
                color: currentRoute == 'favourites' ? const Color(0xFF2E7D32) : Colors.grey),
            title: Text("Saved Plants",
                style: TextStyle(fontSize: 16, fontWeight: currentRoute == 'favourites' ? FontWeight.bold : FontWeight.normal)),
            selected: currentRoute == 'favourites',
            selectedTileColor: const Color(0xFFE8F5E9),
            onTap: () {
              Navigator.pop(context);
              if (currentRoute != 'favourites') {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const FavouriteScreen()),
                );
              }
            },
          ),

          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Made with ❤️ for Plants", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          )
        ],
      ),
    );
  }
}