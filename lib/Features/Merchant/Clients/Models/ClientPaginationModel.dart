import 'package:vclub/Features/Merchant/Clients/Models/ClientModel.dart';

class ClientsPaginatedResponse {
  final List<ClientModel> data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const ClientsPaginatedResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory ClientsPaginatedResponse.fromJson(Map<String, dynamic> json) {
    return ClientsPaginatedResponse(
      data: (json['data'] as List? ?? [])
          .map((e) => ClientModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 15,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}