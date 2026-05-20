import 'package:flutter_riverpod/legacy.dart';

class OnboardingNotifier extends StateNotifier<int> {
  OnboardingNotifier() : super(0);

  void setPage(int index) {
    state = index;
  }
}

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, int>((ref) {
  return OnboardingNotifier();
});