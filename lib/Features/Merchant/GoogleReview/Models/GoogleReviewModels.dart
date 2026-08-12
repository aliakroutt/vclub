class RewardBonusModel {
  final String type;
  final double value;
  final bool enabled;

  RewardBonusModel({required this.type, required this.value, required this.enabled});

  factory RewardBonusModel.fromJson(Map<String, dynamic> json) {
    return RewardBonusModel(
      type: json['type']?.toString() ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0,
      enabled: json['enabled'] as bool? ?? false,
    );
  }
}

class LoyaltyProgramModel {
  final String id;
  final String companyId;
  final String name;
  final String mode; // points | stamps | cashback
  final int reviewRewardPoints;
  final int reviewRewardCooldownDays;
  final String? rewardId;
  final String? reviewRewardId;
  final String? reviewTrigger; // reward_redeem | program_end
  final int pointsExpiryDays;
  final int stampsExpiryDays;
  final int cashbackExpiryDays;

  LoyaltyProgramModel({
    required this.id,
    required this.companyId,
    required this.name,
    required this.mode,
    required this.reviewRewardPoints,
    required this.reviewRewardCooldownDays,
    this.rewardId,
    this.reviewRewardId,
    this.reviewTrigger,
    required this.pointsExpiryDays,
    required this.stampsExpiryDays,
    required this.cashbackExpiryDays,
  });

  factory LoyaltyProgramModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyProgramModel(
      id: json['_id']?.toString() ?? '',
      companyId: json['companyId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      mode: json['mode']?.toString() ?? 'points',
      reviewRewardPoints: (json['reviewRewardPoints'] as num?)?.toInt() ?? 0,
      reviewRewardCooldownDays: (json['reviewRewardCooldownDays'] as num?)?.toInt() ?? 0,
      rewardId: json['rewardId']?.toString(),
      reviewRewardId: json['reviewRewardId']?.toString(),
      reviewTrigger: json['reviewTrigger']?.toString(),
      pointsExpiryDays: (json['pointsExpiryDays'] as num?)?.toInt() ?? 0,
      stampsExpiryDays: (json['stampsExpiryDays'] as num?)?.toInt() ?? 0,
      cashbackExpiryDays: (json['cashbackExpiryDays'] as num?)?.toInt() ?? 0,
    );
  }
}

class RewardModel {
  final String id;
  final String companyId;
  final String name;
  final String type;
  final int cost;
  final int? stock;
  final bool active;

  RewardModel({
    required this.id,
    required this.companyId,
    required this.name,
    required this.type,
    required this.cost,
    this.stock,
    required this.active,
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      id: json['_id']?.toString() ?? '',
      companyId: json['companyId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      cost: (json['cost'] as num?)?.toInt() ?? 0,
      stock: (json['stock'] as num?)?.toInt(),
      active: json['active'] as bool? ?? true,
    );
  }
}

/// Review invitation trigger enum from the program API.
enum ReviewTrigger { rewardRedeem, programEnd }

extension ReviewTriggerX on ReviewTrigger {
  String get apiValue => this == ReviewTrigger.rewardRedeem ? 'reward_redeem' : 'program_end';

  static ReviewTrigger? fromApi(String? value) {
    switch (value) {
      case 'reward_redeem':
        return ReviewTrigger.rewardRedeem;
      case 'program_end':
        return ReviewTrigger.programEnd;
      default:
        return null;
    }
  }
}
