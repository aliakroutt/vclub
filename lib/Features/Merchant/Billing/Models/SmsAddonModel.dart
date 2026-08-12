class SmsAddonInfoModel {
  final String key;
  final String name;
  final int amount; // cents
  final String currency;

  SmsAddonInfoModel({
    required this.key,
    required this.name,
    required this.amount,
    required this.currency,
  });

  double get amountValue => amount / 100;

  factory SmsAddonInfoModel.fromJson(Map<String, dynamic> json) {
    return SmsAddonInfoModel(
      key: json['key']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      currency: json['currency']?.toString() ?? 'eur',
    );
  }
}

class SmsAddonToggleResult {
  final bool enabled;
  final bool changed;
  final int amountDue;
  final int amountPaid;
  final String currency;
  final bool paid;
  final String? invoiceUrl;

  SmsAddonToggleResult({
    required this.enabled,
    required this.changed,
    required this.amountDue,
    required this.amountPaid,
    required this.currency,
    required this.paid,
    this.invoiceUrl,
  });

  double get amountDueValue => amountDue / 100;
  double get amountPaidValue => amountPaid / 100;

  factory SmsAddonToggleResult.fromJson(Map<String, dynamic> json) {
    return SmsAddonToggleResult(
      enabled: json['enabled'] as bool? ?? false,
      changed: json['changed'] as bool? ?? false,
      amountDue: (json['amountDue'] as num?)?.toInt() ?? 0,
      amountPaid: (json['amountPaid'] as num?)?.toInt() ?? 0,
      currency: json['currency']?.toString() ?? 'eur',
      paid: json['paid'] as bool? ?? false,
      invoiceUrl: json['invoiceUrl']?.toString(),
    );
  }
}

/// Simple currency symbol helper used across billing widgets.
String currencySymbolFor(String currency) {
  switch (currency.toLowerCase()) {
    case 'eur':
      return '€';
    case 'usd':
      return '\$';
    case 'tnd':
      return 'DT';
    case 'gbp':
      return '£';
    default:
      return currency.toUpperCase();
  }
}

String formatMoney(double value, String currency) {
  final symbol = currencySymbolFor(currency);
  final amountStr = value.toStringAsFixed(2);
  // DT / other multi-letter codes read better after the number.
  if (symbol.length > 1) return "$amountStr $symbol";
  return "$symbol$amountStr";
}

class ReactivateSubscriptionResult {
  final bool resumed;
  final bool cancelAtPeriodEnd;

  ReactivateSubscriptionResult({
    required this.resumed,
    required this.cancelAtPeriodEnd,
  });

  factory ReactivateSubscriptionResult.fromJson(Map<String, dynamic> json) {
    return ReactivateSubscriptionResult(
      resumed: json['resumed'] as bool? ?? false,
      cancelAtPeriodEnd: json['cancelAtPeriodEnd'] as bool? ?? false,
    );
  }
}

class CancelSubscriptionResult {
  final bool canceled;
  final bool immediate;
  final bool cancelAtPeriodEnd;
  final DateTime? subscriptionEndsAt;

  CancelSubscriptionResult({
    required this.canceled,
    required this.immediate,
    required this.cancelAtPeriodEnd,
    this.subscriptionEndsAt,
  });

  factory CancelSubscriptionResult.fromJson(Map<String, dynamic> json) {
    return CancelSubscriptionResult(
      canceled: json['canceled'] as bool? ?? false,
      immediate: json['immediate'] as bool? ?? false,
      cancelAtPeriodEnd: json['cancelAtPeriodEnd'] as bool? ?? false,
      subscriptionEndsAt: json['subscriptionEndsAt'] != null
          ? DateTime.tryParse(json['subscriptionEndsAt'].toString())
          : null,
    );
  }
}