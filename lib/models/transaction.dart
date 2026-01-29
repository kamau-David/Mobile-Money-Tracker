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
}
