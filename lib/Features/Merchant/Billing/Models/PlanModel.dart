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
class PlanFeaturesModel {
  final String key;
  final String titleKey;
  final List<String> featureKeys;
  final bool popular;

  const PlanFeaturesModel({
    required this.key,
    required this.titleKey,
    required this.featureKeys,
    this.popular = false,
  });

  static const List<PlanFeaturesModel> all = [
    PlanFeaturesModel(
      key: "STARTER",
      titleKey: "starter",
      featureKeys: [
        "loyalty_program",
        "qr_code",
        "clients_200_max",
        "google_reviews",
        "basic_analytics",
      ],
    ),
    PlanFeaturesModel(
      key: "BUSINESS",
      titleKey: "business",
      featureKeys: [
        "unlimited_clients",
        "nfc_card",
        "lucky_wheel",
        "marketing_tools",
        "push_notifications",
        "campaigns",
      ],
      popular: true,
    ),
    PlanFeaturesModel(
      key: "PREMIUM",
      titleKey: "premium",
      featureKeys: [
        "multi_location",
        "advanced_crm",
        "white_label",
        "automation",
        "api_access",
        "multiple_employees",
      ],
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