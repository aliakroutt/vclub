import 'package:vclub/Features/Merchant/Clients/Models/ClientModel.dart';

class ClientDetailsResponse {
  final Map<String, dynamic> membership;
  final List<ActivityItem> history;

  const ClientDetailsResponse({required this.membership, required this.history});

  factory ClientDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ClientDetailsResponse(
      membership: (json['membership'] as Map<String, dynamic>?) ?? {},
      history: (json['history'] as List? ?? [])
          .map((e) => ActivityItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}