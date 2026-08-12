class ChangePlanResult {
  final String? url;
  final String? sessionId;
  final String plan;
  final String? previousPlan;
  final bool upgrade;
  final int amountDue;
  final String currency;
  final bool requiresPayment;
  final bool changed;

  ChangePlanResult({
    this.url,
    this.sessionId,
    required this.plan,
    this.previousPlan,
    required this.upgrade,
    required this.amountDue,
    required this.currency,
    required this.requiresPayment,
    required this.changed,
  });

  double get amountDueValue => amountDue / 100;

  factory ChangePlanResult.fromJson(Map<String, dynamic> json) {
    final url = json['url']?.toString();

    return ChangePlanResult(
      url: url,
      sessionId: json['sessionId']?.toString(),
      plan: json['plan']?.toString() ?? '',
      previousPlan: json['previousPlan']?.toString(),
      upgrade: json['upgrade'] as bool? ?? false,
      amountDue: (json['amountDue'] as num?)?.toInt() ?? 0,
      currency: json['currency']?.toString() ?? 'eur',
      // resubscribe's response has no `requiresPayment` field — if a
      // checkout `url` is present, payment is implicitly required.
      requiresPayment: json['requiresPayment'] as bool? ?? (url != null && url.isNotEmpty),
      // resubscribe's response has no `changed` field either — default to
      // true since a resubscribe call always represents a real change
      // (going from no plan to having one).
      changed: json['changed'] as bool? ?? true,
    );
  }
}