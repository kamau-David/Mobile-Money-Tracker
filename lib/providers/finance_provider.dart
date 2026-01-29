import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';

class FinanceState {
  final double balance;
  final List<TransactionModel> transactions;

  FinanceState({required this.balance, required this.transactions});
}

class FinanceNotifier extends Notifier<FinanceState> {
  @override
  FinanceState build() {
    return FinanceState(balance: 192500.0, transactions: []);
  }

  void addTransaction({
    required String title,
    required String category,
    required double amount,
    required bool isIncome,
  }) {
    final newTx = TransactionModel(
      title: title,
      category: category,
      amount: isIncome
          ? "+ ${amount.toStringAsFixed(0)} KES"
          : "- ${amount.toStringAsFixed(0)} KES",
      color: isIncome ? Colors.green : Colors.red,
      date: _getFormattedDate(),
    );

    state = FinanceState(
      balance: isIncome ? state.balance + amount : state.balance - amount,
      transactions: [newTx, ...state.transactions],
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
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
    return "${months[now.month - 1]} ${now.day}";
  }
}

final financeProvider = NotifierProvider<FinanceNotifier, FinanceState>(() {
  return FinanceNotifier();
});
