import 'package:flutter_riverpod/legacy.dart';


final onboardingProvider = StateNotifierProvider<OnboardingNotifier, int>((ref) {
  return OnboardingNotifier();
});

class OnboardingNotifier extends StateNotifier<int> {
  OnboardingNotifier() : super(0);

  void setPage(int index) {
    state = index;
  }
}

