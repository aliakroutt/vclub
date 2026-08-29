// lib/API/Socket/Models/SubscriptionRevokedEvent.dart
enum SubscriptionRevokedReason { canceled, expired, paymentFailed, suspended, unknown }

SubscriptionRevokedReason _parseRevokedReason(String? raw) {
  switch (raw) {
    case 'canceled':
      return SubscriptionRevokedReason.canceled;
    case 'expired':
      return SubscriptionRevokedReason.expired;
    case 'payment_failed':
      return SubscriptionRevokedReason.paymentFailed;
    case 'suspended':
      return SubscriptionRevokedReason.suspended;
    default:
      return SubscriptionRevokedReason.unknown;
  }
}

class SubscriptionRevokedEvent {
  final String companyId;
  final SubscriptionRevokedReason reason;
  final DateTime? endedAt;

  SubscriptionRevokedEvent({
    required this.companyId,
    required this.reason,
    this.endedAt,
  });

  factory SubscriptionRevokedEvent.fromJson(Map<String, dynamic> json) {
    return SubscriptionRevokedEvent(
      companyId: json['companyId']?.toString() ?? '',
      reason: _parseRevokedReason(json['reason']?.toString()),
      endedAt: json['endedAt'] != null
          ? DateTime.tryParse(json['endedAt'].toString())
          : null,
    );
  }
}