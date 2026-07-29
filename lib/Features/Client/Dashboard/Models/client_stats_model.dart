class ClientStatsModel {
  final int pointsEarned;
  final int pointsSpent;
  final int bonusReceived;
  final int stampsEarned;
  final int stampsRewardsClaimed;
  final int cashbackEarned;
  final int totalTransactions;

  ClientStatsModel({
    required this.pointsEarned,
    required this.pointsSpent,
    required this.bonusReceived,
    required this.stampsEarned,
    required this.stampsRewardsClaimed,
    required this.cashbackEarned,
    required this.totalTransactions,
  });

  factory ClientStatsModel.fromJson(Map<String, dynamic> json) {
    return ClientStatsModel(
      pointsEarned: json["pointsEarned"] ?? 0,
      pointsSpent: json["pointsSpent"] ?? 0,
      bonusReceived: json["bonusReceived"] ?? 0,
      stampsEarned: json["stampsEarned"] ?? 0,
      stampsRewardsClaimed: json["stampsRewardsClaimed"] ?? 0,
      cashbackEarned: json["cashbackEarned"] ?? 0,
      totalTransactions: json["totalTransactions"] ?? 0,
    );
  }
}