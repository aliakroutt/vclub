class GoogleReviewModel {
  final String googleReviewLink;
  final GoogleReviewReward? reward;
  final String trigger;
  final bool unlocked;
  final bool eligible;
  final bool alreadyClaimed;
  final int rewardPoints;
  final DateTime? nextEligibleAt;

  GoogleReviewModel({
    required this.googleReviewLink,
    required this.reward,
    required this.trigger,
    required this.unlocked,
    required this.eligible,
    required this.alreadyClaimed,
    required this.rewardPoints,
    required this.nextEligibleAt,
  });

  factory GoogleReviewModel.fromJson(Map<String, dynamic> json) {
    return GoogleReviewModel(
      googleReviewLink: json["googleReviewLink"] ?? "",
      reward: json["reward"] != null
          ? GoogleReviewReward.fromJson(
              Map<String, dynamic>.from(json["reward"]),
            )
          : null,
      trigger: json["trigger"] ?? "",
      unlocked: json["unlocked"] ?? false,
      eligible: json["eligible"] ?? false,
      alreadyClaimed: json["alreadyClaimed"] ?? false,
      rewardPoints: json["rewardPoints"] ?? 0,
      nextEligibleAt: json["nextEligibleAt"] != null
          ? DateTime.parse(json["nextEligibleAt"])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "googleReviewLink": googleReviewLink,
      "reward": reward?.toJson(),
      "trigger": trigger,
      "unlocked": unlocked,
      "eligible": eligible,
      "alreadyClaimed": alreadyClaimed,
      "rewardPoints": rewardPoints,
      "nextEligibleAt": nextEligibleAt?.toIso8601String(),
    };
  }
}

class GoogleReviewReward {
  final String id;
  final String name;
  final String type;

  GoogleReviewReward({
    required this.id,
    required this.name,
    required this.type,
  });

  factory GoogleReviewReward.fromJson(Map<String, dynamic> json) {
    return GoogleReviewReward(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      type: json["type"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "type": type,
    };
  }
}
class ReviewStartModel {
  final String reviewToken;
  final int minDwellSeconds;

  ReviewStartModel({required this.reviewToken, required this.minDwellSeconds});

  factory ReviewStartModel.fromJson(Map<String, dynamic> json) {
    return ReviewStartModel(
      reviewToken: json['reviewToken'] ?? '',
      minDwellSeconds: json['minDwellSeconds'] ?? 0,
    );
  }
}

class ReviewClaimReward {
  final String id;
  final String name;
  final String type;

  ReviewClaimReward({required this.id, required this.name, required this.type});

  factory ReviewClaimReward.fromJson(Map<String, dynamic> json) {
    return ReviewClaimReward(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
    );
  }
}

class ReviewClaimModel {
  final bool claimed;
  final bool alreadyClaimed;
  final ReviewClaimReward? reward;
  final String? code;
  final String? googleReviewLink;

  ReviewClaimModel({
    required this.claimed,
    required this.alreadyClaimed,
    this.reward,
    this.code,
    this.googleReviewLink,
  });

  factory ReviewClaimModel.fromJson(Map<String, dynamic> json) {
    return ReviewClaimModel(
      claimed: json['claimed'] ?? false,
      alreadyClaimed: json['alreadyClaimed'] ?? false,
      reward: json['reward'] != null
          ? ReviewClaimReward.fromJson(Map<String, dynamic>.from(json['reward']))
          : null,
      code: json['code']?.toString(),
      googleReviewLink: json['googleReviewLink']?.toString(),
    );
  }
}