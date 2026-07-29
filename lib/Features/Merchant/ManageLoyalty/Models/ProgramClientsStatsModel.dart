class ProgramClientsStatsModel {
  final int members;
  final int active;
  final int inactive;
  final int vip;
  final int newThisMonth;
  final num retentionRate;
  final ProgramClientsStatsTotals totals;

  ProgramClientsStatsModel({
    required this.members,
    required this.active,
    required this.inactive,
    required this.vip,
    required this.newThisMonth,
    required this.retentionRate,
    required this.totals,
  });

  factory ProgramClientsStatsModel.fromJson(Map<String, dynamic> json) {
    return ProgramClientsStatsModel(
      members: json['members'] ?? 0,
      active: json['active'] ?? 0,
      inactive: json['inactive'] ?? 0,
      vip: json['vip'] ?? 0,
      newThisMonth: json['newThisMonth'] ?? 0,
      retentionRate: json['retentionRate'] ?? 0,
      totals: ProgramClientsStatsTotals.fromJson(
        json['totals'] ?? const {},
      ),
    );
  }
}

class ProgramClientsStatsTotals {
  final int pointsHeld;
  final int pointsEarnedLifetime;
  final int stamps;
  final int cashback;
  final int visits;

  ProgramClientsStatsTotals({
    required this.pointsHeld,
    required this.pointsEarnedLifetime,
    required this.stamps,
    required this.cashback,
    required this.visits,
  });

  factory ProgramClientsStatsTotals.fromJson(Map<String, dynamic> json) {
    return ProgramClientsStatsTotals(
      pointsHeld: json['pointsHeld'] ?? 0,
      pointsEarnedLifetime: json['pointsEarnedLifetime'] ?? 0,
      stamps: json['stamps'] ?? 0,
      cashback: json['cashback'] ?? 0,
      visits: json['visits'] ?? 0,
    );
  }
}