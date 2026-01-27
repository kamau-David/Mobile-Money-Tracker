import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text(
          "Transaction History",
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            margin: EdgeInsets.symmetric(vertical: 5),
            child: Center(child: const Text("Filter: Last 30 Days")),
          ),
          const SizedBox(height: 10),
          _historyTile(
            "Apr 14",
            "Groceries",
            "shopping",
            "-700 KES",
            Colors.red,
          ),
          _historyTile(
            "Apr 12",
            "Salary",
            "income",
            "+100,000 KES",
            Colors.green,
          ),

          _historyTile(
            "Apr 10",
            "M-Pesa Transfer",
            "Transfer",
            "+20,000 KES",
            Colors.green,
          ),
          _historyTile(
            "Apr 8",
            "Airtime",
            "utilities",
            "-5,000 KES",
            Colors.red,
          ),

          _historyTile("Apr 6", "Lunch Out", "food", "+5,000 KES", Colors.red),
        ],
      ),
    );
  }

  Widget _historyTile(String d, String t, String f, String a, Color c) {
    return Card(
      child: ListTile(
        leading: Text(d, style: const TextStyle(fontSize: 16)),
        title: Text(
          t,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(f, style: TextStyle(fontSize: 18)),
        trailing: Text(
          a,
          style: TextStyle(color: c, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
