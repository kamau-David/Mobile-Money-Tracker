import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/finance_provider.dart';

class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key});

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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Filter: ${activeFilter.name.toUpperCase()}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),

            // PIE CHART SECTION
            SizedBox(
              height: 250,
              child: categoryData.isEmpty
                  ? const Center(
                      child: Text("No expenses recorded for this period"),
                    )
                  : PieChart(
                      PieChartData(
                        sections: _buildPieSections(categoryData),
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                      ),
                    ),
            ),

            const SizedBox(height: 40),

            // SUMMARY CARDS
            _summaryRow(
              "Total Expenses",
              "KES ${totalSpent.toStringAsFixed(0)}",
              Colors.red,
            ),
            const Divider(),
            _summaryRow(
              "Active Categories",
              "${categoryData.length}",
              Colors.blue,
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(Map<String, double> data) {
    final List<Color> colors = [
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.blue,
      Colors.teal,
    ];
    int i = 0;

    return data.entries.map((entry) {
      final color = colors[i % colors.length];
      i++;
      return PieChartSectionData(
        value: entry.value,
        title: "${entry.key}\n${entry.value.toStringAsFixed(1)}%",
        color: color,
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _summaryRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
