import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart'; // Ensure this matches your file name

// 1. Define the State Object
class FinanceState {
  final double balance;
  final List<TransactionModel> transactions;

  FinanceState({required this.balance, required this.transactions});
}

// 2. Create the Notifier (The Brain)
class FinanceNotifier extends Notifier<FinanceState> {
  @override
  FinanceState build() {
    // Initial State: Starting balance and empty list
    return FinanceState(balance: 192500.0, transactions: []);
  }

  // 3. Logic to add a transaction
  void addTransaction({
    required String title,
    required String category,
    required double amount,
    required bool isIncome,
  }) {
    // Create the visual TransactionModel based on your specific class
    final newTx = TransactionModel(
      title: title,
      category: category,
      amount: isIncome
          ? "+ ${amount.toStringAsFixed(0)} KES"
          : "- ${amount.toStringAsFixed(0)} KES",
      color: isIncome ? Colors.green : Colors.red,
      date: _getFormattedDate(),
    );

    // Update state: Mathematics for balance + adding to list
    state = FinanceState(
      balance: isIncome ? state.balance + amount : state.balance - amount,
      transactions: [newTx, ...state.transactions], // Newest at the top
    );
  }

  // Helper method for the date string
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

// 4. The Global Provider
final financeProvider = NotifierProvider<FinanceNotifier, FinanceState>(() {
  return FinanceNotifier();
});
