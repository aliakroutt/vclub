import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

enum ClientBadgeLevel { bronze, silver, gold, platinum }

extension ClientBadgeLevelX on ClientBadgeLevel {
  List<Color> get gradient {
    switch (this) {
      case ClientBadgeLevel.platinum:
        return [const Color(0xFF9CA3AF), const Color(0xFF4B5563)];
      case ClientBadgeLevel.gold:
        return [const Color(0xFFFBBF24), const Color(0xFFD97706)];
      case ClientBadgeLevel.silver:
        return [const Color(0xFFCBD5E1), const Color(0xFF64748B)];
      case ClientBadgeLevel.bronze:
        return [const Color(0xFFD97757), const Color(0xFF9A3412)];
    }
  }

  IconData get icon {
    switch (this) {
      case ClientBadgeLevel.platinum:
        return Icons.workspace_premium;
      case ClientBadgeLevel.gold:
        return Icons.star;
      case ClientBadgeLevel.silver:
        return Icons.star_half;
      case ClientBadgeLevel.bronze:
        return Icons.star_outline;
    }
  }

  String get labelKey {
    switch (this) {
      case ClientBadgeLevel.platinum:
        return 'level_platinum';
      case ClientBadgeLevel.gold:
        return 'level_gold';
      case ClientBadgeLevel.silver:
        return 'level_silver';
      case ClientBadgeLevel.bronze:
        return 'level_bronze';
    }
  }

  // NOTE: guessing tier string -> badge mapping since API only
  // returned "standard" in the sample. Adjust once you confirm
  // the full set of tier values your backend sends
  // (e.g. standard/silver/gold/platinum, or standard/vip).
  static ClientBadgeLevel fromTier(String tier) {
    switch (tier.toLowerCase()) {
      case 'platinum':
        return ClientBadgeLevel.platinum;
      case 'gold':
        return ClientBadgeLevel.gold;
      case 'silver':
        return ClientBadgeLevel.silver;
      default:
        return ClientBadgeLevel.bronze;
    }
  }
}

/// What the loyalty program is primarily tracking —
/// drives which stat is shown as the "main" chip in the list item.
enum ProgramMode { stamps, points, cashback }

extension ProgramModeX on ProgramMode {
  static ProgramMode fromString(String value) {
    switch (value) {
      case 'points':
        return ProgramMode.points;
      case 'cashback':
        return ProgramMode.cashback;
      default:
        return ProgramMode.stamps;
    }
  }
}

class ClientModel {
  final String membershipId;
  final String clientId;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final DateTime? birthday;

  final ProgramMode programMode;
  final int points;
  final int stamps;
  final num cashbackBalance;
  final String tier;
  final int visits;
  final int rewardsUsed;
  final DateTime? lastActivityAt;
  final DateTime createdAt;

  ClientModel({
    required this.membershipId,
    required this.clientId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.birthday,
    required this.programMode,
    required this.points,
    required this.stamps,
    required this.cashbackBalance,
    required this.tier,
    required this.visits,
    required this.rewardsUsed,
    this.lastActivityAt,
    required this.createdAt,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    final client = json['client'] as Map<String, dynamic>? ?? const {};
    final program = json['program'] as Map<String, dynamic>? ?? const {};

    DateTime? parseDate(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString());

    return ClientModel(
      membershipId: json['membershipId']?.toString() ?? '',
      clientId: client['_id']?.toString() ?? '',
      firstName: client['firstName']?.toString() ?? '',
      lastName: client['lastName']?.toString() ?? '',
      email: client['email']?.toString() ?? '',
      phone: client['phone']?.toString(),
      birthday: parseDate(client['birthday']),
      programMode: ProgramModeX.fromString(
        (program['mode'] ?? json['modes']?[0] ?? 'stamps').toString(),
      ),
      points: json['points'] ?? 0,
      stamps: json['stamps'] ?? 0,
      cashbackBalance: json['cashbackBalance'] ?? 0,
      tier: json['tier']?.toString() ?? 'standard',
      visits: json['visits'] ?? 0,
      rewardsUsed: json['rewardsUsed'] ?? 0,
      lastActivityAt: parseDate(json['lastActivityAt']),
      createdAt: parseDate(json['createdAt']) ?? DateTime.now(),
    );
  }

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    return (f + l).toUpperCase();
  }

  ClientBadgeLevel get level => ClientBadgeLevelX.fromTier(tier);

  /// The headline stat for this client, based on what the program tracks.
  int get primaryStatValue {
    switch (programMode) {
      case ProgramMode.stamps:
        return stamps;
      case ProgramMode.points:
        return points;
      case ProgramMode.cashback:
        return cashbackBalance.round();
    }
  }

  String get primaryStatLabelKey {
    switch (programMode) {
      case ProgramMode.stamps:
        return 'stat_stamps';
      case ProgramMode.points:
        return 'stat_points';
      case ProgramMode.cashback:
        return 'stat_cashback';
    }
  }

  IconData get primaryStatIcon {
    switch (programMode) {
      case ProgramMode.stamps:
        return Iconsax.tag;
      case ProgramMode.points:
        return Iconsax.wallet_2;
      case ProgramMode.cashback:
        return Iconsax.money;
    }
  }
}