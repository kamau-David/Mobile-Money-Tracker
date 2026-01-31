import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';

enum TransactionFilter { all, daily, weekly, monthly }

class FinanceState {
  final double balance;
  final List<TransactionModel> transactions;
  final TransactionFilter activeFilter;
  final bool isLoading;

  FinanceState({
    required this.balance,
    required this.transactions,
    this.activeFilter = TransactionFilter.all,
    this.isLoading = true,
  });

  FinanceState copyWith({
    double? balance,
    List<TransactionModel>? transactions,
    TransactionFilter? activeFilter,
    bool? isLoading,
  }) {
    return FinanceState(
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
      activeFilter: activeFilter ?? this.activeFilter,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class FinanceNotifier extends Notifier<FinanceState> {
  static const _storageKey = 'money_tracker_data';

  @override
  FinanceState build() {
    _loadData();
    return FinanceState(balance: 0.0, transactions: [], isLoading: true);
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? saved = prefs.getString(_storageKey);

    if (saved != null) {
      try {
        final List<dynamic> decoded = jsonDecode(saved);
        final list = decoded
            .map((item) => TransactionModel.fromJson(item))
            .toList();

        double currentBalance = 0.0;
        for (var tx in list) {
          final val =
              double.tryParse(tx.amount.replaceAll(RegExp(r'[^0-9.]'), '')) ??
              0.0;
          tx.amount.contains('+')
              ? currentBalance += val
              : currentBalance -= val;
        }

        state = state.copyWith(
          balance: currentBalance,
          transactions: list,
          isLoading: false,
        );
      } catch (e) {
        state = state.copyWith(isLoading: false);
      }
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  void addTransaction({
    required String title,
    required String category,
    required double amount,
    required bool isIncome,
  }) {
    final now = DateTime.now();
    final newTx = TransactionModel(
      title: title,
      category: category,
      amount: isIncome
          ? "+ KES ${amount.toStringAsFixed(0)}"
          : "- KES ${amount.toStringAsFixed(0)}",
      color: isIncome ? Colors.green : Colors.red,
      date: "${_getMonth(now.month)} ${now.day}",
      timestamp: now,
    );

    final updatedTransactions = [newTx, ...state.transactions];
    final updatedBalance = isIncome
        ? state.balance + amount
        : state.balance - amount;

    state = state.copyWith(
      balance: updatedBalance,
      transactions: updatedTransactions,
    );
    _saveToDisk(updatedTransactions);
  }

  // --- NEW: CLEAR ALL DATA METHOD ---
  Future<void> clearAllTransactions() async {
    // 1. Reset the local state
    state = state.copyWith(balance: 0.0, transactions: []);

    // 2. Clear from disk (SharedPreferences)
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  Future<void> _saveToDisk(List<TransactionModel> list) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(list.map((tx) => tx.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  void setFilter(TransactionFilter filter) =>
      state = state.copyWith(activeFilter: filter);

  String _getMonth(int m) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[m - 1];
  }
}

final financeProvider = NotifierProvider<FinanceNotifier, FinanceState>(
  () => FinanceNotifier(),
);

// --- PROVIDERS FOR FILTERING AND SUMMARY ---

final filteredTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final finance = ref.watch(financeProvider);
  final now = DateTime.now();
  if (finance.activeFilter == TransactionFilter.all)
    return finance.transactions;
  return finance.transactions.where((tx) {
    final diff = now.difference(tx.timestamp);
    if (finance.activeFilter == TransactionFilter.daily)
      return diff.inHours < 24;
    if (finance.activeFilter == TransactionFilter.weekly)
      return diff.inDays <= 7;
    if (finance.activeFilter == TransactionFilter.monthly)
      return diff.inDays <= 30;
    return true;
  }).toList();
});

final filteredTotalSpentProvider = Provider<double>((ref) {
  final transactions = ref.watch(filteredTransactionsProvider);
  return transactions.fold(0.0, (sum, tx) {
    if (!tx.amount.contains('-')) return sum;
    final val =
        double.tryParse(tx.amount.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    return sum + val;
  });
});

final categorySpendingProvider = Provider<Map<String, double>>((ref) {
  final transactions = ref.watch(filteredTransactionsProvider);
  final expenses = transactions.where((tx) => tx.amount.contains('-')).toList();
  Map<String, double> categoryMap = {};
  double total = 0.0;
  for (var tx in expenses) {
    final val =
        double.tryParse(tx.amount.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    categoryMap[tx.category] = (categoryMap[tx.category] ?? 0.0) + val;
    total += val;
  }
  if (total == 0) return {};
  return categoryMap.map((key, value) => MapEntry(key, (value / total) * 100));
});
