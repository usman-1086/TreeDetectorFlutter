import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final splashProvider = FutureProvider<String>((ref) async {
  await Future.delayed(const Duration(seconds: 3));

  final prefs = await SharedPreferences.getInstance();

  final bool hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

  if (hasSeenOnboarding) {
    return 'home';
  } else {
    return 'onboarding';
  }
});