import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/finance_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(filteredTransactionsProvider);
    final activeFilter = ref.watch(financeProvider).activeFilter;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text(
          "Transaction History",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            color: isDark ? Colors.black12 : Colors.grey[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterChip(
                  ref,
                  "1 Day",
                  TransactionFilter.daily,
                  activeFilter,
                  isDark,
                ),
                _buildFilterChip(
                  ref,
                  "7 Days",
                  TransactionFilter.weekly,
                  activeFilter,
                  isDark,
                ),
                _buildFilterChip(
                  ref,
                  "30 Days",
                  TransactionFilter.monthly,
                  activeFilter,
                  isDark,
                ),
                _buildFilterChip(
                  ref,
                  "All",
                  TransactionFilter.all,
                  activeFilter,
                  isDark,
                ),
              ],
            ),
          ),
          Expanded(
            child: transactions.isEmpty
                ? Center(
                    child: Text(
                      "No transactions found for this period.",
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      return _historyTile(transactions[index], isDark);
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
    bool isDark,
  ) {
    final isSelected = filter == current;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) ref.read(financeProvider.notifier).setFilter(filter);
      },
      selectedColor: const Color(0xFF2E7D32),
      backgroundColor: isDark ? Colors.white10 : Colors.white,
      labelStyle: TextStyle(
        color: isSelected
            ? Colors.white
            : (isDark ? Colors.white70 : Colors.black87),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? Colors.transparent
              : (isDark ? Colors.white24 : Colors.grey.shade300),
        ),
      ),
      elevation: isSelected ? 2 : 0,
      pressElevation: 4,
    );
  }

  Widget _historyTile(tx, bool isDark) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200),
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
        subtitle: Text(
          "${tx.category} • ${tx.date}",
          style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
        ),
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
