import 'package:flutter/material.dart';

class TransactionModel {
  final String title;
  final String category;
  final String amount;
  final Color color;
  final String date;
  final DateTime timestamp;

  TransactionModel({
    required this.title,
    required this.category,
    required this.amount,
    required this.color,
    required this.date,
    required this.timestamp,
  });

  TransactionModel copyWith({
    String? title,
    String? category,
    String? amount,
    Color? color,
    String? date,
    DateTime? timestamp,
  }) {
    return TransactionModel(
      title: title ?? this.title,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      color: color ?? this.color,
      date: date ?? this.date,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category': category,
      'amount': amount,
      'colorValue': color.value,
      'date': date,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      title: json['title'],
      category: json['category'],
      amount: json['amount'],
      color: Color(json['colorValue']),
      date: json['date'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
