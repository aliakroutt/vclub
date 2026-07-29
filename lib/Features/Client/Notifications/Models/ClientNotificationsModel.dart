class NotificationModel {
  final String id;
  final String clientId;
  final String companyId;
  final String title;
  final String body;
  final NotificationDataModel? data;
  final String type;
  bool read;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.clientId,
    required this.companyId,
    required this.title,
    required this.body,
    this.data,
    required this.type,
    required this.read,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      clientId: json['clientId'] ?? '',
      companyId: json['companyId'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      data: json['data'] != null
          ? NotificationDataModel.fromJson(json['data'])
          : null,
      type: json['type'] ?? '',
      read: json['read'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "clientId": clientId,
      "companyId": companyId,
      "title": title,
      "body": body,
      "data": data?.toJson(),
      "type": type,
      "read": read,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }
}

class NotificationDataModel {
  final String? campaignId;

  NotificationDataModel({
    this.campaignId,
  });

  factory NotificationDataModel.fromJson(Map<String, dynamic> json) {
    return NotificationDataModel(
      campaignId: json["campaignId"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "campaignId": campaignId,
    };
  }
}

class NotificationsResponseModel {
  final List<NotificationModel> notifications;
  final int total;
  final int unread;
  final int page;
  final int limit;
  final int totalPages;

  NotificationsResponseModel({
    required this.notifications,
    required this.total,
    required this.unread,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory NotificationsResponseModel.fromJson(
      Map<String, dynamic> json) {
    return NotificationsResponseModel(
      notifications: (json["data"] as List)
          .map((e) => NotificationModel.fromJson(e))
          .toList(),
      total: json["total"] ?? 0,
      unread: json["unread"] ?? 0,
      page: json["page"] ?? 1,
      limit: json["limit"] ?? 20,
      totalPages: json["totalPages"] ?? 1,
    );
  }
}