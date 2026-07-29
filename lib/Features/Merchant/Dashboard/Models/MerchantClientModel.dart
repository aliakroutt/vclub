class MembershipClientModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final DateTime? birthday;

  MembershipClientModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.birthday,
  });

  factory MembershipClientModel.fromJson(Map<String, dynamic> json) {
    return MembershipClientModel(
      id: json['_id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      birthday: json['birthday'] != null
          ? DateTime.tryParse(json['birthday'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'birthday': birthday?.toIso8601String(),
    };
  }
}

class MerchantClientModel {
  final String membershipId;
  final MembershipClientModel client;
  final List<String> modes;
  final int points;
  final int stamps;
  final double cashbackBalance;
  final String tier;
  final int visits;
  final int rewardsUsed;
  final DateTime? lastActivityAt;
  final DateTime? createdAt;

  MerchantClientModel({
    required this.membershipId,
    required this.client,
    required this.modes,
    required this.points,
    required this.stamps,
    required this.cashbackBalance,
    required this.tier,
    required this.visits,
    required this.rewardsUsed,
    this.lastActivityAt,
    this.createdAt,
  });

  factory MerchantClientModel.fromJson(Map<String, dynamic> json) {
    return MerchantClientModel(
      membershipId: json['membershipId']?.toString() ?? '',
      client: json['client'] != null
          ? MembershipClientModel.fromJson(json['client'] as Map<String, dynamic>)
          : MembershipClientModel.fromJson(const {}),
      modes: (json['modes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      points: (json['points'] as num?)?.toInt() ?? 0,
      stamps: (json['stamps'] as num?)?.toInt() ?? 0,
      cashbackBalance: (json['cashbackBalance'] as num?)?.toDouble() ?? 0.0,
      tier: json['tier']?.toString() ?? 'standard',
      visits: (json['visits'] as num?)?.toInt() ?? 0,
      rewardsUsed: (json['rewardsUsed'] as num?)?.toInt() ?? 0,
      lastActivityAt: json['lastActivityAt'] != null
          ? DateTime.tryParse(json['lastActivityAt'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'membershipId': membershipId,
      'client': client.toJson(),
      'modes': modes,
      'points': points,
      'stamps': stamps,
      'cashbackBalance': cashbackBalance,
      'tier': tier,
      'visits': visits,
      'rewardsUsed': rewardsUsed,
      'lastActivityAt': lastActivityAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

class MerchantClientsPageModel {
  final List<MerchantClientModel> data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  MerchantClientsPageModel({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory MerchantClientsPageModel.fromJson(Map<String, dynamic> json) {
    return MerchantClientsPageModel(
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => MerchantClientModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}