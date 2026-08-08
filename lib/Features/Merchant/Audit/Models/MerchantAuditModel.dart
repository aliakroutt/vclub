class AuditActorModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;

  AuditActorModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  String get fullName => "$firstName $lastName".trim();

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    return (f + l).toUpperCase();
  }

  factory AuditActorModel.fromJson(Map<String, dynamic> json) {
    return AuditActorModel(
      id: json['_id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }
}

class MerchantAuditItem {
  final String id;
  final AuditActorModel? actor;
  final String actorRole;
  final String action;
  final String targetType;
  final String targetId;
  final String companyId;
  final String summary;
  final String? ip;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  MerchantAuditItem({
    required this.id,
    this.actor,
    required this.actorRole,
    required this.action,
    required this.targetType,
    required this.targetId,
    required this.companyId,
    required this.summary,
    this.ip,
    required this.metadata,
    required this.createdAt,
  });

  /// e.g. "auth.login" -> "auth", "company.update" -> "company"
  String get actionGroup => action.contains('.') ? action.split('.').first : action;

  factory MerchantAuditItem.fromJson(Map<String, dynamic> json) {
    return MerchantAuditItem(
      id: json['_id']?.toString() ?? '',
      actor: json['actorId'] is Map<String, dynamic>
          ? AuditActorModel.fromJson(json['actorId'] as Map<String, dynamic>)
          : null,
      actorRole: json['actorRole']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      targetType: json['targetType']?.toString() ?? '',
      targetId: json['targetId']?.toString() ?? '',
      companyId: json['companyId']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      ip: json['ip']?.toString(),
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class MerchantAuditResponse {
  final List<MerchantAuditItem> data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  MerchantAuditResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory MerchantAuditResponse.fromJson(Map<String, dynamic> json) {
    return MerchantAuditResponse(
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => MerchantAuditItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}