
import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';
import 'package:vclub/Features/Client/Dashboard/Models/Client_Reward_Model.dart';



class RewardsApiClient {
  RewardsApiClient._();

  static Future<List<RewardModel>> getRewards() async {
  final response = await ApiClient.get(ApiRoutes.client_rewards);

  final data = response.data;

  if (data is! List) return [];

  return data
      .map((e) => RewardModel.fromJson(
            Map<String, dynamic>.from(e),
          ))
      .toList();
}
}