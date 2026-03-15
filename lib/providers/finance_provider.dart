import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import 'user_provider.dart';

enum TransactionFilter { all, daily, weekly, monthly }

class FinanceState {
  final double balance;
  final double totalIncome;
  final double totalExpense;
  final List<TransactionModel> transactions;
  final TransactionFilter activeFilter;
  final bool isLoading;

  FinanceState({
    required this.balance,
    this.totalIncome = 0.0,
    this.totalExpense = 0.0,
    required this.transactions,
    this.activeFilter = TransactionFilter.all,
    this.isLoading = true,
  });

  FinanceState copyWith({
    double? balance,
    double? totalIncome,
    double? totalExpense,
    List<TransactionModel>? transactions,
    TransactionFilter? activeFilter,
    bool? isLoading,
  }) {
    return FinanceState(
      balance: balance ?? this.balance,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      transactions: transactions ?? this.transactions,
      activeFilter: activeFilter ?? this.activeFilter,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class FinanceNotifier extends Notifier<FinanceState> {
  final String baseUrl = 'http://10.0.2.2:3000/api';

  // Endpoint Paths
  String get transactionUrl => '$baseUrl/transactions';
  String get summaryUrl => '$baseUrl/summary';
  String get parseSmsUrl => '$baseUrl/transactions/parse';
  String get goalsUrl => '$baseUrl/goals/progress';

  @override
  FinanceState build() {
    refreshHomeData();
    return FinanceState(balance: 0.0, transactions: [], isLoading: true);
  }

  Map<String, String> _getHeaders() {
    final dynamic user = ref.read(userProvider);
    final String token = user.token ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<void> refreshHomeData() async {
    state = state.copyWith(isLoading: true);
    try {
      final summaryResponse = await http.get(
        Uri.parse(summaryUrl),
        headers: _getHeaders(),
      );
      final transResponse = await http.get(
        Uri.parse(transactionUrl),
        headers: _getHeaders(),
      );

      if (summaryResponse.statusCode == 200 &&
          transResponse.statusCode == 200) {
        final summaryData = jsonDecode(summaryResponse.body);
        final List<dynamic> transData = jsonDecode(transResponse.body);

        state = state.copyWith(
          balance:
              double.tryParse(summaryData['currentBalance'].toString()) ?? 0.0,
          totalIncome:
              double.tryParse(summaryData['totalIncome'].toString()) ?? 0.0,
          totalExpense:
              double.tryParse(summaryData['totalExpense'].toString()) ?? 0.0,
          transactions: transData
              .map((item) => TransactionModel.fromJson(item))
              .toList(),
          isLoading: false,
        );
      }
    } catch (e) {
      debugPrint("Error refreshing data: $e");
      state = state.copyWith(isLoading: false);
    }
  }

  /// NEW: Records savings towards a specific goal (Used by GoalNudgeSheet)
  Future<void> recordGoalSavings({
    required String goalId,
    required double amount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(goalsUrl),
        headers: _getHeaders(),
        body: jsonEncode({'goalId': goalId, 'amount': amount}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint("✅ Goal progress updated");
        await refreshHomeData(); // Refresh UI to show updated balance
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Error recording goal savings: $e");
      rethrow;
    }
  }

  /// NEW: Updates a category (Used for manual verification/corrections)
  Future<void> updateTransactionCategory(
    String transactionId,
    String newCategory,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$transactionUrl/$transactionId'),
        headers: _getHeaders(),
        body: jsonEncode({'category': newCategory}),
      );

      if (response.statusCode == 200) {
        await refreshHomeData();
      }
    } catch (e) {
      debugPrint("Error updating category: $e");
    }
  }

  Future<Map<String, dynamic>?> autoProcessSms(String smsText) async {
    try {
      final response = await http.post(
        Uri.parse(parseSmsUrl),
        headers: _getHeaders(),
        body: jsonEncode({'smsText': smsText}),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await refreshHomeData();
        return data['suggestion'] as Map<String, dynamic>?;
      }
    } catch (e) {
      debugPrint("Error in Gemini auto-processing: $e");
    }
    return null;
  }

  Future<void> addTransaction({
    required String merchant,
    required String category,
    required double amount,
    required String type,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(transactionUrl),
        headers: _getHeaders(),
        body: jsonEncode({
          'merchant': merchant,
          'category': category,
          'amount': amount,
          'type': type.toLowerCase(),
        }),
      );
      if (response.statusCode == 201) {
        await refreshHomeData();
      }
    } catch (e) {
      debugPrint("Error adding transaction: $e");
    }
  }

  Future<void> clearAllTransactions() async {
    try {
      final response = await http.delete(
        Uri.parse(transactionUrl),
        headers: _getHeaders(),
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        state = state.copyWith(
          balance: 0.0,
          transactions: [],
          totalIncome: 0.0,
          totalExpense: 0.0,
        );
      }
    } catch (e) {
      debugPrint("Error clearing: $e");
    }
  }

  Future<bool> triggerPdfEmail(String filter, String userEmail) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reports/send-report'),
        headers: _getHeaders(),
        body: jsonEncode({'filter': filter, 'email': userEmail}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  void setFilter(TransactionFilter filter) =>
      state = state.copyWith(activeFilter: filter);
}

// --- PROVIDERS ---

final financeProvider = NotifierProvider<FinanceNotifier, FinanceState>(
  () => FinanceNotifier(),
);

final recentTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  return ref.watch(financeProvider).transactions.take(5).toList();
});

final filteredTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final finance = ref.watch(financeProvider);
  if (finance.activeFilter == TransactionFilter.all)
    return finance.transactions;

  final now = DateTime.now();
  return finance.transactions.where((tx) {
    final diff = now.difference(tx.createdAt);
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
  final filteredTxs = ref.watch(filteredTransactionsProvider);
  return filteredTxs
      .where((tx) => tx.type.toLowerCase() == 'expense')
      .fold(0.0, (sum, tx) => sum + tx.amount);
});

final categorySpendingProvider = Provider<Map<String, double>>((ref) {
  final filteredTxs = ref.watch(filteredTransactionsProvider);
  final expenses = filteredTxs
      .where((tx) => tx.type.toLowerCase() == 'expense')
      .toList();
  if (expenses.isEmpty) return {};

  final total = expenses.fold(0.0, (sum, tx) => sum + tx.amount);
  Map<String, double> grouped = {};
  for (var tx in expenses) {
    grouped[tx.category] = (grouped[tx.category] ?? 0.0) + tx.amount;
  }
  return grouped.map((cat, amt) => MapEntry(cat, (amt / total) * 100));
});
