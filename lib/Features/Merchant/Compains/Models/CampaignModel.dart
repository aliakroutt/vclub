class CampaignModel {
  final String id;
  final String companyId;
  final String name;
  final String type;
  final String description;
  final DateTime? startDate;
  final DateTime? endDate;
  final num? value;
  final String targetAudience;
  final List<String> channels;
  final bool paused;
  final int participantsCount;
  final int deliveredCount;
  final int emailsSent;
  final int pushSent;
  final int smsSent;
  final int whatsappSent;
  final int failedCount;
  final int sendCount;
  final int emailOpens;
  final int uniqueOpens;
  final DateTime? sentAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String status; // ended, active, paused, scheduled...

  CampaignModel({
    required this.id,
    required this.companyId,
    required this.name,
    required this.type,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.value,
    required this.targetAudience,
    required this.channels,
    required this.paused,
    required this.participantsCount,
    required this.deliveredCount,
    required this.emailsSent,
    required this.pushSent,
    required this.smsSent,
    required this.whatsappSent,
    required this.failedCount,
    required this.sendCount,
    required this.emailOpens,
    required this.uniqueOpens,
    required this.sentAt,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
  });

  factory CampaignModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    return CampaignModel(
      id: json['_id']?.toString() ?? '',
      companyId: json['companyId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      startDate: parseDate(json['startDate']),
      endDate: parseDate(json['endDate']),
      value: json['value'] is num ? json['value'] as num : null,
      targetAudience: json['targetAudience']?.toString() ?? 'all',
      channels: (json['channels'] as List?)?.map((e) => e.toString()).toList() ?? [],
      paused: json['paused'] == true,
      participantsCount: (json['participantsCount'] ?? 0) as int,
      deliveredCount: (json['deliveredCount'] ?? 0) as int,
      emailsSent: (json['emailsSent'] ?? 0) as int,
      pushSent: (json['pushSent'] ?? 0) as int,
      smsSent: (json['smsSent'] ?? 0) as int,
      whatsappSent: (json['whatsappSent'] ?? 0) as int,
      failedCount: (json['failedCount'] ?? 0) as int,
      sendCount: (json['sendCount'] ?? 0) as int,
      emailOpens: (json['emailOpens'] ?? 0) as int,
      uniqueOpens: (json['uniqueOpens'] ?? 0) as int,
      sentAt: parseDate(json['sentAt']),
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
      status: json['status']?.toString() ?? 'active',
    );
  }
}

class CampaignsPaginatedResponse {
  final List<CampaignModel> data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  CampaignsPaginatedResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory CampaignsPaginatedResponse.fromJson(Map<String, dynamic> json) {
    return CampaignsPaginatedResponse(
      data: (json['data'] as List? ?? [])
          .map((e) => CampaignModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] ?? 0) as int,
      page: (json['page'] ?? 1) as int,
      limit: (json['limit'] ?? 20) as int,
      totalPages: (json['totalPages'] ?? 1) as int,
    );
  }
}