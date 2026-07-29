class ClientsStatsModel {
  final int total;
  final int active;
  final int inactive;
  final int vip;
  final int newThisMonth;
  final double retentionRate;

  ClientsStatsModel({
    required this.total,
    required this.active,
    required this.inactive,
    required this.vip,
    required this.newThisMonth,
    required this.retentionRate,
  });

  factory ClientsStatsModel.fromJson(Map<String, dynamic> json) {
    return ClientsStatsModel(
      total: (json['total'] as num?)?.toInt() ?? 0,
      active: (json['active'] as num?)?.toInt() ?? 0,
      inactive: (json['inactive'] as num?)?.toInt() ?? 0,
      vip: (json['vip'] as num?)?.toInt() ?? 0,
      newThisMonth: (json['newThisMonth'] as num?)?.toInt() ?? 0,
      retentionRate: (json['retentionRate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'active': active,
      'inactive': inactive,
      'vip': vip,
      'newThisMonth': newThisMonth,
      'retentionRate': retentionRate,
    };
  }
}

class ScansStatsModel {
  final int total;
  final int thisMonth;

  ScansStatsModel({
    required this.total,
    required this.thisMonth,
  });

  factory ScansStatsModel.fromJson(Map<String, dynamic> json) {
    return ScansStatsModel(
      total: (json['total'] as num?)?.toInt() ?? 0,
      thisMonth: (json['thisMonth'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'thisMonth': thisMonth,
    };
  }
}

class RewardsRedeemedStatsModel {
  final int total;
  final int thisMonth;

  RewardsRedeemedStatsModel({
    required this.total,
    required this.thisMonth,
  });

  factory RewardsRedeemedStatsModel.fromJson(Map<String, dynamic> json) {
    return RewardsRedeemedStatsModel(
      total: (json['total'] as num?)?.toInt() ?? 0,
      thisMonth: (json['thisMonth'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'thisMonth': thisMonth,
    };
  }
}

class ReviewsStatsModel {
  final int total;
  final int thisMonth;

  ReviewsStatsModel({
    required this.total,
    required this.thisMonth,
  });

  factory ReviewsStatsModel.fromJson(Map<String, dynamic> json) {
    return ReviewsStatsModel(
      total: (json['total'] as num?)?.toInt() ?? 0,
      thisMonth: (json['thisMonth'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'thisMonth': thisMonth,
    };
  }
}

class MemberGrowthModel {
  final String month;
  final int count;

  MemberGrowthModel({
    required this.month,
    required this.count,
  });

  factory MemberGrowthModel.fromJson(Map<String, dynamic> json) {
    return MemberGrowthModel(
      month: json['month']?.toString() ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'count': count,
    };
  }
}

class MerchantStatsModel {
  final ClientsStatsModel clients;
  final ScansStatsModel scans;
  final RewardsRedeemedStatsModel rewardsRedeemed;
  final ReviewsStatsModel reviews;
  final double retentionRate;
  final List<MemberGrowthModel> memberGrowth;

  MerchantStatsModel({
    required this.clients,
    required this.scans,
    required this.rewardsRedeemed,
    required this.reviews,
    required this.retentionRate,
    required this.memberGrowth,
  });

  factory MerchantStatsModel.fromJson(Map<String, dynamic> json) {
    return MerchantStatsModel(
      clients: json['clients'] != null
          ? ClientsStatsModel.fromJson(json['clients'] as Map<String, dynamic>)
          : ClientsStatsModel.fromJson(const {}),
      scans: json['scans'] != null
          ? ScansStatsModel.fromJson(json['scans'] as Map<String, dynamic>)
          : ScansStatsModel.fromJson(const {}),
      rewardsRedeemed: json['rewardsRedeemed'] != null
          ? RewardsRedeemedStatsModel.fromJson(
              json['rewardsRedeemed'] as Map<String, dynamic>)
          : RewardsRedeemedStatsModel.fromJson(const {}),
      reviews: json['reviews'] != null
          ? ReviewsStatsModel.fromJson(json['reviews'] as Map<String, dynamic>)
          : ReviewsStatsModel.fromJson(const {}),
      retentionRate: (json['retentionRate'] as num?)?.toDouble() ?? 0.0,
      memberGrowth: (json['memberGrowth'] as List<dynamic>?)
              ?.map((e) => MemberGrowthModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clients': clients.toJson(),
      'scans': scans.toJson(),
      'rewardsRedeemed': rewardsRedeemed.toJson(),
      'reviews': reviews.toJson(),
      'retentionRate': retentionRate,
      'memberGrowth': memberGrowth.map((e) => e.toJson()).toList(),
    };
  }
}