class InvoiceModel {
  final String id;
  final int amount; // cents
  final String currency;
  final DateTime createdAt;
  final String? hostedInvoiceUrl;
  final String? invoicePdfUrl;
  final String plan;
  final String source;
  final String status;
  final String? stripeInvoiceId;

  InvoiceModel({
    required this.id,
    required this.amount,
    required this.currency,
    required this.createdAt,
    this.hostedInvoiceUrl,
    this.invoicePdfUrl,
    required this.plan,
    required this.source,
    required this.status,
    this.stripeInvoiceId,
  });

  double get amountValue => amount / 100;

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['_id']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      currency: json['currency']?.toString() ?? 'eur',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      hostedInvoiceUrl: json['hostedInvoiceUrl']?.toString(),
      invoicePdfUrl: json['invoicePdfUrl']?.toString(),
      plan: json['plan']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      stripeInvoiceId: json['stripeInvoiceId']?.toString(),
    );
  }
}

class InvoicesSummaryModel {
  final int succeededCount;
  final int totalPaid; // cents
  final DateTime? lastPaymentAt;
  final int lastAmount; // cents
  final String currency;

  InvoicesSummaryModel({
    required this.succeededCount,
    required this.totalPaid,
    this.lastPaymentAt,
    required this.lastAmount,
    required this.currency,
  });

  double get totalPaidValue => totalPaid / 100;
  double get lastAmountValue => lastAmount / 100;

  factory InvoicesSummaryModel.fromJson(Map<String, dynamic> json) {
    return InvoicesSummaryModel(
      succeededCount: (json['succeededCount'] as num?)?.toInt() ?? 0,
      totalPaid: (json['totalPaid'] as num?)?.toInt() ?? 0,
      lastPaymentAt: json['lastPaymentAt'] != null ? DateTime.tryParse(json['lastPaymentAt'].toString()) : null,
      lastAmount: (json['lastAmount'] as num?)?.toInt() ?? 0,
      currency: json['currency']?.toString() ?? 'eur',
    );
  }
}

class InvoicesPageResponse {
  final List<InvoiceModel> data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final InvoicesSummaryModel? summary;

  InvoicesPageResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    this.summary,
  });

  factory InvoicesPageResponse.fromJson(Map<String, dynamic> json) {
    return InvoicesPageResponse(
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => InvoiceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
      summary: json['summary'] != null
          ? InvoicesSummaryModel.fromJson(json['summary'] as Map<String, dynamic>)
          : null,
    );
  }
}