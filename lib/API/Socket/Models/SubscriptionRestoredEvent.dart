// lib/API/Socket/Models/SubscriptionRestoredEvent.dart
class SubscriptionRestoredEvent {
  final String companyId;
  final String plan;

  SubscriptionRestoredEvent({required this.companyId, required this.plan});

  factory SubscriptionRestoredEvent.fromJson(Map<String, dynamic> json) {
    return SubscriptionRestoredEvent(
      companyId: json['companyId']?.toString() ?? '',
      plan: json['plan']?.toString() ?? '',
    );
  }
}