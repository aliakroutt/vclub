// lib/Core/Sockets/Models/ScanPointsAddedEvent.dart

/// Payload for the `scan:points_added` socket event — fired when staff
/// scans the client's card and awards points, a stamp, or cashback.
class ScanPointsAddedEvent {
  final String companyId;
  final String action; // add_points | add_stamp | cashback
  final num awarded;
  final int points;
  final int stamps;
  final num cashbackBalance;
  final String? earnedReward;
  final bool cardCompleted;

  ScanPointsAddedEvent({
    required this.companyId,
    required this.action,
    required this.awarded,
    required this.points,
    required this.stamps,
    required this.cashbackBalance,
    this.earnedReward,
    required this.cardCompleted,
  });

  factory ScanPointsAddedEvent.fromJson(Map<String, dynamic> json) {
    return ScanPointsAddedEvent(
      companyId: json['companyId']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      awarded: (json['awarded'] as num?) ?? 0,
      points: (json['points'] as num?)?.toInt() ?? 0,
      stamps: (json['stamps'] as num?)?.toInt() ?? 0,
      cashbackBalance: (json['cashbackBalance'] as num?) ?? 0,
      earnedReward: json['earnedReward']?.toString(),
      cardCompleted: json['cardCompleted'] == true,
    );
  }
}