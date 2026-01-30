import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/finance_provider.dart';

class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key});

  // 1. Fixed Color Mapping: Assigns specific colors to categories
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Colors.orangeAccent;
      case 'transport':
        return Colors.blueAccent;
      case 'shopping':
        return Colors.pinkAccent;
      case 'rent':
        return Colors.brown;
      case 'airtime':
        return Colors.teal;
      case 'utilities':
        return Colors.amber;
      case 'health':
        return Colors.redAccent;
      case 'family':
        return Colors.purpleAccent;
      case 'education':
        return Colors.indigo;
      case 'entertainment':
        return Colors.cyan;
      case 'savings':
        return Colors.green;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryData = ref.watch(categorySpendingProvider);
    final totalSpent = ref.watch(filteredTotalSpentProvider);
    final activeFilter = ref.watch(financeProvider).activeFilter;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text(
          "Spending Summary",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              "Viewing: ${activeFilter.name.toUpperCase()}",
              style: const TextStyle(
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 50), // Increased height to give labels room
            // --- PIE CHART SECTION ---
            SizedBox(
              height: 300, // Slightly taller to accommodate external labels
              child: categoryData.isEmpty
                  ? const Center(
                      child: Text("No expense data for this period."),
                    )
                  : PieChart(
                      PieChartData(
                        sections: _buildSections(categoryData),
                        centerSpaceRadius: 40,
                        sectionsSpace: 4, // More space between slices
                        pieTouchData: PieTouchData(enabled: true),
                      ),
                    ),
            ),

            const SizedBox(height: 50),

            _dataCard(
              "Total Expenses",
              "KES ${totalSpent.toStringAsFixed(0)}",
              Colors.red,
            ),
            const SizedBox(height: 15),
            _dataCard("Categories", "${categoryData.length}", Colors.blue),

            const SizedBox(height: 30),
            const Text(
              "Note: Only negative transactions (expenses) are shown.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections(Map<String, double> data) {
    return data.entries.map((entry) {
      final color = _getCategoryColor(entry.key);

      return PieChartSectionData(
        value: entry.value,
        showTitle: false,
        color: color,
        radius: 55,

        badgeWidget: _buildExternalLabel(entry.key, entry.value, color),
        badgePositionPercentageOffset: 1.5,
      );
    }).toList();
  }

  Widget _buildExternalLabel(String label, double value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 2, height: 12, color: color.withOpacity(0.6)),
        // The Label Content
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: color, width: 1),
          ),
          child: Text(
            "$label\n${value.toStringAsFixed(0)}%",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _dataCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
