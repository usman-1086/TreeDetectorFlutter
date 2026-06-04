import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../custom_drawer.dart';
import '../providers/tree_provider.dart';
import 'detail_screen.dart';

class FavouriteScreen extends ConsumerWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch only favorites list
    final favouriteList = ref.watch(favouriteTreesProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Saved Collection", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF2E7D32),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const CustomDrawer(currentRoute: 'favourites'),
      body: favouriteList.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
              child: const Icon(Icons.favorite_outline_rounded, size: 60, color: Colors.redAccent),
            ),
            const SizedBox(height: 16),
            const Text("Your collection is empty", style: TextStyle(fontSize: 18, color: Color(0xFF263238), fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text("Tap the heart icon in detail views to save items.", style: TextStyle(color: Colors.grey)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: favouriteList.length,
        itemBuilder: (context, index) {
          final tree = favouriteList[index];
          final bool isHealthy = tree.diseaseStatus.toLowerCase().contains('healthy');

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
              border: Border.all(color: Colors.grey.withOpacity(0.12), width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DetailScreen(initialImagePath: tree.imagePath, passedTreeData: tree),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Image.file(File(tree.imagePath), width: 115, height: 125, fit: BoxFit.cover),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    tree.name,
                                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF263238)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 22),
                                  onPressed: () {
                                    ref.read(treeHistoryProvider.notifier).toggleFavourite(tree.imagePath);
                                  },
                                )
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isHealthy ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6, height: 6,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isHealthy ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isHealthy ? "Healthy" : "Infected",
                                    style: TextStyle(
                                        color: isHealthy ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                                        fontWeight: FontWeight.w600, fontSize: 11
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Text("View Full Diagnosis", style: TextStyle(color: const Color(0xFF2E7D32).withOpacity(0.9), fontWeight: FontWeight.bold, fontSize: 12)),
                                const SizedBox(width: 4),
                                Icon(Icons.arrow_forward_rounded, size: 13, color: const Color(0xFF2E7D32).withOpacity(0.9)),
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}