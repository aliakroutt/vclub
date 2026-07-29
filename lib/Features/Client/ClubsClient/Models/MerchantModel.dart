/// Model for the merchant response (e.g. Techazum), including its
/// list of loyalty [LoyaltyProgram]s.
class Merchant {
  final String name;
  final String slug;
  final String qrUrl;
  final String? logo;
  final String? brandColor;
  final String? secondaryColor;
  final String industry;
  final String currencyCode;
  final String status;
  final String? googleReviewLink;
  final List<LoyaltyProgram> programs;

  Merchant({
    required this.name,
    required this.slug,
    required this.qrUrl,
    this.logo,
    this.brandColor,
    this.secondaryColor,
    required this.industry,
    required this.currencyCode,
    required this.status,
    this.googleReviewLink,
    required this.programs,
  });

  factory Merchant.fromJson(Map<String, dynamic> json) {
    return Merchant(
      name: json['name'] as String,
      slug: json['slug'] as String,
      qrUrl: json['qrUrl'] as String,
      logo: json['logo'] as String?,
      brandColor: json['brandColor'] as String?,
      secondaryColor: json['secondaryColor'] as String?,
      industry: json['industry'] as String,
      currencyCode: json['currencyCode'] as String,
      status: json['status'] as String,
      googleReviewLink: json['googleReviewLink'] as String?,
      programs: (json['programs'] as List<dynamic>? ?? [])
          .map((e) => LoyaltyProgram.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'slug': slug,
      'qrUrl': qrUrl,
      'logo': logo,
      'brandColor': brandColor,
      'secondaryColor': secondaryColor,
      'industry': industry,
      'currencyCode': currencyCode,
      'status': status,
      'googleReviewLink': googleReviewLink,
      'programs': programs.map((e) => e.toJson()).toList(),
    };
  }
}

/// The mode a [LoyaltyProgram] operates in.
enum ProgramMode { points, stamps, cashback, unknown }

ProgramMode programModeFromString(String? value) {
  switch (value) {
    case 'points':
      return ProgramMode.points;
    case 'stamps':
      return ProgramMode.stamps;
    case 'cashback':
      return ProgramMode.cashback;
    default:
      return ProgramMode.unknown;
  }
}

extension ProgramModeX on ProgramMode {
  String get value {
    switch (this) {
      case ProgramMode.points:
        return 'points';
      case ProgramMode.stamps:
        return 'stamps';
      case ProgramMode.cashback:
        return 'cashback';
      case ProgramMode.unknown:
        return 'unknown';
    }
  }
}

class LoyaltyProgram {
  final String id;
  final String slug;
  final String name;
  final ProgramMode mode;
  final bool isDefault;
  final ProgramConfig config;

  LoyaltyProgram({
    required this.id,
    required this.slug,
    required this.name,
    required this.mode,
    required this.isDefault,
    required this.config,
  });

  factory LoyaltyProgram.fromJson(Map<String, dynamic> json) {
    return LoyaltyProgram(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String,
      mode: programModeFromString(json['mode'] as String?),
      isDefault: json['isDefault'] as bool? ?? false,
      config: ProgramConfig.fromJson(
        json['config'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'name': name,
      'mode': mode.value,
      'isDefault': isDefault,
      'config': config.toJson(),
    };
  }
}

class ProgramConfig {
  final num pointsPerCurrencyUnit;
  final num pointsPerReward;
  final num? pointsReward;
  final num minPurchase;
  final int pointsExpiryDays;
  final int stampsPerVisit;
  final int stampsPerReward;
  final String stampReward;
  final int stampsExpiryDays;
  final num cashbackPercent;
  final num cashbackMinPurchase;
  final int cashbackExpiryDays;
  final ProgramReward? reward;

  ProgramConfig({
    required this.pointsPerCurrencyUnit,
    required this.pointsPerReward,
    this.pointsReward,
    required this.minPurchase,
    required this.pointsExpiryDays,
    required this.stampsPerVisit,
    required this.stampsPerReward,
    required this.stampReward,
    required this.stampsExpiryDays,
    required this.cashbackPercent,
    required this.cashbackMinPurchase,
    required this.cashbackExpiryDays,
    this.reward,
  });

  factory ProgramConfig.fromJson(Map<String, dynamic> json) {
    return ProgramConfig(
      pointsPerCurrencyUnit: json['pointsPerCurrencyUnit'] as num? ?? 0,
      pointsPerReward: json['pointsPerReward'] as num? ?? 0,
      pointsReward: json['pointsReward'] as num?,
      minPurchase: json['minPurchase'] as num? ?? 0,
      pointsExpiryDays: json['pointsExpiryDays'] as int? ?? 0,
      stampsPerVisit: json['stampsPerVisit'] as int? ?? 0,
      stampsPerReward: json['stampsPerReward'] as int? ?? 0,
      stampReward: json['stampReward'] as String? ?? '',
      stampsExpiryDays: json['stampsExpiryDays'] as int? ?? 0,
      cashbackPercent: json['cashbackPercent'] as num? ?? 0,
      cashbackMinPurchase: json['cashbackMinPurchase'] as num? ?? 0,
      cashbackExpiryDays: json['cashbackExpiryDays'] as int? ?? 0,
      reward: json['reward'] == null
          ? null
          : ProgramReward.fromJson(json['reward'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pointsPerCurrencyUnit': pointsPerCurrencyUnit,
      'pointsPerReward': pointsPerReward,
      'pointsReward': pointsReward,
      'minPurchase': minPurchase,
      'pointsExpiryDays': pointsExpiryDays,
      'stampsPerVisit': stampsPerVisit,
      'stampsPerReward': stampsPerReward,
      'stampReward': stampReward,
      'stampsExpiryDays': stampsExpiryDays,
      'cashbackPercent': cashbackPercent,
      'cashbackMinPurchase': cashbackMinPurchase,
      'cashbackExpiryDays': cashbackExpiryDays,
      'reward': reward?.toJson(),
    };
  }
}

class ProgramReward {
  final String id;
  final String name;
  final String type;

  ProgramReward({
    required this.id,
    required this.name,
    required this.type,
  });

  factory ProgramReward.fromJson(Map<String, dynamic> json) {
    return ProgramReward(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
    };
  }
}