import 'package:flutter/material.dart';

class TransactionModel {
  final int id;
  final String transactionId; // Maps to transaction_id in DB
  final String merchant;
  final String category;
  final double amount;
  final String type; // 'income' or 'expense'
  final String? smsRaw; // Maps to sms_raw in DB
  final Map<String, dynamic>? parsedMetadata; // Maps to jsonb
  final DateTime createdAt;
  final bool needsClarification; // Maps to needs_clarification in DB
  final double? postBalance; // Maps to post_balance in DB
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
    bool? isRecurring,
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
      isRecurring: isRecurring ?? this.isRecurring,
    );
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as int,
      transactionId: json['transaction_id'] ?? '',
      merchant: json['merchant'] ?? 'Unknown',
      category: json['category'] ?? 'General',
      // Explicitly handling Postgres numeric/decimal types
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      type: json['type'] ?? 'expense',
      smsRaw: json['sms_raw'],
      parsedMetadata: json['parsed_metadata'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      needsClarification: json['needs_clarification'] ?? false,
      postBalance: json['post_balance'] != null
          ? double.tryParse(json['post_balance'].toString())
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
