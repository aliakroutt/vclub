class WheelHistorySpinModel {
  final String id;
  final String companyId;
  final String clientId;
  final String firstName;
  final String lastName;
  final int segmentIndex;
  final String label;
  final String type; // discount, points, cashback, gift, no_win
  final String value;
  final String? code; // only present for discount-type rewards
  final DateTime createdAt;

  WheelHistorySpinModel({
    required this.id,
    required this.companyId,
    required this.clientId,
    required this.firstName,
    required this.lastName,
    required this.segmentIndex,
    required this.label,
    required this.type,
    required this.value,
    this.code,
    required this.createdAt,
  });

  String get userName {
    final full = '$firstName $lastName'.trim();
    return full.isEmpty ? '—' : full;
  }

  factory WheelHistorySpinModel.fromJson(Map<String, dynamic> json) {
    final client = json['clientId'];
    final clientMap = client is Map<String, dynamic> ? client : <String, dynamic>{};

    return WheelHistorySpinModel(
      id: json['_id']?.toString() ?? '',
      companyId: json['companyId']?.toString() ?? '',
      clientId: clientMap['_id']?.toString() ??
          (client is String ? client : ''),
      firstName: clientMap['firstName']?.toString() ?? '',
      lastName: clientMap['lastName']?.toString() ?? '',
      segmentIndex: (json['segmentIndex'] ?? 0) as int,
      label: json['label']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
      code: json['code']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class WheelHistoryPageModel {
  final List<WheelHistorySpinModel> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  WheelHistoryPageModel({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory WheelHistoryPageModel.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>? ?? [])
        .map((e) => WheelHistorySpinModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return WheelHistoryPageModel(
      items: list,
      page: (json['page'] ?? 1) as int,
      limit: (json['limit'] ?? 20) as int,
      total: (json['total'] ?? list.length) as int,
      totalPages: (json['totalPages'] ?? 1) as int,
    );
  }
}