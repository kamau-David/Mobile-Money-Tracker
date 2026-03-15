import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/finance_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watching the filtered provider ensures the list updates when chips are clicked
    final transactions = ref.watch(filteredTransactionsProvider);
    final activeFilter = ref.watch(financeProvider).activeFilter;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        title: const Text(
          "Transaction History",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            decoration: BoxDecoration(
              color: isDark ? Colors.black26 : Colors.grey[50],
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.white10 : Colors.grey.shade300,
                ),
              ),
            ),
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

          // Transactions List
          Expanded(
            child: transactions.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
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
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? Colors.transparent
              : (isDark ? Colors.white24 : Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off,
            size: 64,
            color: isDark ? Colors.white24 : Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            "No transactions found.",
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyTile(tx, bool isDark) {
    // Dynamic logic based on backend model fields
    final bool isIncome = tx.type.toLowerCase() == 'income';
    final Color txColor = isIncome ? Colors.green : Colors.red;

    // Formatting the date from the DateTime object
    final String formattedDate = DateFormat(
      'MMM dd, yyyy • hh:mm a',
    ).format(tx.createdAt);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: txColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isIncome ? Icons.add_circle_outline : Icons.remove_circle_outline,
            color: txColor,
            size: 24,
          ),
        ),
        title: Text(
          tx.merchant,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          "${tx.category} • $formattedDate",
          style: TextStyle(
            color: isDark ? Colors.white54 : Colors.black54,
            fontSize: 12,
          ),
        ),
        trailing: Text(
          "${isIncome ? '+' : '-'} KES ${tx.amount.toStringAsFixed(2)}",
          style: TextStyle(
            color: txColor,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
