

class ClientCardModel {
  final String id;
  final CompanyModel company;
  final ProgramModel program;

  final int points;
  final int stamps;
  final num cashbackBalance;
  final String tier;
  final int visits;
  final DateTime? lastActivityAt;
  final bool cardCompleted;

  ClientCardModel({
    required this.id,
    required this.company,
    required this.program,
    required this.points,
    required this.stamps,
    required this.cashbackBalance,
    required this.tier,
    required this.visits,
    required this.lastActivityAt,
    required this.cardCompleted,
  });

  factory ClientCardModel.fromJson(Map<String, dynamic> json) {
    return ClientCardModel(
      id: json["id"] ?? "",
      company: CompanyModel.fromJson(json["company"] ?? {}),
      program: ProgramModel.fromJson(json["program"] ?? {}),
      points: json["points"] ?? 0,
      stamps: json["stamps"] ?? 0,
      cashbackBalance: json["cashbackBalance"] ?? 0,
      tier: json["tier"] ?? "",
      visits: json["visits"] ?? 0,
      lastActivityAt: json["lastActivityAt"] != null
          ? DateTime.tryParse(json["lastActivityAt"])
          : null,
      cardCompleted: json["cardCompleted"] ?? false,
    );
  }

  /// Returns a copy with the given fields overridden — used to apply a
  /// realtime socket update (points/stamps/cashback/cardCompleted) onto
  /// an existing card without refetching it from the API.
  ClientCardModel copyWith({
    int? points,
    int? stamps,
    num? cashbackBalance,
    bool? cardCompleted,
    int? visits,
    String? tier,
    DateTime? lastActivityAt,
  }) {
    return ClientCardModel(
      id: id,
      company: company,
      program: program,
      points: points ?? this.points,
      stamps: stamps ?? this.stamps,
      cashbackBalance: cashbackBalance ?? this.cashbackBalance,
      tier: tier ?? this.tier,
      visits: visits ?? this.visits,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      cardCompleted: cardCompleted ?? this.cardCompleted,
    );
  }
}

class ProgramModel {
  final String id;
  final String name;
  final String slug;
  final String status;
  final String mode;

  final int pointsPerCurrencyUnit;
  final int pointsPerReward;
  final int stampsPerReward;
  final int stampsPerVisit;
  final int minPurchase;
  final int cashbackPercent;
  final int cashbackMinPurchase;

  ProgramModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.status,
    required this.mode,
    required this.pointsPerCurrencyUnit,
    required this.pointsPerReward,
    required this.stampsPerReward,
    required this.stampsPerVisit,
    required this.minPurchase,
    required this.cashbackPercent,
    required this.cashbackMinPurchase,
  });

  factory ProgramModel.fromJson(Map<String, dynamic> json) {
    return ProgramModel(
      id: json["_id"] ?? "",
      name: json["name"] ?? "",
      slug: json["slug"] ?? "",
      status: json["status"] ?? "",
      mode: json["mode"] ?? "",
      pointsPerCurrencyUnit: json["pointsPerCurrencyUnit"] ?? 0,
      pointsPerReward: json["pointsPerReward"] ?? 0,
      stampsPerReward: json["stampsPerReward"] ?? 0,
      stampsPerVisit: json["stampsPerVisit"] ?? 0,
      minPurchase: json["minPurchase"] ?? 0,
      cashbackPercent: json["cashbackPercent"] ?? 0,
      cashbackMinPurchase: json["cashbackMinPurchase"] ?? 0,
    );
  }
}

class CompanyModel {
  final String id;
  final String name;
  final String status;
  final String logo;
  final String slug;

  CompanyModel({
    required this.id,
    required this.name,
    required this.status,
    required this.logo,
    required this.slug,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json["_id"] ?? "",
      name: json["name"] ?? "",
      status: json["status"] ?? "",
      logo: json["logo"] ?? "",
      slug: json["slug"] ?? "",
    );
  }
}