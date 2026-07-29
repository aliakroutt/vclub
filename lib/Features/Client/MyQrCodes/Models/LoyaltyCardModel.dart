import 'package:flutter/material.dart';

class LoyaltyCardModel {
  final String id;
  final String name;
  final String type; // bronze, agent...
  final int points;
  final int targetPoints;
  final IconData icon;

  LoyaltyCardModel({
    required this.id,
    required this.name,
    required this.type,
    required this.points,
    required this.targetPoints,
    required this.icon,
  });
}