class RewardModel {
  final String id;
  final String code;
  final int cost;
  final String status;
  final String source;
  final String mode;

  final RewardInfo reward;
  final CompanyInfo company;

  final String membershipId;
  final DateTime? redeemedAt;
  final String? validatedBy;

  RewardModel({
    required this.id,
    required this.code,
    required this.cost,
    required this.status,
    required this.source,
    required this.mode,
    required this.reward,
    required this.company,
    required this.membershipId,
    required this.redeemedAt,
    required this.validatedBy,
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      cost: json['cost'] ?? 0,
      status: json['status'] ?? '',
      source: json['source'] ?? '',
      mode: json['mode'] ?? '',

      reward: RewardInfo.fromJson(json['reward'] ?? {}),
      company: CompanyInfo.fromJson(json['company'] ?? {}),

      membershipId: json['membershipId'] ?? '',
      redeemedAt: json['redeemedAt'] != null
          ? DateTime.tryParse(json['redeemedAt'])
          : null,
      validatedBy: json['validatedBy']?.toString(),
    );
  }
}

class RewardInfo {
  final String? id;
  final String name;
  final String type;

  RewardInfo({
    required this.id,
    required this.name,
    required this.type,
  });

  factory RewardInfo.fromJson(Map<String, dynamic> json) {
    return RewardInfo(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      type: json['type'] ?? '',
    );
  }
}

class CompanyInfo {
  final String id;
  final String name;
  final String slug;
  final String logo;

  CompanyInfo({
    required this.id,
    required this.name,
    required this.slug,
    required this.logo,
  });

  factory CompanyInfo.fromJson(Map<String, dynamic> json) {
    return CompanyInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      logo: json['logo'] ?? '',
    );
  }
}