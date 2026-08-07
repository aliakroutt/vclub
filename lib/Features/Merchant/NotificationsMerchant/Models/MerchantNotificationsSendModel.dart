class MerchantNotificationsResponse {
  final List<MerchantNotificationModel> data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  MerchantNotificationsResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory MerchantNotificationsResponse.fromJson(Map<String, dynamic> json) {
    return MerchantNotificationsResponse(
      data: (json["data"] as List<dynamic>? ?? [])
          .map((e) => MerchantNotificationModel.fromJson(e))
          .toList(),
      total: json["total"] ?? 0,
      page: json["page"] ?? 1,
      limit: json["limit"] ?? 20,
      totalPages: json["totalPages"] ?? 1,
    );
  }
}

class MerchantNotificationModel {
  final String id;
  final NotificationClientModel? client;
  final String audience;
  final String companyId;
  final String title;
  final String body;
  final NotificationPayloadModel? payload;
  final String type;
  final bool read;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MerchantNotificationModel({
    required this.id,
    this.client,
    required this.audience,
    required this.companyId,
    required this.title,
    required this.body,
    this.payload,
    required this.type,
    required this.read,
    this.createdAt,
    this.updatedAt,
  });

  factory MerchantNotificationModel.fromJson(Map<String, dynamic> json) {
    return MerchantNotificationModel(
      id: json["_id"] ?? "",
      client: json["clientId"] == null
          ? null
          : NotificationClientModel.fromJson(json["clientId"]),
      audience: json["audience"] ?? "",
      companyId: json["companyId"] ?? "",
      title: json["title"] ?? "",
      body: json["body"] ?? "",
      payload: json["data"] == null
          ? null
          : NotificationPayloadModel.fromJson(json["data"]),
      type: json["type"] ?? "",
      read: json["read"] ?? false,
      createdAt: json["createdAt"] != null
          ? DateTime.tryParse(json["createdAt"])
          : null,
      updatedAt: json["updatedAt"] != null
          ? DateTime.tryParse(json["updatedAt"])
          : null,
    );
  }
}

class NotificationClientModel {
  final String id;
  final String firstName;
  final String lastName;

  NotificationClientModel({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  String get fullName => "$firstName $lastName";

  factory NotificationClientModel.fromJson(Map<String, dynamic> json) {
    return NotificationClientModel(
      id: json["_id"] ?? "",
      firstName: json["firstName"] ?? "",
      lastName: json["lastName"] ?? "",
    );
  }
}

class NotificationPayloadModel {
  final String? campaignId;

  NotificationPayloadModel({
    this.campaignId,
  });

  factory NotificationPayloadModel.fromJson(Map<String, dynamic> json) {
    return NotificationPayloadModel(
      campaignId: json["campaignId"],
    );
  }
}