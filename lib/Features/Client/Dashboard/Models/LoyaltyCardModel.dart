import 'package:flutter/material.dart';

class LoyaltyCardModel {
  final String name;
  final String subtitle;
  final IconData icon;

  final String cardNumber; // still masked if needed
  final int transactions; // 🔥 FIXED (was unclear before)

  final int points;
  final int targetPoints;

  final String type; // bronze / argent / gold
  final Color color;

  LoyaltyCardModel({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.cardNumber,
    required this.transactions,
    required this.points,
    required this.targetPoints,
    required this.type,
    required this.color,
  });

  double get progress => points / targetPoints;
}