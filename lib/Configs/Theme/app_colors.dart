import 'package:flutter/material.dart';

class AppColors {
  // =========================
  // PRIMARY BRAND COLOR
  // =========================
  static const primary = Color(0xFF006D77);
  static const primaryLight = Color(0xFF0A9396);
  static const primaryDark = Color(0xFF004E56);

  // =========================
  // STATUS COLORS
  // =========================
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  // =========================
  // SHADOW
  // =========================
  static List<BoxShadow> shadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    )
  ];
}