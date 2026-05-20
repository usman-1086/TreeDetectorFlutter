import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

// 1. Tree Data Structure
class TreeData {
  final String imagePath;
  final String name;
  final String category;
  final String locations;
  final String advantages;
  final String disadvantages;
  final String diseaseStatus;

  TreeData({
    required this.imagePath,
    required this.name,
    required this.category,
    required this.locations,
    required this.advantages,
    required this.disadvantages,
    required this.diseaseStatus,
  });
}

class TreeHistoryNotifier extends StateNotifier<List<TreeData>> {
  TreeHistoryNotifier() : super([]);

  void addTree(TreeData tree) {
    state = [...state, tree];
  }
}
final treeHistoryProvider = StateNotifierProvider<TreeHistoryNotifier, List<TreeData>>((ref) {
  return TreeHistoryNotifier();
});

// 3. Gemini Detection State Provider
class GeminiDetectionNotifier extends StateNotifier<AsyncValue<TreeData?>> {
  GeminiDetectionNotifier() : super(const AsyncValue.data(null));

  Future<void> detectTree(String imagePath) async {
    state = const AsyncValue.loading();
    try {
      // Gemini Model Setup
      final model = GenerativeModel(
        model: 'gemini-1.5-flash', // Vision supporting fast model
        apiKey: 'YOUR_GEMINI_API_KEY', // <--- APNI GEMINI KEY YAHAN LAGAYEIN
      );

      final imageBytes = await File(imagePath).readAsBytes();

      // Strict Prompt taaki response hamesha ek hi format mein aaye aur hum parse kar sakein
      final prompt = TextPart(
          "Identify this tree from the image. Give the output strictly in this format split by '##':\n"
              "Name##Category##Places where it exists##Advantages##Disadvantages##Disease status (If any disease detected, mention it and provide recovery steps. If healthy, just say Healthy)."
      );

      final imagePart = DataPart('image/jpeg', imageBytes);
      final response = await model.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      final resText = response.text;
      if (resText != null && resText.contains('##')) {
        final parts = resText.split('##');

        final tree = TreeData(
          imagePath: imagePath,
          name: parts[0].trim(),
          category: parts[1].trim(),
          locations: parts[2].trim(),
          advantages: parts[3].trim(),
          disadvantages: parts[4].trim(),
          diseaseStatus: parts[5].trim(),
        );

        state = AsyncValue.data(tree);
      } else {
        throw Exception("Could not identify properly. Format mismatch.");
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}
final geminiDetectionProvider = StateNotifierProvider<GeminiDetectionNotifier, AsyncValue<TreeData?>>((ref) {
  return GeminiDetectionNotifier();
});