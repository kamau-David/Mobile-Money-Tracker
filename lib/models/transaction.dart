import 'package:flutter/material.dart';

class TransactionModel {
  final int id;
  final String transactionId; // Maps to transaction_id in DB
  final String merchant; // Maps to merchant (replaces 'title')
  final String category;
  final double amount; // Changed to double for finance math
  final String type; // e.g., 'Income' or 'Expense'
  final String? smsRaw; // Stores the original SMS
  final Map<String, dynamic>? parsedMetadata; // Maps to jsonb
  final DateTime createdAt;
  final bool needsClarification;
  final double? postBalance; // Tracks account health after transaction
  final bool isRecurring;

  TransactionModel({
    required this.id,
    required this.transactionId,
    required this.merchant,
    required this.category,
    required this.amount,
    required this.type,
    this.smsRaw,
    this.parsedMetadata,
    required this.createdAt,
    this.needsClarification = false,
    this.postBalance,
    this.isRecurring = false,
  });

  // --- UI HELPER: CATEGORY COLORS ---
  // Maintaining your color logic but keeping it out of the database
  Color get categoryColor {
    switch (category.toLowerCase()) {
      case 'food':
        return Colors.orange;
      case 'transport':
        return Colors.blue;
      case 'utilities':
        return Colors.purple;
      case 'shopping':
        return Colors.pink;
      case 'income':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // --- HELPER: FORMATTED DATE ---
  String get formattedDate =>
      "${createdAt.day}/${createdAt.month}/${createdAt.year}";

  TransactionModel copyWith({
    int? id,
    String? transactionId,
    String? merchant,
    String? category,
    double? amount,
    String? type,
    DateTime? createdAt,
    bool? needsClarification,
    double? postBalance,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      merchant: merchant ?? this.merchant,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      needsClarification: needsClarification ?? this.needsClarification,
      postBalance: postBalance ?? this.postBalance,
    );
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      transactionId: json['transaction_id'] ?? '',
      merchant: json['merchant'] ?? 'Unknown',
      category: json['category'] ?? 'General',
      // Handles numeric/decimal coming from Postgres as String or Double
      amount: double.parse(json['amount'].toString()),
      type: json['type'] ?? 'Expense',
      smsRaw: json['sms_raw'],
      parsedMetadata: json['parsed_metadata'],
      createdAt: DateTime.parse(json['created_at']),
      needsClarification: json['needs_clarification'] ?? false,
      postBalance: json['post_balance'] != null
          ? double.parse(json['post_balance'].toString())
          : null,
      isRecurring: json['is_recurring'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'merchant': merchant,
      'category': category,
      'amount': amount,
      'type': type,
      'sms_raw': smsRaw,
      'parsed_metadata': parsedMetadata,
      'created_at': createdAt.toIso8601String(),
      'needs_clarification': needsClarification,
      'post_balance': postBalance,
      'is_recurring': isRecurring,
    };
  }
}
