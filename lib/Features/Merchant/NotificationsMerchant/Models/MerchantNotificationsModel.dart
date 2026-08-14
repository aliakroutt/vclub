class MerchantNotificationModel {
  final String id;
  final String companyId;
  final String title;
  final String body;
  final MerchantNotificationDataModel? data;
  final String type;
  bool read;
  final DateTime createdAt;
  final DateTime updatedAt;

  MerchantNotificationModel({
    required this.id,
    required this.companyId,
    required this.title,
    required this.body,
    this.data,
    required this.type,
    required this.read,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MerchantNotificationModel.fromJson(Map<String, dynamic> json) {
    return MerchantNotificationModel(
      id: json['_id'] ?? '',
      companyId: json['companyId'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      data: json['data'] != null
          ? MerchantNotificationDataModel.fromJson(json['data'])
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

class MerchantNotificationDataModel {
  final String? campaignId;

  MerchantNotificationDataModel({
    this.campaignId,
  });

  factory MerchantNotificationDataModel.fromJson(Map<String, dynamic> json) {
    return MerchantNotificationDataModel(
      campaignId: json["campaignId"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "campaignId": campaignId,
    };
  }
}

class MerchantNotificationsResponseModel {
  final List<MerchantNotificationModel> notifications;
  final int total;
  final int unread;
  final int page;
  final int limit;
  final int totalPages;

  MerchantNotificationsResponseModel({
    required this.notifications,
    required this.total,
    required this.unread,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory MerchantNotificationsResponseModel.fromJson(
      Map<String, dynamic> json) {
    return MerchantNotificationsResponseModel(
      notifications: (json["data"] as List)
          .map((e) => MerchantNotificationModel.fromJson(e))
          .toList(),
      total: json["total"] ?? 0,
      unread: json["unread"] ?? 0,
      page: json["page"] ?? 1,
      limit: json["limit"] ?? 20,
      totalPages: json["totalPages"] ?? 1,
    );
  }
}