import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';

enum TransactionFilter { all, daily, weekly, monthly }

class FinanceState {
  final double balance;
  final List<TransactionModel> transactions;
  final TransactionFilter activeFilter;

  FinanceState({
    required this.balance,
    required this.transactions,
    this.activeFilter = TransactionFilter.all,
  });
}

class FinanceNotifier extends Notifier<FinanceState> {
  @override
  FinanceState build() {
    return FinanceState(
      balance: 192500.0,
      transactions: [],
      activeFilter: TransactionFilter.all,
    );
  }

  void setFilter(TransactionFilter filter) {
    state = FinanceState(
      balance: state.balance,
      transactions: state.transactions,
      activeFilter: filter,
    );
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
          ? "+ ${amount.toStringAsFixed(0)} KES"
          : "- ${amount.toStringAsFixed(0)} KES",
      color: isIncome ? Colors.green : Colors.red,
      date: "${_getMonthName(now.month)} ${now.day}",
      timestamp: now,
    );

    state = FinanceState(
      balance: isIncome ? state.balance + amount : state.balance - amount,
      transactions: [newTx, ...state.transactions],
      activeFilter: state.activeFilter,
    );
  }

  String _getMonthName(int month) {
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
    return months[month - 1];
  }
}

final financeProvider = NotifierProvider<FinanceNotifier, FinanceState>(() {
  return FinanceNotifier();
});

final filteredTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final finance = ref.watch(financeProvider);
  final now = DateTime.now();

  if (finance.activeFilter == TransactionFilter.all) {
    return finance.transactions;
  }

  return finance.transactions.where((tx) {
    final difference = now.difference(tx.timestamp);

    if (finance.activeFilter == TransactionFilter.daily) {
      return difference.inHours < 24;
    } else if (finance.activeFilter == TransactionFilter.weekly) {
      return difference.inDays <= 7;
    } else if (finance.activeFilter == TransactionFilter.monthly) {
      return difference.inDays <= 30;
    }
    return true;
  }).toList();
});
