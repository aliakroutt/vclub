class RedeemRewardInfo {
  final String name;

  RedeemRewardInfo({required this.name});

  factory RedeemRewardInfo.fromJson(Map<String, dynamic> json) {
    return RedeemRewardInfo(
      name: json["name"]?.toString() ?? "",
    );
  }
}

class RedeemResultModel {
  final String code;
  final RedeemRewardInfo reward;
  final String? validatedAt;

  RedeemResultModel({
    required this.code,
    required this.reward,
    this.validatedAt,
  });

  factory RedeemResultModel.fromJson(Map<String, dynamic> json) {
    return RedeemResultModel(
      code: json["code"]?.toString() ?? "",
      reward: RedeemRewardInfo.fromJson(json["reward"] ?? {}),
      validatedAt: json["validatedAt"]?.toString(),
    );
  }
}
class ScanClientModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  ScanClientModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
  });

  String get fullName => "$firstName $lastName".trim();

  factory ScanClientModel.fromJson(Map<String, dynamic> json) {
    return ScanClientModel(
      id: json["id"]?.toString() ?? "",
      firstName: json["firstName"]?.toString() ?? "",
      lastName: json["lastName"]?.toString() ?? "",
      email: json["email"]?.toString() ?? "",
      phone: json["phone"]?.toString() ?? "",
    );
  }
}

class ScanProgramModel {
  final String id;
  final String name;
  final String mode; // points | stamps | cashback
  final bool requiresAmount;
  final String? rewardId;
  final double pointsPerCurrencyUnit;
  final int pointsPerReward;
  final int stampsPerVisit;
  final int stampsPerReward;
  final double cashbackPercent;
  final double minPurchase;
  final double cashbackMinPurchase;

  ScanProgramModel({
    required this.id,
    required this.name,
    required this.mode,
    required this.requiresAmount,
    this.rewardId,
    required this.pointsPerCurrencyUnit,
    required this.pointsPerReward,
    required this.stampsPerVisit,
    required this.stampsPerReward,
    required this.cashbackPercent,
    required this.minPurchase,
    required this.cashbackMinPurchase,
  });

  factory ScanProgramModel.fromJson(Map<String, dynamic> json) {
    return ScanProgramModel(
      id: json["id"]?.toString() ?? "",
      name: json["name"]?.toString() ?? "",
      mode: json["mode"]?.toString() ?? "points",
      requiresAmount: json["requiresAmount"] == true,
      rewardId: json["rewardId"]?.toString(),
      pointsPerCurrencyUnit:
          (json["pointsPerCurrencyUnit"] as num?)?.toDouble() ?? 1,
      pointsPerReward: (json["pointsPerReward"] as num?)?.toInt() ?? 0,
      stampsPerVisit: (json["stampsPerVisit"] as num?)?.toInt() ?? 1,
      stampsPerReward: (json["stampsPerReward"] as num?)?.toInt() ?? 0,
      cashbackPercent: (json["cashbackPercent"] as num?)?.toDouble() ?? 0,
      minPurchase: (json["minPurchase"] as num?)?.toDouble() ?? 0,
      cashbackMinPurchase:
          (json["cashbackMinPurchase"] as num?)?.toDouble() ?? 0,
    );
  }
}

class ScanCardModel {
  final String membershipId;
  final ScanProgramModel program;
  final int points;
  final int stamps;
  final double cashbackBalance;
  final String tier;
  final int visits;

  ScanCardModel({
    required this.membershipId,
    required this.program,
    required this.points,
    required this.stamps,
    required this.cashbackBalance,
    required this.tier,
    required this.visits,
  });

  factory ScanCardModel.fromJson(Map<String, dynamic> json) {
    return ScanCardModel(
      membershipId: json["membershipId"]?.toString() ?? "",
      program: ScanProgramModel.fromJson(json["program"] ?? {}),
      points: (json["points"] as num?)?.toInt() ?? 0,
      stamps: (json["stamps"] as num?)?.toInt() ?? 0,
      cashbackBalance: (json["cashbackBalance"] as num?)?.toDouble() ?? 0,
      tier: json["tier"]?.toString() ?? "standard",
      visits: (json["visits"] as num?)?.toInt() ?? 0,
    );
  }
}

class ClientLookupResult {
  final ScanClientModel client;
  final ScanCardModel card;

  ClientLookupResult({required this.client, required this.card});

  factory ClientLookupResult.fromJson(Map<String, dynamic> json) {
    return ClientLookupResult(
      client: ScanClientModel.fromJson(json["client"] ?? {}),
      card: ScanCardModel.fromJson(json["card"] ?? {}),
    );
  }
}

class ScanResultModel {
  final String membershipId;
  final ScanProgramModel program;
  final String action;
  final int awarded;
  final bool duplicate;
  final int points;
  final int stamps;
  final double cashbackBalance;
  final int? rewardTarget;
  final int? stampsTarget;
  final dynamic earnedReward;
  final bool cardCompleted;
  final bool monthlyLimitReached;

  ScanResultModel({
    required this.membershipId,
    required this.program,
    required this.action,
    required this.awarded,
    required this.duplicate,
    required this.points,
    required this.stamps,
    required this.cashbackBalance,
    this.rewardTarget,
    this.stampsTarget,
    this.earnedReward,
    required this.cardCompleted,
    required this.monthlyLimitReached,
  });

  factory ScanResultModel.fromJson(Map<String, dynamic> json) {
    return ScanResultModel(
      membershipId: json["membershipId"]?.toString() ?? "",
      program: ScanProgramModel.fromJson(json["program"] ?? {}),
      action: json["action"]?.toString() ?? "",
      awarded: (json["awarded"] as num?)?.toInt() ?? 0,
      duplicate: json["duplicate"] == true,
      points: (json["points"] as num?)?.toInt() ?? 0,
      stamps: (json["stamps"] as num?)?.toInt() ?? 0,
      cashbackBalance: (json["cashbackBalance"] as num?)?.toDouble() ?? 0,
      rewardTarget: (json["rewardTarget"] as num?)?.toInt(),
      stampsTarget: (json["stampsTarget"] as num?)?.toInt(),
      earnedReward: json["earnedReward"],
      cardCompleted: json["cardCompleted"] == true,
      monthlyLimitReached: json["monthlyLimitReached"] == true,
    );
  }
}