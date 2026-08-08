class RedemptionPersonModel {
  final String id;
  final String firstName;
  final String lastName;

  RedemptionPersonModel({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  String get fullName => "$firstName $lastName".trim();

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    return (f + l).toUpperCase();
  }

  factory RedemptionPersonModel.fromJson(Map<String, dynamic> json) {
    return RedemptionPersonModel(
      id: json['_id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
    );
  }
}

class RedemptionRewardModel {
  final String id;
  final String name;

  RedemptionRewardModel({required this.id, required this.name});

  factory RedemptionRewardModel.fromJson(Map<String, dynamic> json) {
    return RedemptionRewardModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

enum RedemptionStatus { fulfilled, canceled, unknown }

extension RedemptionStatusX on RedemptionStatus {
  String get apiValue {
    switch (this) {
      case RedemptionStatus.fulfilled:
        return 'fulfilled';
      case RedemptionStatus.canceled:
        return 'canceled';
      case RedemptionStatus.unknown:
        return '';
    }
  }

  static RedemptionStatus fromApi(String value) {
    switch (value) {
      case 'fulfilled':
        return RedemptionStatus.fulfilled;
      case 'canceled':
        return RedemptionStatus.canceled;
      default:
        return RedemptionStatus.unknown;
    }
  }
}

class MerchantRedemptionItem {
  final String id;
  final String companyId;
  final RedemptionPersonModel? client;
  final String membershipId;
  final RedemptionRewardModel? reward;
  final String source;
  final int cost;
  final String code;
  final RedemptionStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final RedemptionPersonModel? validatedBy;

  MerchantRedemptionItem({
    required this.id,
    required this.companyId,
    this.client,
    required this.membershipId,
    this.reward,
    required this.source,
    required this.cost,
    required this.code,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.validatedBy,
  });

  factory MerchantRedemptionItem.fromJson(Map<String, dynamic> json) {
    return MerchantRedemptionItem(
      id: json['_id']?.toString() ?? '',
      companyId: json['companyId']?.toString() ?? '',
      client: json['clientId'] is Map<String, dynamic>
          ? RedemptionPersonModel.fromJson(json['clientId'] as Map<String, dynamic>)
          : null,
      membershipId: json['membershipId']?.toString() ?? '',
      reward: json['rewardId'] is Map<String, dynamic>
          ? RedemptionRewardModel.fromJson(json['rewardId'] as Map<String, dynamic>)
          : null,
      source: json['source']?.toString() ?? '',
      cost: (json['cost'] as num?)?.toInt() ?? 0,
      code: json['code']?.toString() ?? '',
      status: RedemptionStatusX.fromApi(json['status']?.toString() ?? ''),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
      validatedBy: json['validatedBy'] is Map<String, dynamic>
          ? RedemptionPersonModel.fromJson(json['validatedBy'] as Map<String, dynamic>)
          : null,
    );
  }
}

class MerchantRedemptionsResponse {
  final List<MerchantRedemptionItem> data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  MerchantRedemptionsResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory MerchantRedemptionsResponse.fromJson(Map<String, dynamic> json) {
    return MerchantRedemptionsResponse(
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => MerchantRedemptionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}