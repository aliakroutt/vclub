import 'package:flutter/material.dart';

class LoyaltyTransaction {
  final String company;
  final String description;
  final int points;
  final DateTime date;
  final Color color;

  LoyaltyTransaction({
    required this.company,
    required this.description,
    required this.points,
    required this.date,
    required this.color,
  });

  bool get isPositive => points >= 0;
}