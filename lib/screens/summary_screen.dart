import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text(
          "Spending Summary",
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Divider(
                    thickness: 1,
                    color: Colors.grey,
                    indent: 10,
                    endIndent: 10,
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Card(
                    margin: EdgeInsets.zero,
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: const Text(
                        "April 2024",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    thickness: 1,
                    color: Colors.grey,
                    indent: 10,
                    endIndent: 10,
                  ),
                ),
              ],
            ),

            (const SizedBox(height: 20)),
            Center(
              child: SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: 35,
                        color: Colors.orange,
                        title: "35%",
                        radius: 50,
                      ),
                      PieChartSectionData(
                        value: 20,
                        color: Colors.blue,
                        title: "20%",
                        radius: 50,
                      ),
                      PieChartSectionData(
                        value: 45,
                        color: Colors.green,
                        title: "45%",
                        radius: 50,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 80),
            _row("Total Spent:", "KES 27,200"),
            const Divider(),
            _row("Top Category", "Shopping"),
            const Divider(),
            _row("Number of Transactions", "18"),
            const Divider(),
          ],
        ),
      ),
    );
  }

  Widget _row(String l, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(
            v,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
        ],
      ),
    );
  }
}
