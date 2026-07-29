/// Model for a single client loyalty card, as returned in the
/// client-facing "my cards" list endpoint.
class LoyaltyCard {
  final String id;
  final CardCompany company;
  final CardProgram program;
  final int points;
  final int stamps;
  final num cashbackBalance;
  final String tier;
  final int visits;
  final DateTime lastActivityAt;
  final bool cardCompleted;

  LoyaltyCard({
    required this.id,
    required this.company,
    required this.program,
    required this.points,
    required this.stamps,
    required this.cashbackBalance,
    required this.tier,
    required this.visits,
    required this.lastActivityAt,
    required this.cardCompleted,
  });

  factory LoyaltyCard.fromJson(Map<String, dynamic> json) {
    return LoyaltyCard(
      id: json['id'] as String,
      company: CardCompany.fromJson(json['company'] as Map<String, dynamic>),
      program: CardProgram.fromJson(json['program'] as Map<String, dynamic>),
      points: json['points'] as int? ?? 0,
      stamps: json['stamps'] as int? ?? 0,
      cashbackBalance: json['cashbackBalance'] as num? ?? 0,
      tier: json['tier'] as String? ?? 'standard',
      visits: json['visits'] as int? ?? 0,
      lastActivityAt: DateTime.parse(json['lastActivityAt'] as String),
      cardCompleted: json['cardCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company': company.toJson(),
      'program': program.toJson(),
      'points': points,
      'stamps': stamps,
      'cashbackBalance': cashbackBalance,
      'tier': tier,
      'visits': visits,
      'lastActivityAt': lastActivityAt.toIso8601String(),
      'cardCompleted': cardCompleted,
    };
  }

  /// Convenience helper: list of loyalty cards from a raw JSON array.
  static List<LoyaltyCard> listFromJson(List<dynamic> json) {
    return json
        .map((e) => LoyaltyCard.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

class CardCompany {
  final String id;
  final String name;
  final String status;
  final String? logo;
  final String slug;

  CardCompany({
    required this.id,
    required this.name,
    required this.status,
    this.logo,
    required this.slug,
  });

  factory CardCompany.fromJson(Map<String, dynamic> json) {
    return CardCompany(
      id: json['_id'] as String,
      name: json['name'] as String,
      status: json['status'] as String,
      logo: json['logo'] as String?,
      slug: json['slug'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'status': status,
      'logo': logo,
      'slug': slug,
    };
  }
}

/// The mode a [CardProgram] operates in.
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

/// Note: unlike the merchant-side program model, here the program's
/// tuning fields are flattened directly onto the program object rather
/// than nested under a `config` key, and limits are provided per-card.
class CardProgram {
  final String id;
  final String name;
  final String slug;
  final String status;
  final ProgramMode mode;
  final num pointsPerCurrencyUnit;
  final num pointsPerReward;
  final num minPurchase;
  final int stampsPerVisit;
  final int stampsPerReward;
  final String stampReward;
  final num cashbackPercent;
  final num cashbackMinPurchase;
  final ProgramLimits limits;

  CardProgram({
    required this.id,
    required this.name,
    required this.slug,
    required this.status,
    required this.mode,
    required this.pointsPerCurrencyUnit,
    required this.pointsPerReward,
    required this.minPurchase,
    required this.stampsPerVisit,
    required this.stampsPerReward,
    required this.stampReward,
    required this.cashbackPercent,
    required this.cashbackMinPurchase,
    required this.limits,
  });

  factory CardProgram.fromJson(Map<String, dynamic> json) {
    return CardProgram(
      id: json['_id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      status: json['status'] as String,
      mode: programModeFromString(json['mode'] as String?),
      pointsPerCurrencyUnit: json['pointsPerCurrencyUnit'] as num? ?? 0,
      pointsPerReward: json['pointsPerReward'] as num? ?? 0,
      minPurchase: json['minPurchase'] as num? ?? 0,
      stampsPerVisit: json['stampsPerVisit'] as int? ?? 0,
      stampsPerReward: json['stampsPerReward'] as int? ?? 0,
      stampReward: json['stampReward'] as String? ?? '',
      cashbackPercent: json['cashbackPercent'] as num? ?? 0,
      cashbackMinPurchase: json['cashbackMinPurchase'] as num? ?? 0,
      limits: ProgramLimits.fromJson(
        json['limits'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'slug': slug,
      'status': status,
      'mode': mode.value,
      'pointsPerCurrencyUnit': pointsPerCurrencyUnit,
      'pointsPerReward': pointsPerReward,
      'minPurchase': minPurchase,
      'stampsPerVisit': stampsPerVisit,
      'stampsPerReward': stampsPerReward,
      'stampReward': stampReward,
      'cashbackPercent': cashbackPercent,
      'cashbackMinPurchase': cashbackMinPurchase,
      'limits': limits.toJson(),
    };
  }
}

class ProgramLimits {
  final int maxPointsPerDay;
  final int maxPointsPerTx;
  final int maxRewardsPerMonth;
  final int maxStampsPerDay;

  ProgramLimits({
    required this.maxPointsPerDay,
    required this.maxPointsPerTx,
    required this.maxRewardsPerMonth,
    required this.maxStampsPerDay,
  });

  factory ProgramLimits.fromJson(Map<String, dynamic> json) {
    return ProgramLimits(
      maxPointsPerDay: json['maxPointsPerDay'] as int? ?? 0,
      maxPointsPerTx: json['maxPointsPerTx'] as int? ?? 0,
      maxRewardsPerMonth: json['maxRewardsPerMonth'] as int? ?? 0,
      maxStampsPerDay: json['maxStampsPerDay'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maxPointsPerDay': maxPointsPerDay,
      'maxPointsPerTx': maxPointsPerTx,
      'maxRewardsPerMonth': maxRewardsPerMonth,
      'maxStampsPerDay': maxStampsPerDay,
    };
  }
}