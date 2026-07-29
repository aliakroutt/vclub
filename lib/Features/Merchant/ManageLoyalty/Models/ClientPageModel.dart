import 'package:vclub/Features/Merchant/ManageLoyalty/Models/ClientModel.dart';

class ClientsPageModel {
  final List<ClientModel> data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  ClientsPageModel({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory ClientsPageModel.fromJson(Map<String, dynamic> json) {
    return ClientsPageModel(
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => ClientModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 15,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}