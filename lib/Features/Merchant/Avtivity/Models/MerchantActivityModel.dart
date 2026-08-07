class ActivityPersonModel {
  final String id;
  final String firstName;
  final String lastName;

  ActivityPersonModel({
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

  factory ActivityPersonModel.fromJson(Map<String, dynamic> json) {
    return ActivityPersonModel(
      id: json['_id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
    );
  }
}

class MerchantActivityItem {
  final String id;
  final String companyId;
  final String clientId;
  final String membershipId;
  final String? actorId;
  final String? actorRole;
  final String action;
  final int amount;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final ActivityPersonModel? client;
  final ActivityPersonModel? actor;

  MerchantActivityItem({
    required this.id,
    required this.companyId,
    required this.clientId,
    required this.membershipId,
    this.actorId,
    this.actorRole,
    required this.action,
    required this.amount,
    required this.metadata,
    required this.createdAt,
    this.client,
    this.actor,
  });

  String? get label => metadata['label']?.toString();
  String? get mode => metadata['mode']?.toString();
  String? get code => metadata['code']?.toString();
  int? get count => (metadata['count'] as num?)?.toInt();

  bool get isCredit =>
      action == 'add_points' || action == 'add_stamp' || action == 'cashback';

  bool get isDebit =>
      action == 'validate_reward' ||
      action == 'redeem_reward' ||
      action == 'stamp_reward' ||
      action == 'points_reward';

  /// Magnitude to display when `amount` is 0 but `count` carries the value
  /// (stamp_reward / points_reward payloads).
  int get displayValue => amount != 0 ? amount : (count ?? 0);

  factory MerchantActivityItem.fromJson(Map<String, dynamic> json) {
    return MerchantActivityItem(
      id: json['_id']?.toString() ?? '',
      companyId: json['companyId']?.toString() ?? '',
      clientId: json['clientId']?.toString() ?? '',
      membershipId: json['membershipId']?.toString() ?? '',
      actorId: json['actorId']?.toString(),
      actorRole: json['actorRole']?.toString(),
      action: json['action']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      client: json['client'] != null
          ? ActivityPersonModel.fromJson(json['client'] as Map<String, dynamic>)
          : null,
      actor: json['actor'] != null
          ? ActivityPersonModel.fromJson(json['actor'] as Map<String, dynamic>)
          : null,
    );
  }
}

class MerchantActivityResponse {
  final List<MerchantActivityItem> data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  MerchantActivityResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory MerchantActivityResponse.fromJson(Map<String, dynamic> json) {
    return MerchantActivityResponse(
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => MerchantActivityItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}

/// All action types documented by the API.
enum ActivityActionType {
  join,
  addPoints,
  addStamp,
  cashback,
  redeemReward,
  validateReward,
  reviewReward,
  stampReward,
  pointsReward,
}

extension ActivityActionTypeX on ActivityActionType {
  String get apiValue {
    switch (this) {
      case ActivityActionType.join:
        return 'join';
      case ActivityActionType.addPoints:
        return 'add_points';
      case ActivityActionType.addStamp:
        return 'add_stamp';
      case ActivityActionType.cashback:
        return 'cashback';
      case ActivityActionType.redeemReward:
        return 'redeem_reward';
      case ActivityActionType.validateReward:
        return 'validate_reward';
      case ActivityActionType.reviewReward:
        return 'review_reward';
      case ActivityActionType.stampReward:
        return 'stamp_reward';
      case ActivityActionType.pointsReward:
        return 'points_reward';
    }
  }
}