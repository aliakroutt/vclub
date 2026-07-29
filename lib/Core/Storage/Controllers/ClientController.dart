import 'package:get/get.dart';
import 'package:vclub/Core/Storage/UserStorage.dart';
import 'package:vclub/Features/Auth/Models/ClientModel.dart';

class ClientController extends GetxController {
  static ClientController get to => Get.find();

  final Rxn<ClientProfileModel> client = Rxn<ClientProfileModel>();

  bool get isLogged => client.value != null;

  Future<void> saveClient(ClientProfileModel model) async {
    client.value = model;
    await UserStorage.saveClient(model);
  }

  Future<void> loadClient() async {
    final data = await UserStorage.getClient();

    if (data != null) {
      client.value = data;
    }
  }

  Future<void> clear() async {
    client.value = null;
    await UserStorage.clear();
  }
}