
import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';
import 'package:vclub/Features/Client/Dashboard/Models/Client_History_Model.dart';




class HistoryApiClient {
  HistoryApiClient._();

  static Future<List<HistoryModel>> gethistory() async {
  final response = await ApiClient.get(ApiRoutes.client_history);

  final data = response.data;

  if (data is! List) return [];

  return data
      .map((e) => HistoryModel.fromJson(
            Map<String, dynamic>.from(e),
          ))
      .toList();
}
}