enum NotificationRecipientType { all, vip, inactive, program, client }

class SendNotificationDto {
  final String title;
  final String body;
  final String? clientId;
  final String segment;
  final String? programId;

  SendNotificationDto({
    required this.title,
    required this.body,
    required this.segment,
    this.clientId,
    this.programId,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      "title": title,
      "body": body,
      "segment": segment,
    };

    if (clientId != null && clientId!.isNotEmpty) map["clientId"] = clientId;
    if (programId != null && programId!.isNotEmpty) map["programId"] = programId;

    return map;
  }
}

class SendNotificationResult {
  final bool success;
  final String? message;

  const SendNotificationResult({required this.success, this.message});
}