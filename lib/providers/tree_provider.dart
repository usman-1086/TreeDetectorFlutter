import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TreeData {
  final String imagePath;
  final String name;
  final String category;
  final String locations;
  final String advantages;
  final String disadvantages;
  final String diseaseStatus;
  final String healthMeasures;
  final bool isFavourite;

  TreeData({
    required this.imagePath,
    required this.name,
    required this.category,
    required this.locations,
    required this.advantages,
    required this.disadvantages,
    required this.diseaseStatus,
    required this.healthMeasures,
    this.isFavourite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'imagePath': imagePath,
      'name': name,
      'category': category,
      'locations': locations,
      'advantages': advantages,
      'disadvantages': disadvantages,
      'diseaseStatus': diseaseStatus,
      'healthMeasures': healthMeasures,
      'isFavourite': isFavourite,
    };
  }

  factory TreeData.fromMap(Map<String, dynamic> map) {
    return TreeData(
      imagePath: map['imagePath'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      locations: map['locations'] ?? '',
      advantages: map['advantages'] ?? '',
      disadvantages: map['disadvantages'] ?? '',
      diseaseStatus: map['diseaseStatus'] ?? '',
      healthMeasures: map['healthMeasures'] ?? 'Regular maintenance.',
      isFavourite: map['isFavourite'] ?? false,
    );
  }

  TreeData copyWith({bool? isFavourite}) {
    return TreeData(
      imagePath: imagePath,
      name: name,
      category: category,
      locations: locations,
      advantages: advantages,
      disadvantages: disadvantages,
      diseaseStatus: diseaseStatus,
      healthMeasures: healthMeasures,
      isFavourite: isFavourite ?? this.isFavourite,
    );
  }
}

class TreeHistoryNotifier extends StateNotifier<List<TreeData>> {
  TreeHistoryNotifier() : super([]) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cachedData = prefs.getString('scanned_trees_history');
    if (cachedData != null) {
      final List<dynamic> decodedList = jsonDecode(cachedData);
      state = decodedList.map((item) => TreeData.fromMap(item)).toList();
    }
  }

  Future<void> _saveToStorage(List<TreeData> currentList) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(currentList.map((item) => item.toMap()).toList());
    await prefs.setString('scanned_trees_history', encodedData);
  }

  void toggleFavourite(String path) {
    state = [
      for (final tree in state)
        if (tree.imagePath == path) tree.copyWith(isFavourite: !tree.isFavourite) else tree
    ];
    _saveToStorage(state);
  }

  void addTree(TreeData tree) {
    if (!state.any((element) => element.imagePath == tree.imagePath)) {
      final newState = [...state, tree];
      state = newState;
      _saveToStorage(newState);
    }
  }

  void deleteTreeByPath(String path) {
    final newState = state.where((element) => element.imagePath != path).toList();
    state = newState;
    _saveToStorage(newState);
  }

  void deleteTree(int index) {
    final newState = List<TreeData>.from(state)..removeAt(index);
    state = newState;
    _saveToStorage(newState);
  }

  void clearAllHistory() {
    state = [];
    _saveToStorage([]);
  }
}

final treeHistoryProvider = StateNotifierProvider<TreeHistoryNotifier, List<TreeData>>((ref) {
  return TreeHistoryNotifier();
});

class GeminiDetectionNotifier extends StateNotifier<AsyncValue<TreeData?>> {
  final Ref ref;
  GeminiDetectionNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> detectTree(String imagePath) async {
    state = const AsyncValue.loading();

    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: '',

        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          responseSchema: Schema.object(
            properties: {
              'name': Schema.string(description: "Common Name (Scientific Name)"),
              'category': Schema.string(description: "Category (e.g., Fruit, Medicinal)"),
              'locations': Schema.string(description: "Where it exists globally or locally"),
              'advantages': Schema.string(description: "List of advantages/uses"),
              'disadvantages': Schema.string(description: "List of disadvantages/risks"),
              'diseaseStatus': Schema.string(description: "Disease Diagnosis & Precise Cure instructions if active infection is spotted. If healthy, write: '✨ This plant is perfectly Healthy! No active diseases detected.'"),
              'healthMeasures': Schema.string(description: "Comprehensive daily/weekly maintenance guide for this plant species including details on watering schedule, sunlight needs, fertilizer, and seasonal tips."),
            },
            requiredProperties: ['name', 'category', 'locations', 'advantages', 'disadvantages', 'diseaseStatus', 'healthMeasures'],
          ),
        ),
      );

      final imageBytes = await File(imagePath).readAsBytes();
      final imagePart = DataPart('image/jpeg', imageBytes);

      final prompt = TextPart(
          "Analyze this plant/leaf image very carefully. "
              "If the image does NOT show a tree, plant, leaf, or flower, fill all JSON fields with 'NOT_A_TREE'.\n\n"
              "Otherwise, identify the plant and populate the JSON schema values accurately based on the image provided. "
              "Make sure both diseaseStatus and healthMeasures are completely detailed and never left short or truncated."
      );

      final response = await model.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      final String? resText = response.text?.trim();
      print("Gemini Strictly JSON Response: $resText");

      if (resText == null || resText.isEmpty || resText.contains("NOT_A_TREE")) {
        throw Exception("Tree not detected or image unclear.");
      }

      final Map<String, dynamic> jsonData = jsonDecode(resText);

      final realTree = TreeData(
        imagePath: imagePath,
        name: jsonData['name'] ?? "Unknown Plant",
        category: jsonData['category'] ?? "Botanical/Plant",
        locations: jsonData['locations'] ?? "Information not available",
        advantages: jsonData['advantages'] ?? "Information not available",
        disadvantages: jsonData['disadvantages'] ?? "Information not available",
        diseaseStatus: jsonData['diseaseStatus'] ?? "Perfectly Healthy",
        healthMeasures: jsonData['healthMeasures'] ?? "Regular watering and proper maintenance.",
        isFavourite: false,
      );

      ref.read(treeHistoryProvider.notifier).addTree(realTree);
      state = AsyncValue.data(realTree);

    } catch (e, stack) {
      print("🔥 FINAL PARSING ERROR: $e");
      state = AsyncValue.error(e, stack);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final geminiDetectionProvider = StateNotifierProvider<GeminiDetectionNotifier, AsyncValue<TreeData?>>((ref) {
  return GeminiDetectionNotifier(ref);
});

final healthyTreesProvider = Provider<List<TreeData>>((ref) {
  final allTrees = ref.watch(treeHistoryProvider);
  return allTrees.where((tree) =>
      tree.diseaseStatus.toLowerCase().contains('healthy')
  ).toList();
});

final diseasedTreesProvider = Provider<List<TreeData>>((ref) {
  final allTrees = ref.watch(treeHistoryProvider);
  return allTrees.where((tree) =>
  !tree.diseaseStatus.toLowerCase().contains('healthy')
  ).toList();
});

final favouriteTreesProvider = Provider<List<TreeData>>((ref) {
  final allTrees = ref.watch(treeHistoryProvider);
  return allTrees.where((tree) => tree.isFavourite).toList();
});