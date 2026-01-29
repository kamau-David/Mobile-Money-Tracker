import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/finance_provider.dart'; // Make sure this path is correct

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the finance state
    final finance = ref.watch(financeProvider);
    final transactions = finance.transactions;

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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Cards Section
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    "Balance",
                    "KES ${finance.balance}",
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
            const Text(
              "Recent Transactions",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 10),

            // DYNAMIC LIST SECTION
            Expanded(
              child: transactions.isEmpty
                  ? const Center(child: Text("No transactions yet. Add some!"))
                  : ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final tx = transactions[index];
                        return _listTile(
                          tx.title,
                          tx.category,
                          tx.amount,
                          tx.color,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Your existing _statCard and _listTile widgets stay the same
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
