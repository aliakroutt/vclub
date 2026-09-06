class NotificationCompanyModel {
  final String id;
  final String name;
  final String? tradeName;
  final String logo;

  NotificationCompanyModel({
    required this.id,
    required this.name,
    this.tradeName,
    required this.logo,
  });

  factory NotificationCompanyModel.fromJson(Map<String, dynamic> json) {
    return NotificationCompanyModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      tradeName: json['tradeName']?.toString(),
      logo: json['logo']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "tradeName": tradeName,
      "logo": logo,
    };
  }
}

class NotificationModel {
  final String id;
  final String clientId;
  final String audience;
  final NotificationCompanyModel? company;
  final String title;
  final String body;

  /// i18n key + params, in case the app ever wants to re-render the
  /// notification text locally instead of using the server-sent
  /// pre-formatted [title]/[body].
  final String? titleKey;
  final String? bodyKey;
  final Map<String, dynamic> params;

  final NotificationDataModel? data;
  final String type;
  bool read;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.clientId,
    required this.audience,
    this.company,
    required this.title,
    required this.body,
    this.titleKey,
    this.bodyKey,
    this.params = const {},
    this.data,
    required this.type,
    required this.read,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convenience — kept for any existing code that referenced companyId
  /// as a plain string.
  String get companyId => company?.id ?? '';

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final companyJson = json['companyId'];

    return NotificationModel(
      id: json['_id']?.toString() ?? '',
      clientId: json['clientId']?.toString() ?? '',
      audience: json['audience']?.toString() ?? '',
      company: companyJson is Map<String, dynamic>
          ? NotificationCompanyModel.fromJson(companyJson)
          : null,
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      titleKey: json['titleKey']?.toString(),
      bodyKey: json['bodyKey']?.toString(),
      params: json['params'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['params'])
          : const {},
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? NotificationDataModel.fromJson(json['data'])
          : null,
      type: json['type']?.toString() ?? '',
      read: json['read'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "clientId": clientId,
      "audience": audience,
      "companyId": company?.toJson(),
      "title": title,
      "body": body,
      "titleKey": titleKey,
      "bodyKey": bodyKey,
      "params": params,
      "data": data?.toJson(),
      "type": type,
      "read": read,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }
}

class NotificationDataModel {
  final String? type;
  final String? campaignId;
  final String? code;

  NotificationDataModel({
    this.type,
    this.campaignId,
    this.code,
  });

  factory NotificationDataModel.fromJson(Map<String, dynamic> json) {
    return NotificationDataModel(
      type: json["type"]?.toString(),
      campaignId: json["campaignId"]?.toString(),
      code: json["code"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "type": type,
      "campaignId": campaignId,
      "code": code,
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

  factory NotificationsResponseModel.fromJson(Map<String, dynamic> json) {
    return NotificationsResponseModel(
      notifications: (json["data"] as List)
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json["total"] as num?)?.toInt() ?? 0,
      unread: (json["unread"] as num?)?.toInt() ?? 0,
      page: (json["page"] as num?)?.toInt() ?? 1,
      limit: (json["limit"] as num?)?.toInt() ?? 20,
      totalPages: (json["totalPages"] as num?)?.toInt() ?? 1,
    );
  }
}