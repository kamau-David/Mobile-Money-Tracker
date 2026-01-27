import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text(
          "Mobile-Money Tracker",
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: const Icon(Icons.menu, color: Colors.white),
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.notifications, color: Colors.white, size: 30),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      "Balance",
                      "KES 192,500",
                      const Color(0xFF1565C0),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _statCard(
                      "This Month",
                      "-KES 27,200",
                      const Color(0xFFC62828),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              Text(
                "Recent Transactions",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),

              const SizedBox(height: 10),
              _listTile("Groceries", "Shopping", "- 700 KES", Colors.red),
              _listTile(
                "M-Pesa Transfer",
                "Transfer",
                "- 20,000 KES",
                Colors.green,
              ),

              _listTile("salary", "income", "+ 100000 KES", Colors.green),

              _listTile("Airtime", "calls", "- 5000 KES", Colors.red),

              _listTile("Entertainment", "games", "- 5000 KES", Colors.red),

              _listTile("Books", "learning", "- 10,000 KES", Colors.red),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String title, String val, Color col) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: col,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          Text(
            val,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _listTile(String t, String s, String p, Color c) {
    return Card(
      child: ListTile(
        title: Text(t),
        subtitle: Text(s),
        trailing: Text(
          p,
          style: TextStyle(color: c, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
