import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart'; // Chart framework
import 'package:plant_detector/custom_drawer.dart';
import '../providers/tree_provider.dart';
import 'home_screen.dart';
import 'camera_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final allTrees = ref.watch(treeHistoryProvider);
    final healthyTrees = ref.watch(healthyTreesProvider);
    final diseasedTrees = ref.watch(diseasedTreesProvider);

    int totalCount = allTrees.length;
    int healthyCount = healthyTrees.length;
    int diseasedCount = diseasedTrees.length;

    double healthyPercentage = totalCount > 0 ? (healthyCount / totalCount) * 100 : 0;
    double diseasedPercentage = totalCount > 0 ? (diseasedCount / totalCount) * 100 : 0;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Plant Health Analytics", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: CustomDrawer(currentRoute: "dashboard"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome Back !",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF263238)),
            ),
            Text(
              "Here is your plant detection summary data.",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                _buildStatCard("Total Scanned", totalCount.toString(), const Color(0xFFECEFF1), const Color(0xFF455A64)),
                const SizedBox(width: 12),
                _buildStatCard("Healthy", healthyCount.toString(), const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
                const SizedBox(width: 12),
                _buildStatCard("Infected", diseasedCount.toString(), const Color(0xFFFFF3E0), const Color(0xFFE65100)),
              ],
            ),
            const SizedBox(height: 28),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.15)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  const Text(
                    "Health Distribution Ratio",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF263238)),
                  ),
                  const SizedBox(height: 20),
                  totalCount == 0
                      ? SizedBox(
                    height: 180,
                    child: Center(
                      child: Text("No data available.\nScan some plants to view chart analytics.",
                          textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade500)),
                    ),
                  )
                      : SizedBox(
                    height: 180,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 4,
                        centerSpaceRadius: 45,
                        sections: [
                          PieChartSectionData(
                            color: const Color(0xFF4CAF50),
                            value: healthyCount.toDouble(),
                            title: '${healthyPercentage.toStringAsFixed(1)}%',
                            radius: 25,
                            titleStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          PieChartSectionData(
                            color: const Color(0xFFFF9800),
                            value: diseasedCount.toDouble(),
                            title: '${diseasedPercentage.toStringAsFixed(1)}%',
                            radius: 25,
                            titleStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (totalCount > 0) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLegendItem("Healthy Plants", const Color(0xFF4CAF50)),
                        const SizedBox(width: 24),
                        _buildLegendItem("Infected / Sick", const Color(0xFFFF9800)),
                      ],
                    )
                  ]
                ],
              ),
            ),
            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                },
                icon: const Icon(Icons.history_toggle_off_rounded, color: Colors.white),
                label: const Text("Go to Scanned History Logs", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 1,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CameraScreen()));
        },
        backgroundColor: const Color(0xFFFF9800),
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color bgColor, Color textColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor.withOpacity(0.7))),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF455A64))),
      ],
    );
  }
}