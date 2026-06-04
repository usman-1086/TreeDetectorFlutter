import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_detector/custom_drawer.dart';
import '../providers/tree_provider.dart';
import 'camera_screen.dart';
import 'detail_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTrees = ref.watch(treeHistoryProvider);
    final healthyTrees = ref.watch(healthyTreesProvider);
    final diseasedTrees = ref.watch(diseasedTreesProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,

        appBar: AppBar(
          title: const Text("Tree Identity Home", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: const Color(0xFF2E7D32),
          elevation: 2,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            if (allTrees.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete_sweep, color: Colors.white),
                tooltip: "Clear All History",
                onPressed: () {
                  ref.read(treeHistoryProvider.notifier).clearAllHistory();
                },
              )
          ],
          bottom: const TabBar(
            indicatorColor: Colors.orange,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: "All", icon: Icon(Icons.history)),
              Tab(text: "Healthy", icon: Icon(Icons.check_circle_outline)),
              Tab(text: "Diseased", icon: Icon(Icons.bug_report_outlined)),
            ],
          ),
        ),

        drawer: CustomDrawer(currentRoute: "home"),

        body: TabBarView(
          children: [
            _buildTreeList(context, ref, allTrees, "No trees scanned yet!"),
            _buildTreeList(context, ref, healthyTrees, "No healthy trees detected yet!"),
            _buildTreeList(context, ref, diseasedTrees, "Hooray! No diseased trees found."),
          ],
        ),

        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CameraScreen()),
            );
          },
          backgroundColor: const Color(0xFFFF9800),
          icon: const Icon(Icons.camera_alt, color: Colors.white),
          label: const Text("Scan Tree", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }

  Widget _buildTreeList(BuildContext context, WidgetRef ref, List<TreeData> list, String emptyMessage) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.eco_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 10),
            Text(emptyMessage, style: const TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500)),
            const Text("Tap the camera button below to start.", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final tree = list[index];
        final bool isHealthy = tree.diseaseStatus.toLowerCase().contains('healthy');

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.grey.withOpacity(0.12),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DetailScreen(
                      initialImagePath: tree.imagePath,
                      passedTreeData: tree,
                    ),
                  ),
                );
              },
              child: Row(
                children: [
                  Hero(
                    tag: tree.imagePath,
                    child: Image.file(
                      File(tree.imagePath),
                      width: 115,
                      height: 125,
                      fit: BoxFit.cover,
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  tree.name,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF263238),
                                    letterSpacing: -0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFE57373), size: 22),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                visualDensity: VisualDensity.compact,
                                tooltip: "Remove",
                                onPressed: () {
                                  ref.read(treeHistoryProvider.notifier).deleteTreeByPath(tree.imagePath);
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
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isHealthy ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isHealthy ? "Healthy" : "Infected / Sick",
                                  style: TextStyle(
                                    color: isHealthy ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Text(
                                "View Full Diagnosis",
                                style: TextStyle(
                                  color: const Color(0xFF2E7D32).withOpacity(0.9),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 13,
                                  color: const Color(0xFF2E7D32).withOpacity(0.9)
                              ),
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
    );

  }
}