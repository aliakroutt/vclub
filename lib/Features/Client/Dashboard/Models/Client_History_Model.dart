class HistoryModel {
  final String id;
  final Company company;
  final String clientId;
  final String membershipId;
  final String? actorId;
  final String action;
  final String? actorRole;
  final int? amount;
  final Map<String, dynamic>? metadata;
  final String createdAt;
  final String updatedAt;

  HistoryModel({
    required this.id,
    required this.company,
    required this.clientId,
    required this.membershipId,
    this.actorId,
    required this.action,
    this.actorRole,
    this.amount,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      id: json["_id"] ?? "",
      company: Company.fromJson(json["companyId"] ?? {}),
      clientId: json["clientId"] ?? "",
      membershipId: json["membershipId"] ?? "",
      actorId: json["actorId"],
      action: json["action"] ?? "",
      actorRole: json["actorRole"],
      amount: json["amount"],
      metadata: json["metadata"],
      createdAt: json["createdAt"] ?? "",
      updatedAt: json["updatedAt"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "companyId": company.toJson(),
      "clientId": clientId,
      "membershipId": membershipId,
      "actorId": actorId,
      "action": action,
      "actorRole": actorRole,
      "amount": amount,
      "metadata": metadata,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
    };
  }
}

class Company {
  final String id;
  final String name;
  final String logo;
  final String slug;

  Company({
    required this.id,
    required this.name,
    required this.logo,
    required this.slug,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json["_id"] ?? "",
      name: json["name"] ?? "",
      logo: json["logo"] ?? "",
      slug: json["slug"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "logo": logo,
      "slug": slug,
    };
  }
}