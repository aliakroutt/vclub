class BonusModel {
  final String type;
  final double value;
  final bool enabled;

  BonusModel({
    required this.type,
    required this.value,
    required this.enabled,
  });

  factory BonusModel.fromJson(Map<String, dynamic> json) {
    return BonusModel(
      type: json['type']?.toString() ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      enabled: json['enabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'value': value,
      'enabled': enabled,
    };
  }
}

class ProgramLimitsModel {
  final int maxPointsPerDay;
  final int maxPointsPerTx;
  final int maxRewardsPerMonth;
  final int maxStampsPerDay;

  ProgramLimitsModel({
    required this.maxPointsPerDay,
    required this.maxPointsPerTx,
    required this.maxRewardsPerMonth,
    required this.maxStampsPerDay,
  });

  factory ProgramLimitsModel.fromJson(Map<String, dynamic> json) {
    return ProgramLimitsModel(
      maxPointsPerDay: (json['maxPointsPerDay'] as num?)?.toInt() ?? 0,
      maxPointsPerTx: (json['maxPointsPerTx'] as num?)?.toInt() ?? 0,
      maxRewardsPerMonth: (json['maxRewardsPerMonth'] as num?)?.toInt() ?? 0,
      maxStampsPerDay: (json['maxStampsPerDay'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maxPointsPerDay': maxPointsPerDay,
      'maxPointsPerTx': maxPointsPerTx,
      'maxRewardsPerMonth': maxRewardsPerMonth,
      'maxStampsPerDay': maxStampsPerDay,
    };
  }
}

class VipLevelModel {
  final String name;
  final int minPoints;
  final String? color;

  VipLevelModel({
    required this.name,
    required this.minPoints,
    this.color,
  });

  factory VipLevelModel.fromJson(Map<String, dynamic> json) {
    return VipLevelModel(
      name: json['name']?.toString() ?? '',
      minPoints: (json['minPoints'] as num?)?.toInt() ?? 0,
      color: json['color']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'minPoints': minPoints,
      'color': color,
    };
  }
}

class ProgramModel {
  final String id;
  final String companyId;
  final String name;
  final String slug;
  final String status;
  final bool isDefault;
  final String mode;
  final double pointsPerCurrencyUnit;
  final double minPurchase;
  final int stampsPerVisit;
  final int stampsPerReward;
  final String stampReward;
  final int stampsExpiryDays;
  final double cashbackPercent;
  final double cashbackMinPurchase;
  final int cashbackExpiryDays;
  final int pointsExpiryDays;
  final int vipThreshold;
  final List<BonusModel> bonuses;
  final ProgramLimitsModel? limits;
  final List<VipLevelModel> vipLevels;
  final int reviewRewardPoints;
  final int reviewRewardCooldownDays;
  final bool active;
  final int? pointsPerReward;
  final String? rewardId;
  final String? reviewRewardId;
  final String? reviewTrigger;
  final String? joinUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProgramModel({
    required this.id,
    required this.companyId,
    required this.name,
    required this.slug,
    required this.status,
    required this.isDefault,
    required this.mode,
    required this.pointsPerCurrencyUnit,
    required this.minPurchase,
    required this.stampsPerVisit,
    required this.stampsPerReward,
    required this.stampReward,
    required this.stampsExpiryDays,
    required this.cashbackPercent,
    required this.cashbackMinPurchase,
    required this.cashbackExpiryDays,
    required this.pointsExpiryDays,
    required this.vipThreshold,
    required this.bonuses,
    this.limits,
    required this.vipLevels,
    required this.reviewRewardPoints,
    required this.reviewRewardCooldownDays,
    required this.active,
    this.pointsPerReward,
    this.rewardId,
    this.reviewRewardId,
    this.reviewTrigger,
    this.joinUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory ProgramModel.fromJson(Map<String, dynamic> json) {
    return ProgramModel(
      id: json['_id']?.toString() ?? '',
      companyId: json['companyId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      isDefault: json['isDefault'] as bool? ?? false,
      mode: json['mode']?.toString() ?? '',
      pointsPerCurrencyUnit: (json['pointsPerCurrencyUnit'] as num?)?.toDouble() ?? 0.0,
      minPurchase: (json['minPurchase'] as num?)?.toDouble() ?? 0.0,
      stampsPerVisit: (json['stampsPerVisit'] as num?)?.toInt() ?? 0,
      stampsPerReward: (json['stampsPerReward'] as num?)?.toInt() ?? 0,
      stampReward: json['stampReward']?.toString() ?? '',
      stampsExpiryDays: (json['stampsExpiryDays'] as num?)?.toInt() ?? 0,
      cashbackPercent: (json['cashbackPercent'] as num?)?.toDouble() ?? 0.0,
      cashbackMinPurchase: (json['cashbackMinPurchase'] as num?)?.toDouble() ?? 0.0,
      cashbackExpiryDays: (json['cashbackExpiryDays'] as num?)?.toInt() ?? 0,
      pointsExpiryDays: (json['pointsExpiryDays'] as num?)?.toInt() ?? 0,
      vipThreshold: (json['vipThreshold'] as num?)?.toInt() ?? 0,
      bonuses: (json['bonuses'] as List<dynamic>?)
              ?.map((e) => BonusModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      limits: json['limits'] != null
          ? ProgramLimitsModel.fromJson(json['limits'] as Map<String, dynamic>)
          : null,
      vipLevels: (json['vipLevels'] as List<dynamic>?)
              ?.map((e) => VipLevelModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      reviewRewardPoints: (json['reviewRewardPoints'] as num?)?.toInt() ?? 0,
      reviewRewardCooldownDays: (json['reviewRewardCooldownDays'] as num?)?.toInt() ?? 0,
      active: json['active'] as bool? ?? true,
      pointsPerReward: (json['pointsPerReward'] as num?)?.toInt(),
      rewardId: json['rewardId']?.toString(),
      reviewRewardId: json['reviewRewardId']?.toString(),
      reviewTrigger: json['reviewTrigger']?.toString(),
      joinUrl: json['joinUrl']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'companyId': companyId,
      'name': name,
      'slug': slug,
      'status': status,
      'isDefault': isDefault,
      'mode': mode,
      'pointsPerCurrencyUnit': pointsPerCurrencyUnit,
      'minPurchase': minPurchase,
      'stampsPerVisit': stampsPerVisit,
      'stampsPerReward': stampsPerReward,
      'stampReward': stampReward,
      'stampsExpiryDays': stampsExpiryDays,
      'cashbackPercent': cashbackPercent,
      'cashbackMinPurchase': cashbackMinPurchase,
      'cashbackExpiryDays': cashbackExpiryDays,
      'pointsExpiryDays': pointsExpiryDays,
      'vipThreshold': vipThreshold,
      'bonuses': bonuses.map((e) => e.toJson()).toList(),
      'limits': limits?.toJson(),
      'vipLevels': vipLevels.map((e) => e.toJson()).toList(),
      'reviewRewardPoints': reviewRewardPoints,
      'reviewRewardCooldownDays': reviewRewardCooldownDays,
      'active': active,
      'pointsPerReward': pointsPerReward,
      'rewardId': rewardId,
      'reviewRewardId': reviewRewardId,
      'reviewTrigger': reviewTrigger,
      'joinUrl': joinUrl,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  ProgramModel copyWith({bool? active, String? status}) {
    return ProgramModel(
      id: id,
      companyId: companyId,
      name: name,
      slug: slug,
      status: status ?? this.status,
      isDefault: isDefault,
      mode: mode,
      pointsPerCurrencyUnit: pointsPerCurrencyUnit,
      minPurchase: minPurchase,
      stampsPerVisit: stampsPerVisit,
      stampsPerReward: stampsPerReward,
      stampReward: stampReward,
      stampsExpiryDays: stampsExpiryDays,
      cashbackPercent: cashbackPercent,
      cashbackMinPurchase: cashbackMinPurchase,
      cashbackExpiryDays: cashbackExpiryDays,
      pointsExpiryDays: pointsExpiryDays,
      vipThreshold: vipThreshold,
      bonuses: bonuses,
      limits: limits,
      vipLevels: vipLevels,
      reviewRewardPoints: reviewRewardPoints,
      reviewRewardCooldownDays: reviewRewardCooldownDays,
      active: active ?? this.active,
      pointsPerReward: pointsPerReward,
      rewardId: rewardId,
      reviewRewardId: reviewRewardId,
      reviewTrigger: reviewTrigger,
      joinUrl: joinUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class ProgramsPageModel {
  final List<ProgramModel> data;
  final int total;
  final int page;
  final int totalPages;

  ProgramsPageModel({
    required this.data,
    required this.total,
    required this.page,
    required this.totalPages,
  });

  factory ProgramsPageModel.fromJson(Map<String, dynamic> json) {
    return ProgramsPageModel(
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => ProgramModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}

