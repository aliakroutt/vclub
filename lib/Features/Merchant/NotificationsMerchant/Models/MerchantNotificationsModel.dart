class MerchantNotificationCompanyModel {
  final String id;
  final String name;
  final String logo;

  MerchantNotificationCompanyModel({
    required this.id,
    required this.name,
    required this.logo,
  });

  factory MerchantNotificationCompanyModel.fromJson(Map<String, dynamic> json) {
    return MerchantNotificationCompanyModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      logo: json['logo']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "logo": logo,
    };
  }
}

class MerchantNotificationModel {
  final String id;
  final String userId;
  final String audience;
  final MerchantNotificationCompanyModel? company;
  final String title;
  final String body;

  /// i18n key + params, in case the app ever wants to re-render the
  /// notification text locally instead of using the server-sent
  /// pre-formatted [title]/[body] (e.g. for a different language than
  /// what the backend rendered).
  final String? titleKey;
  final String? bodyKey;
  final Map<String, dynamic> params;

  final MerchantNotificationDataModel? data;
  final String type;
  bool read;
  final DateTime createdAt;
  final DateTime updatedAt;

  MerchantNotificationModel({
    required this.id,
    required this.userId,
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

  factory MerchantNotificationModel.fromJson(Map<String, dynamic> json) {
    final companyJson = json['companyId'];

    return MerchantNotificationModel(
      id: json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      audience: json['audience']?.toString() ?? '',
      company: companyJson is Map<String, dynamic>
          ? MerchantNotificationCompanyModel.fromJson(companyJson)
          : null,
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      titleKey: json['titleKey']?.toString(),
      bodyKey: json['bodyKey']?.toString(),
      params: json['params'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['params'])
          : const {},
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? MerchantNotificationDataModel.fromJson(json['data'])
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
      "userId": userId,
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

class MerchantNotificationDataModel {
  final String? type;
  final String? campaignId;

  MerchantNotificationDataModel({
    this.type,
    this.campaignId,
  });

  factory MerchantNotificationDataModel.fromJson(Map<String, dynamic> json) {
    return MerchantNotificationDataModel(
      type: json["type"]?.toString(),
      campaignId: json["campaignId"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "type": type,
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

  factory MerchantNotificationsResponseModel.fromJson(Map<String, dynamic> json) {
    return MerchantNotificationsResponseModel(
      notifications: (json["data"] as List)
          .map((e) => MerchantNotificationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json["total"] as num?)?.toInt() ?? 0,
      unread: (json["unread"] as num?)?.toInt() ?? 0,
      page: (json["page"] as num?)?.toInt() ?? 1,
      limit: (json["limit"] as num?)?.toInt() ?? 20,
      totalPages: (json["totalPages"] as num?)?.toInt() ?? 1,
    );
  }
}