class RewardModel {
  final String id;
  final String companyId;
  final String name;
  final String type;
  final double cost;
  final int? stock;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RewardModel({
    required this.id,
    required this.companyId,
    required this.name,
    required this.type,
    required this.cost,
    this.stock,
    required this.active,
    this.createdAt,
    this.updatedAt,
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      id: json['_id']?.toString() ?? '',
      companyId: json['companyId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
      stock: (json['stock'] as num?)?.toInt(),
      active: json['active'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'companyId': companyId,
      'name': name,
      'type': type,
      'cost': cost,
      'stock': stock,
      'active': active,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}