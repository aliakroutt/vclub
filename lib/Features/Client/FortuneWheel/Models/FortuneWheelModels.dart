import 'package:flutter/material.dart';

enum WheelSegmentType { gift, discount, points, cashback, noWin }

extension WheelSegmentTypeX on WheelSegmentType {
  static WheelSegmentType fromApi(String? value) {
    switch (value) {
      case 'gift': return WheelSegmentType.gift;
      case 'discount': return WheelSegmentType.discount;
      case 'points': return WheelSegmentType.points;
      case 'cashback': return WheelSegmentType.cashback;
      case 'no_win': return WheelSegmentType.noWin;
      default: return WheelSegmentType.gift;
    }
  }

  IconData get icon {
    switch (this) {
      case WheelSegmentType.gift: return Icons.card_giftcard_rounded;
      case WheelSegmentType.discount: return Icons.local_offer_rounded;
      case WheelSegmentType.points: return Icons.stars_rounded;
      case WheelSegmentType.cashback: return Icons.attach_money_rounded;
      case WheelSegmentType.noWin: return Icons.sentiment_dissatisfied_rounded;
    }
  }
}

enum WheelTrigger { purchase, googleReview, inscription, event }

extension WheelTriggerX on WheelTrigger {
  static WheelTrigger? fromApi(String value) {
    switch (value) {
      case 'purchase': return WheelTrigger.purchase;
      case 'google_review': return WheelTrigger.googleReview;
      case 'inscription': return WheelTrigger.inscription;
      case 'event': return WheelTrigger.event;
      default: return null;
    }
  }
}

class WheelSegmentModel {
  final String label;
  final WheelSegmentType type;
  final String value;
  final String colorHex;
  final int probability;

  WheelSegmentModel({
    required this.label,
    required this.type,
    required this.value,
    required this.colorHex,
    required this.probability,
  });

  Color get color {
    try {
      final hex = colorHex.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  factory WheelSegmentModel.fromJson(Map<String, dynamic> json) {
    return WheelSegmentModel(
      label: json['label']?.toString() ?? '',
      type: WheelSegmentTypeX.fromApi(json['type']?.toString()),
      value: json['value']?.toString() ?? '',
      colorHex: json['color']?.toString() ?? '#9E9E9E',
      probability: (json['probability'] as num?)?.toInt() ?? 0,
    );
  }
}

class WheelModel {
  final String id;
  final String companyId;
  final bool active;
  final List<WheelSegmentModel> segments;
  final bool canSpin;
  final List<WheelTrigger> triggers;
  final int maxPerDay;
  final int maxPerWeek;
  final String? activeHours;

  WheelModel({
    required this.id,
    required this.companyId,
    required this.active,
    required this.segments,
    required this.canSpin,
    required this.triggers,
    required this.maxPerDay,
    required this.maxPerWeek,
    this.activeHours,
  });

  factory WheelModel.fromJson(String companyId, Map<String, dynamic> json) {
    final wheelId = json['_id']?.toString() ??
        json['id']?.toString() ??
        json['wheelId']?.toString() ??
        companyId;

    return WheelModel(
      id: wheelId,
      companyId: companyId,
      active: json['active'] as bool? ?? false,
      segments: (json['segments'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => WheelSegmentModel.fromJson(e))
          .toList(),
      canSpin: json['canSpin'] as bool? ?? false,
      triggers: (json['triggers'] as List<dynamic>? ?? [])
          .map((e) => WheelTriggerX.fromApi(e.toString()))
          .whereType<WheelTrigger>()
          .toList(),
      maxPerDay: (json['maxPerDay'] as num?)?.toInt() ?? 0,
      maxPerWeek: (json['maxPerWeek'] as num?)?.toInt() ?? 0,
      activeHours: json['activeHours']?.toString(),
    );
  }
}

class ClientCompanyModel {
  final String companyId;
  final String companyName;
  final String? companyLogo;
  final String? programId;

  ClientCompanyModel({
    required this.companyId,
    required this.companyName,
    this.companyLogo,
    this.programId,
  });

  static String? _asId(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.isNotEmpty ? value : null;
    if (value is Map<String, dynamic>) {
      return value['_id']?.toString() ?? value['id']?.toString();
    }
    return null;
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    return value is Map<String, dynamic> ? value : null;
  }

  factory ClientCompanyModel.fromJson(Map<String, dynamic> json) {
    final companyRaw = json['companyId'] ?? json['company'];
    final programRaw = json['programId'] ?? json['program'];

    final companyMap = _asMap(companyRaw);
    final programMap = _asMap(programRaw);

    final companyId = _asId(companyRaw) ??
        json['companyId']?.toString() ??
        json['company_id']?.toString() ??
        '';

    final companyName = companyMap?['name']?.toString() ??
        companyMap?['companyName']?.toString() ??
        json['companyName']?.toString() ??
        json['company_name']?.toString() ??
        programMap?['companyName']?.toString() ??
        '';

    final companyLogo = companyMap?['logo']?.toString() ?? json['companyLogo']?.toString();

    final programId = _asId(programRaw) ?? json['programId']?.toString();

    return ClientCompanyModel(
      companyId: companyId,
      companyName: companyName,
      companyLogo: companyLogo,
      programId: programId,
    );
  }
}

class WheelHistoryItemModel {
  final String id;
  final String? companyId;
  final String? companyName;
  final String label;
  final WheelSegmentType type;
  final String value;
  final String? code;
  final DateTime createdAt;

  WheelHistoryItemModel({
    required this.id,
    this.companyId,
    this.companyName,
    required this.label,
    required this.type,
    required this.value,
    this.code,
    required this.createdAt,
  });

  bool get isWin => type != WheelSegmentType.noWin;

  factory WheelHistoryItemModel.fromJson(Map<String, dynamic> json) {
    final company = json['companyId'];
    final companyMap = company is Map<String, dynamic> ? company : null;

    return WheelHistoryItemModel(
      id: json['_id']?.toString() ?? '',
      companyId: companyMap?['_id']?.toString() ?? (company is String ? company : null),
      companyName: companyMap?['name']?.toString(),
      label: json['label']?.toString() ?? json['prize']?['label']?.toString() ?? '',
      type: WheelSegmentTypeX.fromApi(json['type']?.toString() ?? json['prize']?['type']?.toString()),
      value: json['value']?.toString() ?? json['prize']?['value']?.toString() ?? '',
      code: json['code']?.toString() ?? json['prize']?['code']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class SpinPrizeModel {
  final WheelSegmentType type;
  final String value;
  final String label;
  final String? code;

  SpinPrizeModel({required this.type, required this.value, required this.label, this.code});

  factory SpinPrizeModel.fromJson(Map<String, dynamic> json) {
    return SpinPrizeModel(
      type: WheelSegmentTypeX.fromApi(json['type']?.toString()),
      value: json['value']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      code: json['code']?.toString(),
    );
  }
}

class WheelSpinResult {
  final int segmentIndex;
  final WheelSegmentModel segment;
  final SpinPrizeModel prize;

  WheelSpinResult({required this.segmentIndex, required this.segment, required this.prize});

  factory WheelSpinResult.fromJson(Map<String, dynamic> json) {
    return WheelSpinResult(
      segmentIndex: (json['segmentIndex'] as num?)?.toInt() ?? 0,
      segment: WheelSegmentModel.fromJson(json['segment'] as Map<String, dynamic>? ?? {}),
      prize: SpinPrizeModel.fromJson(json['prize'] as Map<String, dynamic>? ?? {}),
    );
  }
}