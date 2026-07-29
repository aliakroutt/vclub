class WheelHistoryModel {
  final String id;
  final String label;
  final String type; // points | discount
  final String value;
  final String? code;
  final DateTime spunAt;
  final CompanyModel company;

  WheelHistoryModel({
    required this.id,
    required this.label,
    required this.type,
    required this.value,
    required this.spunAt,
    required this.company,
    this.code,
  });

  factory WheelHistoryModel.fromJson(Map<String, dynamic> json) {
    return WheelHistoryModel(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      type: json['type'] ?? '',
      value: json['value']?.toString() ?? '0',
      code: json['code'],
      spunAt: DateTime.parse(json['spunAt']),
      company: CompanyModel.fromJson(
        Map<String, dynamic>.from(json['company'] ?? {}),
      ),
    );
  }
}

class CompanyModel {
  final String id;
  final String name;
  final String logo;

  CompanyModel({
    required this.id,
    required this.name,
    required this.logo,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      logo: json['logo'] ?? '',
    );
  }
}