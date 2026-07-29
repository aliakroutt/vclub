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