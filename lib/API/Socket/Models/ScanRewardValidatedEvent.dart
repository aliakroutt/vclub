// lib/Core/Sockets/Models/ScanRewardValidatedEvent.dart

/// Payload for the `scan:reward_validated` socket event — fired when staff
/// validates the client's reward coupon at the counter.
class ScanRewardValidatedEvent {
  final String companyId;
  final String rewardName;
  final String code;
  final DateTime? validatedAt;

  ScanRewardValidatedEvent({
    required this.companyId,
    required this.rewardName,
    required this.code,
    this.validatedAt,
  });

  factory ScanRewardValidatedEvent.fromJson(Map<String, dynamic> json) {
    return ScanRewardValidatedEvent(
      companyId: json['companyId']?.toString() ?? '',
      rewardName: json['rewardName']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      validatedAt: json['validatedAt'] != null
          ? DateTime.tryParse(json['validatedAt'].toString())
          : null,
    );
  }
}