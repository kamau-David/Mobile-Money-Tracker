import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';

// 1. Define the filters available in the UI
enum TransactionFilter { all, daily, weekly, monthly }

// 2. Define the State Object
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

// 3. The Notifier Logic
class FinanceNotifier extends Notifier<FinanceState> {
  final String baseUrl = 'http://10.0.2.2:5000/api/transactions';

  @override
  FinanceState build() {
    fetchTransactions();
    return FinanceState(balance: 0.0, transactions: [], isLoading: true);
  }

  /// GET all transactions from Postgres
  Future<void> fetchTransactions() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final list = data
            .map((item) => TransactionModel.fromJson(item))
            .toList();

        double currentBalance = list.fold(
          0.0,
          (sum, tx) => tx.type == 'Income' ? sum + tx.amount : sum - tx.amount,
        );

        state = state.copyWith(
          balance: currentBalance,
          transactions: list,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      print("Database sync error: $e");
      state = state.copyWith(isLoading: false);
    }
  }

  /// POST a new transaction to Postgres
  Future<void> addTransaction({
    required String merchant,
    required String category,
    required double amount,
    required String type,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'merchant': merchant,
          'category': category,
          'amount': amount,
          'type': type,
        }),
      );

      if (response.statusCode == 201) {
        await fetchTransactions();
      }
    } catch (e) {
      print("Error adding transaction: $e");
    }
  }

  /// DELETE all transactions from Postgres
  Future<void> clearAllTransactions() async {
    try {
      final response = await http.delete(Uri.parse(baseUrl));

      if (response.statusCode == 200 || response.statusCode == 204) {
        state = state.copyWith(
          balance: 0.0,
          transactions: [],
          isLoading: false,
        );
      }
    } catch (e) {
      print("Error wiping database: $e");
    }
  }

  void setFilter(TransactionFilter filter) {
    state = state.copyWith(activeFilter: filter);
  }
}

// 4. THE PROVIDERS

final financeProvider = NotifierProvider<FinanceNotifier, FinanceState>(
  () => FinanceNotifier(),
);

final filteredTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final finance = ref.watch(financeProvider);
  final now = DateTime.now();

  if (finance.activeFilter == TransactionFilter.all)
    return finance.transactions;

  return finance.transactions.where((tx) {
    final diff = now.difference(tx.createdAt);
    switch (finance.activeFilter) {
      case TransactionFilter.daily:
        return diff.inHours < 24;
      case TransactionFilter.weekly:
        return diff.inDays <= 7;
      case TransactionFilter.monthly:
        return diff.inDays <= 30;
      default:
        return true;
    }
  }).toList();
});

final filteredTotalSpentProvider = Provider<double>((ref) {
  final filteredTxs = ref.watch(filteredTransactionsProvider);
  return filteredTxs
      .where((tx) => tx.type == 'Expense')
      .fold(0.0, (sum, tx) => sum + tx.amount);
});

final categorySpendingProvider = Provider<Map<String, double>>((ref) {
  final filteredTxs = ref.watch(filteredTransactionsProvider);
  final totalExpenses = ref.watch(filteredTotalSpentProvider);

  if (totalExpenses == 0) return {};

  Map<String, double> grouped = {};
  for (var tx in filteredTxs.where((tx) => tx.type == 'Expense')) {
    grouped[tx.category] = (grouped[tx.category] ?? 0.0) + tx.amount;
  }

  return grouped.map(
    (category, amount) => MapEntry(category, (amount / totalExpenses) * 100),
  );
});
