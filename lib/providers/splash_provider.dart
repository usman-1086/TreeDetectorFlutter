import 'package:flutter_riverpod/flutter_riverpod.dart';

final splashProvider = FutureProvider<String>((ref) async {
  await Future.delayed(const Duration(seconds: 3));
  return 'onboarding';
});