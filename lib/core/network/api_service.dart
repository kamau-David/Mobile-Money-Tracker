import 'package:dio/dio.dart';
import 'api_config.dart'; // Ensure this file exists in the same folder

class ApiService {
  // 1. Singleton pattern: Access this via ApiService().method()
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // 1. Send raw M-Pesa SMS for parsing
  Future<Map<String, dynamic>> parseMpesaSms(String smsText) async {
    try {
      final response = await _dio.post(
        ApiConfig.parseSms,
        data: {'smsText': smsText},
      );
      // Return the data as a Map
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 2. Fetch Pending Clarifications
  Future<List<dynamic>> getPendingTransactions() async {
    try {
      final response = await _dio.get(ApiConfig.pending);
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 3. Update a transaction (Verify Category)
  Future<void> updateTransactionCategory(int id, String category) async {
    try {
      // NOTE: We use ApiConfig.baseUrl + the specific string to match your backend
      await _dio.patch(
        '/sms/update/$id', 
        data: {'category': category},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 4. Add Savings to a Goal
  Future<void> addGoalSavings(int goalId, double amount) async {
    try {
      await _dio.patch(
        ApiConfig.addGoalProgress,
        data: {
          'goalId': goalId,
          'amount': amount,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error handling helper
  String _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      return "Connection timed out. Is your Node.js server running?";
    }
    if (e.response != null) {
      // Pulls the error message from your Express res.status(500).json({ error: "..." })
      return e.response?.data['error'] ?? e.response?.data['message'] ?? "Server Error";
    }
    return "Connection failed. Check your internet or Emulator IP (10.0.2.2).";
  }
}