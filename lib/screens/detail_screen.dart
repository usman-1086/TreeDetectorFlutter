import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tree_provider.dart';
import 'camera_screen.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class DetailScreen extends ConsumerWidget {
  final String initialImagePath;
  final TreeData? passedTreeData;

  const DetailScreen({
    super.key,
    required this.initialImagePath,
    this.passedTreeData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detectionState = ref.watch(geminiDetectionProvider);
    final double height = MediaQuery.sizeOf(context).height;

    if (passedTreeData != null) {
      return _buildSuccessUI(
        context,
        passedTreeData!,
        height,
        ref,
        isFromHistory: true,
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: detectionState.when(
        loading: () => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    File(initialImagePath),
                    height: height * 0.35,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 40),
                const CircularProgressIndicator(
                  color: Color(0xFF2E7D32),
                  strokeWidth: 5,
                ),
                const SizedBox(height: 24),
                const Text(
                  "Analyzing with Gemini AI...",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Extracting category, advantages, and health status.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.center_focus_weak_rounded,
                    size: 80,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Identification Failed",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Gemini couldn't clearly identify a tree or leaf in this photo. Please take a closer, clearer shot in good lighting.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 35),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref.read(geminiDetectionProvider.notifier).reset();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const CameraScreen()),
                      );
                    },
                    icon: const Icon(
                      Icons.flip_camera_ios_rounded,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Try Again",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(geminiDetectionProvider.notifier).reset();
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "Go to Home",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
        data: (tree) {
          if (tree == null) return const SizedBox.shrink();
          return _buildSuccessUI(
            context,
            tree,
            height,
            ref,
            isFromHistory: false,
          );
        },
      ),
    );
  }

  Widget _buildSuccessUI(
    BuildContext context,
    TreeData tree,
    double height,
    WidgetRef ref, {
    required bool isFromHistory,
  }) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: height * 0.38,
            pinned: true,
            backgroundColor: const Color(0xFF2E7D32),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black26,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    if (!isFromHistory) {
                      ref.read(geminiDetectionProvider.notifier).reset();
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),

            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Consumer(
                  builder: (context, ref, child) {
                    final currentTreeList = ref.watch(treeHistoryProvider);
                    final currentTree = currentTreeList.firstWhere(
                            (element) => element.imagePath == tree.imagePath,
                        orElse: () => tree
                    );

                    return CircleAvatar(
                      backgroundColor: Colors.black26,
                      child: IconButton(
                        icon: Icon(
                          currentTree.isFavourite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: currentTree.isFavourite ? Colors.redAccent : Colors.white,
                        ),
                        onPressed: () {
                          ref.read(treeHistoryProvider.notifier).toggleFavourite(tree.imagePath);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(currentTree.isFavourite
                                  ? "Removed from saved plants."
                                  : "Added to premium saved plants collection!"),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              )
            ],

            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(
                left: 60,
                bottom: 16,
                right: 20,
              ),
              title: Text(
                tree.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18,
                  shadows: [
                    Shadow(
                      blurRadius: 6,
                      color: Colors.black87,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(File(tree.imagePath), fit: BoxFit.cover),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailCard(
                    "🌿 Category",
                    tree.category,
                    const Color(0xFFE8F5E9),
                    const Color(0xFF2E7D32),
                  ),
                  _buildDetailCard(
                    "📍 Where it Exists",
                    tree.locations,
                    const Color(0xFFE3F2FD),
                    const Color(0xFF1565C0),
                  ),
                  _buildDetailCard(
                    "✅ Advantages",
                    tree.advantages,
                    const Color(0xFFF1F8E9),
                    const Color(0xFF558B2F),
                  ),
                  _buildDetailCard(
                    "❌ Disadvantages",
                    tree.disadvantages,
                    const Color(0xFFFFEBEE),
                    const Color(0xFFC62828),
                  ),
                  _buildDetailCard(
                    "🩺 Disease Status & Diagnosis",
                    tree.diseaseStatus,
                    tree.diseaseStatus.toLowerCase().contains('healthy')
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFF3E0),
                    tree.diseaseStatus.toLowerCase().contains('healthy')
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFEF6C00),
                    isBoldContent: !tree.diseaseStatus.toLowerCase().contains(
                      'healthy',
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(
    String title,
    String content,
    Color bgColor,
    Color titleColor, {
    bool isBoldContent = false,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: MarkdownBody(
              data:
                  content,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.black87,
                  fontWeight: isBoldContent
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
                strong: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors
                      .black,
                ),
                listBullet: const TextStyle(
                  color: Color(0xFF2E7D32),
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
