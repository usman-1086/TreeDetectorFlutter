import 'package:flutter_riverpod/legacy.dart';

final selectedPlanProvider = StateProvider<String>((ref) => 'lifetime');

final freeTrialProvider = StateProvider<bool>((ref) => true);