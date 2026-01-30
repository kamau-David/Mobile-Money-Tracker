import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/finance_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(filteredTransactionsProvider);
    final activeFilter = ref.watch(financeProvider).activeFilter;

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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterChip(
                  ref,
                  "1 Day",
                  TransactionFilter.daily,
                  activeFilter,
                ),
                _buildFilterChip(
                  ref,
                  "7 Days",
                  TransactionFilter.weekly,
                  activeFilter,
                ),
                _buildFilterChip(
                  ref,
                  "30 Days",
                  TransactionFilter.monthly,
                  activeFilter,
                ),
                _buildFilterChip(
                  ref,
                  "All",
                  TransactionFilter.all,
                  activeFilter,
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      return _historyTile(tx);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    WidgetRef ref,
    String label,
    TransactionFilter filter,
    TransactionFilter current,
  ) {
    final isSelected = filter == current;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) ref.read(financeProvider.notifier).setFilter(filter);
      },
      selectedColor: const Color(0xFF2E7D32),
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
    );
  }

  Widget _historyTile(tx) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: tx.color.withOpacity(0.1),
          child: Icon(
            tx.amount.contains('+') ? Icons.arrow_upward : Icons.arrow_downward,
            color: tx.color,
            size: 18,
          ),
        ),
        title: Text(
          tx.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("${tx.category} • ${tx.date}"),
        trailing: Text(
          tx.amount,
          style: TextStyle(
            color: tx.color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
