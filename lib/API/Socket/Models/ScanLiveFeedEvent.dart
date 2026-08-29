// lib/API/Socket/Models/ScanLiveFeedEvent.dart
class ScanLiveFeedEvent {
  final String membershipId;
  final String clientName;
  final String action; // add_points | add_stamp | cashback | reward_redeemed | reward_validated ...
  final num awarded;
  final String? actorName;
  final DateTime? scannedAt;

  ScanLiveFeedEvent({
    required this.membershipId,
    required this.clientName,
    required this.action,
    required this.awarded,
    this.actorName,
    this.scannedAt,
  });

  factory ScanLiveFeedEvent.fromJson(Map<String, dynamic> json) {
    return ScanLiveFeedEvent(
      membershipId: json['membershipId']?.toString() ?? '',
      clientName: json['clientName']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      awarded: (json['awarded'] as num?) ?? 0,
      actorName: json['actorName']?.toString(),
      scannedAt: json['scannedAt'] != null
          ? DateTime.tryParse(json['scannedAt'].toString())
          : null,
    );
  }
}