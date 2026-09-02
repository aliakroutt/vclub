class PlanPriceModel {
  final String key;
  final String name;
  final int amount; // cents
  final String currency;

  PlanPriceModel({
    required this.key,
    required this.name,
    required this.amount,
    required this.currency,
  });

  double get amountValue => amount / 100;

  factory PlanPriceModel.fromJson(Map<String, dynamic> json) {
    return PlanPriceModel(
      key: json['key']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      currency: json['currency']?.toString() ?? 'eur',
    );
  }
}

/// Static feature list per plan key, merged with live pricing from the API.
/// Static feature list per plan key, merged with live pricing from the API.
class PlanFeaturesModel {
  final String key;
  final String titleKey;
  final List<String> featureKeys;
  final String? inheritedKey;
  final bool popular;

  const PlanFeaturesModel({
    required this.key,
    required this.titleKey,
    required this.featureKeys,
    this.inheritedKey,
    this.popular = false,
  });

  static const List<PlanFeaturesModel> all = [
    PlanFeaturesModel(
      key: "STARTER",
      titleKey: "starter",
      featureKeys: [
        "plan_limited_loyalty_program",
        "plan_qr_code",
        "plan_clients_200_max",
        "plan_statistics",
      ],
    ),
    PlanFeaturesModel(
      key: "BUSINESS",
      titleKey: "business",
      featureKeys: [
        "plan_unlimited_loyalty_program",
        "plan_unlimited_clients",
        "plan_lucky_wheel",
        "plan_google_reviews",
      ],
      inheritedKey: "everything_in_starter",
      popular: true,
    ),
    PlanFeaturesModel(
      key: "PREMIUM",
      titleKey: "premium",
      featureKeys: [
        "plan_multi_access_employees",
        "plan_marketing_campaigns",
      ],
      inheritedKey: "everything_in_starter_business",
    ),
  ];

  static PlanFeaturesModel? of(String key) {
    try {
      return all.firstWhere((p) => p.key.toUpperCase() == key.toUpperCase());
    } catch (_) {
      return null;
    }
  }
}

/// Merged view model combining live price + static features, ready for the UI.
class PlanDisplayModel {
  final PlanPriceModel price;
  final PlanFeaturesModel features;

  PlanDisplayModel({required this.price, required this.features});
}