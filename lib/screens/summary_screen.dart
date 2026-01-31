import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/finance_provider.dart';

class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key});

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text(
          "Spending Summary",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              "Viewing: ${activeFilter.name.toUpperCase()}",
              style: TextStyle(
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white54 : Colors.grey,
              ),
            ),
            const SizedBox(height: 50),
            SizedBox(
              height: 300,
              child: categoryData.isEmpty
                  ? Center(
                      child: Text(
                        "No expense data for this period.",
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    )
                  : PieChart(
                      PieChartData(
                        sections: _buildSections(categoryData, isDark),
                        centerSpaceRadius: 40,
                        sectionsSpace: 4,
                        pieTouchData: PieTouchData(enabled: true),
                      ),
                    ),
            ),
            const SizedBox(height: 50),
            _dataCard(
              context,
              "Total Expenses",
              "KES ${totalSpent.toStringAsFixed(0)}",
              Colors.red,
              isDark,
            ),
            const SizedBox(height: 15),
            _dataCard(
              context,
              "Categories",
              "${categoryData.length}",
              Colors.blue,
              isDark,
            ),
            const SizedBox(height: 30),
            Text(
              "Note: Only negative transactions (expenses) are shown.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.white38 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections(
    Map<String, double> data,
    bool isDark,
  ) {
    return data.entries.map((entry) {
      final color = _getCategoryColor(entry.key);
      return PieChartSectionData(
        value: entry.value,
        showTitle: false,
        color: color,
        radius: 55,
        badgeWidget: _buildExternalLabel(entry.key, entry.value, color, isDark),
        badgePositionPercentageOffset: 1.5,
      );
    }).toList();
  }

  Widget _buildExternalLabel(
    String label,
    double value,
    Color color,
    bool isDark,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 2, height: 12, color: color.withOpacity(0.6)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
            ],
            border: Border.all(color: color.withOpacity(0.5), width: 1),
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

  Widget _dataCard(
    BuildContext context,
    String title,
    String value,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (!isDark)
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
        border: isDark ? Border.all(color: Colors.white10) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
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
