// Features/Merchant/FortuneWheel/Models/FortuneWheelConfigModel.dart
import 'package:flutter/material.dart';

class FortuneSegmentModel {
  final String label;
  final String type; // discount, points, cashback...
  final String value;
  final int probability;
  final Color color;
  final int maxWinnersPerDay;

  FortuneSegmentModel({
    required this.label,
    required this.type,
    required this.value,
    required this.probability,
    required this.color,
    required this.maxWinnersPerDay,
  });

  factory FortuneSegmentModel.fromJson(Map<String, dynamic> json) {
    return FortuneSegmentModel(
      label: json['label']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
      probability: (json['probability'] ?? 0) as int,
      color: _parseColor(json['color']),
      maxWinnersPerDay: (json['maxWinnersPerDay'] ?? 0) as int,
    );
  }

  static Color _parseColor(dynamic hex) {
    if (hex == null) return Colors.grey;
    String h = hex.toString().replaceAll('#', '');
    if (h.length == 6) h = 'FF$h';
    return Color(int.tryParse(h, radix: 16) ?? 0xFF9E9E9E);
  }
}

class FortuneWheelConfigModel {
  final String id;
  final String companyId;
  final bool active;
  final bool activeHoursEnabled;
  final String activeHoursStart;
  final String activeHoursEnd;
  final int maxPerDay;
  final int maxPerWeek;
  final List<FortuneSegmentModel> segments;
  final List<String> triggers;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FortuneWheelConfigModel({
    required this.id,
    required this.companyId,
    required this.active,
    required this.activeHoursEnabled,
    required this.activeHoursStart,
    required this.activeHoursEnd,
    required this.maxPerDay,
    required this.maxPerWeek,
    required this.segments,
    required this.triggers,
    this.createdAt,
    this.updatedAt,
  });

  /// Backend returns segments: [] and triggers: [] when the wheel
  /// hasn't been configured yet — that's our source of truth.
  bool get isConfigured => segments.isNotEmpty;

  factory FortuneWheelConfigModel.fromJson(Map<String, dynamic> json) {
    return FortuneWheelConfigModel(
      id: json['_id']?.toString() ?? '',
      companyId: json['companyId']?.toString() ?? '',
      active: json['active'] ?? false,
      activeHoursEnabled: json['activeHoursEnabled'] ?? false,
      activeHoursStart: json['activeHoursStart']?.toString() ?? '09:00',
      activeHoursEnd: json['activeHoursEnd']?.toString() ?? '21:00',
      maxPerDay: (json['maxPerDay'] ?? 0) as int,
      maxPerWeek: (json['maxPerWeek'] ?? 0) as int,
      segments: (json['segments'] as List<dynamic>? ?? [])
          .map((e) => FortuneSegmentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      triggers: (json['triggers'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }
}