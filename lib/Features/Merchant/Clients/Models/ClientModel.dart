import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';

class ActivityItem {
  final String id;
  final String action;
  final String name;
  final DateTime date;
  final int points;
  final String mode;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  const ActivityItem({
    required this.id,
    required this.action,
    required this.name,
    required this.date,
    required this.points,
    required this.mode,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  String get dateFormatted => DateFormat('d MMM yyyy • HH:mm').format(date);

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    final action = json['action']?.toString() ?? '';
    final metadata = (json['metadata'] as Map<String, dynamic>?) ?? {};
    final amount = (json['amount'] as num?)?.toInt() ?? 0;
    final count = (metadata['count'] as num?)?.toInt();
    final label = metadata['label']?.toString();
    final mode = metadata['mode']?.toString() ?? '';

    String name;
    int points;
    IconData icon;
    Color iconColor;

    switch (action) {
      case 'add_points':
        name = label ?? 'points_earned';
        points = amount;
        icon = Iconsax.coin;
        iconColor = const Color(0xFF1DB876);
        break;
      case 'add_stamp':
        name = label ?? 'stamp_earned';
        points = amount;
        icon = Iconsax.star_1;
        iconColor = const Color(0xFF3D8BFF);
        break;
      case 'validate_reward':
        name = label ?? 'reward_redeemed';
        points = -amount;
        icon = Iconsax.gift;
        iconColor = const Color(0xFFE24B4A);
        break;
      case 'stamp_reward':
      case 'points_reward':
        name = label ?? 'reward_claimed';
        points = -(count ?? 0);
        icon = Iconsax.gift;
        iconColor = const Color(0xFFE24B4A);
        break;
      default:
        name =  'activity' ;
        points = amount;
        icon = Iconsax.activity;
        iconColor = AppColors.primary;
    }

    return ActivityItem(
      id: json['_id']?.toString() ?? '',
      action: action,
      name: name,
      date: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      points: points,
      mode: mode,
      icon: icon,
      iconColor: iconColor,
      iconBg: iconColor.withOpacity(.12),
    );
  }
}

class ClientModel {
  final String membershipId;
  final String clientId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final DateTime? birthday;
  final int points;
  final int stamps;
  final double cashbackBalance;
  final String tier;
  final int visits;
  final int rewardsUsed;
  final List<String> modes;
  final DateTime? lastActivityAt;
  final DateTime? createdAt;
  final List<ActivityItem> history;

  const ClientModel({
    required this.membershipId,
    required this.clientId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.birthday,
    this.points = 0,
    this.stamps = 0,
    this.cashbackBalance = 0,
    this.tier = 'standard',
    this.visits = 0,
    this.rewardsUsed = 0,
    this.modes = const [],
    this.lastActivityAt,
    this.createdAt,
    this.history = const [],
  });

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    return (f + l).toUpperCase();
  }

  String get level =>
      tier.isEmpty ? 'Standard' : tier[0].toUpperCase() + tier.substring(1).toLowerCase();

  int get rewards => rewardsUsed;

  String get birthdayFormatted => birthday != null ? DateFormat('d MMM').format(birthday!) : '—';
  String get memberSince => createdAt != null ? DateFormat('MMM yyyy').format(createdAt!) : '—';

  String get lastVisit {
    if (lastActivityAt == null) return '—';
    final diff = DateTime.now().difference(lastActivityAt!);
    if (diff.inDays == 0) return 'today';
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    return DateFormat('d MMM yyyy').format(lastActivityAt!);
  }

  String get cashbackFormatted => '${cashbackBalance.toStringAsFixed(2)} EUR';

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    final client = (json['client'] as Map<String, dynamic>?) ?? {};
    return ClientModel(
      membershipId: json['membershipId']?.toString() ?? '',
      clientId: client['_id']?.toString() ?? '',
      firstName: client['firstName']?.toString() ?? '',
      lastName: client['lastName']?.toString() ?? '',
      email: client['email']?.toString() ?? '',
      phone: client['phone']?.toString() ?? '',
      birthday: _parseDate(client['birthday']),
      points: (json['points'] as num?)?.toInt() ?? 0,
      stamps: (json['stamps'] as num?)?.toInt() ?? 0,
      cashbackBalance: (json['cashbackBalance'] as num?)?.toDouble() ?? 0,
      tier: json['tier']?.toString() ?? 'standard',
      visits: (json['visits'] as num?)?.toInt() ?? 0,
      rewardsUsed: (json['rewardsUsed'] as num?)?.toInt() ?? 0,
      modes: (json['modes'] as List?)?.map((e) => e.toString()).toList() ?? [],
      lastActivityAt: _parseDate(json['lastActivityAt']),
      createdAt: _parseDate(json['createdAt']),
    );
  }

  /// Merge fresh stats coming from GET /merchant/clients/:membershipId
  /// (personal info like name/email isn't returned there, so we keep it).
  ClientModel mergeMembership(Map<String, dynamic> membership) {
    return ClientModel(
      membershipId: membership['_id']?.toString() ?? membershipId,
      clientId: membership['clientId']?.toString() ?? clientId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      birthday: birthday,
      points: (membership['points'] as num?)?.toInt() ?? points,
      stamps: (membership['stamps'] as num?)?.toInt() ?? stamps,
      cashbackBalance: (membership['cashbackBalance'] as num?)?.toDouble() ?? cashbackBalance,
      tier: membership['tier']?.toString() ?? tier,
      visits: (membership['visits'] as num?)?.toInt() ?? visits,
      rewardsUsed: rewardsUsed,
      modes: modes,
      lastActivityAt: _parseDate(membership['lastActivityAt']) ?? lastActivityAt,
      createdAt: _parseDate(membership['createdAt']) ?? createdAt,
      history: history,
    );
  }

  ClientModel copyWithHistory(List<ActivityItem> history) {
    return ClientModel(
      membershipId: membershipId,
      clientId: clientId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      birthday: birthday,
      points: points,
      stamps: stamps,
      cashbackBalance: cashbackBalance,
      tier: tier,
      visits: visits,
      rewardsUsed: rewardsUsed,
      modes: modes,
      lastActivityAt: lastActivityAt,
      createdAt: createdAt,
      history: history,
    );
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }
}