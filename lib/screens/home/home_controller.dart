import 'package:flutter/material.dart';
import '../../core/network/api_service.dart';

class HomeController {
  final ApiService _apiService = ApiService();

  // 1. Data Variables (The "Trays" to hold the food from the kitchen)
  List<dynamic> pendingTransactions = [];
  Map<String, dynamic>? financialForecast;
  bool isLoading = false;
  String? errorMessage;

  // 2. The "Morning Call" (Fetch all data when app starts)
  Future<void> refreshDashboard({required Function onUpdate}) async {
    isLoading = true;
    errorMessage = null;
    onUpdate(); // Tell UI to show the loading spinner

    try {
      // We run these in parallel to save time
      final results = await Future.wait([
        _apiService.getPendingTransactions(),
        // Add other calls here like getForecast() once implemented in ApiService
      ]);

      pendingTransactions = results[0] as List<dynamic>;

      isLoading = false;
      onUpdate(); // Tell UI data is here!
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      onUpdate();
    }
  }

  // 3. Logic: Should we show the "Action Required" Banner?
  bool get showPendingBanner => pendingTransactions.isNotEmpty;

  // 4. Logic: Handle the Goal Nudge
  // This is called when the SMS Listener detects a new income
  void handleNewIncome(Map<String, dynamic> data, BuildContext context) {
    if (data['suggestion'] != null) {
      final suggestion = data['suggestion'];

      // Here is where we would trigger your GoalNudgeSheet!
      print("Triggering Nudge for Goal: ${suggestion['goalName']}");

      // Logic to show the BottomSheet goes here
    }
  }
}
