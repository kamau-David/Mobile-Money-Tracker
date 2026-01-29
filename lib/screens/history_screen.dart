import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/finance_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finance = ref.watch(financeProvider);
    // We watch the logic-heavy list here
    final transactions = ref.watch(filteredTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text(
          "Transaction History",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter Chips Row
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _filterChip(
                  ref,
                  "1 Day",
                  TransactionFilter.daily,
                  finance.activeFilter,
                ),
                _filterChip(
                  ref,
                  "7 Days",
                  TransactionFilter.weekly,
                  finance.activeFilter,
                ),
                _filterChip(
                  ref,
                  "30 Days",
                  TransactionFilter.monthly,
                  finance.activeFilter,
                ),
              ],
            ),
          ),

          Expanded(
            child: transactions.isEmpty
                ? const Center(
                    child: Text("No transactions found for this period."),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      return _historyTile(
                        tx.date,
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
    );
  }

  Widget _filterChip(
    WidgetRef ref,
    String label,
    TransactionFilter filter,
    TransactionFilter active,
  ) {
    final isSelected = filter == active;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        ref.read(financeProvider.notifier).setFilter(filter);
      },
      selectedColor: const Color(0xFF2E7D32),
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
    );
  }

  Widget _historyTile(String d, String t, String f, String a, Color c) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: c.withOpacity(0.1),
          child: Text(
            d.split(' ')[1],
            style: TextStyle(color: c, fontSize: 12),
          ),
        ),
        title: Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(f),
        trailing: Text(
          a,
          style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
